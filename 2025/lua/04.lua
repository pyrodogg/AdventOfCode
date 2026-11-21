package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
require"lib.vec2d"
local aoc = require "lib.aoc"

local dir_tuples = {{x=0, y=-1},{x=1, y=0},{x=0, y=1},{x=-1, y=0},{x=-1, y=-1},{x=-1,y=1}, {x=1,y=-1},{x=1,y=1}}

local grid = {}
-- local kernel = {{1,1,1},{1,1,1},{1,1,1}}

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function renderGrid(grid)
    local out = ""
    local W, H = aoc.bounds(grid)
    for y=1,H,1 do
        for x=1,W,1 do
            out = out..(grid[y][x] or " ")
        end
        out = out.."\n"
    end
    return out
end

for k,v in pairs(lines) do
    grid[k] = grid[k] or {}
    for i=1,#v do
       grid[k][i] = v:sub(i,i)
    end
end

local function removeRolls(grid)
    local removed = 0
    local W, H, oob = aoc.bounds(grid)
    for y=1, H do
        for x=1,W do
            local n = 0
            if grid[y][x] == "@" then 
                for i=1, #dir_tuples do
                    local cx, cy  = x+dir_tuples[i].x, y+dir_tuples[i].y
                    
                    if oob(cx,cy) == false then
                        local c = grid[cy][cx] or "."
                        if c == "@" or c == "X" then
                            n = n +1
                        end
                    end
                end
                if n < 4 then
                    removed  = removed + 1
                    grid[y][x] = "X"
                end
            end
        end
    end

    for y=1, H do
        for x=1,W do
            if grid[y][x] == "X" then
                grid[y][x] = "."
            end
        end
    end
    return removed
end

P1 = removeRolls(grid)
P2 = P1

while true do
    local newP2 =  P2 + removeRolls(grid)
    if newP2 > P2 then
        P2 = newP2
    else
        print("done")
        break
    end
end
-- print(renderGrid(grid))


print('\n2025 Day Four')
print(string.format('Part 1 - Answer %s',P1)) -- 1397
print(string.format('Part 2 - Answer %d', P2)) -- 8758
