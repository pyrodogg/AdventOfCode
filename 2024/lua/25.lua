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

local locks = {}
local keys = {}
local mode = ""
local counts = {}
for k,v in pairs(lines) do

    if v == "....." and (k%8)==1 then
        -- key
        mode = "key"
    elseif v == "#####" and (k%8)==1 then
        mode = "lock"
    elseif (k%8) < 7 then
        
        for i=1,5 do
            counts[i] = counts[i] or 0
            if v:sub(i,i) == "#" then
                counts[i] = counts[i] + 1
            end
        end
    elseif (k%8) == 7 then
         --commit key/lock
         if mode == "key" then
            --table.insert(keys,table.shallow_copy(counts))
            keys[k] = table.shallow_copy(counts)
            counts = {}
        else
            --table.insert(locks,table.shallow_copy(counts))
            locks[k] = table.shallow_copy(counts)
            counts = {}
        end
    end
end

local count = 0
for kl,l in pairs(locks) do
    for kk, k in pairs(keys) do
        local pair_fits = true
        print()
        print(string.format("Testing key %d against lock %d",kk,kl))
        print("lock",inspect(l))
        print("key",inspect(k))
        for i = 1,5 do
            if l[i]+k[i] > 5 then
                pair_fits = false
                print("","  "..string.rep("   ",i-1).."^")
                break
            end
        end
        if pair_fits then
            P1 = P1 + 1
            print("OK")
        end
        -- break
        count = count +1
        --if count > 30 then break end
    end
   -- break
end


print('\n2024 Day Twenty Five')
print(string.format('Part 1 - Answer %s', P1)) --
print(string.format('Part 2 - Answer %s', P2)) --

--[[
3095 too low
]]