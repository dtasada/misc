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

local tree = {}

local function order(update)
	for i = 1, #update do
		local num = update[i]
		local after, before = tree[num].after, tree[num].before

		for j = i + 1, #update do
			if not after[update[j]] then
				update[i], update[j] = update[j], update[i]
				return order(update)
			end
		end
		for j = i - 1, 1, -1 do
			if not before[update[j]] then
				update[i], update[j] = update[j], update[i]
				return order(update)
			end
		end
	end
end

local function main()
	local file = io.open("day5.txt", "r")

	if not file then
		return nil
	end

	local rules = {}
	local updates = {}

	local corrected_updates = {}

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

		tree[before] = tree[before] or { before = {}, after = {} }
		tree[after] = tree[after] or { before = {}, after = {} }

		table.insert(tree[before].before, after)
		table.insert(tree[after].after, before)
	end

	for _, line in pairs(updates) do
		local update_t = {}
		for num in string.gmatch(line, "%d+") do
			table.insert(update_t, tonumber(num))
		end

		local correct = true
		for i = 1, #update_t - 1 do
			correct = in_t(update_t[i], tree[update_t[i + 1]].after)
			if not correct then
				break
			end
		end

		if not correct then
			table.insert(corrected_updates, order(update_t))
		end
	end

	local total = 0
	for _, update in pairs(corrected_updates) do
		total = total + update[math.ceil(#update / 2)]
	end

	print("Total: " .. total)
	io.write("corrected_updates: ")
	pretty.print(corrected_updates)

	file:close()
end

main()
