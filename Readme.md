# Warcraft 3 Pack Helper Library (Lua)

This is a small wrapper around string.pack() and string.unpack() in Lua to help with reading and writing binary file data of WC3 file formats.

Consider this library to be in alpha, I've made it for my own use first and foremost. The API will change.

## Code style

If there are symmetric functions in files like a `read.lua` and `write.lua` file, then keep all functions in both files horizontally aligned. For example, functions `readSome` and `writeSome` must begin on the same line number in both files.
This is required for synchronized vertical scrolling to work (Notepad++ when viewing two files side by side).


## Usage example

```lua
require("lib/wc3-read")
local file = assert(io.open("some.w3i", "rb"))

function parseW3i(file)
    assert(file)
    local w3i = {}
    w3i.w3i_version = readIntU(file)
    w3i.saves_counter = readIntU(file)
    w3i.editor_version = readIntU(file)
    
    if w3i.w3i_version >= 28 then
        w3i.wc3_version_A_v28 = readIntU(file)
        w3i.wc3_version_B_v28 = readIntU(file)
        w3i.wc3_version_C_v28 = readIntU(file)
        w3i.wc3_version_D_v28 = readIntU(file)
    end
	
	-- more code
	-- ...
	
	-- sanity check if EOF reached
	local fileCurPos = file:seek("cur")
	local fileEndPos = file:seek("end")
	if fileCurPos ~= fileEndPos then
		error("Finished parsing, but there's more data in the file! " ..
			"Expected EOF at ".. fileCurPos ..
			"Actual EOF at ".. fileEndPos)
	end

    return w3i
end

parsed_w3i = parseW3i(file)
```