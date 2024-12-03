local io = require("io")
local pretty = require("pretty")

local function main()
	local file = io.open("day3.txt", "r")

	if not file then
		return nil
	end

	local mults = 0
	local enabled = true

	local mdo = "do%(%)"
	local mdont = "don't%(%)"
	local mmul = "mul%(%d+,%d+%)"
	local many = "([%a']+%(%d-,-%d-%))"

	for line in file:lines() do
		for match in string.gmatch(line, many) do
			if string.match(match, mdo) then
				enabled = true
			elseif string.match(match, mdont) then
				enabled = false
			else
				for a, b in string.gmatch(match, "mul%((%d+),(%d+)%)") do
					if enabled then
						mults = mults + tonumber(a) * tonumber(b)
					end
				end
			end
		end
	end

	pretty.print(mults)

	file:close()
end

main()
