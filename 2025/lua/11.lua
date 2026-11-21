package.path = package.path .. ';../../?.lua'
require "util"
-- require "luarocks.loader"
local inspect = require "inspect"
local aoc = require "lib.aoc"
local maths = require "lib.maths"
local C = require "lib.combine"
local set = require "lib.set"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local edges = {}
local edges_r = {}
for k,v in pairs(lines) do
    v = unroll(v:gmatch("%w+"))
    edges[v[1]] = {}
    edges_r[v[1]] = edges_r[v[1]] or {}
    edges_r[v[1]]["in"] = edges_r[v[1]]["in"] or 0
    for i=2,#v do
        table.insert(edges[v[1]],v[i])
        edges[v[i]] = edges[v[i]] or {}
        edges_r[v[i]] = edges_r[v[i]] or {}
        edges_r[v[i]][v[1]] = true
        edges_r[v[i]]["in"] = (edges_r[v[i]]["in"] or 0) + 1
    end
end

local queue = T{}
local paths = {}
paths["svr"] = 1
local fftpaths = {}
local dacpaths = {}

for k, v in pairs(edges_r) do
    if v["in"] == 0 then
        table.insert(queue,k)
    end
end

local topoOrder = {}
while #queue > 0 do
    local v = queue:remove()

    table.insert(topoOrder,v)
    for _, u in pairs(edges[v]) do
        paths[u] = (paths[u] or 0) + paths[v]
        --                         + if (dyed from fft or dac) paths[v] end)

        if u == "fft" then
            fftpaths[u] = (fftpaths[u] or 0) + paths[v]

        elseif fftpaths[v] then
            fftpaths[u] = (fftpaths[u] or 0) + fftpaths[v]
        end

        if u == "dac" and fftpaths[v] then
            dacpaths[u] = (dacpaths[u] or 0) + fftpaths[v]
        elseif dacpaths[v] and fftpaths[v] then
            dacpaths[u] = (dacpaths[u] or 0) + dacpaths[v]
        end

        edges_r[u]["in"] = edges_r[u]["in"] - 1
        if edges_r[u]["in"] == 0 then
            queue:insert(u)
        end
    end
end

--print(inspect(topoOrder))
--print(inspect(paths))


for k, v in pairs(topoOrder) do
    if v == "svr" or v=="fft" or v=="dac" or v=="out" then
        print(k,v, paths[v])
    end
end

-- print(inspect(dacpaths))

print(paths["out"])
P2 = dacpaths["out"]

---comment
---@param p Set
---@param n string
---@param goal string
---@param edges table
---@param memo table
---@return integer
local function dfs(p,n,goal,edges,memo)

    if memo[n] then return memo[n] end

    local score = 0
    if n == goal then
        if p:contains("fft") and p:contains("dac") then
            P2 = P2 + 1
        end
        return 1
    end

    -- local pn = table.shallow_copy(p)
    -- table.insert(pn,n)
    local pn = p:copy()
    pn:add(n)
    for _,v in pairs(edges[n]) do
        score = score + dfs(pn,v,goal,edges,memo)
    end

    memo[n] = score
    return score
end

local memo = {}
P1 = dfs(Set({}),"you","out",edges,memo)



print('\n2025 Day Eleven')
print(string.format('Part 1 - Answer %s',P1)) -- 701
print(string.format('Part 2 - Answer %d', P2)) -- 390108778818526

