function parse(inputText: string): { dependencies: { { number } }, updates: { { number } } }
	local dependencies: { { number } } = {}
	local updates: { { number } } = {}

	local areDependenciesComplete = false
	for line in inputText:gmatch("[^\n]+") do
		if not areDependenciesComplete then
			local pageNumberStrings = line:split("|")
			if #pageNumberStrings == 2 then
				table.insert(dependencies, { tonumber(pageNumberStrings[1]), tonumber(pageNumberStrings[2]) })
			else
				areDependenciesComplete = true
			end
		end

		if areDependenciesComplete then
			local pageNumberStrings = line:split(",")
			if #pageNumberStrings == 0 then
				continue
			end

			local pageNumbers: { number } = {}
			for j = 1, #pageNumberStrings do
				table.insert(pageNumbers, tonumber(pageNumberStrings[j]))
			end

			table.insert(updates, pageNumbers)
		end
	end

	return { dependencies = dependencies, updates = updates }
end

function part1(input: { dependencies: { { number } }, updates: { { number } } })
	local mustNotComeAfterByPageNumber: { [number]: { number } } = {}
	for _, dependency in input.dependencies do
		if mustNotComeAfterByPageNumber[dependency[1]] == nil then
			mustNotComeAfterByPageNumber[dependency[1]] = {}
		end

		table.insert(mustNotComeAfterByPageNumber[dependency[1]], dependency[2])
	end

	local function isUpdateCorrect(update: { number })
		local alreadyUpdated: { [number]: boolean } = {}
		for _, pageNumber in update do
			if mustNotComeAfterByPageNumber[pageNumber] ~= nil then
				for _, mustComeFirstPageNumber in mustNotComeAfterByPageNumber[pageNumber] do
					if alreadyUpdated[mustComeFirstPageNumber] then
						return false
					end
				end
			end

			alreadyUpdated[pageNumber] = true
		end

		return true
	end

	local sum = 0

	for _, update in input.updates do
		if isUpdateCorrect(update) then
			local middleIndex = math.ceil(#update / 2)
			sum += update[middleIndex]
		end
	end

	return sum
end

function part2(input: { dependencies: { { number } }, updates: { { number } } })
	local mustNotComeAfterByPageNumber: { [number]: { number } } = {}
	for _, dependency in input.dependencies do
		if mustNotComeAfterByPageNumber[dependency[1]] == nil then
			mustNotComeAfterByPageNumber[dependency[1]] = {}
		end

		table.insert(mustNotComeAfterByPageNumber[dependency[1]], dependency[2])
	end

	-- returns true if corrections were applied, false if none were needed
	local function applyCorrections(update: { number }): boolean
		local didApplyAnyCorrections = false

		local didApplyCorrections = false
		repeat
			didApplyCorrections = false
			for i = 1, #update do
				local pageNumber1 = update[i]
				for j = i + 1, #update do
					local pageNumber2 = update[j]
					if mustNotComeAfterByPageNumber[pageNumber2] ~= nil and table.find(mustNotComeAfterByPageNumber[pageNumber2], pageNumber1) then
						table.remove(update, j)
						table.insert(update, i, pageNumber2)
						didApplyCorrections = true
						didApplyAnyCorrections = true
					end
				end
			end
		until not didApplyCorrections

		if didApplyAnyCorrections then
			print(table.concat(update, ",") .. " is now correct")
		end

		return didApplyAnyCorrections
	end

	local sum = 0

	for _, update in input.updates do
		local didApplyCorrections = applyCorrections(update)
		if didApplyCorrections then
			local middleIndex = math.ceil(#update / 2)
			sum += update[middleIndex]
		end
	end

	return sum
end

return {
	parse = parse,
	part1 = part1,
	part2 = part2
}