package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"


local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
local deck = {}
-- Parse lines
for k,v in ipairs(lines) do

    local winners = {}
    local power = 0
    local foo = v:sub(9) -- skip game ID
    local delim = foo:find('%|')
    for i, j in foo:gmatch('()'..'([%d]+)'..'') do

        if i < delim then 
            winners[j] = j -- set for lookup
        else
            if winners[j] ~= nil then
                power = power + 1
            end
        end
    end

    if deck[k] == nil then deck[k] = {} end
    deck[k]["card"] = k
    deck[k]["copies"] = (deck[k]["copies"] or 0) + 1
    if power > 0 then 
        P1 = P1 + 2^(power-1)

        --Propegate copies
        for i = k+1, k+power do
            if deck[i] == nil then deck[i] = {} end
            deck[i].card = i
            deck[i].copies = (deck[i].copies or 0) + deck[k].copies
        end
    end

    P2 = P2 + deck[k]["copies"]
end

--Alt P2 calc
P3 = sumBy(deck,'copies')

print('\nDay Four')
print(string.format('Part 1 - Answer %d',P1)) -- 21959
print(string.format('Part 2 - Answer %d', P2)) -- 5132675
print(string.format('Part 2 - SumBy %d', P3))