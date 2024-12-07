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

local function copyMatrix(matrix: { { number } }): { { number } }
	local newMatrix: { { number } } = {}

	for row = 1, #matrix do
		newMatrix[row] = {}
		for col = 1, #matrix[row] do
			newMatrix[row][col] = matrix[row][col]
		end
	end

	return newMatrix
end

local function findGuards(matrix: { { number } }): { { number } }
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

local previousDirectionByCurrent = {
	["^"] = "<",
	["<"] = "v",
	["v"] = ">",
	[">"] = "^"
}
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

-- moves the guard and returns false if the guard has left the matrix or the new location of the guard; also returns a string if the guard is stuck
local function moveGuard(guardLocation: { number }, matrix: { { number } }): false | { number } | string
	for attempt = 1, 4 do
		local currentGuardChar = matrix[guardLocation[1]][guardLocation[2]]
		local direction = directionsByChar[currentGuardChar]
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
			return nextCell
		end
	end

	return "Guard is stuck"
end

local function buildVisitedMatrix(matrix: { { number } }): { { boolean } }
	local visitedMatrix: { { boolean } } = {}

	for row = 1, #matrix do
		visitedMatrix[row] = {}
		for col = 1, #matrix[row] do
			visitedMatrix[row][col] = false
		end
	end

	return visitedMatrix
end

-- marks a location as visited and returns true if the location was not visited before
local function markVisited(visitedMatrix: { { boolean } }, location: { number }): booelean
	local wasAlreadyVisited = visitedMatrix[location[1]][location[2]]
	visitedMatrix[location[1]][location[2]] = true
	return not wasAlreadyVisited
end

function part1(input: { { string } })
	local matrix = copyMatrix(input)

	local initialGuardLocations = findGuards(matrix)
	if #initialGuardLocations ~= 1 then
		error("There must be exactly one guard")
	end

	local visitedCounter = 0
	local visitedLocations = buildVisitedMatrix(matrix)

	local currentGuardLocation = initialGuardLocations[1]
	while currentGuardLocation ~= false do
		if markVisited(visitedLocations, currentGuardLocation) then
			visitedCounter = visitedCounter + 1
		end

		currentGuardLocation = moveGuard(currentGuardLocation, matrix)
	end

	return visitedCounter
end

function part2(input: { { string } })
	--[[
		Objective: Find all possible locations that an obstacle can be placed in order to force the guard into a loop
		Idea:
			I can guarantee a brute forced approach by placing an obstacle in every cell that the guard visits in a normal run
			Then, I can run a simulation to see if the guard ever gets stuck
		Notes:
			This is about as brute force as it gets, but slightly better than just trying every single cell
	]]
	local matrix = copyMatrix(input)

	local initialGuardLocations = findGuards(matrix)
	if #initialGuardLocations ~= 1 then
		error("There must be exactly one guard")
	end

	local visitedLocations = buildVisitedMatrix(matrix)

	do 
		local currentGuardLocation = initialGuardLocations[1]
		while currentGuardLocation ~= false do
			markVisited(visitedLocations, currentGuardLocation)
			currentGuardLocation = moveGuard(currentGuardLocation, matrix)
		end
	end

	local counter = 0

	for row = 1, #matrix do
		for col = 1, #matrix[row] do
			if visitedLocations[row][col] and not (row == initialGuardLocations[1][1] and col == initialGuardLocations[1][2]) then
				local visitedLocationsByDirection: { [string]: { { boolean } } } = {
					["^"] = buildVisitedMatrix(matrix),
					[">"] = buildVisitedMatrix(matrix),
					["v"] = buildVisitedMatrix(matrix),
					["<"] = buildVisitedMatrix(matrix)
				}

				local matrixCopy = copyMatrix(input)
				matrixCopy[row][col] = OBSTACLE_CHAR

				local currentGuardLocation = initialGuardLocations[1]
				while currentGuardLocation ~= false and currentGuardLocation ~= "Guard is stuck" do
					local currentGuardChar = matrixCopy[currentGuardLocation[1]][currentGuardLocation[2]]
					if visitedLocationsByDirection[currentGuardChar][currentGuardLocation[1]][currentGuardLocation[2]] then
						counter = counter + 1
						break
					end

					visitedLocationsByDirection[currentGuardChar][currentGuardLocation[1]][currentGuardLocation[2]] = true

					currentGuardLocation = moveGuard(currentGuardLocation, matrixCopy)

					if currentGuardLocation == "Guard is stuck" then
						counter = counter + 1
						break
					end
				end
			end
		end
	end

	return counter
end

function part2_dead_try(input: { { string } }) -- this underestimates
	--[[
		Objective: Find all possible locations that an obstacle can be placed in order to force the guard into a loop
		Idea:
			I can keep track of every cell that is ever directly behind the guard as they move in a given direction.
			Using this, I can then track to see if they ever step on one of those cells while facing exactly left of that initial direction.
			If they do, I can slap an obstacle in front of them on their leftward trajectory and force a loop.
		Approach:
			- Create 4 matrices, one for each direction, to keep track of the cells that are directly behind the guard
			- On each step of the guard's movement, check if the new cell was marked in the matrix for the guard's direction if they were to turn right
			- If it was, check if in front of them is in-bounds
			- If it is, save that cell as a possible obstacle location and continue
	]]
	local matrix = copyMatrix(input)
	
	local behindGuardByDirection: { [string]: { { boolean } } } = {
		["^"] = {},
		[">"] = {},
		["v"] = {},
		["<"] = {}
	}
	for direction, m in pairs(behindGuardByDirection) do
		for row = 1, #matrix do
			m[row] = {}
			for col = 1, #matrix[row] do
				m[row][col] = false
			end
		end
	end

	local function markBehindGuard(guardLocation: { number })
		local currentGuardChar = matrix[guardLocation[1]][guardLocation[2]]

		local behindGuardMatrix = behindGuardByDirection[currentGuardChar]
		local facingDirection = directionsByChar[currentGuardChar]

		local behindLocation = { guardLocation[1] - facingDirection[1], guardLocation[2] - facingDirection[2] }
		while 
			behindLocation[1] >= 1 and behindLocation[1] <= #matrix and behindLocation[2] >= 1 and behindLocation[2] <= #matrix[1]
			and matrix[behindLocation[1]][behindLocation[2]] ~= OBSTACLE_CHAR
		do
			behindGuardMatrix[behindLocation[1]][behindLocation[2]] = true
			behindLocation[1] = behindLocation[1] - facingDirection[1]
			behindLocation[2] = behindLocation[2] - facingDirection[2]
		end
	end

	local initialGuardLocations = findGuards(matrix)
	if #initialGuardLocations ~= 1 then
		error("There must be exactly one guard")
	end

	local identifiedPossibleObstacleLocations: { { boolean } } = {}
	for row = 1, #matrix do
		identifiedPossibleObstacleLocations[row] = {}
		for col = 1, #matrix[row] do
			identifiedPossibleObstacleLocations[row][col] = false
		end
	end

	local function markPossibleObstacleLocationIfDiscovered(guardLocation: { number })
		local currentGuardChar = matrix[guardLocation[1]][guardLocation[2]]
		local rightFacingChar = nextDirectionByCurrent[currentGuardChar]
		local wasBehindWhenFacingRightMatrix = behindGuardByDirection[rightFacingChar]

		if wasBehindWhenFacingRightMatrix[guardLocation[1]][guardLocation[2]] then
			local currentDirection = directionsByChar[currentGuardChar]
			local nextCellInCurrentDirection = { guardLocation[1] + currentDirection[1], guardLocation[2] + currentDirection[2] }
			if 
				nextCellInCurrentDirection[1] >= 1 and nextCellInCurrentDirection[1] <= #matrix and nextCellInCurrentDirection[2] >= 1 and nextCellInCurrentDirection[2] <= #matrix[1]
				and not (nextCellInCurrentDirection[1] == initialGuardLocations[1][1] and nextCellInCurrentDirection[2] == initialGuardLocations[1][2])
			then
				--print(table.concat(guardLocation, ","), currentGuardChar, table.concat(nextCellInCurrentDirection, ","))
				identifiedPossibleObstacleLocations[nextCellInCurrentDirection[1]][nextCellInCurrentDirection[2]] = true
			end
		end

		return false
	end

	local currentGuardLocation = initialGuardLocations[1]
	while currentGuardLocation ~= false do
		markBehindGuard(currentGuardLocation)
		markPossibleObstacleLocationIfDiscovered(currentGuardLocation)
		currentGuardLocation = moveGuard(currentGuardLocation, matrix)
	end

	local counter = 0
	for row = 1, #matrix do
		for col = 1, #matrix[row] do
			if identifiedPossibleObstacleLocations[row][col] then
				counter = counter + 1
			end
		end
	end
	return counter
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}