package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local range = {}
local ingredients = {}

for k,v in pairs(lines) do
    local r = unroll(v:gmatch("(%d+)"))
    if r ~= nil then
        if #r == 2 then
            table.insert(range,{tobase10(r[1]),tobase10(r[2])})
        elseif #r == 1 then
            table.insert(ingredients,tobase10(r[1]))
        end
    end
end

--merge ranges
table.sort(range, function(a,b) return a[1] < b[1] end)
for i=#range-1,1,-1  do
    local ri = range[i]
    for j=#range,i+1,-1  do
        local rj = range[j]
        
        if ri[2] < rj[1] or ri[1] > rj[2] then
            --skip, no overlap
        else
            ri[1] = math.min(ri[1],rj[1])
            ri[2] = math.max(ri[2],rj[2])
            -- Process ranges from 'end' to 'start' so redundant ranges can be quickly removed
            -- Without changing the order or having to reindex things.
            table.remove(range,j)
        end
    end
end

for _, v in pairs(range) do
    if v[1] > 0 then
        for i=1,#ingredients do
            if ingredients[i] >= v[1] and ingredients[i] <= v[2] then
                P1 = P1 + 1
            end
        end
        P2 = P2 + v[2]-v[1]+1
    end
end

-- print(inspect(range))
-- print(inspect(ingredients))


print('\n2025 Day Five')
print(string.format('Part 1 - Answer %s',P1)) -- 744
print(string.format('Part 2 - Answer %d', P2)) -- 347468726696961
