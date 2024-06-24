local M = {}

---@class Entity
---@field _id number
---@field _removed boolean

---@class Component
---@field parent number
---@field z number

---@type Entity[]
local entities = {}
local entityById = {}

local function is_valid_component(k, v)
    return k ~= '_id' and k ~= 'parent' and v ~= nil
end

---@alias ID number
local nextID = 1

---comment
---@generic C : table
---@param components C
---@return C
function M.entity(components)
    ---@type Entity
    local entity = components
    entity._id = nextID
    nextID = nextID + 1
    for k, component in pairs(entity) do
        if is_valid_component(k, component) then
            component.parent = entity._id
            component.z = component.z or 0
        end
    end
    table.insert(entities, entity._id)
    entityById[entity._id] = entity
    -- init
    for k, component in pairs(entity) do
        if is_valid_component(k, component) and component['init'] then
            component['init'](component, entity)
        end
    end
    return entity
end

---@param ent number|Entity
function M.remove(ent)
    print('remove entity', ent)
    if type(ent) == 'number' then
        ent = M.get(ent)
    end
    if ent then
        ent._removed = true
        entityById[ent._id] = nil
    end
end

function M.call(name, ...)
    for _, id in ipairs(entities) do
        local entity = entityById[id] --[[@as Entity]]
        for k, component in pairs(entity) do
            if not entity._removed and is_valid_component(k, component) and component[name] then
                component[name](component, ...)
            end
        end
    end
end

function M.get(id)
    return entityById[id]
end

---Iterate entities
---@param fn fun(ent:Entity):boolean? Return true to stop iterating
function M.each(fn)
    local entity
    for _, id in ipairs(entities) do
        entity = entityById[id]
        if entity and not entity._removed and fn(entity) then
            return
        end
    end
end

---@class Signal
---@field connect fun(function)
---@field emit fun(...)

---Create a signal
---@return Signal
function M.signal()
    local fns = {}
    return {
        connect = function(fn)
            table.insert(fns, fn)
        end,
        disconnect = function(fn)
            lume.remove(fns, fn)
        end,
        emit = function(...)
            for _, fn in ipairs(fns) do
                fn(...)
            end
        end
    }
end

function M.push()
    love.graphics.push('all')
end
M.pop = love.graphics.pop

return M