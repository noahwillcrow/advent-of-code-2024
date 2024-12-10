return function<T>(sortedArray: { T }, isTarget: (value: T) -> boolean, shouldAppearBeforeTarget: (value: T) -> boolean): number
    local leftIndex = 1
    local rightIndex = #sortedArray

    while leftIndex <= rightIndex do
        local middleIndex = math.floor((leftIndex + rightIndex) / 2)
        local middleValue = sortedArray[middleIndex]

        if isTarget(middleValue) then
            return middleIndex
        end

        if shouldAppearBeforeTarget(middleValue) then
            leftIndex = middleIndex + 1
        else
            rightIndex = middleIndex - 1
        end
    end

    return nil
end