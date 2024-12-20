package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
--local rex = require"rex_pcre2"
---@type Vec2D | v2call
local Vec2D = require "lib.vec2d"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
local dir_vec = {Vec2D{0,-1},Vec2D{1,0},Vec2D{0,1},Vec2D{-1,0}}

local function parse_input(lines)
    local start, goal
    local maze = {}
   
    for k,v in pairs(lines) do
        maze[k] = maze[k] or {}
        for x=1,#v do
            maze[k][x] = v:sub(x,x)
            if maze[k][x] == "#" then

            elseif maze[k][x] == "S" then
                start = Vec2D{x=x,y=k}
            elseif maze[k][x] == "E" then
                goal = Vec2D{x=x,y=k}
            end
        end
    end
    return maze, start, goal
end

local function find_shortest_path(map,start,goal)

    local frontier = {} -- "Priority Queue" {score, {x,y,dir}}
    table.insert(frontier,{score=0, p=start})

    local W,H,oob = aoc.bounds(map)

    local costsofar = {}
    local camefrom = {}
    costsofar[start:toString()] = 0
    --camefrom[start:toString()] = 0/0
    
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
            if not oob(check_pos) and
               map[check_pos.y][check_pos.x] ~= "#" then

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

local function find_cheats_part1_og(maze,weights)
    -- {w:Vec2D,i:Vec2D,o:Vec2D,s:number}
    local cheats = 0
    local W,H,oob = aoc.bounds(maze)

    for y=1,H do
        for x=1,W do
            local pos = Vec2D(x,y)
            if maze[y][x] == "#" then
                if maze[y-1] and maze[y-1][x] and maze[y-1][x] ~= "#" and
                maze[y+1] and maze[y+1][x] and maze[y+1][x] ~= "#" then
                    local savings = math.abs(weights[x..","..(y-1)]-weights[x..","..(y+1)])-2
                    --string.format("%d,%d saving %d",x,y,savings)
                    if savings >= 100 then
                        cheats = cheats + 1
                        --table.insert(cheats,{w=Vec2D(x,y),s=savings})
                    end
                elseif maze[y][x-1] and maze[y][x-1] ~= "#" and
                    maze[y][x+1] and maze[y][x+1] ~= "#" then
                    local savings = math.abs(weights[(x-1)..","..y]-weights[(x+1)..","..y])-2
                    --string.format("%d,%d saving %d",x,y,savings)
                    if savings >= 100 then
                        cheats = cheats + 1
                        -- table.insert(cheats,{w=Vec2D(x,y),s=savings})
                    end
                end
            end
        end
    end

    return cheats
end

local function find_cheats(maze, weights,savings_min,dist_max)
    local W,H,oob = aoc.bounds(maze)

    --[[
    for every point (.) J compare to every point K that is below, or the the right of J
    and within 20
    ~~if valid (wall path <= 20) then add cheat~~  
    Having to actually path through blocks of wall was never part of the problem
    ]]
    local teleports = 0
    savings_min = savings_min or 100
    dist_max = dist_max or 20
    for y=2,H-1 do
        for x=2,W-1 do
            if maze[y][x] ~= "#" then
                for j = y, math.min(y+dist_max,H-1) do
                    local d_y = j-y
                    local x_start = j==y and x+2 or math.max(1,x-dist_max+(d_y))
                    for k = x_start, math.min(x+dist_max-(d_y),W-1) do
                        if maze[j][k] ~= "#" then
                            local dist = d_y+math.abs(k-x)
                            local savings = math.abs(weights[x..","..y]-weights[k..","..j])-dist
                            if dist <= dist_max and savings >= savings_min then
                                -- print("comparing",x..","..y,k..","..j,dist, savings)
                                --table.insert(teleports,{i=x..","..y,o=k..","..j,s=savings})
                                teleports = teleports + 1
                            end
                        end
                    end
                end
            end
            -- break
        end
        -- break
    end
    return teleports
end

local maze, start, goal = parse_input(lines)
local base_length, weights = find_shortest_path(maze,start,goal)
-- local cheats = find_cheats_part1_og(maze,weights)
--local example = find_cheats(maze,weights,50,2)
P1 = find_cheats(maze,weights,100,2)
P2 = find_cheats(maze,weights,100,20)

-- table.sort(teleports, function(a,b) return a.s>b.s end)
-- local cheat_sum= {}
-- for k,v in pairs(teleports) do
--     cheat_sum[v.s] = (cheat_sum[v.s] or 0) +1
   
-- end
-- print(base_length,#cheats,inspect(cheat_sum))

print('\n2024 Day Twenty')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %s', P2)) --
