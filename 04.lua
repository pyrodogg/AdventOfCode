

require 'util'


-- [1518-04-05 00:00] Guard #131 begins shift
-- [1518-09-12 00:54] falls asleep
-- [1518-08-28 00:12] falls asleep
-- [1518-06-06 00:25] wakes up



function countBy(t,f) 
    local res = {}
    local g

    for k,v in pairs(t) do
        if type(f) == 'function' then
            g = f(v)
        elseif type(f) == 'string' and v[f] ~= nil then
            g = v[f]
        else
            g = v
        end

        res[g] = (res[g] or 0) + 1
    end

    return res
end

function reduce(t,f,a)
    local res = a

    for k,v in pairs(t) do 
        res = f(res,v,k,t)
    end

    return res
end

function range(a,b,c)
    local from, to, step
    if c == nil then step = 1 end
    if b == nil then 
        from = 1
        to = a
    else
        from = a
        to =  b
    end

    local res = {}
    for i = from,to,step do
        table.insert(res,i)
    end

    return res
end

function flow(...)
    local functions
    if type(...) == 'table' then
        functions = ...
    else
        functions = table.pack(...)
    end
    return function(...)
        local ret = table.pack(...)
        for k,v in ipairs(functions) do
            ret = table.pack(v(table.unpack(ret)))
        end
        return table.unpack(ret)
    end
end

print('Day 4 - Part 1')
local input = '04 - Input.txt'
local parsedLogs = map(sort(lines_from(input)),function(v,k,t)

    return {
        guard = tonumber(v:match('#(%d+)')) or 0,
        timestamp = v:match('%[(.+)]'),
        minute = tonumber(v:match('(%d+)]')),
        action =  v:match('](.+)')
    }
end)

local guards = reduce(parsedLogs,function(a,v,k,t) 

    local res = a or {
        currentId = 0,
        sleepStart = 0, 
        guards = {}}

    if v.guard ~= 0 then
        res.currentId = v.guard
        if res.guards[v.guard] == nil  then
            res.guards[v.guard] = {
                id = v.guard,
                length = 0,
                minutes = {}
            }
        end
    elseif v.action:match('sleep') then
        res.sleepStart = v.minute
    else
        res.guards[res.currentId].length = res.guards[res.currentId].length + v.minute - res.sleepStart -1
        for k,v in pairs(range(res.sleepStart,v.minute-1)) do
            table.insert(res.guards[res.currentId].minutes,v)
        end
    end
    return res
end).guards

guards = map(guards, function(v,k,t)
    local maxMinFreq, maxMin = maxBy(countBy(v.minutes))
    v.maxMinFreq = maxMinFreq or 0
    v.maxMin = maxMin or 0
    return v
end)


local sleepy = maxBy(guards,'length')
print('Sleepiest guard is '..sleepy.id..', who slept for '..sleepy.length..' minutes')
print("Most-slept minute "..sleepy.maxMin) 

print('Day 4 - Part 1 - Answer = '..sleepy.maxMin..' * '..sleepy.id..' = '..sleepy.maxMin*sleepy.id..'\n')

print('Day 4 - Part 2')

local freq = maxBy(guards,'maxMinFreq')

print('Guard ['..freq.id..'] slept most frequently on minute '..freq.maxMin..', a total of  '..freq.maxMinFreq..' times')
print("Day 4 - Part 2 - Answer = "..freq.maxMin.. ' * '..freq.id.. ' = '..freq.maxMin*freq.id)