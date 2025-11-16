package.path = package.path .. ';../../?.lua'
require "util"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

-- 2024 Advent of Code Puzzle 1

local left, right = {}, {}

for k, v in pairs(lines) do
    for l,r in v:gmatch('(%d+)   (%d+)') do
        --print(l, r)
        table.insert(left,tonumber(l))
        table.insert(right,tonumber(r))
    end
end

table.sort(left)
table.sort(right)

for k,v in pairs(left) do
    P1 = P1 + math.abs(v - right[k])
end

local function numMatches(list, m)
    local count = 0 
    for k,v in pairs(list) do
        if v == m then 
         count = count +1 
        end
    end
    return count 
end

for k,v in pairs(left) do 
    P2 = P2 + (v * numMatches(right,v))
end



print('\n2024 Day One')
print(string.format('Part 1 - Answer %s',P1)) -- 1151792
print(string.format('Part 2 - Answer %d', P2)) -- 21790168