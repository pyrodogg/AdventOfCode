package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function fastdiv(dividend, divisor)
    local quot, rem = 0,0
    rem = dividend - divisor
    while true do
        if rem < 0 then
            break
        end
        quot = quot + 1
        rem = rem - divisor
        if rem < 0 then break end
    end


    return quot, math.abs(rem+divisor)
end

local cache = {}

local function hash(s)
    
    local cv = 0
    for j = 1, #s do
        local char = s:sub(j,j)
        
        if cache[char] ~= nil then
        else
            cv = cv + string.byte(char)
            cv = cv * 17
            _, cv  = fastdiv(cv, 256)
        end
    end

    return cv
end

local box = {}
local mc = 1
local err
for s in lines[1]:gmatch("([^,]*),-") do

    P1 = P1 + hash(s)

    local label = s:match("(%w*)")
    local op = s:match("([%-%=])")
    local n = tobase10(s:match("(%d+)") or "0")

    local h = hash(label)

    --print(label, op, n)

    if box[h] == nil then 
        box[h] = {}
    end
    
    if op == "=" then
        local done
        for i=1, #box[h] do
            if box[h][i].l == label then
                --update power
                box[h][i].p = n
                done = true
            end
        end
        if done == nil then 
            table.insert(box[h],{l=label, p=n})
        end

    else
        -- remove
        local rindex = 0
        local r
        for bi, i in ipairs(box[h]) do
            if i.l == label then
                rindex = bi
                r = table.remove(box[h],rindex)
                break
            end
        end
    end

    --if mc >=10 then break end
    mc = mc + 1

    if err then break end
end

-- print(inspect(box))

for k,b in pairs(box) do

    for i,l in pairs(b) do
        --print(1+k, i, l.p, ((1+k) * i * l.p), l.l)

        P2 = P2 + ((1+k) * i * l.p)
    end
end


print('\nDay Twelve')
print(string.format('Part 1 - Answer %s',P1)) -- 514639
print(string.format('Part 2 - Answer %d', P2)) -- 279470
