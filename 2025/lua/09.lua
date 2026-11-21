package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local points = {}
local x_min,x_max,y_min,y_max = math.huge,0,math.huge,0
for k,v in pairs(lines) do
    local a = aoc.intsFromLine(v)
    table.insert(points,{x=a[1],y=a[2]})
    x_min = math.min(x_min,a[1])
    y_min = math.min(y_min,a[2])
    x_max = math.max(x_max,a[1])
    y_max = math.max(y_max,a[2])
end

local rect = {}
for i=1, #points do
    for j=i+1, #points do

        local p1 = points[i]
        local p2 = points[j]

        local a = (math.abs(p2.x - p1.x) + 1)*(math.abs(p2.y - p1.y) + 1)
        table.insert(rect,{p1=p1,p2=p2,a=a})
        P1 = math.max(P1,a)
    end
end

table.sort(rect,function(a,b) return a.a < b.a end)

-- P2 BR go through largest rects and see if good?
-- I remember some kind of ray trace algo from prior years, toggle on walls

-- All rects either add to, overlap, or subtract from the total shape by the perimiter
-- for y
-- cast ray from left, state outside, toggle to inside on walls
-- also track for proposed rect and throw out mismatches

-- for i=1,#rect do
    
--     local p1 = rect[i].p1
--     local p2 = rect[i].p2

--     -- get test area from rect

--     -- for y=1,?? do
--     --     -- cat fireball
--     -- end


-- end

print(x_min,x_max,y_min,y_max)




-- print(inspect(points))

print('\n2025 Day Nine')
print(string.format('Part 1 - Answer %s',P1)) -- 4755064176
print(string.format('Part 2 - Answer %d', P2)) -- 
