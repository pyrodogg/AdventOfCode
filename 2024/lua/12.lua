
package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local W, H, oob = aoc.bounds(lines)

local grid = {}
local regions = {}
local regionid = 1

for k,v in pairs(lines) do
    grid[k] = grid[k] or {}

    for i = 1, #v, 1 do
        if grid[k][i] == nil then

            local t = v:sub(i,i)
            local p = 4 -- perimiter
            local adj = {}
            local pr = nil
            local sides = {}
            if k > 1 and lines[k-1]:sub(i,i) == t then
                p = p - 1
                pr = grid[k-1][i].r
            else
                sides[1] = true
            end
            if k < H and
                lines[k+1]:sub(i,i) == t then
                p = p - 1
            else
                sides[3] = true
            end
            if i > 1 and v:sub(i-1,i-1) == t then
                p = p-1
                if pr == nil then
                    pr = grid[k][i-1].r
                end
            else
                sides[4] = true
            end
            if i < W and v:sub(i+1,i+1) == t then
                p = p - 1 
            else
                sides[2] = true
            end
            
            -- print(k,i,t,r,p)

            grid[k][i] = {t=t, p=p, sides=sides}

        end
    end
end


local dir_tuples = {{x=0, y=-1},{x=1, y=0},{x=0, y=1},{x=-1, y=0}}
local function floodSetRegion(x,y,r)

    --if set, stop
    --for neighbors, floodSet
    if grid[y][x].r == r then
        return
    else
        grid[y][x].r = r
        regions[r] = regions[r] or {a=0,p=0,r=r,t=grid[y][x].t,s={[1]={},[2]={},[3]={},[4]={}}}
        regions[r].p = regions[r].p + grid[y][x].p
        regions[r].a = regions[r].a + 1
        for i=1,4,1 do
            if grid[y][x].sides[i] then
                table.insert(regions[r].s[i],{x=x,y=y})
            end
        end
        for i =1 ,4 do
            local d = dir_tuples[i]
            if not oob(x+d.x,y+d.y) then
                if grid[y][x].t == grid[y+d.y][x+d.x].t then
                    floodSetRegion(x+d.x,y+d.y,r)
                end
            end
        end
    end
end

for y = 1, H, 1 do
    for x = 1, W, 1 do

        local r = grid[y][x].r
        if r == nil then
            r = regionid
            regionid = regionid + 1
        end
        floodSetRegion(x,y,r)
    end
end

local function filterAndSort(s,x,y)
    local r = {}
    if x == nil then
        for i=1,#s,1 do
           if s[i].y == y then
            table.insert(r,s[i])
           end
        end
        table.sort(r, function(a,b)
            return a.x < b.x
        end)
    else
        for i=1,#s,1 do
            if s[i].x == x then
                table.insert(r,s[i])
            end
        end
        table.sort(r,function(a,b)
            return a.y < b.y 
        end)
    end
    return r
end

for k,v in pairs(regions) do
    -- print(v.r,v.t ,v.a,v.p)
    P1 = P1 + v.a*v.p

    local sides = 0

    local top = v.s[1]
    local right = v.s[2]
    local bottom = v.s[3]
    local left = v.s[4]

    for y=1,H,1 do
        local topY = filterAndSort(top,nil,y)
        if topY and #topY > 0 then
            sides = sides + 1
            for j = 1, #topY-1, 1 do
                if topY[j].x+1 ~= topY[j+1].x then
                    -- print(y, inspect(topY))
                    sides = sides + 1
                end
            end
        end
        
        local bottomY = filterAndSort(bottom, nil,y)
        if bottomY and #bottomY > 0 then
            sides = sides + 1
            for j = 1, #bottomY-1, 1 do
                if bottomY[j].x+1 ~= bottomY[j+1].x then
                    sides = sides + 1
                end
            end
        end
    end

    for x = 1, W, 1 do
        local leftX = filterAndSort(left,x,nil)
        if leftX and #leftX > 0 then
            sides = sides + 1
            for j = 1, #leftX-1,1 do
                if leftX[j].y+1 ~= leftX[j+1].y then
                    sides = sides +1
                end
            end
        end
        
        local rightX = filterAndSort(right,x,nil)
        if rightX and #rightX > 0 then
            sides = sides + 1
            for j =1, #rightX-1, 1 do
                if rightX[j].y+1 ~= rightX[j+1].y then
                    sides = sides + 1
                end
            end
        end
    end

    -- print(k,v.t,v.a,sides)

    P2 = P2 + v.a*sides

end

-- print(inspect(grid))
-- print(regions[1].t)
-- print(inspect(regions[1].s[1]))


print('\n2024 Day Twelve')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
