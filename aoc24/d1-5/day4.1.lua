local io = require("io")
local pretty = require("pretty")

local map = {}
local lines = {}
local file = io.open("day4.txt", "r")

local function find(position, direction, search_char)
	for y = -1, 1 do
		for x = -1, 1 do
			if x ~= direction[1] or y ~= direction[2] then
				goto continue
			end

			local found_x = position[1] + x
			local found_y = position[2] + y

			if (y == 0 and x == 0) or found_y < 1 or found_x < 1 or found_y > #lines or found_x > #lines[1] then
				goto continue
			end

			if string.sub(lines[found_y], found_x, found_x) == search_char then
				return { found_x, found_y }
			end

			::continue::
		end
	end
end

local function main()
	if not file then
		return nil
	end

	local found = {}

	-- get map of characters
	local row = 0
	for line in file:lines() do
		table.insert(lines, line)
		row = row + 1
		for column = 1, #line do
			local char = line:sub(column, column)
			if char == "X" then
				table.insert(map, { column, row })
			end
		end
	end

	for _, xpos in ipairs(map) do
		for dy = -1, 1 do
			for dx = -1, 1 do
				if dx == 0 and dy == 0 then
					goto continue
				end

				local mpos = find(xpos, { dx, dy }, "M")
				if mpos ~= nil then
					local direction = { mpos[1] - xpos[1], mpos[2] - xpos[2] }
					local apos = find(mpos, direction, "A")
					if apos ~= nil then
						local spos = find(apos, direction, "S")
						if spos ~= nil then
							table.insert(found, xpos)
						end
					end
				end

				::continue::
			end
		end
	end

	print("Found " .. #found .. " matches")

	file:close()
end

main()
