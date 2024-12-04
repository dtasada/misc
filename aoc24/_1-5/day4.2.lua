local io = require("io")
local pretty = require("pretty")

local map = {}
local lines = {}
local file = io.open("day4.txt", "r")

local function find(position)
	local x, y = position[1], position[2]

	local left = x - 1
	local right = x + 1
	local top = y + 1
	local bottom = y - 1

	if bottom < 1 or top > #lines or left < 1 or right > #lines[1] then
		return false
	end

	-- Start at the top left corner
	local top_left_to_bottom_right = string.sub(lines[top], left, left) == "M"
		and string.sub(lines[bottom], right, right) == "S"
	local top_right_to_bottom_left = string.sub(lines[top], right, right) == "M"
		and string.sub(lines[bottom], left, left) == "S"
	local bottom_left_to_top_right = string.sub(lines[bottom], left, left) == "M"
		and string.sub(lines[top], right, right) == "S"
	local bottom_right_to_top_left = string.sub(lines[bottom], right, right) == "M"
		and string.sub(lines[top], left, left) == "S"

	return (top_left_to_bottom_right and top_right_to_bottom_left)
		or (bottom_left_to_top_right and bottom_right_to_top_left)
		or (top_left_to_bottom_right and bottom_left_to_top_right)
		or (top_right_to_bottom_left and bottom_right_to_top_left)
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
			if char == "A" then
				table.insert(map, { column, row })
			end
		end
	end

	for _, apos in ipairs(map) do
		if find(apos) then
			table.insert(found, apos)
		end
	end

	print("Found " .. #found .. " matches")

	file:close()
end

main()
