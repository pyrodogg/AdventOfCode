package.path = package.path .. ';../../?.lua'
require "util"



local lines = lines_from('../input/03.txt')
local gears = {}
local P1, P2 = 0, 0

local function checkSymbols(k, i, j)

    local h_off = i
    if h_off > 1 then h_off = h_off -1 end

    -- check line
    local s = lines[k]:sub(i-1,i+#j)
    if s:match('[^.%d]') then
        P1 = P1 + tonumber(j)
    end

    for gi in s:gmatch('()'..'[*]'..'') do 
        -- for all adjacent gears
        if gears[k][h_off+gi-1] == nil then gears[k][h_off+gi-1] = {} end
        table.insert(gears[k][h_off+gi-1],tonumber(j))
    end
end

for k,v in pairs(lines) do
    if gears[k] == nil then gears[k] = {} end
    if gears[k+1] == nil then gears[k+1] = {} end

    --Iter numbers
    for i, j in v:gmatch('()'..'(%d+)'..'') do

        if k > 1 then checkSymbols(k-1, i, j) end

        checkSymbols(k, i, j)

        if k < #lines then checkSymbols(k+1, i, j) end
    end
end

for k in pairs(gears) do
    for i in pairs(gears[k]) do
        if #gears[k][i] == 2 then
            P2 = P2 + (gears[k][i][1] * gears[k][i][2])
        end
    end
end

print('\nDay Three')
print(string.format('Part 1 - Answer %d',P1)) -- 556367
print(string.format('Part 2 - Answer %d', P2)) --89471771
