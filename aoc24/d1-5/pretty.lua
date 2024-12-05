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

function pretty.table(tbl, indent)
	indent = indent or 0
	local formatting = string.rep("  ", indent) -- Create indentation
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			print(formatting .. tostring(key) .. ":")
			pretty.table(value, indent + 1)
		else
			print(formatting .. tostring(key) .. " = " .. tostring(value))
		end
	end
end

return pretty
