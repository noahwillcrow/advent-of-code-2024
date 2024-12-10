local printIfVerbose = require("../../../../packages/print-if-verbose/index.luau")
local sortedInsert = require("../../../../packages/sorted-insert/index.luau")
local queue = require("../../../../packages/queue/index.luau")

type Input = { number }
function parse(inputText: string): Input
	local numbers: Input = {}

	for i = 1, #inputText do
		local char = inputText:sub(i, i)
		table.insert(numbers, tonumber(char))
	end

	return numbers
end

local EMPTY_BLOCK_ID = "."

function buildBlockIdsFromInput(input: Input): { blockIds: { number | "." }, emptyBlockIndexes: { number } }
	local blockIds: { number | "." } = {}
	local emptyBlockIndexes: { number } = {}

	local isFileLength = true
	local currentFileId = 0
	for i = 1, #input do
		local inputNumber = input[i]
		
		local blockId = if isFileLength then currentFileId else EMPTY_BLOCK_ID
		for j = 1, inputNumber do
			table.insert(blockIds, blockId)

			if not isFileLength then
				table.insert(emptyBlockIndexes, #blockIds)
			end
		end

		if isFileLength then
			currentFileId = currentFileId + 1
		end

		isFileLength = not isFileLength
	end

	return {
		blockIds = blockIds,
		emptyBlockIndexes = emptyBlockIndexes
	}
end

function swapIndividualBlocksIntoEarlyFreeSpace(blockIds: { number | "." }, emptyBlockIndexes: { number }): { number | "." }
	local swappedBlockIds = table.clone(blockIds)
	local swapEndIndex = #blockIds
	while swapEndIndex > queue.peek(emptyBlockIndexes) do
		if swappedBlockIds[swapEndIndex] ~= EMPTY_BLOCK_ID then
			local swapStartIndex = queue.pop(emptyBlockIndexes)
			swappedBlockIds[swapStartIndex] = blockIds[swapEndIndex]
			swappedBlockIds[swapEndIndex] = EMPTY_BLOCK_ID
		end
		swapEndIndex = swapEndIndex - 1
	end

	return swappedBlockIds
end

function computeChecksum(blockIds: { number | "." }): number
	local sum = 0

	for i = 1, #blockIds do
		if blockIds[i] ~= EMPTY_BLOCK_ID then
			sum += blockIds[i] * (i - 1)
		end
	end

	return sum
end

function part1(input: Input)
	local buildResult = buildBlockIdsFromInput(input)
	local blockIds = buildResult.blockIds
	local emptyBlockIndexes = buildResult.emptyBlockIndexes
	printIfVerbose(function() return { "Block IDs: " .. table.concat(blockIds, "") } end)
	printIfVerbose(function() return { "Empty block indexes: " .. table.concat(emptyBlockIndexes, ", ") } end)

	local swappedBlockIds = swapIndividualBlocksIntoEarlyFreeSpace(blockIds, emptyBlockIndexes)
	printIfVerbose(function() return { "Swapped block IDs: " .. table.concat(swappedBlockIds, "") } end)

	return computeChecksum(swappedBlockIds)
end

type ContiguousSection = { value: number | ".", start: number, finish: number }

function contiguousSectionToString(contiguousSection: ContiguousSection): string
	return "{ value = " .. contiguousSection.value .. ", start = " .. contiguousSection.start .. ", finish = " .. contiguousSection.finish .. " }"
end

function identifyContiguousFreeSpaceSections(emptyBlockIndexes: { number }): { ContiguousSection }
	local contiguousFreeSpaceSections: { ContiguousSection } = {}

	local contiguousFreeSpaceSection = nil
	for i = 1, #emptyBlockIndexes do
		local emptyBlockIndex = emptyBlockIndexes[i]

		if contiguousFreeSpaceSection == nil then
			contiguousFreeSpaceSection = { value = EMPTY_BLOCK_ID, start = emptyBlockIndex, finish = emptyBlockIndex }
		elseif emptyBlockIndex == contiguousFreeSpaceSection.finish + 1 then
			contiguousFreeSpaceSection.finish = emptyBlockIndex
		else
			table.insert(contiguousFreeSpaceSections, contiguousFreeSpaceSection)
			contiguousFreeSpaceSection = { value = EMPTY_BLOCK_ID, start = emptyBlockIndex, finish = emptyBlockIndex }
		end
	end

	if contiguousFreeSpaceSection ~= nil then
		table.insert(contiguousFreeSpaceSections, contiguousFreeSpaceSection)
	end

	return contiguousFreeSpaceSections
end

function computeContiguousSectionSize(contiguousSection: ContiguousSection): number
	return contiguousSection.finish - contiguousSection.start + 1
end

function areContiguousSectionsOrderedCorrectly(a: ContiguousSection, b: ContiguousSection): boolean
	local aSize = computeContiguousSectionSize(a)
	local bSize = computeContiguousSectionSize(b)

	if aSize == bSize then
		return a.start < b.start
	end

	return aSize < bSize
end

function buildFilesQueue(blockIds: { number | "." }): { ContiguousSection }
	local filesQueue: { ContiguousSection } = {}

	local currentFile = nil
	for i = #blockIds, 1, -1 do
		local blockId = blockIds[i]

		if blockId == EMPTY_BLOCK_ID then
			if currentFile ~= nil then
				table.insert(filesQueue, currentFile)
				currentFile = nil
			end
		else
			if currentFile == nil then
				currentFile = { value = blockId, start = i, finish = i }
			elseif currentFile.value ~= blockId then
				table.insert(filesQueue, currentFile)
				currentFile = { value = blockId, start = i, finish = i }
			else
				currentFile.start = i
			end
		end
	end

	if currentFile ~= nil then
		table.insert(filesQueue, currentFile)
		currentFile = nil
	end

	return filesQueue
end

function findBestFitForFile(fileSection: ContiguousSection, contiguousFreeSpaceSections: { ContiguousSection }): number
	local fileSectionSize = computeContiguousSectionSize(fileSection)

	-- step 1, identify where the file can fit
	local minFitIndex = #contiguousFreeSpaceSections + 1
	for i = #contiguousFreeSpaceSections, 1, -1 do
		local freeSpaceSection = contiguousFreeSpaceSections[i]
		local freeSpaceSectionSize = computeContiguousSectionSize(freeSpaceSection)

		if freeSpaceSectionSize < fileSectionSize then
			printIfVerbose(function() return { "Free space section too small:", contiguousSectionToString(freeSpaceSection) } end)
			break
		end

		minFitIndex -= 1
	end
	printIfVerbose(function() return { "Minimum fit index:", minFitIndex, "/", #contiguousFreeSpaceSections } end)

	-- if we cannot find a fit, return nil
	if minFitIndex > #contiguousFreeSpaceSections then
		printIfVerbose(function() return { "No fit found" } end)
		return nil
	end

	-- step 2, find the left-most fit
	local leftMostFitFreeSpaceSectionIndex = minFitIndex
	local leftMostFitFreeSpaceSection = contiguousFreeSpaceSections[leftMostFitFreeSpaceSectionIndex]
	for i = minFitIndex, #contiguousFreeSpaceSections do
		local freeSpaceSection = contiguousFreeSpaceSections[i]
		if freeSpaceSection.start < leftMostFitFreeSpaceSection.start then
			leftMostFitFreeSpaceSectionIndex = i
			leftMostFitFreeSpaceSection = freeSpaceSection
		end
	end

	if leftMostFitFreeSpaceSection.start > fileSection.start then
		printIfVerbose(function() return { "Left-most fit is too far right:", contiguousSectionToString(leftMostFitFreeSpaceSection) } end)
		return nil
	end

	-- return the index of the left-most fit
	return leftMostFitFreeSpaceSectionIndex
end

function swapWholeFilesIntoEarlyFreeSpace(sourceBlockIds: { number | "." }, emptyBlockIndexes: { number }): { number | "." }
	local blockIds = table.clone(sourceBlockIds)

	local contiguousFreeSpaceSections = identifyContiguousFreeSpaceSections(emptyBlockIndexes)
	printIfVerbose(function() return { "Contiguous free space sections:", contiguousFreeSpaceSections } end)
	table.sort(contiguousFreeSpaceSections, areContiguousSectionsOrderedCorrectly)
	printIfVerbose(function() return { "Sorted contiguous free space sections:", contiguousFreeSpaceSections } end)

	local filesQueue = buildFilesQueue(blockIds)
	printIfVerbose(function() return { "Files queue:", filesQueue } end)

	while #filesQueue > 0 and #contiguousFreeSpaceSections > 0 do
		local fileSection = queue.pop(filesQueue)
		local fileSectionSize = computeContiguousSectionSize(fileSection)

		printIfVerbose(function() return { "File section:", contiguousSectionToString(fileSection), "\nSize:", fileSectionSize } end)

		local bestFitIndex = findBestFitForFile(fileSection, contiguousFreeSpaceSections)

		printIfVerbose(function() return { "Best fit index:", bestFitIndex } end)

		if bestFitIndex ~= nil then
			local freeSpaceSection = table.remove(contiguousFreeSpaceSections, bestFitIndex)
			local freeSpaceSectionSize = computeContiguousSectionSize(freeSpaceSection)

			printIfVerbose(function() return { "Free space section:", contiguousSectionToString(freeSpaceSection) } end)
			
			for i = 0, fileSectionSize - 1 do
				blockIds[freeSpaceSection.start + i] = fileSection.value
				blockIds[fileSection.start + i] = EMPTY_BLOCK_ID
				printIfVerbose(function() return { "Swapped block IDs in progress: " .. table.concat(blockIds, ",") } end)
			end

			freeSpaceSection.start = freeSpaceSection.start + fileSectionSize
			if freeSpaceSection.start <= freeSpaceSection.finish then
				local insertedIndex = sortedInsert(contiguousFreeSpaceSections, freeSpaceSection, areContiguousSectionsOrderedCorrectly)
				printIfVerbose(function() return { "Re-inserted at index", insertedIndex } end)
			end
		end
	end

	return blockIds
end

function part2(input: Input)
	local buildResult = buildBlockIdsFromInput(input)
	local blockIds = buildResult.blockIds
	local emptyBlockIndexes = buildResult.emptyBlockIndexes
	printIfVerbose(function() return { "Block IDs: " .. table.concat(blockIds, ",") } end)
	printIfVerbose(function() return { "Empty block indexes: " .. table.concat(emptyBlockIndexes, ", ") } end)

	local swappedBlockIds = swapWholeFilesIntoEarlyFreeSpace(blockIds, emptyBlockIndexes)
	printIfVerbose(function() return { "Swapped block IDs: " .. table.concat(swappedBlockIds, ",") } end)

	return computeChecksum(swappedBlockIds)
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}