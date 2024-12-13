local stack = require("../../../../packages/stack/index.luau")
local v2 = require("../../../../packages/vector2/index.luau")

type Input = { { number } }
function parse(inputText: string): Input
	local grid = {}
	for line in string.gmatch(inputText, "[^\n]+") do
		local row = {}
		for digit in string.gmatch(line, "%d") do
			table.insert(row, tonumber(digit))
		end
		table.insert(grid, row)
	end
	return grid
end

function part1(input: Input)
	print(input)

	function trailEndpointsToString(head: v2.Vector2, tail: v2.Vector2)
		return head.x .. "," .. head.y .. " -> " .. tail.x .. "," .. tail.y
	end

	type StackElement = { position: v2.Vector2, path: { v2.Vector2 } }
	local dfsStack: { StackElement } = {}
	local trailEndpointsFound: { [string]: boolean } = {}

	for y, row in input do
		for x, digit in row do
			if digit == 0 then
				stack.push(dfsStack, { position = v2.new(x, y), path = { v2.new(x, y) } })
			end
		end
	end

	local totalTrails = 0

	while #dfsStack > 0 do
		local currentElement = stack.pop(dfsStack)
		local pos = currentElement.position
		local value = input[pos.y][pos.x]
		local path = currentElement.path

		if value == 9 then
			local trailEndpointsString = trailEndpointsToString(path[1], pos)
			if not trailEndpointsFound[trailEndpointsString] then
				print(trailEndpointsString)
				trailEndpointsFound[trailEndpointsString] = true
				totalTrails += 1
			end
		else
			local neighbors = {
				v2.new(pos.x + 1, pos.y),
				v2.new(pos.x - 1, pos.y),
				v2.new(pos.x, pos.y + 1),
				v2.new(pos.x, pos.y - 1)
			}
			for _, neighbor in neighbors do
				local nx, ny = neighbor.x, neighbor.y
				if nx > 0 and nx <= #input[1] and ny > 0 and ny <= #input then
					local neighborValue = input[ny][nx]
					if neighborValue == value + 1 then
						local newPath = table.clone(path)
						table.insert(newPath, neighbor)
						stack.push(dfsStack, { position = neighbor, path = newPath })
					end
				end
			end
		end
	end

	return totalTrails
end

function part2(input: Input)
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}