package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local rex = require"rex_pcre2"


local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function idValid(id)
    id = tostring(id)

    local f = id:match('(%d*)%1')
    if f ~= "" and f ~= nil  then
        if #(''..f..f) == #id then
            --print('P1',f..''..f)
            P1 = P1 + tobase10(f..''..f)
            P2  = P2 + tobase10(f..''..f)
        else
            local searchset = ''
            for i = 1, #f do
                searchset = searchset .. '['..f:sub(i,i)..']'
            end
            local g = id:match('['..f..']+')
            local r = rex.new('((\\d+?)\\2+)')
            local e = r:match(id)
            if e ~= nil and #e == #id then
                --print('P2',id,e)
                P2 = P2 + e
            end
        end

        return tobase10(f..''..f)
    end
end

for k, v in pairs(lines) do
    local a = unroll(v:gmatch('(%d+)[-](%d+)[,]*'))
    for _, j in pairs(a) do
        --print(inspect(v))
        local firstID = tobase10(j[1])
        local lastID = tobase10(j[2])

        for x = firstID, lastID do
            _ = idValid(x)
        end

    --if k == 2 then break end
    end
end




print('\n2025 Day Two')
print(string.format('Part 1 - Answer %s',P1)) -- 55916882972
print(string.format('Part 2 - Answer %d', P2)) -- 76169125915
