
package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local md5 = require "md5"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function initialize()
    local node = {}
    node["button"] = {type="button",name="button", output={"broadcaster"}}
    for k,v in pairs(lines) do
        -- print(v)
        if v ~= "" then 
            local name = v:match("[%%&]-(%a+)")
            local type = v:match("([%%&])")
            local connections = unroll(v:gmatch(" (%w+)[,]-"))
            -- print(name, type, inspect(connections))

            if type == "%" then
                --flip-flop
                node[name] = {name=name, type="flipflop", state = 0, output=connections}

            elseif type == "&" then
                -- conjunction
                node[name] = {name=name, type="conjunction", input={}, output=connections}
            else
                -- broadcaster
                node[name]= {name=name, type=name, output=connections}
            end
        end
    end

    for k,v in pairs(node) do
        if v.type == "conjunction" then
            for _, i in pairs(node) do
                if i.type ~= "button" then
                    for _, c in pairs(i.output) do
                        if c == v.name then
                        v.input[i.name] = {name=i.name, state=0}
                        end
                    end
                end
            end
        end
    end


    return node
end

local node = initialize()
local net = {} -- PriorityQueue ??? or simple FIFO?
local stats = {[0]=0, [1]=0}
local log = {}
local buttoncount = 0

local function sendpulse(priority, from, to, state)
    local pulse = {from=from, to=to, state=state}

    stats[state] = stats[state] + 1
    table.insert(net, {priority=priority, pulse=pulse})

    -- table.insert(log, string.format("%s -%d-> %s", from, state, to))
end

local function resolvenet(net,node)

    while true do
        local pulse = table.remove(net,1)
        if pulse == nil then break end
        local priority = pulse.priority
        pulse = pulse.pulse -- unwrap from priority

        -- Execute pulse
        local target = node[pulse.to]
        if target ~= nil then
            if target.type == "broadcaster" then
                -- repeat pulse
                for _, c in pairs(target.output) do
                    sendpulse(priority,target.name, c, pulse.state)
                end
            elseif target.type == "flipflop" then
                if pulse.state == 0 then
                    --flipflop
                if target.state == 0 then target.state =1 else target.state = 0 end
                for _, c in pairs(target.output) do
                        sendpulse(priority,target.name, c, target.state)
                end
                else
                    --ignore high pulse
                end
            elseif target.type == "conjunction" then

                target.input[pulse.from].state = pulse.state
                target.state = 0
                if pulse.state == 1 then 
                    for _, i in pairs(target.input) do
                        if i.state == 0 then 
                            target.state = 1
                            break
                        end
                    end
                else
                    -- don't bother checking if we just set one low
                    target.state = 1
                end

                if target.state == 0 and (target.name == "zq" or target.name == "nt" or target.name=="vv" or target.name =="vn") then
                    print("conjunction sending low pulse on press", target.name, buttoncount)
                end

                for _, c in pairs(target.output) do
                    sendpulse(priority,target.name, c, target.state)
                end
            else
                assert(false, "Unknown type"..inspect(target))
            end
        else
            --unknown target, should be output, ignore
            if pulse.to =="rx" and pulse.state == 0 and P2 == 0 then
                P2 = buttoncount
                -- print(buttoncount)
            end
        end
    end
end

local function findcycles(node)


end

local statelog = {}
local function logstate(name, inputs)

    local padding = string.rep(" ",10-#(""..buttoncount))

    if statelog[name] == nil then
        
        statelog[name] = {name}

        local line = string.rep(" ", 10)
        for _,i in pairs(inputs) do
            line = line..i.."    "
        end
        table.insert(statelog[name],line)
    else
        local line = ""..buttoncount..padding
        local allhigh = true
        for _, i in pairs(inputs) do
           line = line..node[name].input[i].state.."    "
           if node[name].input[i].state == 0 then allhigh = false end
        end
        if allhigh then
            line = line .."<--HERE MF"
        end
        table.insert(statelog[name],line)
    end
end

local function writestatelog(name)
   local f = assert(io.open("log/20-"..name.."-log.txt","w"))
   
   for _, l in pairs(statelog[name]) do
    f:write(l.."\n")
   end
   f:close()
end

print("running...")

for i=1, 30000 do
    -- logstate("vn", {"br","qs","xm","mq","zv","dc","mg"})
    -- logstate("vv", {"bh","xb","bb","kg","hr","dv", "mr","pz"})
    -- logstate("zq", {"pj","cf","rm","nc","cl","rd","fp"})
    -- logstate("nt", {"fg","jc","lm","xd","nk","dr","qn","fh"})
    buttoncount = buttoncount + 1
    sendpulse(1,"button", "broadcaster", 0)
    resolvenet(net,node)

    findcycles(node)

    if P2 ~= 0 then break end
end

-- writestatelog("vn")
-- writestatelog("vv")
-- writestatelog("zq")
-- writestatelog("nt")

--print(inspect(node["zp"].input))

local function writenodemap()
    local f = assert(io.open("log/20-nodemap.txt","w"))
    local line = ""
    for _, n in spairs(node, function(t,a,b) return t[a].name < t[b].name end) do
        -- print(inspect(n))
        line = line .. n.name .." ("..n.type..")\n"
        if n.input ~= nil then
            line = line .."in: "
            for _, c in pairs(n.input) do
                if type(c) == "table" then c = c.name end
                line = line..c..", "
            end
            line = line:sub(1,#line-2).."\n"
        end
        if n.output ~= nil then
            line = line .."out: "
            for _, c in pairs(n.output) do
                if type(c) == "table" then c = c.name end
                line = line..c..", "
            end
            line = line:sub(1,#line-2).."\n"
        end
        line = line.."\n"
    end
    f:write(line)
    f:close()
end
writenodemap()

-- print(inspect(net))
print(inspect(stats))

P1 = stats[0] * stats[1]

local function writelog(log)
    local f = assert(io.open("log/20.txt","w"))

    for _, line in pairs(log) do
        f:write(line.."\n")
    end
    f:close()
end

-- writelog(log)

print('\nDay Twenty')
print(string.format('Part 1 - Answer %s',P1)) -- 791120136
print(string.format('Part 2 - Answer %d', P2)) -- 215252378794009

--[[
    P2 
    10000000000000 TOO FUCKING LOW!!!
    100000000000000000 too high
    48431785228652025 wrong
    215252378794009
    
]]