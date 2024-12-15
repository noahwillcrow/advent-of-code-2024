local printIfVerbose = require("../../../../packages/print-if-verbose/index.luau")
local regex = require("@lune/regex")
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

local direction = {
	up = 1,
	right = 2,
	down = 3,
	left = 4
}

local directionUnitVectors = {
	v2.new(0, -1),
	v2.new(1, 0),
	v2.new(0, 1),
	v2.new(-1, 0)
}

local numDirections = 4

function locationToString(p: v2.Vector2)
	return p.x .. "," .. p.y
end

function getBorderString(p: v2.Vector2, dir: number)
	-- cells are indexed by their top-left corner
	-- always orient the border from top/left to bottom/right
	if dir == direction.up then
		-- from top-left to top-right
		return p.x .. "," .. p.y .. "|" .. p.x + 1 .. "," .. p.y
	elseif dir == direction.right then
		-- top-right to bottom-right
		return p.x + 1 .. "," .. p.y .. "|" .. p.x + 1 .. "," .. p.y + 1
	elseif dir == direction.down then
		-- bottom-left to bottom-right
		return p.x .. "," .. p.y + 1 .. "|" .. p.x + 1 .. "," .. p.y + 1
	elseif dir == direction.left then
		-- top-left to bottom-left
		return p.x .. "," .. p.y .. "|" .. p.x .. "," .. p.y + 1
	end
end

local endsRegex = regex.new("(?<start>[^|]+)\\|(?<finish>[^|]+)")
local componentsRegex = regex.new("(?<x>[^,]+),(?<y>[^,]+)")
function parseBorderString(str: string): (v2.Vector2, v2.Vector2)
	local endCaptures = endsRegex:captures(str)
	local startComponentCaptures = componentsRegex:captures(endCaptures:format("$start"))
	local finishComponentCaptures = componentsRegex:captures(endCaptures:format("$finish"))
	local start = v2.new(tonumber(startComponentCaptures:format("$x")), tonumber(startComponentCaptures:format("$y")))
	local finish = v2.new(tonumber(finishComponentCaptures:format("$x")), tonumber(finishComponentCaptures:format("$y")))
	return start, finish
end

type Zone = { char: string, area: number, perimeter: number, borders: { [string]: boolean } }

function identifyZones(input: Input): { Zone }
	local zones: { Zone } = {}
	local alreadyZonedLocations: { [string]: boolean } = {}

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
			table.insert(zones, zone)

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

					local newPosition = v2.add(position, directionUnitVectors[dir])
					stack.push(zoneStack, newPosition)
				end
			end
		end
	end

	return zones
end

function part1(input: Input): number
	local zones = identifyZones(input)
	local sum = 0

	for i = 1, #zones do
		local zone = zones[i]
		local zoneFencingCost = zone.area * zone.perimeter
		sum += zoneFencingCost
	end

	return sum
end

type Side = { directionUnitVector: v2.Vector2, start: v2.Vector2, finish: v2.Vector2 }

function combineBorderStringsIntoSides(zone: Zone): { Side }
	local sides: { Side } = {}

	for borderString, isPerimiter in zone.borders do
		if not isPerimiter then
			continue
		end
		
		local borderStart, borderFinish = parseBorderString(borderString)
		local absoluteBorderStart = if borderStart.x < borderFinish.x or borderStart.y < borderFinish.y then borderStart else borderFinish
		local absoluteBorderFinish = if borderStart.x < borderFinish.x or borderStart.y < borderFinish.y then borderFinish else borderStart
		local directionUnitVector = v2.sub(borderFinish, borderStart)
		
		local sidesToExtend: { { side: Side, index: number } } = {}
		for i = 1, #sides do
			local side = sides[i]
			if v2.dot(side.directionUnitVector, directionUnitVector) == 0 then
				-- orthogonal sides can't be extended by a given border
				continue
			end

			if v2.eq(side.start, absoluteBorderFinish) or v2.eq(side.finish, absoluteBorderStart) then
				table.insert(sidesToExtend, { side = side, index = i })
			end
		end

		if #sidesToExtend == 0 then
			table.insert(sides, {
				directionUnitVector = v2.sub(absoluteBorderFinish, absoluteBorderStart),
				start = absoluteBorderStart,
				finish = absoluteBorderFinish,
			})
			printIfVerbose(function() return { "new side", sides[#sides] } end)
		elseif #sidesToExtend == 1 then
			printIfVerbose(function() return { "extending side" } end)
			local side = sidesToExtend[1].side
			if v2.eq(side.start, absoluteBorderFinish) then
				side.start = absoluteBorderStart
			elseif v2.eq(side.finish, absoluteBorderStart) then
				side.finish = absoluteBorderFinish
			end
		else
			printIfVerbose(function() return { "joining sides" } end)
			table.sort(sidesToExtend, function(a, b)
				return a.index < b.index
			end)

			local earliestStart = sidesToExtend[1].side.start
			local latestFinish = sidesToExtend[#sidesToExtend].side.finish
			for i = #sidesToExtend, 1, -1 do
				local side = sidesToExtend[i].side
				printIfVerbose(function() return { side, earliestStart, latestFinish } end)
				if side.start.x < earliestStart.x or side.start.y < earliestStart.y then
					earliestStart = side.start
				elseif side.finish.x > latestFinish.x or side.finish.y > latestFinish.y then
					latestFinish = side.finish
				end

				table.remove(sides, sidesToExtend[i].index)
			end

			table.insert(sides, {
				directionUnitVector = v2.unit(v2.sub(latestFinish, earliestStart)),
				start = earliestStart,
				finish = latestFinish,
			})
		end
	end

	return sides
end

function findIntersectionPoint(horizontalSide: Side, verticalSide: Side): v2.Vector2?
	if horizontalSide.start.x < verticalSide.start.x and horizontalSide.finish.x > verticalSide.start.x then
		if verticalSide.start.y < horizontalSide.start.y and verticalSide.finish.y > horizontalSide.start.y then
			return v2.new(verticalSide.start.x, horizontalSide.start.y)
		end
	end

	return nil
end

function splitAtIntersections(sides: { Side })
	--[[
		1. Find all intersections
			i. For each pair of sides that are orthogonal, check if they intersect
				- can use outer loop on only vertical, inner loop on only horizontal
				- basic line segment intersection problem here, lines will be on cardinal axes
		2. For each intersection, split the sides at the intersection
		3. Repeat until no intersections are found
	]]

	local i = 1
	while i < #sides do
		local verticalSide = sides[i]
		if verticalSide.directionUnitVector.x ~= 0 then
			i += 1
			continue
		end

		local intersectionPointYs: { number } = {}
		
		local j = 1
		while j < #sides do
			local horizontalSide = sides[j]
			if horizontalSide.directionUnitVector.y ~= 0 then
				j += 1
				continue
			end

			local intersectionPoint = findIntersectionPoint(horizontalSide, verticalSide)
			if intersectionPoint == nil then
				j += 1
				continue
			end

			horizontalSide.finish = intersectionPoint
			local newHorizontalSide = {
				directionUnitVector = v2.unit(v2.sub(horizontalSide.finish, intersectionPoint)),
				start = intersectionPoint,
				finish = horizontalSide.finish,
			}
			table.insert(sides, j + 1, newHorizontalSide)

			table.insert(intersectionPointYs, intersectionPoint.y)

			j += 2 -- skip the new horizontal side
		end

		table.sort(intersectionPointYs)
		local currentVerticalSideToSplit = verticalSide
		for k = 1, #intersectionPointYs do
			local intersectionPoint = v2.new(currentVerticalSideToSplit.start.x, intersectionPointYs[k])
			local newVerticalSide = {
				directionUnitVector = verticalSide.directionUnitVector,
				start = intersectionPoint,
				finish = currentVerticalSideToSplit.finish,
			}
			table.insert(sides, i + k, newVerticalSide)

			currentVerticalSideToSplit.finish = intersectionPoint
			currentVerticalSideToSplit = newVerticalSide
		end

		i += #intersectionPointYs + 1 -- skip the new vertical sides
	end
end

function identifySides(zone: Zone): { Side }
	local sides = combineBorderStringsIntoSides(zone)
	splitAtIntersections(sides)
	return sides
end

function part2(input: Input)
	local zones = identifyZones(input)
	local sum = 0

	for i = 1, #zones do
		local zone = zones[i]
		local sides = identifySides(zone)
		local numSides = #sides
		local zoneFencingCost = zone.area * numSides
		printIfVerbose(function() return { zone.char, zone.area, numSides, zoneFencingCost, sides } end)
		sum += zoneFencingCost
	end

	return sum
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}