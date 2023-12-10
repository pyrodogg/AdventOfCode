package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function isOneOf (a,t) 
    for k,v in ipairs(t) do
        if a == v then return true end
    end
    return false
end

local map = {}
local head = {}
local d = {}
local start 
for k,v in pairs(lines) do
    
    local line = unroll(v:gmatch("(.)"))
    map[k] = line
    d[k] = {}

    for i = 1, #line do
        
        if line[i] == 'S' then
            --Found start calc pipe shape
            -- We know line above and this line
            -- All pipes have exactly 2 opens so this is enough info
            -- pipes -|LFJ7
            -- d = 1,2,3,4 starting top going clockwise
            d[k][i] = line[i]
            P1 = 1
            start = {y=k,x=i,d=1}
            local cUp = isOneOf(map[k-1][i], {"|","F","7"})
            local cL = isOneOf(map[k][i-1],{"-","F","L"})
            local cR = isOneOf(map[k][i+1],{"-","J","7"})
            if cUp and cL then
                start.pipe = "J"
                head[1] = {x=i, y=k-1, d=1}
                head[2] = {x=i-1, y=k, d=4}
            elseif cUp and cR then
                start.pipe = "L"
                head[1] = {x=i, y=k-1, d=1}
                head[2] = {x=i+1, y=k, d=2}
            elseif cL and cR then
                start.pipe = "-"
                head[1] = {x=i-1, y=k, d=4}
                head[2] = {x=i+1, y=k, d=2}
            elseif cUp then 
                start.pipe = "|"
                head[1] = {x=i, y=k-1, d=1}
                head[2] = {x=i, y=k+1, d=3}
            elseif cL then
                start.pipe = "7"
                head[1] = {x=i-1, y=k, d=4}
                head[2] = {x=i, y=k+1, d=3}
            elseif cR then 
                start.pipe = "F"
                head[1] = {x=i+1, y=k, d=2}
                head[2] = {x=i, y=k+1, d=3}
            end
            break
        end
    end
end

local headstart = head

local function move(h, fill)

    local l = map[h.y][h.x]
    d[h.y][h.x] = l
    if l == "S" then l = start.pipe end
    --print(l)
    if l == "|" then
        if h.d == 1 then
            --heading up encountered v.pipe, continue up... I|O
            if fill then 
                d[h.y][h.x+1] = d[h.y][h.x+1] or 'I'
                d[h.y][h.x-1] = d[h.y][h.x-1] or 'O'
            end
            h.y = h.y -1
        else
            --heading down
            if fill then 
                d[h.y][h.x+1] = d[h.y][h.x+1] or 'O'
                d[h.y][h.x-1] = d[h.y][h.x-1] or 'I'
            end
            h.y = h.y + 1
        end
    elseif l == "-" then
        if h.d == 2 then
            if fill then
                d[h.y-1][h.x] = d[h.y-1][h.x] or 'O'
                d[h.y+1][h.x] = d[h.y+1][h.x] or 'I'
            end
            h.x = h.x + 1
        else
            if fill then
                d[h.y-1][h.x] = d[h.y-1][h.x] or 'I'
                d[h.y+1][h.x] = d[h.y+1][h.x] or 'O'
            end
            h.x = h.x - 1
        end
    elseif l == "7" then
        if h.d == 2 then
            if fill then 
                d[h.y+1][h.x-1] = d[h.y+1][h.x-1] or "I"

                d[h.y-1][h.x] = d[h.y-1][h.x] or "O"
                d[h.y-1][h.x+1] = d[h.y-1][h.x+1] or "O"
                d[h.y][h.x+1] = d[h.y][h.x+1] or "O"

            end
            h.d = 3
            h.y = h.y + 1
        else
            if fill then 
                d[h.y+1][h.x-1] = d[h.y+1][h.x-1] or "O"

                d[h.y-1][h.x] = d[h.y-1][h.x] or "I"
                d[h.y-1][h.x+1] = d[h.y-1][h.x+1] or "I"
                d[h.y][h.x+1] = d[h.y][h.x+1] or "I"
            end
            h.d = 4
            h.x = h.x -1
        end
    elseif l == "J" then
        if h.d == 3 then
            if fill then 
                d[h.y-1][h.x-1] = d[h.y-1][h.x-1] or "I"

                d[h.y][h.x+1] = d[h.y][h.x+1] or "O"
                d[h.y+1][h.x+1] = d[h.y+1][h.x+1] or "O"
                d[h.y+1][h.x] = d[h.y+1][h.x] or "O"

            end
            h.x = h.x - 1
            h.d = 4
        else
            if fill then
                d[h.y-1][h.x-1] = d[h.y-1][h.x-1] or "O"

                d[h.y][h.x+1] = d[h.y][h.x+1] or "I"
                d[h.y+1][h.x+1] = d[h.y+1][h.x+1] or "I"
                d[h.y+1][h.x] = d[h.y+1][h.x] or "I"
            end
            h.d = 1
            h.y = h.y - 1

        end
    elseif l =="F" then
        if h.d == 1 then
            h.d = 2
            h.x = h.x + 1
        else
            h.d = 3
            h.y = h.y + 1
        end
    elseif l == "L" then
        if h.d == 3 then
            h.d = 2
            h.x = h.x + 1
        else
            h.d = 1
            h.y = h.y - 1
        end
    end
    return h
end

while true do

    for k,v in ipairs(head) do
        head[k] = move(v)
    end

    P1 = P1 + 1 -- distance
    --break

    if head[1].x == head[2].x and head[1].y == head[2].y then
        break
    end
end

local h = headstart[1]

local count = 0
while true do 

    h = move(h, true)
    count = count + 1

    if count > 6599*2 then break end

    -- if h.x == start.x and h.y == start.y then 
    --     break 
    -- end
end

function floodfill(s,c)
    local c_loc = s:find(c..'[ ]')
    if c_loc then
        return floodfill(string.gsub(s,c.." ",c..c),c)
    else 
        return s
    end
end


local a = assert(io.open("10-out.txt","w"))
for _,v in pairs(d) do
    local s = ''
    for i=1,140 do
        local c = v[i]
        -- if c == "|" then c = "│" end
        -- if c == "F" then c = "┌" end
        -- if c == "7" then c = "┐" end
        -- if c == "L" then c = "└" end
        -- if c == "-" then c = "─" end
        -- if c == "J" then c = "┘" end
        s = s..(c or ' ')
    end
    s = floodfill(s,'O')

    for i=1, #s do
        
        if s:sub(i,i) == "O" then
            P2 = P2 + 1
        end
    end
    a:write(s.."\n")
end


print('\nDay Ten')
print(string.format('Part 1 - Answer %d',P1)) -- 6599
print(string.format('Part 2 - Answer %d', P2)) -- 477

