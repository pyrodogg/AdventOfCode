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
local dir_vec = {Vec2D{0,-1},Vec2D{1,0},Vec2D{0,1},Vec2D{-1,0}}

local seeds = {}
for _,v in pairs(lines) do
    table.insert(seeds,aoc.intsFromLine(v)[1])
end

local cache = {}

local market = {}
local sequence = {}
local book = {}

for k,v in pairs(seeds) do
    local t
    -- v=123
    market[k] = market[k] or {[0]=v}
    sequence[k] = sequence[k] or {}
    local sold = {}

    for i=1,2000 do
        t = v<<6        -- mul 64
        v = v~t         -- mix (XOR)
        v = v&16777215  -- prune
        t = v>>5        -- div 32
        v = v~t         -- mix (XOR)
        v = v&16777215  -- prune
        t = v<<11       -- mul 2048
        v = v~t         -- mix (XOR)
        v = v&16777215  -- prune
        market[k][i] = v

        local r = v%10
        local s = market[k][i-1]

        sequence[k][i] = r-(s or 0)%10
        -- print(string.format("%d: %d (%d)",v,r,r-(s or 0)%10))

        if i >= 4 then
            local s = tuple(sequence[k][i-3],sequence[k][i-2],sequence[k][i-1],sequence[k][i])
            
            if not sold[s] then
                book[s] = (book[s] or 0) + r
                -- mark sequence as used for sequence-k (first come, first-serve)
                sold[s] = true
            end
        end
    end
    P1 = P1 + v
end

for _,v in pairs(book) do
    if v > P2 then
        P2 = v
    end
end

print('\n2024 Day Twenty Two')
print(string.format('Part 1 - Answer %s', P1)) --
print(string.format('Part 2 - Answer %s', P2)) --