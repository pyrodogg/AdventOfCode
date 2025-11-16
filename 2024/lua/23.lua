package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
--local rex = require"rex_pcre2"
---@type Vec2D | v2call
local Vec2D = require "lib.vec2d"
local tuple = require "tuple"
local Graphviz = require'graphviz'

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
local dir_vec = {Vec2D{0,-1},Vec2D{1,0},Vec2D{0,1},Vec2D{-1,0}}

--local connections = {}
local sets = {}

local g = require('luagraphs.data.graph').create(0)
local gviz = Graphviz()
gviz.nodes.style:update{
	nodesep=".5",
    ranksep=".75"
}

for k,v in pairs(lines) do

    local pc_1, pc_2  = v:match("(%a+)-(%a+)")

    gviz:node(pc_1,pc_1)
    gviz:node(pc_2,pc_2)
    gviz:edge(pc_1,pc_2)
    g:addEdge(pc_1,pc_2,1)

    if pc_1:sub(1,1) == "t" then
        sets[pc_1] = sets[pc_1] or {}
        table.insert(sets[pc_1],pc_2)
    end

    if pc_2:sub(1,1) == "t" then
        sets[pc_2] = sets[pc_2] or {}
        table.insert(sets[pc_2],pc_1)
    end
end
--gviz:render("log/23-graph")

--Chiba & Nishizeki (1985)
local cycles = 0
local lans = {}
local marked = {}
for _,v in pairs(g:vertices():enumerate()) do
    if true or v:sub(1,1) == "t" then

        --print(v)
        -- print(inspect(g:adj(v):size()))
        local adj_v = g:adj(v)
        for i=0, adj_v:size()-1 do
            local e = adj_v:get(i)
            local w = e:other(v)
            marked[w] = true
        end

        if adj_v and adj_v:size() > 0 then
            for i=0, adj_v:size()-1 do
                -- for adjacencies to a t-node,compare to t-node adjacencies
                local e = adj_v:get(i)
                local u = e:other(v)
                --print(v,u)
               
                local adj_u = g:adj(u)
                
                for j = 0, adj_u:size()-1 do
                    local e2 = adj_u:get(j)
                    local w = e2:other(u)
                    if marked[w] then
                        P1 = P1+1
                        table.insert(lans,{v,w,u})
                    end

                end
                marked[u] = nil
            end
        end

        g:removeVertex(v)
    end
end

local frq = {}
local maxfrq, maxnet = 0,""
for k,v in pairs(lans) do
    for i=1,3 do
        frq[v[i]] = (frq[v[i]] or 0) + 1
        if frq[v[i]] > maxfrq then
            maxfrq = frq[v[i]]
            maxnet = v[i]
        end
    end
end
table.sort(frq,function(a,b) return a>b end)
print(maxnet)
print(inspect(frq))
local finallan = {}
table.insert(finallan,maxnet)
for k,v in pairs(lans) do
    if v[1] == maxnet then
        table.insert(finallan,v[2])
        table.insert(finallan,v[3])
    elseif v[2] == maxnet then
        table.insert(finallan,v[1])
        table.insert(finallan,v[3])
    elseif v[3] == maxnet then
        table.insert(finallan,v[1])
        table.insert(finallan,v[2])
    end
end
table.sort(finallan,function(a,b) return a<b end)
print(table.concat(finallan,",")) -- need to dedup, but is answer
--absolutely cursed solution from reddit hint. Do want to explore a 'more proper' solution yet



local function bronKerbosch(R,P,X,graph) --
    local cliques = {}
    if #P == 0 and #X == 0 then
        table.insert(cliques,table.shallow_copy(R))
    end

    for _,v in pairs(P) do
        local new_R = table.shallow_copy(R)
        table.insert(new_R,v)
        -- local new_P = 
    end
end




print('\n2024 Day Twenty Three')
print(string.format('Part 1 - Answer %s', P1)) --
print(string.format('Part 2 - Answer %s', P2)) --