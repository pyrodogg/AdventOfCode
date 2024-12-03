package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local lpeg = require "lpeg"
local re = require"re"


local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

-- local w = lpeg.C(lpeg.S("mul(")*lpeg.R("09")^1*lpeg.S","*lpeg.R"09"^1+lpeg.S")")

-- local b = lpeg.P{ "(" * ((1 - lpeg.S"()") + lpeg.V(1))^0 * ")" }

-- local Cp = lpeg.Cp()
-- function anywhere (p)
--   return (1 - lpeg.P(p))^0 * Cp * p * Cp
-- end

local mem = ""
for k,v in pairs(lines) do 
    mem = mem .. v
end

local enabled = true
local ops = {}
for p,a,b,c in mem:gmatch("()(%w+)[(](%d+),(%d+)[)]") do
    if a == "mul" then
        P1 = P1 + (tobase10(b)*tobase10(c))
        table.insert(ops,{p=p,o="mul",v=(tobase10(b)*tobase10(c))})
    end
end

for p, b, c in mem:gmatch("()([%w']+)[(][)]()") do
    if b == "don't" then
        table.insert(ops,{p=p,o="don't"})
    elseif b == "do" then
--        enabled = true
        table.insert(ops,{p=p,o="do"})
    end
   -- print(a,b,c)
end

local function pos(t,a,b)
    return t[a].p < t[b].p
end

for k, v in spairs(ops,pos) do
    
    if v.o == "don't" then
        enabled = false
    elseif v.o == "do" then
        enabled = true
    end
  
    if enabled and v.o == "mul" then
        P2 = P2 + v.v
    end

    --print(inspect(v))
end

print('\n2024 Day Three')
print(string.format('Part 1 - Answer %s',P1)) -- 
print(string.format('Part 2 - Answer %d', P2)) --