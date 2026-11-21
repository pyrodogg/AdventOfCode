package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function getJoltage(digit)
    return tobase10(table.concat(digit,''))
end

local function findHighest(s,i,pos,stop,digit)

    local searchDigit = digit[i]
    local a = s:match("()"..searchDigit, (pos[i-1] or 0)+1)

    if a ~= nil and a <= stop[i] then
        pos[i] = a
        digit[i] = searchDigit
        if i == #pos then
            return pos, stop, digit
        else
            digit[i+1] = 9 -- restart? maybe searchDigit?
            return findHighest(s,i+1,pos,stop,digit)
        end
    else
        if searchDigit == 1 then
            return nil -- even 1 is out of range?, end
        else
            digit[i] = digit[i]-1
            return findHighest(s,i,pos,stop,digit)
        end
    end
end

local function reset(vSize, numDigits)
    local pos = {}
    local stop = {}
    local digit = {}

     for i=1,numDigits do
        pos[i] = i
        stop[i] = vSize-(numDigits-i)
        digit[i] = 9
    end

    return pos,stop,digit
end

for k,v in pairs(lines) do

    local pos, stop, digit = reset(#v, 2)
    pos, stop, digit = findHighest(v,1,pos,stop,digit)
 
    P1 = P1 + getJoltage(digit)

    pos, stop, digit = reset(#v, 12)
    pos, stop, digit = findHighest(v,1,pos,stop,digit)

    P2 = P2 + getJoltage(digit)
end

print('\n2025 Day Three')
print(string.format('Part 1 - Answer %s',P1)) -- 17085
print(string.format('Part 2 - Answer %d', P2)) -- 169408143086082
