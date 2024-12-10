local args = require("../args/index.luau")

local parsedArgs = args.parseArgs({
    {
        aliases = { { shortName = "v" } },
        description = "Whether to be verbose",
        name = "verbose",
        required = false
    }
})

return function(generateArgs: () -> { any })
    if parsedArgs.options["verbose"] == "true" then
        print(table.unpack(generateArgs()))
    end
end