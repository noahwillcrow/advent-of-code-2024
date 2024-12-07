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

function part1(input: { { string } })
	local function checkDirection(row: number, col: number, dRow: number, dCol: number)
		local targetString = "XMAS"
		for i = 1, #targetString do
			local tempRow = row + (dRow * (i - 1))
			local tempCol = col + (dCol * (i - 1))

			if tempRow < 1 or tempRow > #input or tempCol < 1 or tempCol > #input[tempRow] then
				return false
			end
			
			if input[tempRow][tempCol] ~= targetString:sub(i, i) then
				return false
			end
		end

		return true
	end

	local directions = {
		{ -1, 0 }, -- north
		{ -1, 1}, -- northeast
		{ 0, 1 }, -- east
		{ 1, 1 }, -- southeast
		{ 1, 0 }, -- south
		{ 1, -1 }, -- southwest
		{ 0, -1 }, -- west
		{ -1, -1 } -- northwest
	}

	local counter = 0

	for row = 1, #input do
		for col = 1, #input[row] do
			if input[row][col] == "X" then
				for _, direction in directions do
					if checkDirection(row, col, direction[1], direction[2]) then
						counter += 1
					end
				end
			end
		end
	end

	return counter
end

function part2(input: { { string } })
	local counter = 0

	for row = 2, #input - 1 do
		for col = 2, #input[row] - 1 do
			if input[row][col] == "A" then
				local topLeft = input[row - 1][col - 1]
				local topRight = input[row - 1][col + 1]
				local bottomLeft = input[row + 1][col - 1]
				local bottomRight = input[row + 1][col + 1]

				local hasLine1 = (topLeft == "M" or topLeft == "S") and (bottomRight == "M" or bottomRight == "S") and topLeft ~= bottomRight
				local hasLine2 = (topRight == "M" or topRight == "S") and (bottomLeft == "M" or bottomLeft == "S") and topRight ~= bottomLeft

				if hasLine1 and hasLine2 then
					counter += 1
				end
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