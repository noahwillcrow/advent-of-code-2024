local regex = require("@lune/regex")

function parse(inputText: string): string
	return inputText
end

function part1(input: string)
	local re = regex.new("(?:mul\\()([0-9]{1,3})(?:,)([0-9]{1,3})(?:\\))")

	local sum = 0

	local str = input
	local match = re:find(str)
	while match do
		local capture = re:captures(str)
		local num1 = tonumber(capture:get(1).text)
		local num2 = tonumber(capture:get(2).text)
		
		sum += num1 * num2

		str = str:sub(match.finish + 1)
		match = re:find(str)
	end

	return sum
end

function part2(input: string)
	local re = regex.new("mul\\(([0-9]{1,3}),([0-9]{1,3})\\)|do\\(\\)|don't\\(\\)")

	local isAddingEnabled = true

	local sum = 0

	local str = input
	local match = re:find(str)
	while match do
		if match.text == "do()" then
			isAddingEnabled = true
		elseif match.text == "don't()" then
			isAddingEnabled = false
		elseif isAddingEnabled then
			local capture = re:captures(str)
			local num1 = tonumber(capture:get(1).text)
			local num2 = tonumber(capture:get(2).text)
			
			sum += num1 * num2
		end

		str = str:sub(match.finish + 1)
		match = re:find(str)
	end

	return sum
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}