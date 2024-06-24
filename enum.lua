local i = -1

---Create new enum
---@generic E : table<string, number>
---@param t E
---@return E
local function enum(t)
    i = -1
    return t
end

local function auto()
    i = i + 1
    return i
end

return function() return enum, auto end