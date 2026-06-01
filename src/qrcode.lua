local qrcode = {}

local VERSION = 5
local SIZE = 21 + (VERSION - 1) * 4
local DATA_CODEWORDS = 108
local ECC_CODEWORDS = 26
local MAX_BYTES = 106
local MASK_PATTERN = 0

local ALIGNMENT_POSITIONS = { 6, 30 }

local function bxor(a, b)
    local result = 0
    local place = 1

    while a > 0 or b > 0 do
        local abit = a % 2
        local bbit = b % 2

        if abit ~= bbit then
            result = result + place
        end

        a = math.floor(a / 2)
        b = math.floor(b / 2)
        place = place * 2
    end

    return result
end

local function bitAt(value, index)
    return math.floor(value / (2 ^ index)) % 2
end

local function appendBits(bits, value, count)
    for i = count - 1, 0, -1 do
        bits[#bits + 1] = bitAt(value, i) == 1
    end
end

local function bitsToCodewords(bits)
    local codewords = {}

    for i = 1, #bits, 8 do
        local value = 0
        for j = 0, 7 do
            if bits[i + j] then
                value = value + 2 ^ (7 - j)
            end
        end
        codewords[#codewords + 1] = value
    end

    return codewords
end

local function multiply(a, b)
    local result = 0

    while b > 0 do
        if b % 2 == 1 then
            result = bxor(result, a)
        end

        a = a * 2
        if a >= 0x100 then
            a = bxor(a, 0x11D)
        end

        b = math.floor(b / 2)
    end

    return result
end

local function computeDivisor(degree)
    local result = {}
    for _ = 1, degree - 1 do
        result[#result + 1] = 0
    end
    result[#result + 1] = 1

    local root = 1
    for _ = 1, degree do
        for j = 1, #result do
            result[j] = multiply(result[j], root)
            if j < #result then
                result[j] = bxor(result[j], result[j + 1])
            end
        end
        root = multiply(root, 2)
    end

    return result
end

local function computeRemainder(data, divisor)
    local result = {}
    for _ = 1, #divisor do
        result[#result + 1] = 0
    end

    for _, byte in ipairs(data) do
        local factor = bxor(byte, table.remove(result, 1))
        result[#result + 1] = 0

        for i, coefficient in ipairs(divisor) do
            result[i] = bxor(result[i], multiply(coefficient, factor))
        end
    end

    return result
end

local function makeMatrix()
    local modules = {}
    local isFunction = {}

    for y = 1, SIZE do
        modules[y] = {}
        isFunction[y] = {}
        for x = 1, SIZE do
            modules[y][x] = false
            isFunction[y][x] = false
        end
    end

    return modules, isFunction
end

local function setModule(modules, isFunction, x, y, isDark, markFunction)
    modules[y + 1][x + 1] = isDark
    if markFunction then
        isFunction[y + 1][x + 1] = true
    end
end

local function drawFinder(modules, isFunction, left, top)
    for dy = -1, 7 do
        for dx = -1, 7 do
            local x = left + dx
            local y = top + dy

            if 0 <= x and x < SIZE and 0 <= y and y < SIZE then
                local isBorder = 0 <= dx and dx <= 6 and (dy == 0 or dy == 6)
                    or 0 <= dy and dy <= 6 and (dx == 0 or dx == 6)
                local isCenter = 2 <= dx and dx <= 4 and 2 <= dy and dy <= 4
                setModule(modules, isFunction, x, y, isBorder or isCenter, true)
            end
        end
    end
end

local function drawAlignment(modules, isFunction, centerX, centerY)
    for dy = -2, 2 do
        for dx = -2, 2 do
            local isEdge = math.abs(dx) == 2 or math.abs(dy) == 2
            local isCenter = dx == 0 and dy == 0
            setModule(modules, isFunction, centerX + dx, centerY + dy, isEdge or isCenter, true)
        end
    end
end

local function drawFunctionPatterns(modules, isFunction)
    drawFinder(modules, isFunction, 0, 0)
    drawFinder(modules, isFunction, SIZE - 7, 0)
    drawFinder(modules, isFunction, 0, SIZE - 7)

    for i = 8, SIZE - 9 do
        local isDark = i % 2 == 0
        setModule(modules, isFunction, 6, i, isDark, true)
        setModule(modules, isFunction, i, 6, isDark, true)
    end

    for _, x in ipairs(ALIGNMENT_POSITIONS) do
        for _, y in ipairs(ALIGNMENT_POSITIONS) do
            local overlapsFinder = (x == 6 and y == 6)
                or (x == 6 and y == SIZE - 7)
                or (x == SIZE - 7 and y == 6)
            if not overlapsFinder then
                drawAlignment(modules, isFunction, x, y)
            end
        end
    end

    for i = 0, 7 do
        if i ~= 6 then
            setModule(modules, isFunction, 8, i, false, true)
            setModule(modules, isFunction, i, 8, false, true)
        end
        setModule(modules, isFunction, SIZE - 1 - i, 8, false, true)
        setModule(modules, isFunction, 8, SIZE - 1 - i, false, true)
    end

    setModule(modules, isFunction, 8, 7, false, true)
    setModule(modules, isFunction, 8, 8, false, true)
    setModule(modules, isFunction, 7, 8, false, true)
    setModule(modules, isFunction, 8, 4 * VERSION + 9, true, true)
end

local function encodeData(text)
    if #text > MAX_BYTES then
        return nil, "URL is too long for the QR popup."
    end

    local bits = {}
    appendBits(bits, 0x4, 4)
    appendBits(bits, #text, 8)

    for i = 1, #text do
        appendBits(bits, string.byte(text, i), 8)
    end

    local capacityBits = DATA_CODEWORDS * 8
    appendBits(bits, 0, math.min(4, capacityBits - #bits))

    while #bits % 8 ~= 0 do
        bits[#bits + 1] = false
    end

    local data = bitsToCodewords(bits)
    local padBytes = { 0xEC, 0x11 }
    local padIndex = 1

    while #data < DATA_CODEWORDS do
        data[#data + 1] = padBytes[padIndex]
        padIndex = 3 - padIndex
    end

    local divisor = computeDivisor(ECC_CODEWORDS)
    local ecc = computeRemainder(data, divisor)

    for _, byte in ipairs(ecc) do
        data[#data + 1] = byte
    end

    return data
end

local function shouldMask(x, y)
    return (x + y) % 2 == 0
end

local function drawCodewords(modules, isFunction, codewords)
    local bitIndex = 0
    local upward = true
    local right = SIZE - 1

    while right >= 1 do
        if right == 6 then
            right = right - 1
        end

        for vertical = 0, SIZE - 1 do
            local y = upward and (SIZE - 1 - vertical) or vertical

            for dx = 0, 1 do
                local x = right - dx

                if not isFunction[y + 1][x + 1] then
                    bitIndex = bitIndex + 1
                    local codeword = codewords[math.floor((bitIndex - 1) / 8) + 1] or 0
                    local isDark = bitAt(codeword, 7 - ((bitIndex - 1) % 8)) == 1

                    if shouldMask(x, y) then
                        isDark = not isDark
                    end

                    setModule(modules, isFunction, x, y, isDark, false)
                end
            end
        end

        upward = not upward
        right = right - 2
    end
end

local function formatBits()
    local data = 1 * 8 + MASK_PATTERN
    local remainder = data * 1024

    for i = 14, 10, -1 do
        if bitAt(remainder, i) == 1 then
            remainder = bxor(remainder, 0x537 * (2 ^ (i - 10)))
        end
    end

    return bxor(data * 1024 + remainder, 0x5412)
end

local function drawFormatBits(modules, isFunction)
    local bits = formatBits()

    for i = 0, 5 do
        setModule(modules, isFunction, 8, i, bitAt(bits, i) == 1, true)
    end

    setModule(modules, isFunction, 8, 7, bitAt(bits, 6) == 1, true)
    setModule(modules, isFunction, 8, 8, bitAt(bits, 7) == 1, true)
    setModule(modules, isFunction, 7, 8, bitAt(bits, 8) == 1, true)

    for i = 9, 14 do
        setModule(modules, isFunction, 14 - i, 8, bitAt(bits, i) == 1, true)
    end

    for i = 0, 7 do
        setModule(modules, isFunction, SIZE - 1 - i, 8, bitAt(bits, i) == 1, true)
    end

    for i = 8, 14 do
        setModule(modules, isFunction, 8, SIZE - 15 + i, bitAt(bits, i) == 1, true)
    end

    setModule(modules, isFunction, 8, 4 * VERSION + 9, true, true)
end

function qrcode.encode(text)
    local codewords, err = encodeData(text)
    if not codewords then
        return nil, err
    end

    local modules, isFunction = makeMatrix()
    drawFunctionPatterns(modules, isFunction)
    drawCodewords(modules, isFunction, codewords)
    drawFormatBits(modules, isFunction)

    return {
        modules = modules,
        size = SIZE
    }
end

return qrcode
