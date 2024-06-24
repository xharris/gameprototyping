local M = {}

function M.push(t, v)
    table.insert(t, v)
end

function M.pop(t)
    return table.remove(t, 1)
end

return M