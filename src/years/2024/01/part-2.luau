return function(lists: { { number } }): number
    if #lists ~= 2 then
        error("Expected 2 lists, got " .. #lists)
    end

    local list1 = lists[1]
    local list2 = lists[2]
    

    local list2AppearancesForList1Entries: {[number]: number} = {}
    for _, num in list1 do
        list2AppearancesForList1Entries[num] = 0
    end

    for _, num in list2 do
        if list2AppearancesForList1Entries[num] ~= nil then
            list2AppearancesForList1Entries[num] = list2AppearancesForList1Entries[num] + 1
        end
    end

    local totalScore = 0
    for a, b in pairs(list2AppearancesForList1Entries) do
        totalScore = totalScore + a * b
    end

    return totalScore
end