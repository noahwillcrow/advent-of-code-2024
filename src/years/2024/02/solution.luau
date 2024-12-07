function parse(inputText: string): { { number } }
	--[[
		goal: parse each line into a array of numbers
		approach: split the input text by new line, then split each line by space and convert each substring to a number
	]]
	local reports: { { number } } = {}

	local lines = inputText:split("\n")
	for _, line in lines do
		local report = {}
		local substrings = line:split(" ")
		for _, substring in substrings do
			table.insert(report, tonumber(substring))
		end

		if #report > 0 then
			table.insert(reports, report)
		end
	end

	return reports
end

function isSafe(report: { number }, tolerance: number, shouldBeVerbose: boolean?): boolean
	local function printIfVerbose(...)
		if shouldBeVerbose then
			print(...)
		end
	end

	printIfVerbose(table.concat(report, ", "))

	if #report == 1 then
		printIfVerbose("ONLY ONE ELEMENT")
		return true
	end

	local prev = report[1]
	local initialDirection = (report[2] - prev) / math.abs(report[2] - prev)
	
	local i = 2
	while i <= #report do
		local current = report[i]
		local difference = current - prev

		if difference == 0 then
			printIfVerbose("ZERO DIFFERENCE", prev, current)
			break
		end

		local magnitude = math.abs(difference)
		if magnitude > 3 then
			printIfVerbose("MAGNITUDE > 3", prev, current)
			break
		end

		local newDirection = difference / magnitude
		if newDirection ~= initialDirection then
			printIfVerbose("DIRECTION CHANGE", prev, current)
			break
		end

		prev = current
		i += 1
	end

	if i > #report then
		printIfVerbose("SAFE", prev, report[#report])
		return true
	elseif tolerance > 0 then
		printIfVerbose("RECURSING")

		local cleanedReports: { { number } } = {}
		for j = 1, #report do
			local cleanedReport: { number } = { }
			for k = 1, #report do
				if k ~= j then
					table.insert(cleanedReport, report[k])
				end
			end
			table.insert(cleanedReports, cleanedReport)
		end

		for _, cleanedReport in cleanedReports do
			if isSafe(cleanedReport, tolerance - 1, shouldBeVerbose) then
				return true
			end
		end

		return false
	else
		printIfVerbose("UNSAFE", prev, report[#report])
		return false
	end
end

function part1(input: { { number } })
	--[[
		goal: identify all "safe" reports and return the number of reports found to be safe
		definition: "safe" means that a report, which is an array of numbers, satisifies the following condition:
			- each successive number is either greater than or less than the previous number and the direction is monotonic
			- no two successive numbers are equal
			- the delta between any two successive numbers is less than or equal to 3
		approach: iterate through each report and check if it is safe; if so, increment counter; return counter
	]]

	local safeCounter = 0

	for _, report in input do
		if isSafe(report, 0) then
			safeCounter = safeCounter + 1
		end
	end

	return safeCounter
end

function part2(input: { { number } })

	local safeCounter = 0

	for i, report in input do
		print("RUNNING CHECK ON REPORT " .. i)
		if isSafe(report, 1, false) then
			safeCounter = safeCounter + 1
			print("REPORT " .. i .. ": SAFE")
		else
			print("REPORT " .. i .. ": UNSAFE")
		end
	end

	return safeCounter
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}