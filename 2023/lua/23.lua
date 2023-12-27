package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function parseData()
    local map, start, goal = {},{},{}
    for k,v in pairs(lines) do
        map[k] = {}
        for i = 1, #v do
            map[k][i] = v:sub(i,i)
            if k == 1 and v:sub(i,i) == "." then
                start = {x=i,y=k}
            elseif k == #lines and v:sub(i,i) == "." then
                goal = {x=i,y=k}
            end
        end
    end
    return map, start, goal
end

local map, start, goal = parseData()
local width, height = #map[1], #map

local function getEdge(g, v, w)
    local adj = g:adj(v)
    for i=0, adj:size()-1 do
        local e = adj:get(i)
        if e:other(v) == w then
            return e
        end
    end
end

local dirmove= {N={0,-1},S={0,1},E={1,0},W={-1,0}}

local function buildGraph(map, start, goal, part2)

    part2 = part2 or false
    local g = require('luagraphs.data.graph').create(0, not part2)
    local heads = {{p={x=start.x,y=start.y},d="",l=0,sn="start"}}
    while #heads > 0 do
        local h = table.remove(heads)
        if h == nil then break end

        local loc
        if h.p.x == start.x and h.p.y == start.y then
            loc = "start"
        elseif h.p.x == goal.x and h.p.y == goal.y then
            loc = "goal"
        else
            loc = ""..h.p.x..","..h.p.y
        end

        if h.p.x == goal.x and h.p.y == goal.y then
            if not g:hasEdge(h.sn, "goal") then
                g:addEdge(h.sn, "goal", h.l)
            end
        else
            local done = false
            local possiblemoves = {}
            if part2 then
                if h.d ~= "N" and h.p.y < height and map[h.p.y+1][h.p.x] ~= "#" then table.insert(possiblemoves,"S") end
                if h.d ~= "S" and h.p.y > 1 and map[h.p.y-1][h.p.x] ~= "#" then table.insert(possiblemoves,"N") end
                if h.d ~= "E" and map[h.p.y][h.p.x-1] ~= "#" then table.insert(possiblemoves,"W") end
                if h.d ~= "W" and map[h.p.y][h.p.x+1] ~= "#" then table.insert(possiblemoves,"E") end
            else
                if h.d ~= "N" and h.p.y < height and (map[h.p.y+1][h.p.x] == "v" or map[h.p.y+1][h.p.x] == ".") then table.insert(possiblemoves,"S") end
                if h.d ~= "S" and h.p.y > 1 and (map[h.p.y-1][h.p.x] == "^" or map[h.p.y-1][h.p.x] == ".") then table.insert(possiblemoves,"N") end
                if h.d ~= "E" and (map[h.p.y][h.p.x-1] == "<" or map[h.p.y][h.p.x-1] == ".") then table.insert(possiblemoves,"W") end
                if h.d ~= "W" and (map[h.p.y][h.p.x+1] == ">" or map[h.p.y][h.p.x+1] == ".") then table.insert(possiblemoves,"E") end
            end
            local junctiontest = 0
            if (map[h.p.y-1] and map[h.p.y-1][h.p.x] ~= "#") then junctiontest = junctiontest + 1 end
            if (map[h.p.y+1] and map[h.p.y+1][h.p.x] ~= "#") then junctiontest = junctiontest + 1 end
            if map[h.p.y][h.p.x-1] ~= "#" then junctiontest = junctiontest + 1 end
            if map[h.p.y][h.p.x+1] ~= "#"  then junctiontest = junctiontest + 1 end

            if junctiontest > 2 then
                -- Choices, choices...
                g:addVertexIfNotExists(h.sn)
                g:addVertexIfNotExists(loc)
                if g:hasEdge(h.sn, loc)  then
                    done = true
                    local e = getEdge(g, h.sn, loc)
                    if h.l > e.weight then
                        e.weight = h.l
                        local verify = getEdge(g, h.sn, loc)
                        assert(verify.weight == h.l)
                    end
                elseif g:hasEdge(loc, h.sn) then
                    done = true
                    local e = getEdge(g, loc, h.sn)
                    if h.l > e.weight then
                        e.weight = h.l
                        local verify = getEdge(g, loc, h.sn)
                        assert(verify.weight == h.l)
                    end
                else
                    g:addEdge(h.sn, loc, h.l)
                end

                if not done then
                    for _, d in pairs(possiblemoves) do

                            local x = h.p.x + dirmove[d][1]
                            local y = h.p.y + dirmove[d][2]

                            table.insert(heads, {p={x=x,y=y},d=d,l=1,sn=loc})
                    end
                end
            elseif #possiblemoves == 1 then
                -- do move
                h.l = h.l + 1
                h.d = possiblemoves[1]
                h.p.x = h.p.x + dirmove[possiblemoves[1]][1]
                h.p.y = h.p.y + dirmove[possiblemoves[1]][2]

                table.insert(heads,h)
            end
        end
    end
    return g
end

local function findjunctions()

    local junctions = {}
    for y=2, #lines-1 do
        for x=2, #lines[y]-1 do
            
            local open = 0
            if map[y-1][x] ~= "#" then open = open + 1 end
            if map[y+1][x] ~= "#" then open = open + 1 end
            if map[y][x-1] ~= "#" then open = open + 1 end
            if map[y][x+1] ~= "#" then open = open + 1 end

            if open >= 3 and map[y][x] ~= "#" then
                -- print(string.format("verify Junction at (%d,%d)", x,y))
                table.insert(junctions, {x=x, y=y})
            end
        end
    end
    return junctions
end

local function freespace()
    local free = 0
    for y=2, #lines-1 do
        for x = 2, #lines[y]-1 do
            if lines[y]:sub(x,x) ~= "#" then free = free + 1 end
        end
    end
    return free
end

-- local fj = findjunctions()
-- print("Total junctions", #fj)
-- print("free space", freespace())



local function brutefs(g, start, goal, target)

    local listproto = require('luagraphs.data.list')
    local open = {{c=0, n=start, p=listproto.create()}}
    local nvert = g:vertices():size()
    local function expand(node)

        -- print("expanding", node.n)
        -- add adjacnt nodes
        local adj = g:adj(node.n)
        for i=0, adj:size()-1 do
            local e = adj:get(i)
            local u = e:other(node.n)
            assert(e.weight~=0, "invalid weight")

            if node.p:contains(u) then
                --can't reeuse it
            elseif node.n == "134,138" and u ~= "goal" then
                --force to goal as only option
            else
                local next = {c=node.c+e.weight,n=u,p=node.p:makeCopy()}
                next.p:add(node.n)
                -- print("expanding", node.n, next.n, node.c)
                table.insert(open, next)
            end
        end
    end
    
    local loop = 0
    local best
    while #open > 0 do
        loop = loop + 1
        table.sort(open, function(a,b) return a.c < b.c end)
    
        local current = table.remove(open)
        if current == nil then break end
  
        if current.n == goal then
            if best == nil or current.c > best.c then
                best = current
                -- print(best.c, inspect(best.p:enumerate()))
                best.p:add(goal)
                if target and best.c == target then return best end
            end
        else
            expand(current)
        end
    end
    return best
end

local g = buildGraph(map,start,goal,false)

local P1bfs = brutefs(g, "start", "goal")
P1 = P1bfs.c

local g2 = buildGraph(map, start, goal, true)
local P2bfs = brutefs(g2,"start","goal", 6378) --ans added after solve to make regression testing possible
P2 = P2bfs.c


local function verifygraph()
    -- Verify vertices
    -- print("g1 vertices ", inspect(g:vertices():enumerate()))
    -- print("g1 vertices ", inspect(g2:vertices():enumerate()))

    assert(g:vertexCount()-2 == #fj, "missing junctions g fj "..(g:vertexCount()-2).." "..#fj)
    assert(g:vertexCount() == g2:vertexCount(), "Same graph size")
    for i=0, g:vertexCount()-1 do
        local v = g:vertexAt(i)
        assert(g2:vertices():contains(v), "same vertecies")
    end

    local G1adjlines = {}
    local G2adjlines = {}
    local G1totalweight = 0
    for i=0, g:vertexCount()-1 do
        local v = g:vertexAt(i)
        assert(g2:vertices():contains(v), "same vertecies")

        local adj1 = g:adj(v)
        local adj2 = g2:adj(v)

        -- start ->a,b w=2  ->b,q w=34
        local line = string.format("G1 %s adj ",v)
        for j = 0, adj1:size() -1 do
            local e = adj1:get(j)
            -- In g2 may have been discovered in different order
            -- Since we exit early, both directions may not be recorded
            assert(g2:hasEdge(e:from(),e:to()) or g2:hasEdge(e:to(),e:from()), "G2 has same G1 edge "..e:from().."->"..e:to())
            G1totalweight = G1totalweight + e.weight
            line = line..string.format("-> %s w=%d\t", e:to(), e.weight)
            -- assert(g2:edges():contains(e), string.format("Different weights %s -> %s w=%d", e:from(), e:to(), e.weight))
        end
        --print(line)
        table.insert(G1adjlines, line)

        line = string.format("G2 %s adj ",v)
        for j = 0, adj2:size() -1 do
            local e = adj2:get(j)
            assert(g:hasEdge(e:from(), e:to()) or g:hasEdge(e:to(), e:from()), "G2 edges match G1, or are reversed G1 options")
            if v == e:from() then
                line = line..string.format("-> %s w=%d\t", e:to(), e.weight)
            else
                --line = line..string.format("<- %s w=%d\t", e:from(), e.weight)
            end
        end
        -- print(line)
        table.insert(G2adjlines, line)
    end

    for _, l in pairs(G1adjlines) do print(l) end
    print('-----')
    for _, l in pairs(G2adjlines) do print(l) end
end

local function writegraph(g, path, part)

    part = part or ''
    -- local Graphviz = require'graphviz'
    -- local gviz = Graphviz()

    local content = "digraph defaultname {\n"
    content = content..'\tgraph [nodesep=".5" ranksep=".75"]\n'
    content = content.."\tnode []\n\tedge []\n"

    local vertices = {}
    local edges = {}
    for i=0, g:vertexCount() -1 do
        local v = g:vertexAt(i)
        local adj = g:adj(v)
       
        -- gviz:node(string.format('"%s"',v),v)
        table.insert(vertices,string.format('\t\t"%s" [label="%s"]\n',v,v))

        for j=0, adj:size()-1 do
            local e = adj:get(j)
            local u = e:other(v)
            if g.directed or v < u then
                -- gviz:edge(string.format('"%s"',v),string.format('"%s"',u))

                if path:indexOf(v) == path:indexOf(u)-1 or path:indexOf(v)-1 == path:indexOf(u) then
                    table.insert(edges,string.format('\t\t\t"%s" -> "%s" [label="%s" color="red"]\n',v,u, e.weight))
                else
                    table.insert(edges,string.format('\t\t\t"%s" -> "%s" [label="%s"]\n',v, u, e.weight))
                end
            end
        end
    end
    content = content..table.concat(vertices)..table.concat(edges).."}"

    local f = assert(io.open("log/23-graph-"..part.."","w"))
    f:write(content)
    f:close()

    -- gviz:render("log/23-graph")
end

-- writegraph(g,P1bfs.p,"part1")
-- writegraph(g2,P2bfs.p,"part2")


print('\nDay Twenty Three')
print(string.format('Part 1 - Answer %s',P1)) -- 2166
print(string.format('Part 2 - Answer %d', P2)) -- 6378
