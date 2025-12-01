package.path = package.path .. ';../../?.lua'
require "util"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local pos = 50

-- 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3

for k, v in pairs(lines) do
    local dir, l = v:match("(%w)(%d+)")
    l = tonumber(l)
    if dir == "L" then
       if tonumber(l) > pos then P2 = P2 + ((l-pos-1)//100) + 1 end

        -- P2 Initial brute force
        -- for x=1, tonumber(l) do
        --     pos2 = (pos2 - 1) % 100
        --     if pos2 == 0 then P2 = P2 + 1 end
        -- end
        
        pos = ((pos - l) % 100)
    else
        if tonumber(l) > (99-pos) then P2 = P2 + ((l-(99-pos)+1)//100) + 1 end
        
        -- P2 Initial brute force
        -- for x=1, tonumber(l) do
        --     pos2 = (pos2 + 1) % 100
        --     if pos2 == 0 then P2 = P2 + 1 end
        -- end
        pos = ((pos + l) % 100)
    end
    if pos == 0 then P1 = P1 + 1 end
    --print(dir, l, pos, P1,P2)
    --if k > 10 then break end
end

print('\n2025 Day One')
print(string.format('Part 1 - Answer %s',P1)) -- 1031
print(string.format('Part 2 - Answer %d', P2)) -- 5831
