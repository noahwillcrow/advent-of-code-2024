local regex = require("@lune/regex")
local stack = require("../../../../packages/stack/index.luau")

function parse(inputText: string): { { number } }
    local lines: { { string } } = {}
 
    local re = regex.new("([0-9]+)")

    for line in inputText:gmatch("[^\n]+") do
        local numbers: { number } = {}
    
        local str = line
        local match = re:find(str)
        while match do
            local capture = re:captures(str)
            local num = tonumber(capture:get(1).text)

            table.insert(numbers, num)
    
            str = str:sub(match.finish + 1)
            match = re:find(str)
        end

        table.insert(lines, numbers)
    end

    return lines
end

local OperatorTypes = {
    "*",
    "+",
    "||",
}
function canNumbersReachTarget(
    target: number,
    numbers: { number },
    allowedOperators: { ["*"]: boolean?, ["+"]: boolean?, ["||"]: boolean?}): boolean
    if #numbers == 0 then
        return false
    elseif #numbers == 1 then
        return numbers[1] == target
    end

    local numOperators = #numbers - 1

    local operatorsStack: { { resultSoFar: number, operators: { "*" | "+" | "||" } } } = {}
    stack.push(operatorsStack, { resultSoFar = numbers[1], operators = {} })

    while #operatorsStack > 0 do
        local stackElement = stack.pop(operatorsStack)
        local resultSoFar = stackElement.resultSoFar
        local operators = stackElement.operators

        if #operators == numOperators then
            if resultSoFar == target then
                return true
            end
        elseif resultSoFar <= target then
            for _, operator in OperatorTypes do
                if allowedOperators[operator] then
                    local nextOperators = table.clone(operators)
                    table.insert(nextOperators, operator)

                    local newResultSoFar = resultSoFar
                    local number = numbers[#nextOperators + 1]
                    if operator == "+" then
                        newResultSoFar += number
                    elseif operator == "*" then
                        newResultSoFar *= number
                    elseif operator == "||" then
                        local resultAsStr = tostring(newResultSoFar)
                        resultAsStr = resultAsStr .. tostring(number)
                        newResultSoFar = tonumber(resultAsStr)
                    end

                    stack.push(operatorsStack, { resultSoFar = newResultSoFar, operators = nextOperators })
                end
            end
        end
    end

    return false
end

function part1(input: { { number } })
    local sum = 0

    local lines: { { number } } = {}
    for i = 1, #input do
        table.insert(lines, table.clone(input[i]))
    end

    for _, line in lines do
        local target = table.remove(line, 1)
        local numbers = line

        if canNumbersReachTarget(target, numbers, { ["*"] = true, ["+"] = true, ["||"] = false }) then
            sum += target
        end
    end

    return sum
end

function part2(input: { { number } })
    local sum = 0

    local lines: { { number } } = {}
    for i = 1, #input do
        table.insert(lines, table.clone(input[i]))
    end

    for _, line in lines do
        local target = table.remove(line, 1)
        local numbers = line

        if canNumbersReachTarget(target, numbers, { ["*"] = true, ["+"] = true, ["||"] = true }) then
            sum += target
        end
    end

    return sum
end

return {
    parse = parse,
    part1 = part1,
    part2 = part2
}