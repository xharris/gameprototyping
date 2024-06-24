local M = {}

function M.log(...)
    local values = {}
    for _, l in ipairs({...}) do
        if type(l) == 'table' then
            table.insert(values, lume.serialize(l))
        else
            table.insert(values, l)
        end
    end
    print(table.concat(values, ' '))
end

return M