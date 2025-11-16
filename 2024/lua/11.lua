package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

-- local dfscache = {}
local function blink(n,l)
    -- local q = n
    -- while dfscache[q] and l < 25 do
    --     if type(dfscache[q]) == "table" then
    --         local a, b = table.unpack(dfscache[q])

    --     else
    --         q = dfscache[q]
    --     end
    --     l = l+1
    -- end
    if l == 25 then
        -- print("level 25 count number", n)
        P1 = P1 + 1
        return 1
    else
        if n == 0 then
            -- dfscache[0] = 1
            return blink(1,l+1)
        elseif math.floor(math.log(n,10)+1) % 2 == 0 then
            --split
            local nstr = tostring(n)
            local a,b = tobase10(nstr:sub(1,#nstr/2)), tobase10(nstr:sub((#nstr/2)+1,-1))
            return blink(a,l+1) + blink(b, l+1)
        else
            --explode
            local a = n*2024
            -- dfscache[n] = a
            return blink(a,l+1)
        end
    end
end

local mem = {}
local function blinkonce(n)
    if mem[n] and type(mem[n]) == "table" then
        return table.unpack(mem[n])
    elseif mem[n] then
        return mem[n]
    end
    if n == 0 then
        mem[0] = 1
        return 1
    elseif math.floor(math.log(n,10)+1) % 2 == 0 then
        local nstr = tostring(n)
        local a,b = tobase10(nstr:sub(1,#nstr/2)), tobase10(nstr:sub((#nstr/2)+1,-1))
        mem[n] = {a,b}
        return a,b
    else
        local a = n*2024
        mem[n] = a
        return a
    end
end

local seeds = aoc.intsFromLine(lines[1])
local satchel = {}

for k,v in pairs(seeds) do
    satchel[v] = (satchel[v] or 0) +1

    blink(v,0)
end

for i = 1, 75, 1 do
    -- print("round",i)
    -- if i == 1 then print(inspect(satchel)..'\n') end
    local upd = {}
    for k,v in pairs(satchel) do
        if v > 0 then
            satchel[k] = 0
            local a,b = blinkonce(k)
            upd[a] = (upd[a] or 0) + v
            if b ~= nil then
                upd[b] = (upd[b] or 0) + v
            end
        end
    end
    -- print('update',inspect(upd))
    for k,v in pairs(upd) do
        if v > 0 then
            satchel[k] = v
        end
    end
    -- print("")
    -- print('out\n'..inspect(satchel))
end

for _,v in pairs(satchel) do
    P2 = P2 + v
end


print('\n2024 Day Eleven')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
