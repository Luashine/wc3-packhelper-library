#!/usr/bin/env lua
-- keep this file horizontally line-aligned with w3i-write|read

assert(string.pack and string.unpack, "string.pack not available, use Lua 5.3+")

function readChar(file)
    return assert(file:read(1))
end

function readRawcode(file)
    local s = assert(file:read(4))
    return assert(string.unpack("<c4", s))
end

function readByteU(file)
    local s = assert(file:read(1))
    return assert(string.unpack("<I1", s))
end

function readShortU(file)
    local s = assert(file:read(2))
    return assert(string.unpack("<I2", s))
end

function readShortS(file)
    local s = assert(file:read(2))
    return assert(string.unpack("<i2", s))
end

function readIntU(file)
    local s = assert(file:read(4))
    return assert(string.unpack("<I4", s))
end

function readIntS(file)
    local s = assert(file:read(4))
    return assert(string.unpack("<i4", s))
end

function readFloat(file)
    local s = assert(file:read(4))
    -- "f: a float (native size)"
    -- the w3i format has a 32-bit IEEE754 float
    -- if "native" isn't a 32-bit float, will cause a problem
    return assert(string.unpack("<f", s))
end

function readString(file)
    local str = ""
    repeat
        -- slow, optimize please
        local next = file:read(1)
        if next ~= "\0" then
            str = str .. next
        end
    until next == "\0"
    return str
end

-- returns R, G, B, A color values separately
function readColorRgba(file)
    return 
        assert(file:read(1)):byte(),
        assert(file:read(1)):byte(),
        assert(file:read(1)):byte(),
        assert(file:read(1)):byte()
end
