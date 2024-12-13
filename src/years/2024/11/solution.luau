local printIfVerbose = require("../../../../packages/print-if-verbose/index.luau")

type Input = { number }
function parse(inputText: string): Input
	-- input is a single line of integers separated by spaces
	-- goal is to return an array of integers

	local numbers = {}
	for number in inputText:gmatch("%d+") do
		table.insert(numbers, tonumber(number))
	end
	return numbers
end

-- memo[startNum][numIterations] = number of pebbles after numIterations iterations starting with startNum
local memo: { [number]: { [number]: number } } = {}
function countResultingPebblesFromOnePebble(startNum: number, numIterations: number)
	if numIterations == 0 then
		return 1
	end

	if memo[startNum] and memo[startNum][numIterations] then
		return memo[startNum][numIterations]
	end

	local resultingPebbles = 0
	if startNum == 0 then
		resultingPebbles = countResultingPebblesFromOnePebble(1, numIterations - 1)
	else
		local startNumStr = tostring(startNum)
		local startNumStrLen = #startNumStr
		if startNumStrLen % 2 == 0 then
			resultingPebbles =
				countResultingPebblesFromOnePebble(tonumber(startNumStr:sub(1, startNumStrLen / 2)), numIterations - 1)
				+ countResultingPebblesFromOnePebble(tonumber(startNumStr:sub(startNumStrLen / 2 + 1)), numIterations - 1)
		else
			resultingPebbles = countResultingPebblesFromOnePebble(startNum * 2024, numIterations - 1)
		end
	end

	if not memo[startNum] then
		memo[startNum] = {}
	end
	memo[startNum][numIterations] = resultingPebbles

	--printIfVerbose(function() return { startNum, numIterations, resultingPebbles } end)
	return resultingPebbles
end

function countResultingPebbles(initialState: { number }, numberOfIterations: number)
	-- even running with just a single number in the initial state causes the program to run out of memory given only 75 iterations
	-- this has become a DP problem because I want to split the numbers at each step
	-- I should probably just cache as well
	-- yay for memoization

	local sum = 0

	for i = 1, #initialState do
		local resultForValue = countResultingPebblesFromOnePebble(initialState[i], numberOfIterations)
		printIfVerbose(function() return { initialState[i], numberOfIterations, resultForValue } end)
		sum = sum + resultForValue
	end

	return sum
end

function part1(input: Input)
	printIfVerbose(function() return { input } end)

	local NUM_ITERATIONS = 25
	return countResultingPebbles(input, 25)
end

function part2(input: Input)
	-- part 2 is just part 1 but 3x more iterations
	-- this leads to overflowing memory in the current, naive implementation
	-- I want to split the initial input into M groups of numbers, where M is the number of individual numbers in the input
	-- then just sum the results of M calls to runPebbleSplitting

	printIfVerbose(function() return { input } end)

	local NUM_ITERATIONS = 75
	return countResultingPebbles(input, NUM_ITERATIONS)
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}