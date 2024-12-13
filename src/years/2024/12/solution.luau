local printIfVerbose = require("../../../../packages/print-if-verbose/index.luau")
local stack = require("../../../../packages/stack/index.luau")
local v2 = require("../../../../packages/vector2/index.luau")

type Input = { { string } }
function parse(inputText: string): Input
	local input = {}
	for line in inputText:gmatch("[^\n]+") do
		local lineInput = {}
		for i = 1, #line do
			table.insert(lineInput, line:sub(i, i))
		end
		table.insert(input, lineInput)
	end
	return input
end

function part1(input: Input)
	local direction = {
		up = 1,
		left = 2,
		down = 3,
		right = 4
	}
	local numDirections = 4
	local directions = {
		v2.new(0, -1),
		v2.new(-1, 0),
		v2.new(0, 1),
		v2.new(1, 0)
	}
	function getBorderString(p: v2.Vector2, dir: number)
		if dir == direction.up then
			return p.x .. "," .. p.y - 1 .. "|" .. p.x .. "," .. p.y
		elseif dir == direction.left then
			return p.x - 1 .. "," .. p.y .. "|" .. p.x .. "," .. p.y
		elseif dir == direction.down then
			return p.x .. "," .. p.y .. "|" .. p.x .. "," .. p.y + 1
		elseif dir == direction.right then
			return p.x .. "," .. p.y .. "|" .. p.x + 1 .. "," .. p.y
		end
	end

	function locationToString(p: v2.Vector2)
		return p.x .. "," .. p.y
	end

	type Zone = { char: string, area: number, perimeter: number, borders: { [string]: boolean } }
	local alreadyZonedLocations: { [string]: boolean } = {}

	local sum = 0

	for y = 1, #input do
		for x = 1, #input[y] do
			local v = v2.new(x, y)
			if alreadyZonedLocations[locationToString(v)] then
				continue
			end

			local zone: Zone = {
				char = input[y][x],
				area = 0,
				perimeter = 0,
				borders = {},
			}

			local zoneStack: { v2.Vector2 } = {v}
			while #zoneStack > 0 do
				local position = stack.pop(zoneStack)
				if position.x < 1 or position.x > #input[1] or position.y < 1 or position.y > #input then
					continue
				end

				if alreadyZonedLocations[locationToString(position)] then
					continue
				end

				local char = input[position.y][position.x]
				if char ~= zone.char then
					continue
				end

				alreadyZonedLocations[locationToString(position)] = true
				zone.area += 1

				for dir = 1, numDirections do
					local borderString = getBorderString(position, dir)
					if zone.borders[borderString] == nil then
						zone.perimeter += 1
						zone.borders[borderString] = true
					elseif zone.borders[borderString] == true then
						zone.perimeter -= 1
						zone.borders[borderString] = false
					end

					local newPosition = v2.add(position, directions[dir])
					stack.push(zoneStack, newPosition)
				end
			end

			local zoneFencingCost = zone.area * zone.perimeter
			sum += zoneFencingCost
		end
	end

	return sum
end

function part2(input: Input)
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}