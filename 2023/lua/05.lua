package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 999999999999, 0
local almanac = { seeds= {}, seedsP2={}}
local map_key = ''
for k,v in pairs(lines) do

    if v:find('seeds%:') then 
        --Part 1 seeds
        for i in v:gmatch('(%d+)') do
            table.insert(almanac.seeds, {seed=tonumber(i,10)})
        end
  
        --Part 2 seed ranges
        for i,j in v:gmatch('(%d+) (%d+)') do
            i,j = tonumber(i,10),tonumber(j,10)

            table.insert(almanac.seedsP2, {sL=i,sH=i+j-1,sR=j})
        end

    elseif v:match('(%w+) map') ~= nil then
        --New header
        map_key = v:match('(%w+) map')
    end

    if map_key ~= '' and v ~= '' then
        if almanac[map_key] == nil then almanac[map_key] = {} end

        local loc_data = unroll(v:gmatch('(%d+)'))
        if #loc_data > 0 then
            local d = tonumber(loc_data[1],10)
            local sL = tonumber(loc_data[2],10)
            local sR = tonumber(loc_data[3],10)
            
            table.insert(almanac[map_key],{d=d,dH=d+sR-1,sL=sL,sH=sL+sR-1,sR=sR})
        end
    end
end

function mapRange(source, rangeTable)
    for _, data in ipairs(rangeTable) do
        if source >= data.sL and source <= data.sH then
            -- map the rnage
            return data.d + (source - data.sL)
        end
    end
    return source
end

function mapRangeRev(dest, rangeTable)
    for _, data in ipairs(rangeTable) do
        if dest >= data.d and dest <= data.dH then
            -- map the rnage
            return data.sL + (dest - data.d)
        end
    end
    return dest
end

for _, seed in pairs(almanac.seeds) do    
    seed.soil = mapRange(seed.seed, almanac.soil)
    seed.fert = mapRange(seed.soil, almanac.fertilizer)
    seed.water = mapRange(seed.fert, almanac.water)
    seed.light = mapRange(seed.water, almanac.light)
    seed.temp = mapRange(seed.light, almanac.temperature)
    seed.humid = mapRange(seed.temp, almanac.humidity)
    seed.loc = mapRange(seed.humid, almanac.location)

    P1 = math.min(P1, seed.loc)
end

print("P2 start")
for i= 1,10000000 do
    local loc = { loc = i}
    loc.humid = mapRangeRev(loc.loc, almanac.location)
    loc.temp = mapRangeRev(loc.humid, almanac.humidity)
    loc.light = mapRangeRev(loc.temp, almanac.temperature)
    loc.water = mapRangeRev(loc.light, almanac.light)
    loc.fert = mapRangeRev(loc.water, almanac.water)
    loc.soil = mapRangeRev(loc.fert, almanac.fertilizer)
    loc.seed = mapRangeRev(loc.soil, almanac.soil)

    if i%100000 == 0 then
        print(i, print(inspect(loc)))
    end

    for k,v in pairs(almanac.seedsP2) do
        if loc.seed >= v.sL and loc.seed <= v.sH then
            P2 = i
            print("WINNER MF")
            print(inspect(loc))
            break
        end
    end

    if P2 > 0 then break end
end


print('\nDay Five')
print(string.format('Part 1 - Answer %d',P1)) -- 650599855
print(string.format('Part 2 - Answer %d', P2)) -- 1240035  (winning seed# 3454726063)
