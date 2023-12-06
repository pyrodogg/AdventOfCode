package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 1, 0

local races = {}
local raceP2 = {}
for k,v in pairs(lines) do

    local race = 1
    if v:find('Time') then
        for i in v:gmatch('(%d+)') do
            if races[race] == nil then races[race] = {} end
            races[race].time = tonumber(i,10)    
            race = race +1    
        end
        raceP2.time = tonumber(string.gsub(v:match('([%d ]+)'),' ',''),10)
    elseif v:find('Distance') then
        for i in v:gmatch('(%d+)') do
            if races[race] == nil then races[race] = {} end
            races[race].distance = tonumber(i,10)    
            race = race +1    
        end
        raceP2.distance = tonumber(string.gsub(v:match('([%d ]+)'),' ',''),10)
    end
end

function quadDiff(D,T)

    local low = math.ceil((-T + math.sqrt(T^2 - 4*D)) / -2)
    local high = math.ceil((-T - math.sqrt(T^2 - 4*D)) / -2)
    return high - low
end

for k, race in pairs(races) do 

    -- -- min, max, difference <-- mathy solution
    -- -- target is distance, budget is time
    -- -- (time-hold)*(hold) = distance
    P1 = P1 * quadDiff(race.distance, race.time)
end

-- Part 2 (Mathy)
-- Mathy idea - How many points on a curve lie above a threshold line?
P2 = quadDiff(raceP2.distance,raceP2.time)

-- PART 2 (Brute force)
-- Buuut, Brute YAY (took a while, didn't time it) kill when P2 stops changing
-- for h = 1, raceP2.time do
--     if h % 10000000 then print(h, P2) end
--     local attempt = (raceP2.time - h) * h

--     if attempt > raceP2.distance then 
--         P2 = P2 +1
--     end
-- end

print('\nDay Six')
print(string.format('Part 1 - Answer %d',P1)) -- 3316275
print(string.format('Part 2 - Answer %d', P2)) -- 27102791
