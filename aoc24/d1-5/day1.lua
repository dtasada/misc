local io = require("io")

local function main()
	local file = io.open("day1.txt", "r")

	if not file then
		return nil
	end

	local left = {}
	local right = {}

	for line in file:lines() do
		line:gsub("(%d+)   (%d+)", function(a, b)
			table.insert(left, a)
			table.insert(right, b)
		end)
	end

	table.sort(left)
	table.sort(right)

	local p1 = 0
	for i = 1, #left do
		p1 = p1 + math.abs(right[i] - left[i])
	end
	print("p1", p1)

	-- Part 2
	local p2 = 0
	for i = 1, #left do
		local count = 0
		for j = 1, #right do
			if right[j] == left[i] then
				count = count + 1
			end
		end

		p2 = p2 + count * left[i]
	end

	print("p2", p2)

	file:close()
end

main()
