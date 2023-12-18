package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local tuple = require "tuple"
local fun  = require "fun"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local map = {}
local start, goal
for k,v in pairs(lines) do
    map[k] = {}
    for i=1,#v do
        local node = {x=i, y=k, hloss= tobase10(v:sub(i,i))}
        map[k][i] = node
        --table.insert(mapList, {x=i, y=k, hloss=tobase10(v:sub(i,i))})
    end
end
local width, height = #map[1], #map

local function getneighborstuple(grid, pos, dir, minmove, maxmove)
    local minmove = minmove or 1

    local n = {}

    if dir == nil or dir == "u" or dir == "d" then
        for dx in fun.range(minmove, math.min(maxmove, width)) do

            if pos[1]-dx >= 1 then table.insert(n, tuple(pos[1]-dx, pos[2], "l")) end
            if pos[1]+dx <= width then table.insert(n, tuple(pos[1]+dx, pos[2], "r")) end
        end
    end

    if dir == nil or dir == "l" or dir == "r" then
        for dy in fun.range(minmove, math.min(maxmove, height)) do
         
            if pos[2]-dy >= 1 then table.insert(n, tuple(pos[1], pos[2]-dy,"u")) end
            if pos[2]+dy <= height then table.insert(n, tuple(pos[1], pos[2]+dy,"d")) end
        end
    end

    return n
end

local function astar(grid, start, goal, minmove, maxmove)

    local frontier = {} -- "Priority Queue" {score, {x,y,dir}}
    table.insert(frontier,{score=0, pointdir=start})

    local costsofar = {}
    local camefrom = {}
    costsofar[start] = 0
    camefrom[start] = 0/0
    

    while #frontier > 0 do

        table.sort(frontier, function(a,b)
            return a.score > b.score
        end)

        -- presents multiple paths to each node, 
        -- prioritize evaluating the ones with the lowest cost
        
        local scorepointdir = table.remove(frontier)
        local score, curpointdir = scorepointdir.score, scorepointdir.pointdir

        local current, dir = tuple(curpointdir[1],curpointdir[2]), curpointdir[3] or nil

        if current == goal then
            return score, costsofar, camefrom
        end

        for _, n in pairs(getneighborstuple(grid,current, dir, minmove, maxmove)) do
            
            --What are all of the possible moves from current?
            -- 1 right, 2 right, 3 right?
            -- Depends on the incoming direction and path length
            
            -- which dir?
            -- how long of a run?
            -- New cost to continue in dir 
            -- if travelling right on top of graph, after 3 moves the ONLY
            -- option is to go Down

            -- print(n)
            local cost = 0

            if n[3] == "u" then
                for y in fun.range(n[2],current[2]-1) do
                    --print("accumulate costs up", n[1], y)
                    cost = cost + grid[y][n[1]].hloss
                end
            elseif n[3] == "d" then
                for y in fun.range(current[2]+1,n[2]) do
                    --print("accumulate costs down", n[1], y)
                    cost = cost + grid[y][n[1]].hloss
                end
            elseif n[3] == "l" then
                for x in fun.range(n[1], current[1]-1) do
                    --print("accumulate cost left", x, n[2])
                    cost = cost + grid[n[2]][x].hloss
                end
            elseif n[3] == "r" then
                for x in fun.range(current[1]+1, n[1]) do
                    --print("accumulate costs right", x, n[2])
                    cost = cost + grid[n[2]][x].hloss
                end
            end
            -- print("cost",cost)

            local newscore = score + cost
            local inf = 1/0
            if newscore < (costsofar[n] or inf) then
                costsofar[n] = newscore
                camefrom[tuple(n[1],n[2])] = current
                table.insert(frontier,{score=newscore, pointdir=n})
            end

        end
    end

    assert(false, "failed to find path")
end

start = tuple(1,1, nil) --map[1][1]
goal = tuple(width,height) --map[height][width]
local costs, camefrom, costs2, camefrom2
P1, costs, camefrom = astar(map, start, goal, 1, 3)
P2, costs2, camefrom2 = astar(map,start,goal, 4,10)

-- print(inspect(costs, {depth=2}))

local function reconstructpath(camefrom, start, goal)
    local pathrev = {}
    local step = 1

    local current = camefrom[goal]

    while current ~= start do
        
        table.insert(pathrev, current)
        current = camefrom[current]
    end
    table.insert(pathrev,start)

    local path = {}
    for i= #pathrev, 1, -1 do
        table.insert(path,pathrev[i])
    end

    return path

end

-- local path = reconstructpath(camefrom, start, goal)

--print(inspect(path))

local function pathgridstring(path)
    local s = ""
    for y=1,height do
        for x=1, width do
            if map[y][x].path == true then
                s = s ..(map[y][x].indir or "#")
            else
                s = s .."."
            end
        end
        s = s .."\n"
    end
    return s
end

-- print(pathgridstring(path))

local function maptostring(map,key,format, pathonly)
    local key = key or "hloss"
    local format = format or "%s"
    local s = ""
    for y=1,#map do
        for x=1,#map[1] do
            if pathonly and map[y][x].path == true then
                s = s..string.format(format, map[y][x][key])

            elseif pathonly == nil then
                s = s..string.format(format, map[y][x][key])
            else
                s= s..string.format(format, ' ')
            end
        end
        s = s.."\n"
    end
    return s
end

-- print(maptostring(map))


print('\nDay Seventeen')
print(string.format('Part 1 - Answer %s',P1)) -- 1004
print(string.format('Part 2 - Answer %d', P2)) -- 1171
