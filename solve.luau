local process = require("@lune/process")

local day = tonumber(process.args[1])
local dayStr = string.format("%02d", day)
require("./days/" .. dayStr .. "/solution")()
