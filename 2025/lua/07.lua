package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local grid = aoc.charGridFromLines(lines)

local W,H, oob = aoc.bounds(grid)
for y=1,H do
    for x=1,W do
       local c  = grid[y][x]
       if c == "|" or c == "S" then
            --propagate
            if not oob(x,y+1) then
                if grid[y+1][x] == "^" then
                    local bothclear = true
                    if grid[y+1][x+1] == "|" then
                        bothclear = false
                    end
                    grid[y+1][x+1] = "|"
                    grid[y+1][x-1] = "|"

                    if bothclear then
                        P1 = P1 + 1
                    end
                else
                    grid[y+1][x] = "|"
                end
            end
       end
    end
end

local function setWire(x,y,score)
    while grid[y] and grid[y][x] == "|" do
        grid[y][x] = score
        y = y-1
        P2 = math.max(P2,score)
    end
end

for y=H,1,-1 do
    -- "fold up"
    for x=1,W do
        local c = grid[y][x]
        if y==H and c=="|" then
            setWire(x,y,1)
        elseif c == "^" and grid[y-1][x] == "|" then
            setWire(x,y-1,grid[y][x-1]+grid[y][x+1])
        end
    end
end

-- print(aoc.renderGrid(grid))

print('\n2025 Day Seven')
print(string.format('Part 1 - Answer %s',P1)) -- 1638
print(string.format('Part 2 - Answer %d', P2)) -- 7759107121385
