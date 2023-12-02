require "util"
local lpeg = require "lpeg"

print('Day Two')

local file = '../input/02.txt'
local lines = lines_from(file)

local accumulator = 0

local maxDie = {}
maxDie ["red"] = 12
maxDie["green"] = 13
maxDie["blue"] = 14

function validateGame(s)

    local valid_game = true

    local s = s .. ','
    for k, v in s:gmatch('(%d+) (%w+)[,;]') do
        if (tonumber(k) > maxDie[v]) and maxDie[v] ~= nil then 
            valid_game = false
            break
        end

    end

    return valid_game
end

for k,v in pairs(lines) do

    local gameID = tonumber(v:match('Game (%d+)'))

    if validateGame(v) then 
        accumulator = accumulator + gameID
    end 

end

--2685
print(string.format('Part 1 - Answer %d\n', accumulator))


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

accumulator = 0 -- reset accumulator
for k,v in pairs(lines) do

    local score = gamePower(v)

    accumulator = accumulator + score

end

--83707
print(string.format('Part 2 - Answer %d\n', accumulator))
