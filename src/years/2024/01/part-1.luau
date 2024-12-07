return function(lists: { { number } }): number
    if #lists ~= 2 then
        error("Expected 2 lists, got " .. #lists)
    end

    local list1 = lists[1]
    local list2 = lists[2]

    table.sort(list1)
    table.sort(list2)

    local totalDiff = 0
    for i = 1, #list1 do
        totalDiff = totalDiff + math.abs(list1[i] - list2[i])
    end

    return totalDiff
end