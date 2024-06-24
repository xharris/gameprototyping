local COLUMNS = 3
local enemyCount = 0

---@alias NPC_TYPE 'enemy'|'ally'

---@class NPC : Component
---@field idx number
---@field npcType NPC_TYPE

---@param npcType NPC_TYPE
---@return NPC
return function(npcType)
    return {
        idx = 0,
        npcType = npcType,
        init = function (self)
            self.idx = enemyCount
            enemyCount = enemyCount + 1
        end,
        love_draw = function (self)
            -- draw on right side of screen
            local gw, gh = love.graphics.getDimensions()
            local x = 0
            if npcType == 'enemy' then
                x = x + gw/2
            end
            x = x + (self.idx * ((gw/2) / COLUMNS))
            love.graphics.rectangle('fill', x, gh/2 - 16, 32, 32)
        end
    }
end