package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0


local function parsedata(lines) 
    local workflow = {}
    local parts = {}

    for k,v in pairs(lines) do

        local flow = v:match("(%w+){")
        if flow then
            local rules = {}
            local ruleindex = 1
            for p, op, n, f in v:gmatch("(%w)([><])(%d+):(%w+)") do
                
                rules[ruleindex] = {p=p, op=op, n=tobase10(n), f=f}
                ruleindex = ruleindex + 1
            end
            rules[ruleindex] = {f=v:match(",(%w+)}")}

            workflow[flow] = {flow=flow, rules=rules}

            -- print(inspect(rules))
        elseif v ~= "" then
            local comps = {}
            for p, n in v:gmatch("(%w)=(%d+)") do
                
                comps[p] = tobase10(n)
            end
            table.insert(parts,comps)
        end
    end
    return workflow, parts
end

local function routeparts(workflow, parts)
    local accpetedcomponents = 0

    local flow
    for _, p in pairs(parts) do
        flow = workflow["in"]
        while true do
            -- print("testing flow", flow.flow)
            for _, r in ipairs(flow.rules) do
                
                -- print(inspect(r))
                if r.op == ">" then
                    -- print(r.p,r.n,r.f)
                    if p[r.p] > r.n then flow = r.f; break end
                elseif r.op == "<" then
                    -- print(r.p,r.n,r.f)
                    if p[r.p] < r.n then flow = r.f; break end
                else 
                    --default
                    flow = r.f; break
                end
            end

            if flow == "R" then
                --reject
                break
            elseif flow == "A" then
                --accept
                -- print("I'm Accepted!!")
                accpetedcomponents = accpetedcomponents + p.x + p.m + p.a + p.s
                break
            else
                --redirect
                local flowtest = flow
                flow = workflow[flow]
                assert(flow, "Could not identify next flow "..flowtest)
            end
        end
    end

    return accpetedcomponents
end

local workflow, parts = parsedata(lines)
P1 = routeparts(workflow, parts)

local function count(t) 
    local c = 0
    for k, _ in pairs(t) do
        c = c+1
    end
    return c
end

local function replaceflow(flow,rep)
    for _, fr in pairs(workflow) do
        for _, r in pairs(fr.rules) do

            if r.f == flow then
                -- print("NUKING IT ", flow, rep)
                r.f = rep
            end
        end
    end
    workflow[flow] = nil
end

local function mergeandreplacesame(rep)

    for _, f in pairs(workflow) do
        if (#f.rules == 2 and f.rules[1].f == rep and f.rules[1].f == f.rules[2].f) or
        (#f.rules == 3 and f.rules[1].f == rep and f.rules[1].f == f.rules[2].f and f.rules[2].f == f.rules[3].f) then
            --rename f.flow to A

            replaceflow(f.flow, rep)
        end
    end
end

local function logworkflow(workflow) 

    local f = assert(io.open("log/19-workflow.txt","w"))

    for k,v in pairs(workflow) do
        
        f:write(string.format("%s{",k))

        for _,r in pairs(v.rules) do
            if r.op then
                f:write(string.format("%s%s%d:%s,", r.p, r.op, r.n, r.f))
            else
                f:write(string.format("%s}\n",r.f))
            end
        end
    end

    f:close()
end
print("Pre-reuction", count(workflow))

local lastcount  = count(workflow)

while true do 
    mergeandreplacesame("A")
    mergeandreplacesame("R")

    if count(workflow) == lastcount then break end
    lastcount = count(workflow)
end

print("post reduction", count(workflow))
logworkflow(workflow)

local P1part2 = routeparts(workflow, parts)
print(P1part2)

local function scorepartset(parts)

    return (parts.x.max - parts.x.min + 1) * (parts.m.max - parts.m.min + 1) *
    (parts.a.max - parts.a.min +1) * (parts.s.max - parts.s.min + 1)
end

local start = {parts = {x ={min=1,max=4000}, m={min=1, max=4000}, a={min=1, max=4000}, s={min=1, max=4000}}, next ="in"}
local partsets = {start}

local function scoreorforward(testset, next)
    if next == "A" then
        -- accepted, score, done
        P2 = P2 + scorepartset(testset.parts)
    elseif next == "R" then
        --rejected, dead
    else
        testset.next = next
        table.insert(partsets,testset)
    end
end

while true do
    local testset = table.remove(partsets)
    if testset == nil then break end

    local flow = workflow[testset.next]

    for _, r in pairs(flow.rules) do

        if r.op == ">" then
            if r.n >= testset.parts[r.p].min and r.n <= testset.parts[r.p].max then
                -- split
                -- testet always goes 'lower' (fails) so n becomes top of testset and bottom of newset
                local newset = {parts={x={},m={},a={},s={}}, next=r.f}
                for _, p in pairs({"x","m","a","s"}) do
                    newset.parts[p].min = testset.parts[p].min
                    newset.parts[p].max = testset.parts[p].max
                end
                newset.parts[r.p].min = r.n+1
                testset.parts[r.p].max = r.n

                scoreorforward(newset,r.f)
                --testset goes on to next rule
            elseif r.n < testset.parts[r.p].min then
                -- whole set passes
                scoreorforward(testset,r.f)
            else
                -- failed criteria, move to next rule
            end
        elseif r.op == "<" then

            if r.n >= testset.parts[r.p].min and r.n <= testset.parts[r.p].max then
                -- split
                -- testet always goes 'higher' (fails) so n becomes bottom of testset and top of newset
                local newset = {parts={x={},m={},a={},s={}}, next=r.f}
                for _, p in pairs({"x","m","a","s"}) do
                    newset.parts[p].min = testset.parts[p].min
                    newset.parts[p].max = testset.parts[p].max
                end
                newset.parts[r.p].max = r.n-1
                testset.parts[r.p].min = r.n

                scoreorforward(newset, r.f)

            elseif r.n > testset.parts[r.p].max then
                -- whole set passess
                scoreorforward(testset, r.f)
            else
                -- failed crtiteria, move next rule
            end
        else 
            --default
            scoreorforward(testset, r.f)
        end
    end
end

print('\nDay Nineteen')
print(string.format('Part 1 - Answer %s',P1)) -- 401674
print(string.format('Part 2 - Answer %d', P2)) -- 134906204068564