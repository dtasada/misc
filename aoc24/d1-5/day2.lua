local pretty = require("pretty")

local function is_safe(report)
	local safe = true
	local rising = nil

	for i = 1, #report - 1 do
		local diff = report[i + 1] - report[i]
		local new_rising = nil

		if diff > 0 then
			new_rising = true
		elseif diff < 0 then
			new_rising = false
		end

		if rising == nil then
			rising = new_rising
		elseif rising ~= new_rising then
			safe = false
		end

		if rising then
			if diff > 3 or diff < 1 then
				safe = false
			end
		else
			if diff < -3 or diff > -1 then
				safe = false
			end
		end

		if not safe then
			break
		end
	end

	return safe
end

local function main()
	local file = io.open("day2.txt", "r")

	if not file then
		return nil
	end

	local reports = {}
	local safe_reports = {}

	for line in file:lines() do
		local numbers = {}
		for num in line:gmatch("%S+") do
			table.insert(numbers, num)
		end
		table.insert(reports, numbers)
	end

	for _, report in pairs(reports) do
		if is_safe(report) then
			table.insert(safe_reports, report)
		else
			for i = 1, #report do
				local report_copy = {}
				for j = 1, #report do
					table.insert(report_copy, report[j])
				end

				table.remove(report_copy, i)

				if is_safe(report_copy) then
					table.insert(safe_reports, report_copy)
					break
				end
			end
		end
	end

	print("#safe_reports", #safe_reports)

	file:close()
end

main()
