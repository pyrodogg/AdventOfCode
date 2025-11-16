package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local tuple = require "tuple"
local Graphviz = require'graphviz'


local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function parsegraph()
    -- local graph = {}
    -- graph.v = {} -- vertex
    -- graph.e = {} -- edge 
    local g = require('luagraphs.data.graph').create(0)
    local gviz = Graphviz()
    local seen = {}

    for k,v in pairs(lines) do

        local entries = unroll(v:gmatch("(%w+)"))
        -- print(inspect(entries))

        for i, j in pairs(entries) do
            if seen[j] == nil then
                gviz:node(j,j)
                seen[j] = true
            end
           --graph.v[j] = {n=j}
            if i > 1 then
                -- qqq -> mlp
                -- jxx -> qdp
                -- zbr -> vsx
                if (entries[1]=="qqq" and j=="mlp") or
                   (entries[1]=="jxx" and j=="qdp") or
                   (entries[1]=="zbr" and j=="vsx") then

                else
                    g:addEdge(entries[1],j)
                    gviz:edge(entries[1],j)
                    --   table.insert(graph.e, {a=entries[1],b=j})
                end
            end
        end
        -- break
    end

    return g, gviz
end

local graph, gviz = parsegraph()
--gviz:render("log/25-graph")

for i =0, graph:vertexCount() -1 do
    
    local v = graph:vertexAt(i)
    local adj = graph:adj(v)

    -- how many of my adj interconnect?
    for j=0, adj:size()-1 do
        local e = adj:get(j)
        -- print(inspect(e))
    end

    -- print(adj:size())
end


local cc = require('luagraphs.connectivity.ConnectedComponents').create()
cc:run(graph)

print('count: ' .. cc.count)
print(cc.count) -- return 3 connected components
local subcount = {}
for k = 0,graph:vertexCount()-1 do
    local v = graph:vertexAt(k)
    subcount[cc:component(v)] = subcount[cc:component(v)] or 0
    subcount[cc:component(v)] = subcount[cc:component(v)]  + 1
    -- print('id[' .. v .. ']: ' .. cc:component(v))
end

P1 = subcount[0] * subcount[1]

print("\nDay Twenty Five - It's Christmas!!!")
print(string.format('Part 1 - Answer %s',P1)) -- 543256
print(string.format('Part 2 - Answer %d', P2)) -- 
