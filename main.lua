-- press x to do damage

lume = require 'lume'
ecs = require "ecs"
local enum, auto = require "enum" ()
local turns = require 'singleton.turnbased'

-- COMPONENTS

local component_hp = require 'components.hp'
local component_npc = require 'components.npc'
local component_deck = require 'components.deck'

---@type Card[]
local CARDS = {
    {
        name = "Magic Missile",
        steps = {
            { target = 'enemy', hurt = 1 },
        }
    }
}
local START_CARD = CARDS[1]

local STATE = enum{
    COMBAT = auto(),
    SHOP = auto(),
    GAME_OVER = auto(),
}

local state = STATE.COMBAT

---@class Player : Entity
---@field npc NPC
---@field hp HP
---@field deck Deck

---@class Enemy : Entity
---@field npc NPC
---@field hp HP
---@field deck Deck

---@type Player
local player

local function get_enemy_count()
    local c = 0
    ecs.each(function(ent)
        ---@cast ent Player|Entity
        if ent.npc and ent.npc.npcType == 'enemy' then
            c = c + 1
        end
    end)
    return c
end

local function spawn_enemy()
    -- enemy
    local enemy = ecs.entity{
        hp = component_hp(),
        npc = component_npc('enemy'),
        deck = component_deck.new({ START_CARD }),
    }
    enemy.hp.onHealthChanged.connect(function ()
        if enemy.hp.health <= 0 then
            print('enemy died')
            turns.remove(enemy)
            ecs.remove(enemy)
            -- all enemies are defeated?
            if get_enemy_count() == 0 then
                state = STATE.SHOP
            end
        end
    end)
    enemy.deck.onAllCardsPlayed.connect(function ()
        print('enemy finished turn')
        -- turn finished
        local nextNPC = turns.next() --[[@as Player|Enemy]]
        nextNPC.deck.state = component_deck.STATE.PLAY_CARDS
    end)
    turns.push(enemy)
    return enemy
end

-- LOAD GAME

function love.load()
    -- player
    player = ecs.entity{
        hp = component_hp(),
        npc = component_npc('ally'),
        deck = component_deck.new({ START_CARD }),
    } --[[@as Player]]
    player.deck.state = component_deck.STATE.PLAY_CARDS
    player.hp.onHealthChanged.connect(function ()
        if player.hp <= 0 then
            -- player died
            state = STATE.GAME_OVER
            player.deck.state = component_deck.STATE.NONE
            turns.reset()
        end
    end)
    player.deck.onAllCardsPlayed.connect(function ()
        print('player finished turn')
        -- turn finished
        local nextNPC = turns.next() --[[@as Player|Enemy]]
        nextNPC.deck.state = component_deck.STATE.PLAY_CARDS
    end)
    turns.push(player)
    spawn_enemy()
end

function love.update(dt)
    ecs.call('love_update', dt)
end

function love.draw()
    ecs.call('love_draw')
end

function love.keypressed(key, scancode, isrepeat)
    ecs.call('love_keypressed', key, scancode, isrepeat)
end