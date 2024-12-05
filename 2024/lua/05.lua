package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function tprint(t)
    print(inspect(t))
end

local rules, updates = {}, {}
for k,v in pairs(lines) do
    if v:find("[|]") then
        local first, last = v:match("(%d+)|(%d+)")
        --print('ok padre')
        table.insert(rules,{f=tobase10(first),l=tobase10(last)})
    end

    if v:find("[,]") then 
        table.insert(updates, map(unroll(v:gmatch("(%d+)[,]*")), tobase10))
    end
end

local function validateUpdate(update)

    -- each page
    for k, p in pairs(update) do
        -- check every page after
        for i = k+1, #update, 1 do
            local q = update[i]
            
            --each rule
            for _, r in pairs(rules) do
                -- does rule match both pages
                if (r.f == p or r.f == q) and (r.l == p or r.l == q) then
                    --print(r.f,r.l,p,q)
                    if p == r.f and q == r.l then
                        -- ok?
                    else
                        return false, 0
                    end
                else
                    --print("bye")
                end
            end
        end
    end
    return true, update[math.ceil(#update/2)]
end

local function pagesort(a,b)
    --return true if a goes before b
    for _, r in pairs(rules) do
        if r.l == a and r.f == b then
            return false
        end
    end
    return a>b
end

local function insertPage(u,p)
    -- requires correctly sorted update
    local new_index = 1
    for _, r in pairs(rules) do
        for i = new_index, #u, 1 do
            local q = u[i]
            if r.f == q and r.l == p then
                new_index = i+1
            end
        end
    end
    table.insert(u,new_index,p)
    return u
end

--local uorder = {}


for k,v in pairs(updates) do

    local test1, middle = validateUpdate(v)
    if test1 then
        --print (k+1177, "p1", test1, middle,inspect(v))
        P1 = P1 + middle
    else
        --shuffle and validateUpdate
        --table.sort(v,pagesort)
        local w = {}
        for _, p in pairs(v) do
            insertPage(w,p)
        end
        local test2, middle = validateUpdate(w)

        print (k+1177, "p2", test2, middle,inspect(w))
        if test2 then 
            P2 = P2 + middle
        end
    end
end

local u = {}
insertPage(u,26)
insertPage(u,27)
insertPage(u,62)
insertPage(u,87)
insertPage(u,18)
insertPage(u,75)
insertPage(u,86)
print(validateUpdate(u))
tprint(u)



--print(inspect(updates))

print('\n2024 Day Four')
print(string.format('Part 1 - Answer %s',P1)) -- 
print(string.format('Part 2 - Answer %d', P2)) --