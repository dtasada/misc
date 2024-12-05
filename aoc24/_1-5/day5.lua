local io = require("io")
local pretty = require("pretty")

local function main()
	local file = io.open("day5.txt", "r")

	if not file then
		return nil
	end

	local rules = {}
	local updates = {}

	local order = {}

	local section = 1
	for line in file:lines() do
		if line == "" then
			section = 2
		elseif section == 1 then
			table.insert(rules, line)
		elseif section == 2 then
			table.insert(updates, rules)
		end
	end

	for _, rule in pairs(rules) do
		local before, after
		for before_, after_ in string.gmatch(rule, "(%d+)%|(%d+)") do
			before = tonumber(before_)
			after = tonumber(after_)
		end

		if #order ~= 0 then
			for i, num in ipairs(order) do
				if num <= before then
					table.insert(order, i + 1, after)
					break
				end
			end
		else
			table.insert(order, before)
			table.insert(order, after)
		end
	end

	io.write("order: ")
	pretty.print(order)

	file:close()
end

main()
