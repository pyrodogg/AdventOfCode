package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local grid = {}
for k,v in pairs(lines) do
    local r = map(unroll(v:gmatch("(%d+)")),tobase10)
    if #r == 0 then
        r = unroll(v:gmatch("([^ ])"))
    end
   
    for i=1,#r do
        grid[k] = grid[k] or {}
        grid[k][i] = r[i]
    end
end

local W, H, oob = aoc.bounds(grid)
for x=1,W do
    local a
    for y=1,H-1 do
        if grid[H][x] == "*" then
            a = a or 1
            a = a * grid[y][x]
        else
            a = a or 0
            a = a + grid[y][x]
        end
    end
    P1 = P1 + a
end

local function transpose(i)

    local o = {}
    for x= #i[1], 1, -1 do
        local b = #i[1]-x+1
        o[b] = o[b] or ""
        for y= 1,#i do
            o[b] = o[b]..i[y]:sub(x,x)
        end
    end
    return o
end

local tlines = transpose(lines)

local s = {}
for k,v in pairs(tlines) do
    local n = v:match("(%d+)")
    local plus = v:match("[+]")
    local mul = v:match("[*]")

    if v == "" or v == "    " then
    else
        table.insert(s,n)
        if plus then
            -- print(inspect(s))
            P2 = P2 + s[1] + (s[2] or 0) + (s[3] or 0) + (s[4] or 0)
            s = {}
        elseif mul then
            -- print(k,inspect(s))
            P2 = P2 + (s[1] * (s[2] or 1) * (s[3] or 1) * (s[4] or 1))
            s = {}
        end
    end
end

-- print(inspect(grid))
-- print(inspect())

print('\n2025 Day Six')
print(string.format('Part 1 - Answer %s',P1)) -- 8108520669952
print(string.format('Part 2 - Answer %d', P2)) -- 11708563470209
