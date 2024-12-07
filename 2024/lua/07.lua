package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local function tprint(t) print(inspect(t)) end

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local math_opts = {[1]="-",[2]="/",[3]="||",[0]=""}
local bug = false

local function mathWorks(a,t)
    --Exploit integers
    local work = a
    local checkpoint = #t
    local attempts = 1
    local partials = {}
    local forcesub = false

    ::reloop::

    for i = checkpoint, 2, -1 do

        work = a / t[i]
        if work == math.floor(work) and forcesub == false then
            -- division worked = multiply
            if bug then print("div "..a.." by "..t[i]) end
            checkpoint = i --because sus

            a = work
            partials[i] = a
        elseif forcesub then
            forcesub = false
            if bug then print("forcesub " ..t[i].." from "..a, checkpoint) end
            a = a -t[i]
            partials[i] = a
        else
            
            --try subtraction
            if bug then print("sub " ..t[i].." from "..a, checkpoint) end
            a = a - t[i]
            partials[i] = a
        end
    end

    if a == t[1] then
        return true
    elseif attempts < #t then
        attempts = attempts + 1
        forcesub = true
        if bug then print("retry "..checkpoint.." with ans "..partials[checkpoint+1]) end
        a = partials[checkpoint+1] or 0
        --if bug then print("try again", a) end
        goto reloop
    else
        return false
    end
    --return a == t[1]
end

local function flip(t)
    local r = {}
    for i = #t, 1, -1 do
        table.insert(r,t[i])
    end
    return r
end
local function bprint(a) if bug then print(a) end end

local function mathWorksRecurr(a,t,ops,l)
    local work
    if ops == nil then ops = {} end
    if l == nil then l = 1 else l = l + 1 end

    bprint(l..":>"..a..' '..inspect(t))
    --bprint(t)
    for i = #t, 2, -1 do
        work = a / t[i]

        if work ~= math.floor(work) then
            --unclean div, MUST sub
            a = a - t[i]
            table.remove(t,i)
            table.insert(ops,"+")
            --bprint(l..": ".."+")
        else
            --clean div/split
            local opsa = table.shallow_copy(ops)
            table.insert(opsa,"+")
            table.insert(ops,"*")

            local suba = a - t[i]
            a = math.floor(work)
            --bprint(l..": ".."+/"..suba..' '..a)
            table.remove(t,i)

            return mathWorksRecurr(a,table.shallow_copy(t),ops,l) or mathWorksRecurr(suba, table.shallow_copy(t),opsa, l)
        end
    end

    return a == t[1]
end

local function whereismysanity(a,t,optrl)

    assert(#optrl == #t-1, "Invalid #optrl")
    optrl = flip(optrl)

    local attempt = t[1]

    for k, o in pairs(optrl) do
        
        if o == "-" then
            attempt = attempt + t[k+1]
        elseif o == "/" then
            attempt = attempt * t[k+1]
        elseif o == "||" then
            attempt = tobase10(attempt..''..t[k+1])
        else
            assert(false,"wat")
        end
    end

    assert(attempt==a,"Where is my fucking sanity")
end

local function mathWorksPart2(a,t,l,op,optrl)
    
    if l == nil then l = 0 else l = l + 1 end
    if op == nil then op = {} end
    if optrl == nil then optrl = {} end

    

    local i = #t-l

    --print(a,inspect(t),'l '..l, 'i '..i, math_opts[op], inspect(flip(optrl)))

    if #t == 0 then
        -- concats to the end?
        --print("YATZEE")
        assert(false,"yatzee")
        --return true
    elseif a < 0 then
        --print('a<0 out of bounds, false')
        return false
    elseif i < 1 then
        --print('i<1, false')
        return false
    end

    -- if a >= 0 and a<= 1 and i == 1 then
    --     --print("HOLY SHIT")
    --     --print(a, inspect(t),l,op)
    --     return true
    -- end
    -- if (#t-l) < 1 or #t == 0 then
    --     return false
    -- end

    if i == 1 then
        --print("PERFECT!")
        --Sub,Dic,Concat all work here
        if a == t[i] then
            --print("ok", inspect(flip(optrl)))
            return true
        else
            --print("fail", inspect(flip(optrl)))
            return false
        end
    end

    table.insert(optrl,math_opts[op])

    if op == 1 then -- Sub

        if a == t[#t-l] and #t-l == 1 then
            return a == t[#t-l]
        else
            local subA = a - t[#t-l]
            --ok here, continue recurr
            return mathWorksPart2(subA,table.shallow_copy(t),l,1,table.shallow_copy(optrl)) or
            mathWorksPart2(subA,table.shallow_copy(t),l,2,table.shallow_copy(optrl)) or
            mathWorksPart2(subA,table.shallow_copy(t),l,3,table.shallow_copy(optrl))
        end

    elseif op == 2 then -- Div
        local work = a / t[#t-l]

        local divA
        if work == math.floor(work) then
            divA = math.floor(work)

            --ok here, continue recurr
            return mathWorksPart2(divA,table.shallow_copy(t),l,1,table.shallow_copy(optrl)) or
            mathWorksPart2(divA,table.shallow_copy(t),l,2,table.shallow_copy(optrl)) or
            mathWorksPart2(divA,table.shallow_copy(t),l,3,table.shallow_copy(optrl))

        else
            --bad div, branch fails
            return false
        end
    elseif op == 3 then -- Concat
        --can concate? 
        local astr = a..""
        local s,e = astr:find(t[i].."$")
        if s ~= nil then

            local newA = tobase10(astr:sub(1,s-1))
            if newA == nil then return false end
            --print("taco",astr,newA, t[i],s,e)
            --local newT = table.shallow_copy(t)
            --table.remove(newT)
            --print(inspect(t),inspect(newT))

            --ok here, continue recurr
            return mathWorksPart2(newA,table.shallow_copy(t),l,1,table.shallow_copy(optrl)) or
            mathWorksPart2(newA,table.shallow_copy(t),l,2,table.shallow_copy(optrl)) or
            mathWorksPart2(newA,table.shallow_copy(t),l,3,table.shallow_copy(optrl))

        else
            --can't concat, branch fail
            return false
        end
    else
        assert(false,"Invalid Op")
        -- return mathWorksPart2(a,table.shallow_copy(t),-1,1) or
        -- mathWorksPart2(a,table.shallow_copy(t),-1,2) or
        -- mathWorksPart2(a,table.shallow_copy(t),-1,3)
    end
end

for k,v in pairs(lines)  do
 
    local ans, terms = v:match("(%d+): ([%d ]+)")
    ans = tobase10(ans)
    terms = map(unroll(terms:gmatch("(%d+)")),tobase10)

    --if k == 1 then bug = true else bug = false end

    if k > 0 then
        if mathWorksRecurr(ans, table.shallow_copy(terms)) then
            --print(k, 'OK', ans, inspect(terms))
            P1 = P1 + ans
            P2 = P2 + ans
        else
            --if mathWorksPart2(ans,table.shallow_copy(terms)) then
                if mathWorksPart2(ans,table.shallow_copy(terms),-1,1) or
                mathWorksPart2(ans,table.shallow_copy(terms),-1,2) or
                mathWorksPart2(ans,table.shallow_copy(terms),-1,3) then
                --print(k, 'OK2', ans, inspect(terms))
                P2 = P2 + ans
                --whereismysanity(ans,table.shallow_copy(terms),)
            else
                --print(k, 'Fail', ans, inspect(terms))
            end
        end
    end
    --break
end

--print(string.find("4865","5".."$"))

print('\n2024 Day Seven')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --

--[[

P2 

1399219446947 too low 
88310800665502 too low!!
275791737999218 too high
275791737999003


]]