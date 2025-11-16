package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
---@alias v2call fun(x:number|table, y:number?): Vec2D
---@type Vec2D | v2call
local Vec2D = require "lib.vec2d"
local tuple = require "tuple"
local binaryheap = require 'binaryheap'

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local dir_vec = {Vec2D{0,-1},Vec2D{1,0},Vec2D{0,1},Vec2D{-1,0}}

local maze = {}
local deer
local start
local target = {}

local function parseInput()

    local maze = {}
    for k,v in pairs(lines) do
        maze[k] = maze[k] or {}
        for i=1,#v,1 do
            local char = v:sub(i,i)
            maze[k][i] = char
            if char == "S" then
                start = {p=Vec2D{x=i,y=k},f=2} --east
                -- deer = table.shallow_copy(start)
            elseif char =="E" then
                target = Vec2D{x=i,y=k}
            elseif char == "." then

            end
        end
    end
    return maze
end

local function writemaze(maze,slug)
    local text = ""
    local W,H = aoc.bounds(maze)

    for y=1,H,1 do
       text = text..table.concat(maze[y],"").."\n"
    end

    aoc.logfile("16-maze"..slug,text)
end

local function prune_maze(maze)
    local W,H = aoc.bounds(maze)
    local loop = true
    while loop do
        loop = false
        for y=1,H,1 do
            for x=1,W,1 do
                if maze[y][x] =="." then
                    local n = 0
                    if y > 1 and string.find(maze[y-1][x],"[.SE]") then n = n +1 end
                    if x > 1 and string.find(maze[y][x-1],"[.SE]") then n = n+1 end
                    if y < H and string.find(maze[y+1][x],"[.SE]") then n = n+1 end
                    if x < W and string.find(maze[y][x+1],"[.SE]") then n = n+1 end
                    if n < 2 then
                        maze[y][x] = "#"
                        loop = true
                    end
                end
            end
        end
    end
end

local function getEdge(g, v, w)
    local adj = g:adj(v)
    for i=0, adj:size()-1 do
        local e = adj:get(i)
        if e:other(v) == w then
            return e
        end
    end
end

local function bfs(maze,start,goal,part2)
    local g = require('luagraphs.data.graph').create(0, true)
    part2 = part2 or false

    local heads = {{p=start.p:copy(),al=0,l=0,f=start.f,s="start",tc=0,rt={}}}

    local theroute

    while #heads > 0 do

        table.sort(heads,function(a,b) return a.tc > b.tc end)
        
        local h = table.remove(heads)
        if h == nil then break end

        local loc = h.p:toString()
        --local lof = loc..","..h.f
        local herealready = false
        local possiblemoves = {}
        local junctiontest = 0
        for i=1,4,1 do
            ---@type Vec2D
            local check_pos = h.p+dir_vec[i]
            --! exclude backtrack
            -- print("a", h.p,check_pos,dir_vec[i])
            if maze[check_pos.y][check_pos.x] ~= "#" and i ~= ((h.f+1)%4)+1 then
                -- if h.p == Vec2D{6,138} then 
                --     print('f',h.p,'came',h.f,"going",i,check_pos,((h.f+1)%4)+1) 
                -- end
                local turncost = i ~= h.f and 1000 or 0
                table.insert(possiblemoves,{p=check_pos:copy(),f=i,c=turncost})
                junctiontest = junctiontest + 1
            end
        end

        if h.p == goal then

            if not g:hasEdge(h.s,"goal") then
                g:addEdge(h.s, "goal", h.l)
            end
            if h.tc == 111480 then
                table.insert(h.rt,{loc,h.al})
                local steps = 0
                for _, v in pairs(h.rt) do
                    steps = steps + v[2]
                end
                --print("holy fuck",steps,inspect(h))
                theroute= h
            end

            for i=1,4,1 do
                --Add sink routes from edge to node
                g:addEdge("goal,"..i,"goal",0)
            end


            goto continue
        end
        -- print(h.p,"#moves",#possiblemoves)
        -- if h.p == Vec2D{6,136}  then
        --     print("junction junction!", loc, junctiontest, h.s)
        -- end
        if junctiontest > 1 then
            g:addVertexIfNotExists(h.s)
            -- for i=1,4,1 do
            --     g:addVertexIfNotExists(h.s..","..i)
            -- end
            --g:addVertexIfNotExists(lof)
            g:addVertexIfNotExists(loc)
            -- if not getEdge(g,loc,lof) then g:addEdge(loc,lof,0) end

            -- g:addVertexIfNotExists(lof,loc..","..(h.f-2)%4+1)
            -- if not getEdge(g,lof,loc..","..(h.f-2)%4+1) then
            --     g:addEdge(lof,loc..","..(h.f-2)%4+1,1000)
            -- end
            -- g:addVertexIfNotExists(lof,loc..","..(h.f)%4+1)
            -- if not getEdge(g,lof,loc..","..(h.f)%4+1) then
            --     g:addEdge(lof,loc..","..(h.f)%4+1, 1000)
            -- end

            if g:hasEdge(h.s,loc) then
                herealready = true
                local e = getEdge(g, h.s, loc)

                if h.l < e.weight then
                    --assert(false,"in this economy?! (strategy)")
                    -- print(string.format("Lower %s to %s cost from %d to %d",h.s,loc,e.weight,h.l))
                    e.weight = h.l
                    herealready = false
                end
            else
                -- print(string.format("join %s and %s for %d points",h.s,loc,h.l))
                g:addEdge(h.s, loc, h.l)
                -- g:addEdge(loc,h.s,h.l)
            end
            -- if g:hasEdge(loc,h.s) then
            --     herealready = true
            --     local e = getEdge(g, loc, h.s)
                
            --     if h.l < e.weight then
            --         print(string.format("Lower %s to %s cost from %d to %d",loc,h.s,e.weight,h.l))
            --         e.weight = h.l
            --         herealready =false
            --     end
            -- else
            --     --print(string.format("join %s and %s for %d points",h.s,loc,h.l))
            --     g:addEdge(h.s, loc, h.l)
            --     -- g:addEdge(loc,h.s,h.l)
            -- end
            if not herealready then
                for _, mv in pairs(possiblemoves) do

                    -- if h.p == Vec2D{6,136}  then
                        -- print("br",h.p:toString().."|",h.p,h.f,mv.p,mv.f,1+mv.c)
                    --     --print("junction junction!", loc, junctiontest, h.s)
                    -- end
                    local rt = table.shallow_copy(h.rt)
                    table.insert(rt,{loc,h.al})
                    table.insert(heads,{p=mv.p:copy(),f=mv.f,l=1+mv.c,al=1,s=loc,tc=h.tc+1+mv.c,rt=rt})

                end
            end
        elseif #possiblemoves==1 then
            -- print("hey")
            -- print(loc, "move 1")
            
            -- h.l = h.l + 1
            -- h.p = possiblemoves[1].p
            -- h.f = possiblemoves[1].f
            local cornercost = h.f ~= possiblemoves[1].f and 1000 or 0
            -- print("l",h.s.."|",h.p,h.f,possiblemoves[1].p,possiblemoves[1].f,h.l,1+cornercost,h.l+1+cornercost)
            table.insert(heads,{p=possiblemoves[1].p,f=possiblemoves[1].f,l=h.l+1+cornercost,al=h.al+1,s=h.s,tc=h.tc+1+cornercost,rt=h.rt})
        else
            --deadend
            print("d",h.p,h.f, "dead")
        end
        ::continue::
    end

    return g, theroute
end

maze = parseInput()
-- -- writemaze(maze,"clean")
prune_maze(maze)
-- writemaze(maze,"trimmed")

local g,res = bfs(maze,start,target,false)

-- for k,v in pairs(res.rt) do
--     local pos = Vec2D(v[1])
--     maze[pos.y][pos.x] = "A"
-- end
--writemaze(maze,"path")


local function build_graph(maze,start,goal,part2)
    local g = require('luagraphs.data.graph').create(0, true)
    part2 = part2 or false

    local heads = {{p=start.p:copy(),l=0,f=start.f,s="start",tc=0}}

    while #heads > 0 do
        
        local h = table.remove(heads,1)
        if h == nil then break end

        local loc = h.p:toString()
        local lof = loc..","..h.f
        local herealready = false
        local possiblemoves = {}
        local junctiontest = 0
        for i=1,4,1 do
            ---@type Vec2D
            local check_pos = h.p+dir_vec[i]
            --! exclude backtrack
            -- print("a", h.p,check_pos,dir_vec[i])
            if maze[check_pos.y][check_pos.x] ~= "#" and i ~= ((h.f+1)%4)+1 then
                -- if h.p == Vec2D{6,138} then 
                --     print('f',h.p,'came',h.f,"going",i,check_pos,((h.f+1)%4)+1) 
                -- end
                local turncost = i ~= h.f and 1000 or 0
                table.insert(possiblemoves,{p=check_pos:copy(),f=i,c=turncost})
                junctiontest = junctiontest + 1
            end
        end

        if h.p == goal then

            print("holy fuck",h.tc)
            if not g:hasEdge(h.s,"goal") then
                g:addEdge(h.s, "goal", h.l)
            end

            for i=1,4,1 do
                --Add sink routes from edge to node
                g:addEdge("goal,"..i,"goal",0)
            end


            goto continue
        else

        end
        -- print(h.p,"#moves",#possiblemoves)
        -- if h.p == Vec2D{6,136}  then
        --     print("junction junction!", loc, junctiontest, h.s)
        -- end
        if junctiontest > 1 then
            g:addVertexIfNotExists(h.s)
            -- for i=1,4,1 do
            --     g:addVertexIfNotExists(h.s..","..i)
                
            -- end
            g:addVertexIfNotExists(lof)
            g:addVertexIfNotExists(loc)
            if not getEdge(g,loc,lof) then g:addEdge(loc,lof,0) end

            -- g:addVertexIfNotExists(lof,loc..","..(h.f-2)%4+1)
            -- if not getEdge(g,lof,loc..","..(h.f-2)%4+1) then
            --     g:addEdge(lof,loc..","..(h.f-2)%4+1,1000)
            -- end
            -- g:addVertexIfNotExists(lof,loc..","..(h.f)%4+1)
            -- if not getEdge(g,lof,loc..","..(h.f)%4+1) then
            --     g:addEdge(lof,loc..","..(h.f)%4+1, 1000)
            -- end

            if g:hasEdge(h.s,lof) then
                herealready = true
                local e = getEdge(g, h.s, lof)

                if h.l < e.weight then
                    assert(false,"in this economy?! (strategy)")
                    -- print(string.format("Lower %s to %s cost from %d to %d",h.s,loc,e.weight,h.l))
                    e.weight = h.l
                    --herealready = false
                end
            else
                -- print(string.format("join %s and %s for %d points",h.s,loc,h.l))
                g:addEdge(h.s, lof, h.l)
                -- g:addEdge(loc,h.s,h.l)
            end
            -- if g:hasEdge(lof,h.s) then
            --     herealready = true
            --     local e = getEdge(g, loc, h.s)
                
            --     if h.l < e.weight then
            --         print(string.format("Lower %s to %s cost from %d to %d",loc,h.s,e.weight,h.l))
            --         e.weight = h.l
            --         herealready =false
            --     end
            -- else
            --     print(string.format("join %s and %s for %d points",h.s,loc,h.l))
            --     g:addEdge(h.s, lof, h.l)
            --     -- g:addEdge(loc,h.s,h.l)
            -- end
            if not herealready then
                for _, mv in pairs(possiblemoves) do

                    -- if h.p == Vec2D{6,136}  then
                        -- print("br",h.p:toString().."|",h.p,h.f,mv.p,mv.f,1+mv.c)
                    --     --print("junction junction!", loc, junctiontest, h.s)
                    -- end
                    table.insert(heads,{p=mv.p:copy(),f=mv.f,l=1+mv.c,s=lof,tc=h.tc+1+mv.c})

                end
            end
        elseif #possiblemoves==1 then
            -- print("hey")
            -- print(loc, "move 1")
            
            -- h.l = h.l + 1
            -- h.p = possiblemoves[1].p
            -- h.f = possiblemoves[1].f
            local cornercost = h.f ~= possiblemoves[1].f and 1000 or 0
            -- print("l",h.s.."|",h.p,h.f,possiblemoves[1].p,possiblemoves[1].f,h.l,1+cornercost,h.l+1+cornercost)
            table.insert(heads,{p=possiblemoves[1].p,f=possiblemoves[1].f,l=h.l+1+cornercost,s=h.s,tc=h.tc+1+cornercost})
        else
            --deadend
            -- print("d",h.p,h.f, "dead")
        end
        ::continue::
        -- if h.p == Vec2D{7,136} or h.p == Vec2D(6,135) then
        --     print("bye")
        --     break
        -- end
    end

    return g
end

local function solveMaze(maze,graph, start, goal)

    local listproto = require('luagraphs.data.list')
    local open = {{c=0, n="start", p=listproto.create()}}
    -- local nvert = graph:vertices():size()

    local function expand(node)
        -- add adjacnt nodes
        local adj = graph:adj(node.n)
        if adj:size() == 0 then return end
        -- print("expanding", node.n,adj:size())
        local toadd = {}
        for i=0, adj:size()-1 do
            local e = adj:get(i)
            local u = e:other(node.n)
            -- assert(e.weight~=0 and node.n ~="start", string.format("Invalid weight (%s) for v-u (%s - %s) edge", e.weight,node.n,u))

            local stub = string.sub(u,0,-2)
            -- print(u,stub)
            -- assert(false)
            if node.p:contains(u) or
            node.p:contains(stub..1) or
            node.p:contains(stub..2) or
            node.p:contains(stub..3) or
            node.p:contains(stub..4) then
                --can't reeuse it
            --elseif node.n == "134,138" and u ~= "goal" then
                --force to goal as only option
            else
                local next = {c=node.c+e.weight,n=u,p=node.p:makeCopy()}
                next.p:add(node.n)
                -- print("expanding", node.n, next.n, node.c)
                table.insert(toadd, next)
            end
        end
        --pre-sort new additions
        table.sort(toadd, function(a,b) return a.c > b.c end)
        for _,v in pairs(toadd) do
            table.insert(open,v)
        end
    end

    local loop = 0
    local best
    while #open > 0 do
        loop = loop + 1
        table.sort(open, function(a,b) return a.c > b.c end)
    
        local current = table.remove(open)
        -- print("CURRENT",inspect(current))
        if current == nil then break end
  
        -- print(current.n, goal)
        if current.n == goal then
            -- print("HOT STUFF!!!)")
            if best == nil or current.c < best.c then
                best = current
                -- print(best.c, inspect(best.p:enumerate()))
                best.p:add(goal)
                if target and best.c == target then return best end
            end
        else
            expand(current)
        end

        --assert(current.c < 157636, "costs too much")
        -- if loop > 100000 then
        --     print("NO MORE!")
        --     print(inspect(current),inspect(best),inspect(open))
        --     break
        -- end
        if loop % 1000 == 0 then print(loop, inspect(best), inspect(current)) end
    end
    return best
end

local function solve2(maze,graph, start, goal)

    local frontier = {{score=0,p=start}}

    local costsofar = {}
    local camefrom = {}
    costsofar[start] = 0
    camefrom[start] = 0/0
end

-- points move 1, turn 1000, find LOWEST
-- writemaze(maze,"clean")
-- maze = parseInput()
-- prune_maze(maze)
-- writemaze(maze,"trimmed")
-- local graph = build_graph(maze,start,target,false)
-- local best = solveMaze(maze,graph,"start","goal")

-- P1 = best.c

-- print(inspect(best))

-- print(inspect(graph:vertices()))
-- print(inspect(graph))
-- print(inspect(graph:adj("8,136,2")))

-- for i=1,#best.p.a-1,1 do
--     local e = getEdge(graph,best.p.a[i],best.p.a[i+1])

--     print(i,best.p.a[i],best.p.a[i+1],e.weight)
-- end

-- -- print(inspect(graph))
-- print(graph:containsVertex("6,136"))
-- print(graph:containsVertex("2,140"))

-- print("rage",graph:hasEdge("2,140","6,136"))
-- print("rage2",graph:hasEdge("6,136","2,140"))
-- print(inspect(getEdge(graph,"2,140","6,136")))


print('\n2024 Day Sixteen')
print(string.format('Part 1 - Answer %s', P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
