local io = require("io")
local pretty = require("pretty")

local function in_t(v, t)
	for _, value in pairs(t) do
		if value == v then
			return true
		end
	end
	return false
end

local function main()
	local file = io.open("day5.txt", "r")

	if not file then
		return nil
	end

	local rules = {}
	local updates = {}

	local tree = {}
	local correct_updates = {}

	local section = 1
	for line in file:lines() do
		if line == "" then
			section = 2
		elseif section == 1 then
			table.insert(rules, line)
		elseif section == 2 then
			table.insert(updates, line)
		end
	end

	for _, rule in pairs(rules) do
		local before, after
		for before_, after_ in string.gmatch(rule, "(%d+)%|(%d+)") do
			before = tonumber(before_)
			after = tonumber(after_)
		end

		if tree[before] == nil then
			tree[before] = {}
			tree[before]["before"] = {}
			tree[before]["after"] = {}
		end
		if tree[after] == nil then
			tree[after] = {}
			tree[after]["before"] = {}
			tree[after]["after"] = {}
		end

		table.insert(tree[before]["before"], after)
		table.insert(tree[after]["after"], before)
	end

	for _, line in pairs(updates) do
		local update_t = {}
		for num in string.gmatch(line, "%d+") do
			table.insert(update_t, tonumber(num))
		end

		local correct = true
		for i = 1, #update_t - 1 do
			correct = in_t(update_t[i], tree[update_t[i + 1]]["after"])
			if not correct then
				break
			end
		end
		if correct then
			table.insert(correct_updates, update_t)
		end
	end

	local total = 0
	for _, update in pairs(correct_updates) do
		total = total + update[math.ceil(#update / 2)]
	end

	print("total:", total)

	file:close()
end

main()
