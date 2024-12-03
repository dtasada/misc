local pretty = {}

function pretty.print(table, indent)
	indent = indent or 0
	local spacing = string.rep("  ", indent)

	if type(table) ~= "table" then
		print(spacing .. tostring(table))
		return
	end

	print(spacing .. "{")
	for key, value in pairs(table) do
		local formattedKey = type(key) == "string" and string.format("%q", key) or key
		io.write(spacing .. "  [" .. formattedKey .. "] = ")
		if type(value) == "table" then
			pretty.print(value, indent + 1)
		else
			print(value)
		end
	end
	print(spacing .. "}")
end

return pretty
