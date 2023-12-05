package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"


local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 999999999999, 0
local almanac = { seeds= {}, seedsP2={}}
local map_key = ''
for k,v in pairs(lines) do

    if v:find('seeds%:') then 
    
        for i in v:gmatch('(%d+)') do
            table.insert(almanac.seeds, {seed=tonumber(i,10)})
        end
  
        for i,j in v:gmatch('(%d+) (%d+)') do
            i,j = tonumber(i,10),tonumber(j,10)

            table.insert(almanac.seedsP2, {sL=i,sH=i+j-1,sR=j})
        end
        
    elseif v:find('soil map') then
        map_key = "soil"
    elseif v:find('fertilizer map') then
        map_key = 'fertilizer'
    elseif v:find('water map') then
        map_key = 'water'
    elseif v:find('light map') then
        map_key = 'light'
    elseif v:find('temperature map') then
        map_key = 'temperature'
    elseif v:find('humidity map') then
        map_key = 'humidity'
    elseif v:find('location map') then
        map_key = 'location'
    end

    if map_key ~= '' and v ~= '' then
        if almanac[map_key] == nil then almanac[map_key] = {} end

        local loc_data = unroll(v:gmatch('(%d+)'))
        if #loc_data > 0 then
            local d = tonumber(loc_data[1][1],10)
            local sL = tonumber(loc_data[2][1],10)
            local sR = tonumber(loc_data[3][1],10)
            --print(map_key, d, sL, sH)
            
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
    --break
end

--  for _, seedRange in pairs(almanac.seedsP2) do    

--      local low = seedRange.sL
--      local high = low + seedRange.sR

--      print(low,high)

--      for k = low,high do
      
--          local seed = {seed=k}
--          seed.soil = mapRange(seed.seed, almanac.soil)
--          seed.fert = mapRange(seed.soil, almanac.fertilizer)
--          seed.water = mapRange(seed.fert, almanac.water)
--          seed.light = mapRange(seed.water, almanac.light)
--          seed.temp = mapRange(seed.light, almanac.temperature)
--          seed.humid = mapRange(seed.temp, almanac.humidity)
--          seed.loc = mapRange(seed.humid, almanac.location)
--          P2 = math.min(P2, seed.loc)
--      end
--      print('Current P2', P2)
--  end

--print(inspect(almanac.location))
local minLoc = minBy(almanac.location,'d')
--print('minilock',inspect(minLoc))

local wat = {}
function getRangeInfo(t,cL, cH)
    local rL, rH 
    print('searching',cL, cH)
    for k, v in pairs(t) do
        print('fuck',inspect(v))
        if ((v.d+v.sR) >= cL 
        and (v.d+v.sR) <= cH) or 
        (v.d >= cL and v.d <= cH) then
            
            print('f',inspect(v))
            rL = v.sL
            rH = v.sH
        end

    end

    return rL, rH
end

-- local humidL, humidH = getRangeInfo(almanac.humidity,
--                                     minLoc.d,
--                                     minLoc.d+minLoc.sR)
-- local tempL, tempH = getRangeInfo(almanac.temperature,
--                                     humidL,
--                                     humidH)



--print(inspect(almanac.seeds))


print('\nDay Five')
print(string.format('Part 1 - Answer %d',P1)) -- 650599855
print(string.format('Part 2 - Answer %d', P2)) -- 1240035

--[[ WRONG GUESSES
601583464 - too low

P2
60175491 --to high

]]
