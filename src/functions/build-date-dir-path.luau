local datetime = require("@lune/datetime")
local process = require("@lune/process")

return function(day: number): string
    if day < 1 or day > 25 then
        error("Day must be between 1 and 25")
    end

    local dayStr = string.format("%02d", day)

    local year = if process.env.year then tonumber(process.env.year) else datetime.now().year
    local yearStr = string.format("%04d", year)

    return "./years/" .. yearStr .. "/" .. dayStr
end