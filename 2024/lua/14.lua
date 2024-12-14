package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local W,H = 101, 103

local bots = {}
local function reset()
    bots = {}
    for k,v in pairs(lines) do
        local x,y,dx,dy = table.unpack(aoc.intsFromLine(v))

        table.insert(bots,{x=x,y=y,dx=dx,dy=dy,ox=x,oy=y})
    end
end

local function animate(steps)
    steps = steps or 1
    for k,v in pairs(bots) do 
        v.x = (v.x+steps*v.dx)%W
        v.y = (v.y+steps*v.dy)%H
    end
end

local function getQuad()
    local quad = {}
    for k,v in pairs(bots) do
        local H2 = (H-1)/2
        local W2 = (W-1)/2

        if v.x < W2 and v.y < H2 then
            --tl
            quad[1] = (quad[1] or 0) + 1
        elseif v.x > W2 and v.y < H2 then
            --tr
            -- print('q2',v.x,v.y)
            quad[2] = (quad[2] or 0) + 1
        elseif v.x > W2 and v.y > H2 then
            --br
            quad[3] = (quad[3] or 0) + 1

        elseif v.x < W2 and v.y > H2 then
            --bl
            quad[4] = (quad[4] or 0) + 1
        else
            --mid no count
        end
    end
    return quad
end

local function getPositions()
    local grid = {}
    for k,v in pairs(bots) do
        grid[v.y] = grid[v.y] or {}
        grid[v.y][v.x] = (grid[v.y][v.x] or 0) + 1
    end
    return grid
end

reset()
animate(100)
local quad = getQuad()
P1 = quad[1] * quad[2] * quad[3] * quad[4]

reset()
function sleep (a) 
    local sec = tonumber(os.clock() + a); 
    while (os.clock() < sec) do 
    end 
end

local headstart = 6750
animate(headstart)
for k=1,4,1 do

    animate()
    local grid = getPositions()

    local frame = ""
    for y=0,H-1,1 do
        for x=0,W-1,1 do
            frame = frame.. (grid[y] and grid[y][x] or " ")
        end
        frame =  frame .."\n"
    end

    print(string.format("After %d steps",k+headstart))
    print(frame)
    print(string.format("After %d steps",k+headstart))
    sleep(.2)
    
end

print('\n2024 Day Fourteen')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
