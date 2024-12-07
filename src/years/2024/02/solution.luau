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

	local function isSafe(report: { number }): boolean
		if #report <= 1 then
			return true
		end

		local prev = report[1]
		local initialDirection = (report[2] - prev) / math.abs(report[2] - prev)
		
		for i = 2, #report do
			local current = report[i]
			local difference = current - prev

			if difference == 0 then
				return false
			end

			local magnitude = math.abs(difference)
			if magnitude > 3 then
				return false
			end

			local newDirection = difference / magnitude
			if newDirection ~= initialDirection then
				return false
			end

			prev = current
		end

		return true
	end

	for _, report in input do
		if isSafe(report) then
			safeCounter = safeCounter + 1
		end
	end

	return safeCounter
end

function part2(input: { { number } })
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}