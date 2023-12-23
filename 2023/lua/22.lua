package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local rawbricks = {}
for k,v in pairs(lines) do

    local brick = map(unroll(v:gmatch("(%d+),(%d+),(%d+)")), function(a)
        return map(a,function(q) return tobase10(q) end)
    end)

    brick[3] = k -- id

    table.insert(rawbricks, brick)
end

local support = {}

for x=0,9 do
    support[x] = {}
    for y=0,9 do
        support[x][y] = 0 --1
    end
end

local function printsupport()
    local text = ""
    for y = 0, 9 do
        for x = 0, 9 do
            if type(support[x][y]) == "table" then
                local entry =string.format("%d (%d)",support[x][y][3],math.max(support[x][y][1][3], support[x][y][2][3]))
                text = text ..entry..string.rep(" ",12-#entry)
            else
                local entry = ""..support[x][y]
                text = text..entry..string.rep(" ", 12-#entry)
            end
        end
        text = text.."\n"
    end
    print(text)
end

for newindex, brick, ogindex in spairs(rawbricks, function(t,a,b)
    return math.min(t[a][1][3], t[a][2][3]) < math.min(t[b][1][3], t[b][2][3])
end) do

    local minx, maxx, miny, maxy, minz, maxz = 0,0,0,0,0,0
    -- brick orientation?
    if brick[1][1] == brick[2][1] and brick[1][2] == brick[2][2] and brick[1][3] == brick[2][3] then
        --single block, doens't matter
        -- print("single baby")
        minx = brick[1][1]
        maxx = minx
        miny = brick[1][2]
        maxy = miny
        minz = brick[1][3]
        maxz = minz
    elseif brick[1][1] == brick[2][1] and brick[1][2] == brick[2][2] then
        -- z-dir, verticle
        -- print("z")
        minx = brick[1][1]
        maxx = minx
        miny = brick[1][2]
        maxy = miny
        minz = math.min(brick[1][3], brick[2][3])
        maxz = math.max(brick[1][3], brick[2][3])
    elseif brick[1][1] == brick[2][1] and brick[1][2] ~= brick[2][2] then
        -- y-dir
        -- print("y")
        minx = brick[1][1]
        maxx = minx
        miny = math.min(brick[1][2],brick[2][2])
        maxy = math.max(brick[1][2], brick[2][2])
        minz = brick[1][3]
        maxz = minz
    else
        -- x dir
        -- print("x")
        minx = math.min(brick[1][1], brick[2][1])
        maxx = math.max(brick[1][1], brick[2][1])
        miny = brick[1][2]
        maxy = miny
        minz = brick[1][3]
        maxz = minz
    end

    local supportz, supportbricks = 0, {}
    for x = minx, maxx do
        for y = miny, maxy do
            
            -- Check for highest-z in colliding xy plane
            if support[x][y] == 0 then
                --ground
                supportz = math.max(supportz, 0) --already on ground no adjusting z
                -- print("safely landed")
            else
                local testbrick = support[x][y]
                if math.max(testbrick[1][3], testbrick[2][3]) > supportz then
                    -- higher than prior supports, clear
                    supportz = math.max(testbrick[1][3], testbrick[2][3])
                    supportbricks = {}
                    supportbricks[testbrick[3]] = true
                    --table.insert(supportbricks, testbrick[3])
                elseif math.max(testbrick[1][3], testbrick[2][3]) == supportz then
                    -- supporting in addition to another
                    -- table.insert(supportbricks, testbrick[3])
                    supportbricks[testbrick[3]] = true
                else
                    -- not supporting
                end
            end
            support[x][y] = rawbricks[brick[3]]
        end
    end

    local actualsupports = {}
    for id in pairs(supportbricks) do
        table.insert(actualsupports, id)
    end
    rawbricks[brick[3]][4] = actualsupports

    for _, s in pairs(actualsupports) do
        rawbricks[s][5] = rawbricks[s][5] or {}
        table.insert(rawbricks[s][5], brick[3])
    end

    if #actualsupports == 1 then
        rawbricks[actualsupports[1]][6] = rawbricks[actualsupports[1]][6] or {}
        table.insert(rawbricks[actualsupports[1]][6], brick[3])

    end
    --adjust brick z
    if minz > 1 then 
        local dropdist = minz - supportz
        rawbricks[brick[3]][1][3] = brick[1][3] - dropdist + 1
        rawbricks[brick[3]][2][3] = brick[2][3] - dropdist + 1
    end
end
-- printsupport()

for _, b in pairs(rawbricks) do

    if b[5] == nil or #b[5] == 0 then
        -- supporting nothing, can be nuked
        P1 = P1 + 1
    else
        -- check to is if bricks being supported are also supported by something ELSE
        local allsupported = true
        for _, supported in pairs(b[5]) do
           if #rawbricks[supported][4] ==  1 then
            allsupported = false
           end
        end

        if allsupported then
            P1 = P1 + 1
        else
            -- Just how many would fall?
            -- #brick[5] ...and their brick[5] decendents WHICH have no other supports
        end
    end
end

local function testsoleancestry(test, removed)
    local set = {test}

    while true do
        local q = table.remove(set)
        if q == nil then break end

        if q[4] ~= nil and #q[4] > 0 then

            for _, id in pairs(q[4]) do
                if q[3] == removed[3] then
                    -- found target
                    -- stop searching this path, but continue on others
                else
                    table.insert(set,rawbricks[id])
                end
            end
        else
            -- end of a line, is it removed?
            if q[3] ~= removed[3] then
                -- another "root" ancestor has been found
                return false
            end
        end
    end
    return true
end

for _, removed in pairs(rawbricks) do
    for _, test in pairs(rawbricks) do
       if removed[3] == test[3] then
        --same brick, don't count
       else

        if testsoleancestry(test,removed) then
            P2 = P2 + 1
        end
       end
    end
end


print('\nDay Twenty Two')
print(string.format('Part 1 - Answer %s',P1)) -- 443
print(string.format('Part 2 - Answer %d', P2)) -- 69915

