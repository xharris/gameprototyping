---@class HP
---@field onHealthChanged Signal
---@field health number
---@field modify fun(amt:number)
---@field damage fun(amt:number)
---@field heal fun(amt:number)

return function(health)
    return {
        onHealthChanged = ecs.signal(),

        health = health or 10,
        modify = function(self, amt)
            self.health = self.health + amt
            print('hp.modify', amt)
            self.onHealthChanged.emit(amt)
        end,
        damage = function (self, amt)
            self.health = self.health - amt
        end,
        heal = function(self, amt)
            self.health = self.health + amt
        end
    }
end