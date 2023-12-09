package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
-- local lines = lines_from("../input/09-test.txt")

local P1, P2 = 0, 0

for k,v in pairs(lines) do

    local seq = {}
    seq[1] = map(unroll(v:gmatch("([-]*%d+)")),tobase10)
    local reduce = true

    local level = 2
    while reduce do 
        local allzero = true
        seq[level] = {}
        for k= 1, #seq[level-1] - 1 do
            
            local diff = seq[level-1][k+1] - seq[level-1][k]
            if diff ~= 0 then allzero = false end
            table.insert(seq[level], diff)
        end
        level = level  +1
        if allzero then break end
    end

    -- print()
    -- print(inspect(seq))

    local lastdiff = 0
    for k = #seq, 1, -1 do 
        local newdiff = 0
        if k == #seq then 
            newdiff = 0
        else
            newdiff = seq[k][#seq[k]] + lastdiff
        end
        if k == 1 then
            P1 = P1 + newdiff
        end 
        lastdiff = newdiff
        table.insert(seq[k],newdiff)

    end
    -- print('new')
    -- print(inspect(seq))
    
    --break
end

-- Part 2

for k,v in pairs(lines) do
    
    local seq = {}
    seq[1] = map(unroll(v:gmatch("([-]*%d+)")),tobase10)
    local reduce = true

    local level = 2
    while reduce do 
        local allzero = true
        seq[level] = {}
        for k= 1, #seq[level-1] - 1 do
            
            local diff = seq[level-1][k+1] - seq[level-1][k]
            if diff ~= 0 then allzero = false end
            table.insert(seq[level], diff)
        end
        level = level  +1
        if allzero then break end
    end

    -- print()
    -- print(inspect(seq))

    local lastdiff = 0
    for k = #seq, 1, -1 do 
        local newdiff = 0
        if k == #seq then 
            newdiff = 0
        else
            newdiff = seq[k][1] - lastdiff
        end
        if k == 1 then
            P2 = P2 + newdiff
        end 
        lastdiff = newdiff
        table.insert(seq[k],1,newdiff)

    end
    -- print('new')
    -- print(inspect(seq))
    
    --break

end

print('\nDay Nine')
print(string.format('Part 1 - Answer %d',P1)) -- 1921197370
print(string.format('Part 2 - Answer %d', P2)) -- 1124

