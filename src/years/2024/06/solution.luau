function parse(inputText: string): { { string } }
	local matrix: { { string } } = {}

    for line in inputText:gmatch("[^\n]+") do
		local row: { string } = {}

		for i = 1, #line do
			table.insert(row, line:sub(i, i))
		end

		table.insert(matrix, row)
	end

	return matrix
end

function part1(matrix: { { string } })
	local function findGuards(): { { number } }
		local guardLocations: { { number } } = {}

		for row = 1, #matrix do
			for col = 1, #matrix[row] do
				local c = matrix[row][col]
				if c == "^" or c == ">" or c == "v" or c == "<" then
					table.insert(guardLocations, { row, col })
				end
			end
		end

		return guardLocations
	end

	local OPEN_CHAR = "."
	local OBSTACLE_CHAR = "#"

	local nextDirectionByCurrent = {
		["^"] = ">",
		[">"] = "v",
		["v"] = "<",
		["<"] = "^"
	}
	local directionsByChar = {
		["^"] = { -1, 0 },
		[">"] = { 0, 1 },
		["v"] = { 1, 0 },
		["<"] = { 0, -1 }
	}

	local visitedLocations: { { boolean } } = {}
	for row = 1, #matrix do
		visitedLocations[row] = {}
		for col = 1, #matrix[row] do
			visitedLocations[row][col] = false
		end
	end

	local visitedCounter = 0

	local function markVisited(location: { number })
		if not visitedLocations[location[1]][location[2]] then
			visitedCounter = visitedCounter + 1
		end

		visitedLocations[location[1]][location[2]] = true
	end

	-- moves the guard and returns false if the guard has left the matrix or the new location of the guard
	local function moveGuard(guardLocation: { number }): false | { number }
		for attempt = 1, 4 do
			local currentGuardChar = matrix[guardLocation[1]][guardLocation[2]]
			local direction = directionsByChar[currentGuardChar]
			print(table.concat(guardLocation, ","), currentGuardChar)
			local nextCell = { guardLocation[1] + direction[1], guardLocation[2] + direction[2] }
			if nextCell[1] < 1 or nextCell[1] > #matrix or nextCell[2] < 1 or nextCell[2] > #matrix[1] then
				-- the guard has left the matrix
				matrix[guardLocation[1]][guardLocation[2]] = OPEN_CHAR
				return false
			elseif matrix[nextCell[1]][nextCell[2]] == OBSTACLE_CHAR then
				-- the guard has hit an obstacle and must turn right
				matrix[guardLocation[1]][guardLocation[2]] = nextDirectionByCurrent[currentGuardChar]
			else
				matrix[guardLocation[1]][guardLocation[2]] = OPEN_CHAR
				matrix[nextCell[1]][nextCell[2]] = currentGuardChar
				markVisited(nextCell)
				return nextCell
			end
		end

		error("Guard is stuck")
	end

	local initialGuardLocations = findGuards()
	if #initialGuardLocations ~= 1 then
		error("There must be exactly one guard")
	end

	local initialGuardLocation = initialGuardLocations[1]
	markVisited(initialGuardLocation)

	local currentGuardLocation = initialGuardLocation
	while currentGuardLocation ~= false do
		currentGuardLocation = moveGuard(currentGuardLocation)
	end

	return visitedCounter
end

function part2(input: { { string } })
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}