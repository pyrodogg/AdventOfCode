package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from('../input/02.txt')
local P1, P2 = 0,0
local maxDie = {red=12, green=13, blue=14}

local function validateGame(s)

    local gameID = tonumber(s:match('Game (%d+)'))
    local s = s .. ','
    for k, v in s:gmatch('(%d+) (%w+)[,;]') do
        if (tonumber(k) > maxDie[v]) and maxDie[v] ~= nil then
            return 0
        end
    end
    return gameID
end

local function gamePower(s)

    local minDie = {red=0,green=0,blue=0}
    local s = s .. ','
    for roll, color in s:gmatch('(%d+) (%w+)[,;]') do

        minDie[color] = math.max(tonumber(roll,10), minDie[color])
    end
    return reduce(minDie,function(a,v) return a*v end, 1)
end

local function add(a,b) return a+b end
local function mult(a,b) return a*b end

local function gamePower2(s)
    local maxDice = reduce(unroll(s:gmatch('(%d+) (%w+)[,;]-')),
    function(a,v)
        -- v[roll, color]
        a[v[2]] = math.max(tonumber(v[1],10),a[v[2]])
        return a
    end,
    {red=0,green=0,blue=0})

    return reduce(maxDice, mult, 1)
end

-- local P3 = 0
-- for _, v in pairs(lines) do
--     P1 = P1 + validateGame(v)
--     P2 = P2 + gamePower(v)
--     P3 = P3 + gamePower2(v) -- reduce? ;)
-- end

P1, P2 = table.unpack(reduce(lines,
function(a,v) 
    return {a[1]+validateGame(v),a[2]+gamePower(v)}
end, {0,0}))

print('\nDay Two')
print(string.format('Part 1 - Answer %s', P1)) --2685
print(string.format('Part 2 - Answer %s', P2)) --83707
--print(string.format('Part 2b - "Functional" %s', P3)) -- should match P2
