package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local center
local function parsedata()
    local map = {}
    local cells = {}
    for k,v in pairs(lines) do
        map[k] = {}
        for i=1, #v do
            if v:sub(i,i) == "S" then
                -- if cells[k] == nil then cells[k] = {} end
                -- cells[k][i] = true
                center = {x=i, y=k}
                table.insert(cells,center)
                map[k][i] = "."
            else
                map[k][i] = v:sub(i,i)
            end
        end
    end
    return map, cells, #map[1], #map
end

local map, cells, width, height = parsedata()


local function mapcellat(x, y, allowoob)

    local allowoob = allowoob or false

    if allowoob == false then
        if 1 <= y and y <= height then
            return map[y][x] -- no meta translation (P1)
        else
            return nil
        end
    else
        -- Adjust x
        local adjustedx
        if  x > 0 then
            adjustedx = ((x-1) % width)+1
        else
            adjustedx = width+(x%-width)
        end
        
        local adjustedy
        if y > 0 then
            adjustedy = ((y-1) % height)+1
        else
            adjustedy = height+(y%(-height))
        end
        -- print("x,y", x, y, adjustedx, adjustedy)
        return map[adjustedy][adjustedx]
    end
end

local function spacesaftersteps(map, cells, steps, allowoob)
    local dupecheck
    for step = 1, steps do
        local newcells = {}
        dupecheck = {}

        while true do
            local cell = table.remove(cells)
            if cell == nil then break end

            --North
            if mapcellat(cell.x,cell.y-1,allowoob) == "." and (dupecheck[cell.y-1] == nil or dupecheck[cell.y-1][cell.x] == nil) then
                if dupecheck[cell.y-1] == nil then dupecheck[cell.y-1] = {} end

                dupecheck[cell.y-1][cell.x] = true
                table.insert(newcells,{x=cell.x, y=cell.y-1})
            end
            --South
            if mapcellat(cell.x,cell.y+1,allowoob) == "." and (dupecheck[cell.y+1] == nil or dupecheck[cell.y+1][cell.x] == nil) then
                if dupecheck[cell.y+1] == nil then dupecheck[cell.y+1] = {} end

                dupecheck[cell.y+1][cell.x] = true
                table.insert(newcells,{x=cell.x, y=cell.y+1})
            end
            --East
            if mapcellat(cell.x+1,cell.y,allowoob) == "." and (dupecheck[cell.y] == nil or dupecheck[cell.y][cell.x+1] == nil) then
                if dupecheck[cell.y] == nil then dupecheck[cell.y] = {} end

                dupecheck[cell.y][cell.x+1] = true
                table.insert(newcells,{x=cell.x+1, y=cell.y})
            end
            --West
            if mapcellat(cell.x-1,cell.y,allowoob) == "." and (dupecheck[cell.y] == nil or dupecheck[cell.y][cell.x-1] == nil) then
                if dupecheck[cell.y] == nil then dupecheck[cell.y] = {} end

                dupecheck[cell.y][cell.x-1] = true
                table.insert(newcells,{x=cell.x-1, y=cell.y})
            end
        end
        cells = newcells -- eval next generation
    end
    return #cells, dupecheck
end

local function writemapcells(cellmap, section)
    assert(section ~= nil, "section required")
    local f = assert(io.open("log/21/"..section..".txt","w"))
    local text = ""
    for y = 1, height do
        for x = 1, width do
            if cellmap[y] ~= nil and cellmap[y][x] ~= nil then
                text = text.."O"
            else
                text = text..map[y][x]
            end
        end
        text = text ..'\n'
    end
    f:write(text)
    f:close()
end

local cellmap
P1, cellmap = spacesaftersteps(map, cells, 64, false)
map, cells = parsedata()

-- how many cells in 'odd' cells like center? 7558 (center filled, corners empty)
-- how many cells in 'even' center cells? 7623 (center empty, coners filled)
-- how many cells in each corner (all unique)
-- how many cells in "3/4" and "1/4" edge tiles (odd/even) on each side?
    -- if "3/4" is odd, "1/4" is even, vice versa

local part2steps = 26501365
-- part2steps = (width*4)+65
local wingwidth = math.floor((part2steps-(width-1)/2)/width)-1
-- print(wingwidth)
local totalevencells = (wingwidth+1)^2 --(wingwidth- math.floor(wingwidth/2))*4
local totaloddcells = wingwidth^2--(math.floor(wingwidth/2))*4+1 -- +1 is center
print("interior odd cells", totaloddcells)
print("interior even cells", totalevencells)
local edge34tiles = wingwidth
local edge14tiles = (wingwidth+1)
print("edge 3/4", wingwidth*4)
print("edge 1/4", (wingwidth+1)*4)
if (wingwidth +1) %2 ==0 then
    --corner is odd
    -- edge 3/4s are odd
    -- edge 1/4s are even
    print("corner is odd")
else
    --corner is even
    -- edge 3/4s are even
    -- edge 1/4s are odd
    print("corner is even")
end

local function calcandrender(cells, spaces, section)

    local score, cellmap = spacesaftersteps(map, cells, spaces, false)
    writemapcells(cellmap, section)
    return score
end

cells = {center}
local interiorodd = calcandrender(cells, 129, "interiorodd")

cells = {center}
local interioreven = calcandrender(cells, 130, "interioreven")


cells = {{x=66,y=131}}
local topcorner = calcandrender(cells, 130, "corner-top")

cells = {{x=66,y=1}}
local bottomcorner = calcandrender(cells, 130, "corner-bottom")

cells = {{x=131,y=66}}
local leftcorner = calcandrender(cells, 130,"corner-left")

cells = {{x=1,y=66}}
local rightcorner = calcandrender(cells, 130, "corner-right")


cells={{x=1,y=1}}
local bottomright34 = calcandrender(cells,130+65, "bottomright34")

cells={{x=1,y=1}}
local bottomright14 = calcandrender(cells,64, "bottomright14")

cells={{x=131,y=1}}
local bottomleft34 = calcandrender(cells,130+65, "bottomleft34")

cells={{x=131,y=1}}
local bottomleft14 = calcandrender(cells, 64, "bottomleft14")

cells= {{x=1, y=131}}
local topright34 = calcandrender(cells, 130+65, "topright34")

cells={{x=1, y=131}}
local topright14 = calcandrender(cells, 64, "topright14")

cells={{x=131,y=131}}
local topleft34 = calcandrender(cells, 130+65, "topleft34")

cells={{x=131, y=131}}
local topleft14 = calcandrender(cells, 64, "topleft14")


-- cells= {{x=131,y=1}}
-- local bottomleft34, cellmap = spacesaftersteps(map, cells, 130+65, false)
-- -- print("bottomleft34", bottomleft34)
-- cells= {{x=131,y=1}}
-- local bottomleft14, cellmap = spacesaftersteps(map, cells, 64, false)

-- cells = {}
-- local topleft34, cellmap = spacesaftersteps(map, cells, 130+65)


P2 = (topcorner + bottomcorner + leftcorner + rightcorner) +
     (totalevencells * interioreven + totaloddcells * interiorodd) +
     (edge34tiles * bottomright34 + edge14tiles * bottomright14) +
     (edge34tiles * bottomleft34 + edge14tiles * bottomleft14) +
     (edge34tiles * topright34 + edge14tiles * topright14) +
     (edge34tiles * topleft34 + edge14tiles * topleft14)


-- writemapcells()

-- From center S fieldfiels in 129 steps for 7558 cells (or 130 steps for 7623 cells)


print('\nDay Twenty One')
print(string.format('Part 1 - Answer %s',P1)) -- 3729
print(string.format('Part 2 - Answer %d', P2)) -- 621289922886149


--[[
    P2
    12295565317  TOO LOW (forgot non-axis interior space)
]]