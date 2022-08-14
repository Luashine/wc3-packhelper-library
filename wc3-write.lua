#!/usr/bin/env lua
-- keep this file horizontally line-aligned with w3i-write|read

assert(string.pack and string.unpack, "string.pack not available, use Lua 5.3+")

function writeChar(file, char)
    assert(file:write(char))
end

function writeRawcode(file, rawcode)
    assert(file:write(string.pack("<c4", rawcode)))
end


function writeByteU(file, ubyte)
    assert(file:write(string.pack("<I1", ubyte)))
end


function writeShortU(file, ushort)
    assert(file:write(string.pack("<I2", ushort)))
end


function writeShortS(file, sshort)
    assert(file:write(string.pack("<i2", sshort)))
end


function writeIntU(file, uint)
	assert(file:write(string.pack("<I4", uint)))
end


function writeIntS(file, sint)
    assert(file:write(string.pack("<i4", sint)))
end


function writeFloat(file, f32)
    -- "f: a float (native size)"
    -- the w3i format has a 32-bit IEEE754 float
    -- if "native" isn't a 32-bit float, will cause a problem
    assert(file:write(string.pack("<f", f32)))
end


function writeString(file, str)
    assert(file:write(str .. "\0"))
end









-- returns R, G, B, A color values separately
function writeColorRgba(file, r, g, b, a)
    assert(file:write(string.char(r, g, b, a)))
end






