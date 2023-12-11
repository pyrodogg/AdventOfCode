package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

-- Parse
-- Expand
-- Pairs
-- Travelling salesman??

local space = {}
local spacerow = 1
local galaxy_col = {}
local galaxy_row = {}
for k, v in pairs(lines) do
    space[spacerow] = unroll(v:gmatch("(.)"))
    
    for i,j in v:gmatch("()([%#])") do
        galaxy_col[i] = true
        galaxy_row[spacerow] = true
    end
    spacerow = spacerow + 1
    
end

local galaxy = {}
for y = 1, #space do
    for x = 1, #space[1] do
        if space[y][x] == '#' then
            table.insert(galaxy,{x=x, y=y})
        end
    end
end

local function warpdist(a,b,cost)
    --distinct left/right, up/down moves
    -- to get from a ONTO b
    local empty_rows = 0
    local empty_cols = 0
    for i = math.min(a.x,b.x), math.max(a.x,b.x) do
        if galaxy_col[i] == nil then
            empty_cols = empty_cols + 1
        end
    end
    for y = math.min(a.y,b.y), math.max(a.y, b.y) do
        if galaxy_row[y] == nil then
            empty_rows = empty_rows  + 1
        end
    end
    local dist = math.abs(b.y - a.y) + math.abs(b.x - a.x) 
    dist = dist - empty_cols + empty_cols * cost
    dist = dist - empty_rows + empty_rows * cost

    return dist
end

for i = 1, #galaxy do 
    for j = i+1, #galaxy do
        P1 = P1 + warpdist(galaxy[i], galaxy[j], 2)
        P2 = P2 + warpdist(galaxy[i], galaxy[j], 1000000)
    end
end

--[[
    This was the naive solution, but not helps on part 2
    go back to initial array and add 'costs' to each step
    don't actually 'expand space'
    every vertical shift ONTO an empty ROW incurs extra cost
    every horizonal shift ONTO an empty COL incurs extra cost
    moves onto cell in both empty ROW AND COL inclurs exracost*2
    A* - find shortest path? No longer an obvious straight line

    Didn't even have to implement A*, 'straight' lines were still optimal
]]

print('\nDay Eleven')
print(string.format('Part 1 - Answer %d',P1)) -- 10276166
print(string.format('Part 2 - Answer %d', P2)) -- 598693078798
