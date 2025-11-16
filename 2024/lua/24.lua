package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
--local rex = require"rex_pcre2"
---@type Vec2D | v2call
local Vec2D = require "lib.vec2d"
local tuple = require "tuple"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local inf = 1/0
local wires = {}
local gates = {}
local bits = {}
local xbits = {}
local ybits = {}
 
-- sorted out manually
local swaps = {}
swaps["z33"] = "dqr"
swaps["z21"] = "shh"
swaps["vgs"] = "dtk"
swaps["z39"] = "pfw"

local function rev_swaps(swaps)
    local t = {}
    for k,v in pairs(swaps) do
       t[v] = k
    end
    return t
end
local swaps_rev = rev_swaps(swaps)

for k,v in pairs(lines) do
    if v:find(":") then
        local wire, state = v:match("(%w+): (%d)")
        wires[wire] = tobase10(state)
        if wire:sub(1,1) == "x" then
            xbits[tobase10(wire:match("(%d+)"))] = wire
        else
            ybits[tobase10(wire:match("(%d+)"))] = wire
        end
    elseif v ~= "" then
        local a, g, b, o = v:match("(%w+) (%w+) (%w+) .. (%w+)")
        --print(v)
        -- print(a,g,b,o)
        if swaps[o] then
            o = swaps[o]
        elseif swaps_rev[o] then
            o = swaps_rev[o]
        end

        wires[a] = wires[a] or inf
        wires[b] = wires[b] or inf
        wires[o] = wires[o] or inf
        
        table.insert(gates, {t=g,a=a,b=b,o=o})
        if o:sub(1,1) == "z" then
            local n = tobase10(o:match("(%d+)"))
            bits[n] = o
        end
    end
end

--print(inspect(bits))
for i=1,1000 do
    local done = true

    for j=1,#gates do
        local g =gates[j]
        if wires[g.a] ~= inf and wires[g.b] ~= inf then
            if g.t == "AND" then
                wires[g.o] = wires[g.a] & wires[g.b]
            elseif g.t == "OR" then
                wires[g.o] = wires[g.a] | wires[g.b]
            elseif g.t == "XOR" then
                wires[g.o] = wires[g.a] ~ wires[g.b]
            else
                assert(false)
            end
        end
    end

    for k=0,#bits+1 do
        --print("wat",k)
        if wires[bits[k]] == nil or (wires[bits[k]] == inf) then done = false break end
    end
    if done then print("runs", i) break end
end

local a = ""
for i=0,#bits do
    a = wires[bits[i]]..a
end
print(a,tonumber(a,2))


-- print("swaps",inspect(swaps))
-- print("swaps_rev",inspect(swapts_rev))
local function toBits(num,bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end

local correct_bits = "001100111111010010101101001000100101001010010"

local max_correct= 46
for i= 1,#bits do
    if wires[bits[i]] == correct_bits:sub(#correct_bits-i-1,#correct_bits-i-1) then
        max_correct = i
    end
end
print("lowest bit matching from msb -> lsb", max_correct)

local x, y,z = "","",""
for i= 0, 45 do
    x = (wires[xbits[i]] or "")..x
    y = (wires[ybits[i]] or "")..y
    z = wires[bits[i]]..z
end
print("x",tonumber(x,2),"+ y",tonumber(y,2),"=",tonumber(x,2)+tonumber(y,2))
print("z", table.concat(toBits(tonumber(x,2)+tonumber(y,2),45),''))
print(tonumber(table.concat(toBits(tonumber(x,2)+tonumber(y,2),45),''),2))

local allswaps = {}
for k,v in pairs(swaps) do
    table.insert(allswaps,k)
    table.insert(allswaps,v)
end
table.sort(allswaps,function(a,b) return a<b end)

print(table.concat(allswaps,","))


print('\n2024 Day Twenty Four')
print(string.format('Part 1 - Answer %s', P1)) --
print(string.format('Part 2 - Answer %s', P2)) --