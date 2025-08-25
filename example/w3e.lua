#!/usr/bin/env lua
-- start: 16:30
-- first save: 17:00 - 3.6 SLOC/min
-- 18:30 - testing and verification complete - 1.05 SLOC/min :)
package.path = package.path .. ";./../?.lua"
require("wc3-read")

function bool2str(b)
	return b and "y" or "n"
end

filePath = assert(arg[1], "expected argument 1: path to .w3e file!")
file = assert(io.open(filePath, "rb"))

local magic = file:read(4)
assert(magic == "W3E!", magic)
print("magic:", magic)

local version = readIntU(file)
assert(version == 11 or version == 12, "unknown file format version: ".. tostring(version))

local baseTerrainType = readChar(file)
print("baseTerrainType", baseTerrainType)

local usesNonStandardTerrain = readIntU(file)
print("usesNonStandardTerrain", usesNonStandardTerrain)

local usedTilesetCount = readIntU(file)
print("usedTilesetCount", usedTilesetCount)
for i = 1, usedTilesetCount do
	local usedTilesetRawcode = readRawcode(file)
	print("used tile set: ", usedTilesetRawcode)
end

local usedCliffCount = readIntU(file)
print("usedCliffCount", usedCliffCount)
for i = 1, usedCliffCount do
	local usedCliffRawcode = readRawcode(file)
	print("used tile set: ", usedCliffRawcode)
end

local mapWidth = readIntU(file)
local mapHeight = readIntU(file)
print("map size:", mapWidth, "x", mapHeight)

local offsetLeft = readFloat(file)
local offsetDown = readFloat(file)
print("map offset:", offsetLeft, offsetDown)

for y = mapHeight, 1, -1 do
	for x = 1, mapWidth do
		local groundHeight = readShortU(file)
		print(string.format("%3dx%-3d: groundHeight %d (%02x)", x,y, groundHeight, groundHeight))
		
		local waterHeightAndEdgeFlag = readShortU(file)
		local waterHeight = waterHeightAndEdgeFlag & 0x3fff
		local edgeFlag = waterHeightAndEdgeFlag & 0x4000
		local isEdge = edgeFlag ~= 0 and true or false
		print(string.format("%3dx%-3d: waterHeightAndEdgeFlag %d (%02x)", x,y, waterHeightAndEdgeFlag, waterHeightAndEdgeFlag))
		print(string.format("%3dx%-3d: waterHeight=%d", x,y, waterHeight))
		print(string.format("%3dx%-3d: isEdge=%s", x,y, bool2str(isEdge)))
		assert(waterHeightAndEdgeFlag - waterHeight - edgeFlag == 0, "waterHeightAndEdgeFlag doesn't add up")
		
		local textureAndFlag
		local texture
		local flags
		if version == 11 then
			textureAndFlag = readByteU(file)
			texture    = textureAndFlag & 0x0f
			flags    = textureAndFlag & 0xf0
			print(string.format("%3dx%-3d: textureAndFlag %d (%02x)", x,y, textureAndFlag, textureAndFlag))
		elseif version >= 12 then
			textureAndFlag = readShortU(file)
			texture = textureAndFlag & 0x3f
			flags = textureAndFlag & 0xffc0
			print(string.format("%3dx%-3d: textureAndFlag %d (%02x)", x,y, textureAndFlag, textureAndFlag))
		end
		print(string.format("%3dx%-3d: texture %d", x,y, texture))
		print(string.format("%3dx%-3d: flags %d", x,y, flags))
		
		local cliffFlag  = flags & (version <= 11 and 0x10 or (0x10 << 2))
		local blightFlag = flags & (version <= 11 and 0x20 or (0x20 << 2))
		local waterFlag  = flags & (version <= 11 and 0x40 or (0x40 << 2))
		local borderFlag = flags & (version <= 11 and 0x80 or (0x80 << 2))
		
		local isCliff  = cliffFlag  ~= 0 and true or false
		local isBlight = blightFlag ~= 0 and true or false
		local isWater  = waterFlag  ~= 0 and true or false
		local isBorder = borderFlag ~= 0 and true or false
		print(string.format("%3dx%-3d: cliff:%s, blight:%s, water:%s, border:%s",
			x,y, bool2str(isCliff), bool2str(isBlight), bool2str(isWater), bool2str(isBorder)))
		if version == 11 then
			assert(textureAndFlag == texture+cliffFlag+blightFlag+waterFlag+borderFlag, "textureAndFlag doesn't add up!")
		elseif version >= 12 then
			assert(flags == cliffFlag+blightFlag+waterFlag+borderFlag, "v12 flag doesn't add up!")
		else
			error()
		end
		
		local groundAndCliffVariation = readByteU(file)
		local groundVariation = groundAndCliffVariation & 0x1f
		local cliffVarRaw = groundAndCliffVariation & 0xe0
		local cliffVariation = cliffVarRaw >> 5
		print(string.format("%3dx%-3d: groundAndCliffVariation %d (%02x)", x,y, groundAndCliffVariation, groundAndCliffVariation))
		print(string.format("%3dx%-3d: groundVar %d, cliffVar %d", x,y, groundVariation, cliffVariation))
		assert(groundAndCliffVariation == groundVariation + cliffVarRaw, "groundAndCliffVariation doesn't add up!")
		
		local layerHeightAndCliffTexture = readByteU(file)
		local layerHeight = layerHeightAndCliffTexture & 0x0f
		local cliffTextureRaw = layerHeightAndCliffTexture & 0xf0
		local cliffTexture = cliffTextureRaw >> 4
		print(string.format("%3dx%-3d: layerHeightAndCliffTexture %d (%02x)", x,y, layerHeightAndCliffTexture, layerHeightAndCliffTexture))
		print(string.format("%3dx%-3d: layerHeight=%d, cliffTexture %d", x,y, layerHeight, cliffTexture))
		assert(layerHeightAndCliffTexture == layerHeight + cliffTextureRaw, "layerHeightAndCliffTexture doesn't add up (how is this possible?)")
		
		print("----")
	end
end

-- sanity check if EOF reached
local fileCurPos = file:seek("cur")
local fileEndPos = file:seek("end")
if fileCurPos ~= fileEndPos then
	error("Finished parsing, but there's more data in the file! " ..
		"Expected EOF at ".. fileCurPos ..
		"Actual EOF at ".. fileEndPos)
end
