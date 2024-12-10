-- implement a sorted insert function that returns the index at which a value was inserted into the sorted array
return function<T>(sortedArray: { T }, value: T, areOrderedCorrectly: (earlierValue: T, laterValue: T) -> boolean): number
    -- naive O(n) implementation
    -- for i, v in sortedArray do
    --     if areOrderedCorrectly(value, v) then
    --         table.insert(sortedArray, i, value)
    --         return i
    --     end
    -- end

    -- binary search implementation
    local leftIndex = 1
    local rightIndex = #sortedArray

    while leftIndex <= rightIndex do
        local middleIndex = math.floor((leftIndex + rightIndex) / 2)
        local middleValue = sortedArray[middleIndex]

        if areOrderedCorrectly(value, middleValue) then
            rightIndex = middleIndex - 1
        elseif areOrderedCorrectly(middleValue, value) then
            leftIndex = middleIndex + 1
        else
            table.insert(sortedArray, middleIndex, value)
            return middleIndex
        end
    end

    table.insert(sortedArray, leftIndex, value)
    return leftIndex
end
