local loadLists = require("./load-lists")
local part1 = require("./part-1")
local part2 = require("./part-2")

return function()
    local list1, list2 = loadLists("days/01/input.txt")

    print("Part 1:", part1(list1, list2))
    print("Part 2:", part2(list1, list2))
end