function peek<T>(t: { T }): T?
    return t[1]
end

function pop<T>(t: { T }): T?
    return table.remove(t, 1)
end

function push<T>(t: { T }, value: T)
    table.insert(t, value)
end

return {
    peek = peek,
    pop = pop,
    push = push,
}
