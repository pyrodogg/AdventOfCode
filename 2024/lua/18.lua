package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
require"lib.grid2d"
-- ---@type Vec2D | v2call
local Vec2D = require "lib.vec2d"
local tuple = require "tuple"
local binaryheap = require 'binaryheap'

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
local dir_vec = {Vec2D{0,-1},Vec2D{1,0},Vec2D{0,1},Vec2D{-1,0}}


local bytes = {}
local map

for k,v in pairs(lines) do
    local x, y = table.unpack(aoc.intsFromLine(v))
    table.insert(bytes,Vec2D(x,y))
end

local function newMap()
    local m = {}
    for y = 0,70 do
        m[y] = {}
    end
    return m
end

local function corruptMap(map,from,to)
    for i =from, to do
        --corrupt map 
        local b = bytes[i]
        map[b.y][b.x] = "#"
    end
    return map
end

local function render_map(map)
    local out = ""
    for y=0,70 do
        for x=0,70 do
            if map[y][x] == "#" then
                out = out .."#"
            else
                out = out.."."
            end
        end
        out = out .."\n"
    end
    return out
end

local function find_shortest_path(map,start,goal)

    local frontier = {} -- "Priority Queue" {score, {x,y,dir}}
    table.insert(frontier,{score=0, p=start})

    local costsofar = {}
    local camefrom = {}
    costsofar[start:toString()] = 0
    camefrom[start:toString()] = 0/0
    
    while #frontier > 0 do

        table.sort(frontier, function(a,b)
            return a.score > b.score
        end)

        -- presents multiple paths to each node, 
        -- prioritize evaluating the ones with the lowest cost
        
        local scorepointdir = table.remove(frontier)
        local score, current = scorepointdir.score, scorepointdir.p

        -- print(current)

        if current == goal then
            return score, costsofar, camefrom
        end

        for _, n in pairs(dir_vec) do
            
            local check_pos = current + n
            --print(current,check_pos,type)
            if check_pos.y >= 0 and check_pos.y <= 70 and
               check_pos.x >= 0 and check_pos.x <= 70 and
               map[check_pos.y][check_pos.x] == nil then

                --print(n)
                local cost = 1

                local newscore = score + cost
                local inf = 1/0
                if newscore < (costsofar[check_pos:toString()] or inf) then
                    costsofar[check_pos:toString()] = newscore
                    camefrom[check_pos:toString()] = current:toString()
                    table.insert(frontier,{score=newscore, p=check_pos})
                end
            else
                --oob
            end
        end
    end

    return false --assert(false, "failed to find path")
end

local function dijkstra(map, start, goal)
    --local q = binaryheap.minUnique()

    local dist = {}
    local prev = {}
    dist[start:toString()] = 0
    --q:insert(0,start:toString())
    local q = {{s=0,p=start:toString()}}

    -- print(inspect(q))

    -- for y=0,70 do
    --     for x=0,70 do
    --         if x ==0 and y==0 then break end
    --         if map[y][x] ~= "#" then
    --             dist[x..","..y] = math.huge
    --             --q:insert(math.huge,x..","..y)
    --             table.insert(q,{s=math.huge,p=x..","..y})
    --         end
    --     end
    -- end

    -- print(inspect(q))
    table.sort(q, function(a,b) return a.s < b.s end)

    while #q do

        local u = table.remove(q,1)

        for i=1,4 do
            local v = Vec2D(u) + dir_vec[i]
            local v_str = v:toString()

            if v.y >= 0 and v.y <= 70 and v.x >= 0 and v.x <= 70 and
            map[v.y][v.x] ~= "#" then

                -- print(u)
                local alt = (dist[u] or 0) + 1
                if alt < (dist[v_str] or math.huge) then
                    prev[v_str] = u
                    dist[v_str] = alt
          
                    -- q:update(v_str,alt)
                    
                end
            end
        end
    end
    return dist, prev
end

local function part1()
    map = newMap()
    map = corruptMap(map,1,1024)
    --print(render_map(map))

    local start, goal = Vec2D(0,0), Vec2D(70,70)

    local dist, costsofar, prev = find_shortest_path(map, start, goal)

    return dist
end

P1 = part1()

local function part2() --brtfs

    map = newMap()
    map = corruptMap(map,1,1024)
    for i = 1024,#bytes do

        print("test",i)
        map = corruptMap(map,i,i)
        --print(render_map(map))

        local start, goal = Vec2D(0,0), Vec2D(70,70)

        local dist, costsofar, prev = find_shortest_path(map, start, goal)

        if dist == false then
            return bytes[i]:toString()
        end
    end
end

P2 = part2()

-- print(inspect(map))
-- print(inspect(bytes))


print('\n2024 Day Eighteen')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %s', P2)) --
