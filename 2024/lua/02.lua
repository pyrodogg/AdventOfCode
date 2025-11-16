package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local reports = {}
for k,v in pairs(lines) do 
    table.insert(reports, map(unroll(v:gmatch("(%d+)")),tobase10))
end

local function compare(a,b)
    return a<b, b-a
end

function table.copy(t)
    local u = { }
    for k, v in pairs(t) do u[k] = v end
    return setmetatable(u, getmetatable(t))
  end

local function trendOK(v, p2, c)

    local trend
    for i = 1, #v-1, 1 do
        local comp  = v[i+1] - v[i]
       
        --local inc, d = compare(v[i],v[i+1])
        if trend  == nil then
            if comp > 0 and (comp >= 1 and comp <= 3) then
                trend = 1
            elseif comp < 0 and (comp <= -1 and comp >= -3) then
                trend = -1
            else
                if p2 and c == nil then
                    local n = table.copy(v)
                    table.remove(n,i+1)
                    local m = table.copy(v)
                    table.remove(m,i)

                    --print(inspect(v),inspect(m),inspect(n))

                    return trendOK(n,true,1) or trendOK(m, true, 1)
                    
                else
                    return false
                end
            end
        else
            if trend == 1 and comp >= 1 and comp <= 3 then
                --continue
            elseif trend == -1 and comp <= -1 and comp >= -3 then
                -- continue
            else
                if p2 and c == nil then
                    -- print(inspect(v))
                    local n = table.copy(v)
                    table.remove(n,i+1)
                    local m = table.copy(v)
                    table.remove(m,i)
                    local fu = table.copy(v)
                    table.remove(fu, i-1)

                    print(inspect(v),inspect(m),inspect(n))

                    -- print(inspect(n))
                    -- print(inspect(m))
                    -- assert(1==0)
                    return trendOK(n,true,1) or trendOK(m, true, 1) or trendOK(fu, true, 1)
                else
                    return false
                end
            end
        end
    end

    return true
end

print("# reports " .. #reports)

for k,v in pairs(reports) do

    local report = k.."  "
    if trendOK(v) then
        P1 = P1 + 1
        report  = report .. "P1"
    end

    if trendOK(v,true) then
        P2 = P2 + 1
        report = report .. "  P2"
    end

    print(report)

end

print('\n2024 Day Two')
print(string.format('Part 1 - Answer %s',P1)) -- 686
print(string.format('Part 2 - Answer %d', P2)) -- 717