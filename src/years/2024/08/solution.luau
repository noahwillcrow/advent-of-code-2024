local stack = require("../../../../packages/stack/index.luau")
local v2 = require("../../../../packages/vector2/index.luau")

type Dict<K, V> = { [K]: V }
type Input = { mapSize: v2.Vector2, antennasByFrequency: Dict<string, { v2.Vector2 }> }

local ANTENNA_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
function isAntennaChar(char: string): boolean
	return string.find(ANTENNA_CHARS, char, 1, true) ~= nil
end

function parse(inputText: string): Input
	local antennasByFrequency: Dict<string, { v2.Vector2 }> = {}

	function recordPosition(antennaFrequency: string, position: v2.Vector2)
		if not antennasByFrequency[antennaFrequency] then
			antennasByFrequency[antennaFrequency] = {}
		end

		table.insert(antennasByFrequency[antennaFrequency], position)
	end

	local numRows = 0
	local numCols = 0

	local row = 0
    for line in inputText:gmatch("[^\n]+") do
		row += 1

		numRows += 1
		numCols = #line

		for col = 1, #line do
			local char = line:sub(col, col)
			if isAntennaChar(char) then
				recordPosition(char, v2.new(col, row))
			end
		end
	end

	return { mapSize = v2.new(numCols, numRows), antennasByFrequency = antennasByFrequency }
end

function isInBounds(position: v2.Vector2, mapSize: v2.Vector2): boolean
	return position.x >= 1 and position.x <= mapSize.x and position.y >= 1 and position.y <= mapSize.y
end

function part1(input: Input)
	--[[
		Problem:
			Every pair of antennas with the same frequency interfere and create an antinode in each direction
			past them exactly the same displacement as they themselves are apart. I need to count each cell in the map
			that contains at least one antinode.
		Approach:
			First, I'll need a map<number, set<number>> to store cells that already have an antinode so as to avoid
			double counting. Then, I'll iterate over each frequency, then over each pair of antennas using a
			pair of nested loops (i = 1, #antennas; j = i + 1, #antennas), calculate the displacement between the
			antennas, and then iterate over the displacement vector, adding the displacement to the current position,
			checking if the cell is within the map bounds and if it's not already in the set of cells with antinodes,
			then adding it to the set and incrementing the count of cells with antinodes.
	]]

	local mapSize = input.mapSize
	local antennasByFrequency = input.antennasByFrequency

	local cellsWithAntinodes: { [number]: { [number]: boolean } } = {}
	local count = 0

	function doesCellHaveAntinode(cellPosition: v2.Vector2): boolean
		return cellsWithAntinodes[cellPosition.x] and cellsWithAntinodes[cellPosition.x][cellPosition.y]
	end

	function getOrCreateColSet(col: number): { [number]: boolean }
		if not cellsWithAntinodes[col] then
			cellsWithAntinodes[col] = {}
		end

		return cellsWithAntinodes[col]
	end

	function recordAntinodeAtPosition(position: v2.Vector2)
		if not isInBounds(position, mapSize) or doesCellHaveAntinode(position) then
			return
		end

		getOrCreateColSet(position.x)[position.y] = true
		count += 1
	end

	for _, antennas in pairs(antennasByFrequency) do
		for i = 1, #antennas do
			for j = i + 1, #antennas do
				local antenna1 = antennas[i]
				local antenna2 = antennas[j]

				local displacement = v2.sub(antenna2, antenna1)
				recordAntinodeAtPosition(v2.sub(antenna1, displacement))
				recordAntinodeAtPosition(v2.add(antenna2, displacement))
			end
		end
	end

	return count
end

function part2(input: Input)
	--[[
		Problem:
			This is much like part 1, except now antinodes appear at all multiples of the displacement vector
			in both directions from the pair of antennas, including on the antennas themselves.
		Approach:
			Instead of just calculating the antinode positions for each pair of antennas, I'll calculate the
			displacement vector and then iterate over all multiples of the displacement vector in both directions
			from the pair of antennas, adding each position to the set of cells with antinodes.
			
			I can do this using a stack (or queue, but I already wrote a stack implementation) to store the antinode
			position and displacement in the given direction. Then I can simply put the two antenna positions directly
			in the stack to start and loop over it until it's empty, adding the displacement to the current position
			and checking if it's within the map bounds and if it's not already in the set of cells with antinodes,
			then adding it to the set and incrementing the count of cells with antinodes. Once an antinode position
			in the stack is out of bounds, I can pop it and continue the loop.

			One nice thing about this approach is I can build the stack across all antenna pairs at once and then
			do the stack loop just once. This isn't any more efficient but it helps keep the indentation level down.
	]]
	local mapSize = input.mapSize
	local antennasByFrequency = input.antennasByFrequency

	local antinodesStack: { { position: v2.Vector2, displacement: v2.Vector2 } } = {}
	local cellsWithAntinodes: { [number]: { [number]: boolean } } = {}
	local count = 0

	function doesCellHaveAntinode(cellPosition: v2.Vector2): boolean
		return cellsWithAntinodes[cellPosition.x] and cellsWithAntinodes[cellPosition.x][cellPosition.y]
	end

	function getOrCreateColSet(col: number): { [number]: boolean }
		if not cellsWithAntinodes[col] then
			cellsWithAntinodes[col] = {}
		end

		return cellsWithAntinodes[col]
	end

	function recordAntinodeAtPosition(position: v2.Vector2)
		if not isInBounds(position, mapSize) or doesCellHaveAntinode(position) then
			return
		end

		getOrCreateColSet(position.x)[position.y] = true
		count += 1
	end

	for _, antennas in pairs(antennasByFrequency) do
		for i = 1, #antennas do
			for j = i + 1, #antennas do
				local antenna1 = antennas[i]
				local antenna2 = antennas[j]

				local displacement = v2.sub(antenna2, antenna1)

				stack.push(antinodesStack, { position = antenna1, displacement = v2.mul(displacement, -1) })
				stack.push(antinodesStack, { position = antenna2, displacement = displacement, -1 })
			end
		end
	end

	while #antinodesStack > 0 do
		local stackElement = stack.pop(antinodesStack)
		local antinodePosition = stackElement.position
		local displacement = stackElement.displacement

		if not isInBounds(antinodePosition, mapSize) then
			continue
		end

		recordAntinodeAtPosition(antinodePosition)

		stack.push(antinodesStack, { position = v2.add(antinodePosition, displacement), displacement = displacement })
	end

	return count
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}