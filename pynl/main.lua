#!/usr/bin/env lua

local nl_to_en = {
	["^importeer (.*.) als (%w+)$"] = "import %1 as %2",
	["(%s+)importeer (.*.) als (%w+)$"] = "%1import %2 as %3",
	["(%s+)anders:"] = "%1else:%2",
	["(%s+)en(%s+)"] = "%1and%2",
	["(%s+)importeer(%s+)"] = "%1import%2",
	["(%s+)in(%s+)"] = "%1in%2",
	["(%s+)is(%s+)"] = "%1is%2",
	["(%s+)lambda(%s+)"] = "%1lambda%2",
	["(%s+)niet(%s+)"] = "%1not%2",
	["(%s+)of(%s+)"] = "%1or%2",
	["(%s+)verwacht(%s+)"] = "%1await%2",
	["(%s+)voor(%s+)"] = "%1for%2",
	["([%s*,])Geen"] = "%1None",
	["([%s*,])Onwaar"] = "%1False",
	["([%s*,])Waar"] = "%1True",
	["^(%s*)als(%s+)"] = "%1if%2",
	["^(%s*)andersals(%s+)"] = "%1elif%2",
	["^(%s*)async(%s+)"] = "%1async%2",
	["^(%s*)beweer(%s+)"] = "%1assert%2",
	["^(%s*)def(%s+)"] = "%1def%2",
	["^(%s*)doorgaan(%s+)"] = "%1continue%2",
	["^(%s*)geval(%s+)"] = "%1case%2",
	["^(%s*)globaal(%s+)"] = "%1global%2",
	["^(%s*)klasse(%s+)"] = "%1class%2",
	["^(%s*)lever (.*.) op"] = "%1yield %2",
	["^(%s*)lever(%s+)"] = "%1raise%2",
	["^(%s*)met (%w+) als (%w+):"] = "%1with %2 as %3",
	["^(%s*)nietlokaal(%s+)"] = "%1nonlocal%2",
	["^(%s*)overeenkomst(%s+)"] = "%1match%2",
	["^(%s*)pass(%s+)"] = "%1pas%2",
	["^(%s*)probeer([%s+:])"] = "%1try%2",
	["^(%s*)retourneer(%s+)"] = "%1return%2",
	["^(%s*)tenslotte(%s+)"] = "%1finally%2",
	["^(%s*)terwijl(%s+)"] = "%1while%2",
	["^(%s*)uitgezonderd(%s+)"] = "%1except%2",
	["^(%s*)uitgezonderd (%w+) als"] = "%1except %2 as",
	["^(%s*)van(%s+)"] = "%1from%2",
	["^(%s*)verbreek(%s+)"] = "%1break",
	["^(%s*)wis(%s+)"] = "%1del%2",
	["^importeer(%s+)"] = "import%1",
}

local en_to_nl = {
	["(%s*)await(%s+)"] = "%1verwacht%2",
	["(%s+)and(%s+)"] = "%1en%2",
	["(%s+)del(%s+)"] = "%1wis%2",
	["(%s+)import (.*.) as (%w+)"] = "importeer %1 als %2",
	["(%s+)import(%s+)"] = "%1importeer%2",
	["(%s+)in(%s+)"] = "%1in%2",
	["(%s+)is(%s+)"] = "%1is%2",
	["(%s+)lambda(%s+)"] = "%1lambda%2",
	["(%s+)not(%s+)"] = "%1niet%2",
	["(%s+)or(%s+)"] = "%1of%2",
	["([%s*,])False"] = "%1Onwaar",
	["([%s*,])None"] = "%1Geen",
	["([%s*,])True"] = "%1Waar",
	["^(%s*)assert(%s+)"] = "%1beweer%2",
	["^(%s*)async(%s+)"] = "%1async%2",
	["^(%s*)break(%s+)"] = "%1verbreek%2",
	["^(%s*)case(%s+)"] = "%1geval%2",
	["^(%s*)class(%s+)"] = "%1klasse%2",
	["^(%s*)continue(%s+)"] = "%1doorgaan%2",
	["^(%s*)def(%s+)"] = "%1def%2",
	["^(%s*)elif(%s+)"] = "%1andersals%2",
	["^(%s*)else(%s+:)"] = "%1anders%2",
	["^(%s*)except(%s+)"] = "%1uitgezonderd%2",
	["^(%s*)except (%w+) as"] = "%1uitgezonderd %2 als",
	["^(%s*)finally(%s+)"] = "%1tenslotte%2",
	["^(%s*)for(%s+)"] = "%1voor%2",
	["^(%s*)from(%s+)"] = "%1van%2",
	["^(%s*)global(%s+)"] = "%1globaal%2",
	["^(%s*)if(%s+)"] = "%1als%2",
	["^(%s*)match(%s+)"] = "%1overeenkomst%2",
	["^(%s*)nonlocal(%s+)"] = "%1nietlokaal%2",
	["^(%s*)pas(%s+)"] = "%1pass%2",
	["^(%s*)raise(%s+)"] = "%1lever%2",
	["^(%s*)return(%s+)"] = "%1retourneer%2",
	["^(%s*)try([:%s+])"] = "%1probeer%2",
	["^(%s*)while(%s+)"] = "%1terwijl%2",
	["^(%s*)with (%w+) as (%w+)"] = "%1met %2 als :%3",
	["^(%s*)yield(%s+)(.*.)"] = "%1lever%2op%3",
	["^import (.*.) as (%w+)"] = "%1importeer %2 als %3",
	["^import(%s+)"] = "importeer%1",
}

Colors = {
	Green = "\27[38;5;82m",
	Red = "\27[38;5;196m",
	Yellow = "\27[38;5;214m",
	Reset = "\27[0m",
}

local function compile(input)
	local lines = {}
	for old_line in input:gmatch("[^\r\n]*") do
		local new_line = old_line
		for nl, en in pairs(nl_to_en) do
			new_line = new_line:gsub(nl, en)
		end
		table.insert(lines, new_line)
	end

	return table.concat(lines, "\n")
end

local function reverse(input)
	local lines = {}
	for old_line in input:gmatch("[^\r\n]*") do
		local new_line = old_line
		for en, nl in pairs(en_to_nl) do
			new_line = new_line:gsub(en, nl)
		end
		table.insert(lines, new_line)
	end

	return table.concat(lines, "\n")
end

local function is_dir(file_name)
	local command = "cd '" .. file_name .. "'"
	if package.config:sub(1, 1) == "\\" then -- if OS is windows
		command = command .. " > nul 2>&1"
	else
		command = command .. " > /dev/null 2>&1"
	end

	if os.execute(command) then -- If target_loc is a directory
		return true
	else
		return false
	end
end

local function set_args()
	local help_message = [[Usage:
    pynl <file1> <file2>...		--	Compiles (or reverses) given files
    pynl run <file1> 			--	Compile and run file1 and don't save output
    pynl (--output  | -o) <output>	--	Specify output file/folder
    pynl (--verbose | -v)		--	Prints file output
    pynl (--reverse | -r)		--	Decompiles, from English to Dutch
    pynl (--help    | -h)		--	Show this dialogue]]
	local args = {
		should_reverse = false,
		should_verbose = false,
		should_run = arg[1] == "run",
		source_files = {},
		source_dirs = {},
		target_loc = nil,
	}

	for i, value in ipairs(arg) do
		if value == "-r" or value == "--reverse" then
			args.should_reverse = true
		elseif value == "-v" or value == "--verbose" then
			args.should_verbose = true
		elseif value == "-h" or value == "--help" then
			print(help_message)
		elseif value == "-o" or value == "--output" then
			args.target_loc = arg[i + 1]
		else
			if is_dir(value) then
				table.insert(args.source_dirs, value)
			else
				table.insert(args.source_files, value)
			end
		end
	end

	if #arg == 0 then
		print("Error: please provide arguments")
		print(help_message)
		os.exit(1)
	elseif #arg == 1 and args.should_run then
		print(Colors.Red .. "Error: need file name" .. Colors.Reset)
		os.exit(1)
	end

	if args.should_run and args.should_reverse then
		print(Colors.Red .. "Error: `--reverse` and `--run` are mutually exclusive" .. Colors.Reset)
		os.exit(1)
	end

	-- add source_dirs to source_files
	for _, dir in ipairs(args.source_dirs) do
		for _, file in require("lfs").dir(dir) do
			args.source_files:insert(dir .. "/" .. file)
		end
	end

	return args
end

local function main()
	local input = {
		handle = nil,
		name = nil,
		content = nil,
	}

	local args = set_args()

	for _, input_name in pairs(args.source_files) do
		input.name = input_name

		input.handle = io.open(input.name, "r")
		assert(input.handle, Colors.Red .. "Error: " .. input.name .. " does not exist!" .. Colors.Reset)
		input.content = input.handle:read("*all")
		input.handle:close()

		local output = {
			handle = nil,
			name = nil,
			content = nil,
		}

		if args.target_loc then
			if is_dir(args.target_loc) then
				output.name = input.name:gsub("(.*.)\\.$", args.target_loc .. "/%1")
			else
				output.name = args.target_loc
			end
		else
			output.name = input.name:gsub("(.*.)\\.$", "%1")
		end

		if not args.should_reverse then
			print("Compiling: " .. input.name .. "...")
			if not args.target_loc then
				output.name = output.name .. "_pynl-compiled.py"
			end
			output.content = compile(input.content)
		else
			print("Reversing: " .. input.name .. "...")
			if not args.target_loc then
				output.name = output.name .. "_pynl-reversed.pynl"
			end
			output.content = reverse(input.content)

			if output.content == input.content then
				print(Colors.Yellow .. "Warning: did you pass a python file to the pynl compiler?" .. Colors.Reset)
			end
		end

		output.handle = io.open(output.name, "w") -- Maybe todo: check for file already exists
		assert(output.handle, Colors.Red .. "Error: failed to create " .. output.name .. Colors.Reset)
		output.handle:write(output.content)

		if args.should_verbose then
			print(output.content)
		end

		if not args.should_reverse then
			local cmd_handle
			if args.should_run then
				cmd_handle = assert(io.popen("python3 -m py_compile " .. output.name, "r"))
			else
				cmd_handle = assert(io.popen("python3 " .. output.name, "r"))
			end

			print(assert(cmd_handle:read("a")))
			local code = cmd_handle:close()
			if code == nil then
				print(Colors.Red .. "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" .. Colors.Reset)
				print(Colors.Red .. "Error: python3 finished with an error" .. Colors.Reset)
			else
				print(Colors.Green .. "PyNL compiled successfully!" .. Colors.Reset)
			end

			if args.should_run then
				os.remove(output.name)
			end
		else
			print("Reversed " .. input_name .. " successfully")
		end
		output.handle:close()
	end
end

main()
