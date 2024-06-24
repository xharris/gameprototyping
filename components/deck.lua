local M = {}
local enum, auto = require 'enum' ()
local queue = require 'queue'

M.STATE = enum{
    NONE = auto(),
    PLAY_CARDS = auto(),
}

---@class Deck : Component
---@field onAllCardsPlayed Signal
---@field state number

---@class Step
---@field target 'enemy'|'ally'|'self'
---@field repeats? number
---@field heal? number
---@field shield? number
---@field hurt? number
---@field addStatus? string[]
---@field removeStatus? string[]

---@class Card
---@field name string
---@field steps Step[]

---@param cards? Card[]
function M.new(cards)
    return {
        onAllCardsPlayed = ecs.signal(),

        _t = 1,
        cards = cards,
        combatCards = {}, -- copy of cards used for current combat
        combatIdx = 1,

        state = M.STATE.NONE,

        ---@param card Card
        playCard = function(self, card)
            for s, step in ipairs(card.steps) do
                local target
                -- get target
                if step.target == 'self' then
                    target = ecs.get(self.parent)
                else
                    ecs.each(function(ent)
                        local npc = ecs.get(self.parent)
                        ---@cast ent {npc?:NPC}
                        -- target ally
                        if npc and ent.npc and step.target == 'ally' and ent.npc.npcType == npc.parent then
                            target = ent
                        end
                        -- target enemy
                        if npc and ent.npc and step.target == 'enemy' and ent.npc.npcType ~= npc.parent then
                            target = ent
                        end
                    end)
                end
                if not target then
                    print('no target found for ', card.name, ' step ', s)
                    goto continue
                end
                -- perform card action
                for r = 1, (step.repeats or 0) + 1 do
                    local hpChange = 0
                    if step.hurt then
                        hpChange = hpChange - step.hurt
                    end
                    if step.heal then
                        hpChange = hpChange + step.hurt
                    end
                    -- apply hp change
                    if target.hp then
                        target.hp:modify(hpChange)
                    end
                end
                ::continue::
            end
        end,

        love_update = function(self, dt)
            if self._t > 0 then
                self._t = self._t - dt
            end
            -- combat
            if self.state == M.STATE.PLAY_CARDS then
                if #self.cards == 0 and #self.combatCards == 0 then
                    -- no cards to play
                    return
                end
                -- starting combat: copy cards to combat cards
                if #self.combatCards == 0 then
                    self.combatCards = lume.clone(self.cards)
                end
            end
            if self._t <= 0 then
                self._t = 1
                
                -- combat: playing a card
                local card = self.combatCards[self.combatIdx] --[[@as Card]]
                print('play card', self.combatIdx)
                print(lume.serialize(self.combatCards))
                self:playCard(card)
                
                self.combatIdx = self.combatIdx + 1
                if self.combatIdx > #self.combatCards then
                    self.onAllCardsPlayed.emit()
                    self.combatIdx = 1
                end
            end
        end,

        love_draw = function (self)
            if self.state == M.STATE.PLAY_CARDS then
                for c, card in ipairs(self.combatCards) do
                    ---@cast card Card
                    love.graphics.setColor(1,1,1)
                    love.graphics.print(card.name, 0, 16 * c)
                end
            end
        end
    } --[[@as Deck]]
end

return M