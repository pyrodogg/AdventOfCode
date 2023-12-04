package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

print('Day Four')

local lines = lines_from('../input/04.txt')
local P1, P2 = 0, 0
local deck = {}
for k,v in pairs(lines) do

    --local card_number = tonumber(v:match('Card (%d+)%:'),10)

    local winners = {}
    local havers = {}
    local next = false
    local foo = v:sub(9)
    for i, j in foo:gmatch('()'..'([%d|]+)'..'') do

        if j == '|' then 
            next = true 
        end

        if next then
            table.insert(havers,j)
        else
            --table.insert(winners,j)
            winners[j] = j
        end
    end

    local keepers = {}
    local power = 0
    for i, j in pairs(havers) do
        if winners[j] ~= nil then
            power = power + 1
            table.insert(keepers,j)
        end
    end

    if deck[k] == nil then deck[k] = {} end
    deck[k]["card"] = k
    deck[k]["winners"] = winners
    deck[k]["havers"] = havers
    deck[k]["keepers"] = keepers
    if power > 0 then 
        deck[k]["power"] = power
        deck[k]["winner"] = true
        P1 = P1 + 2^(power-1)
    end
end

local toEval = {}
for k,v in pairs(deck) do

    P2 = P2 + 1
    if v.winner then
        for i = v.card+1, v.card+#v.keepers do
            -- copy cards
            table.insert(toEval,i)
            --print(v.card, i) -- had to print to missing +1 causing infinite loop
        end
    end
    --break
end

while true do
    
    local checking = table.remove(toEval,#toEval)
    if checking == nil then break end

    P2 = P2 + 1
    if deck[checking].winner then 

        for i = deck[checking].card+1, deck[checking].card+#deck[checking].keepers do
            -- copy cards
            table.insert(toEval,i)
        end
    end
end

--print('deck end ',#deck)

print(string.format('Part 1 - Answer %d',P1)) -- 21959
print(string.format('Part 2 - Answer %d\n', P2)) -- 5132675

--P1 guesses 26988 21977