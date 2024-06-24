local M = {}

local turn = 0
local round = 1
local idx = 0
local order = {}

function M.reset()
    turn = 0
    round = 1
    idx = 0
    order = {}
end

function M.next()
    print('next turn,', #order, 'participants')
    turn = turn + 1
    idx = idx + 1
    if idx > #order then
        idx = 1
        round = round + 1
    end
    print('turn moves to', order[idx])
    return order[idx]
end

--- Add to turn order
function M.push(v)
    print('add', v, 'to turn order')
    table.insert(order, v)
end

function M.remove(v)
    print('remove', v, 'from turn order')
    lume.remove(order, v)
end

function M.currentTurn()
    return turn
end

function M.currentRound()
    return round
end

return M