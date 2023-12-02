require "util"
local lpeg = require "lpeg"


print('Day Two - Part 1')

local file = '../input/02.txt'
local lines = lines_from(file)

local accumulator = 0


local maxDie = {}
maxDie ["red"] = 12
maxDie["green"] = 13
maxDie["blue"] = 14

-- Game 99: 7 red, 6 green, 2 blue; 8 red; 16 green, 7 red, 4 blue
function validateGame(s)

    local valid_game = true
    --print ('')
    --print(s)
    local s = s .. ','
    for k, v in s:gmatch('(%d+) (%w+)[,;]') do
        -- print(k ..' ' ..v)
        if (tonumber(k) > maxDie[v]) and maxDie[v] ~= nil then 
            valid_game = false
            --print(valid_game)
            --print('too many ' ..v)
            break
        end

    end

    return valid_game
end



-- 12 red cubes, 13 green cubes, and 14 blue cubes
for k,v in pairs(lines) do
    --print(v)

    local gameID = tonumber(v:match('Game (%d+)'))
    --print(k ..v)

    if validateGame(v) then 
        --print ('Adding game ' ..gameID)
        accumulator = accumulator + gameID
    end 

    --if k > 10 then break end
end

print('Day Two - Part 1 - Answer')
print(accumulator) --2685

print('')
print('Day Two - Part 2')

function gamePower(s)

    local minimums = {}

    local s = s .. ','
    for k, v in s:gmatch('(%d+) (%w+)[,;]') do

        if minimums[v] == nil then
            minimums[v] = tonumber(k)
        else
            if tonumber(k) > minimums[v] then 
                minimums[v] = tonumber(k)
            end
        end
    end

    return minimums["red"] * minimums["green"] * minimums["blue"]
end

-- The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together. 
-- The power of the minimum set of cubes in game 1 is 48. In games 2-5 it was 12, 1560, 630, and 36, respectively. 
-- Adding up these five powers produces the sum 2286.

-- For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets?

accumulator = 0 -- reset accumulator
for k,v in pairs(lines) do
    --print(v)

    --local gameID = tonumber(v:match('Game (%d+)'))
    --print(k ..v)

    local score = gamePower(v)

    accumulator = accumulator + score

    --if k > 10 then break end
end


print('Day Two - Part 2 - Answer')
print(accumulator) --83707