package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function getDist(p,q)
    return math.sqrt((q.x-p.x)^2 + (q.y-p.y)^2 + (q.z-p.z)^2)
end

local coords = {}
local cl = {}
local nodeCount = 0
for k,v in pairs(lines) do
    local c = aoc.intsFromLine(v)
    local a = {x=c[1],y=c[2],z=c[3], n = {}}
    coords[v] = a
    a.id = v
    nodeCount = nodeCount + 1
    table.insert(cl,a)
end

local cdist = {}
for i=1,#cl-1 do
    --local close = {}
    for j=i+1, #cl do
        local d = getDist(cl[i],cl[j])
        table.insert(cdist,{d=d,p=cl[i].id,q=cl[j].id})
    end
end

table.sort(cdist, function(a,b)
    return a.d < b.d
end)

local circuit_heap = {}
local circuit_list = {}
local idcount = 0
local num_circuits = 0
for i=1,#cdist do
    local cd = cdist[i]

    if circuit_heap[cd.p] == circuit_heap[cd.q] and circuit_heap[cd.q] ~= nil then
        -- same circuit, do nothing
        print('same',circuit_heap[cd.p],cd.p,cd.q)
    elseif circuit_heap[cd.p] == nil and circuit_heap[cd.q] == nil then
        -- new circuit
        idcount = idcount + 1
        num_circuits = num_circuits +1
        local id = idcount
        print('new',id, id,cd.p,cd.q)
        circuit_heap[cd.p] = id
        circuit_heap[cd.q] = id
        nodeCount = nodeCount -2
        --table.insert(circuit_list,{cd.p,cd.q})
        circuit_list[id] = {cd.p,cd.q}
    elseif circuit_heap[cd.p] ~= nil and circuit_heap[cd.q] == nil then
        -- Add Q to P circuit
        local ccl = circuit_list[circuit_heap[cd.p]]
        print('add q',circuit_heap[cd.p],cd.p,cd.q)
        --print(cd.p,circuit_heap[cd.p],inspect(circuit_list[circuit_heap[cd.p]]))
        circuit_heap[cd.q] = circuit_heap[cd.p]
        table.insert(ccl,cd.q)
        nodeCount = nodeCount -1

    elseif circuit_heap[cd.p] == nil and circuit_heap[cd.q] ~= nil then
        -- Add p to Q circuit
        local ccl = circuit_list[circuit_heap[cd.q]]
        circuit_heap[cd.p] = circuit_heap[cd.q]
        print('add p',circuit_heap[cd.q],cd.p,cd.q)
        table.insert(ccl,cd.p)
        nodeCount = nodeCount-1
    else
        --MERGE CIRCUIT move Q to P
        local cidp = circuit_heap[cd.p]
        local cidq = circuit_heap[cd.q]
        print('merge',cidp, cd.p,cd.q, cidq)
        local cclp = circuit_list[cidp]
        local cclq = circuit_list[cidq]
        for j=1,#circuit_list[cidq] do
           table.insert(cclp,cclq[j])
        end
        circuit_list[cidq] = nil
        --print(cidq,cd.q,inspect(circuit_list[cidq]))
        --if cidq == 175 then print("who murdered jack?!") end
        --table.remove(circuit_list,cidq)
        num_circuits = num_circuits -1
        --print("nuke network",cidq)
        for k,v in pairs(circuit_heap) do
            if v == cidq then
                circuit_heap[k] = cidp
            end
        end
    end
    if num_circuits==1 and nodeCount == 0 then
        --AND still circuits to match
        print("done",inspect(cd))
       P2 = coords[cd.p].x * coords[cd.q].x
       break
    end
end

table.sort(circuit_list, function(a,b)
    return #a>#b
end)

--print('P1', #circuit_list[1], #circuit_list[2], #circuit_list[3])
-- P2 circuit_list nuking not compat with Part1
-- P1 = #circuit_list[1]
-- * #circuit_list[2]
-- * #circuit_list[3]

-- print(inspect(circuit_list[1]))
-- print(inspect(circuit_list[2]))
-- print(inspect(circuit_list[3]))
--print(inspect(circuit_heap))

print('\n2025 Day Eight')
print(string.format('Part 1 - Answer %s',P1)) -- 47040
print(string.format('Part 2 - Answer %d', P2)) -- 4884971896
