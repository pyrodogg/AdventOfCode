package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local md5 = require "md5"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local width,height = #lines[1], #lines
local map = {}  --matrix(#lines,#lines[1])
for k,v  in pairs(lines) do
    map[k] = {}

    for i=1,#v do
        if v:sub(i,i) ~= "." then
            map[k][i] = v:sub(i,i)
        end
    end
end

local function mapstring(m)

    local s = ""
    for y=1,#m do
        for x=1,100 do
            s = s..(m[y][x] or ' ')
        end
        s = s..'\n'
    end
    return s
end

local function collapseNorthSouth(dir)
    local step = (dir == "N" and 1) or -1

    for col = 1, width do
        local lookstart = (dir == "N" and 1) or height
        local lookstop = (dir == "N" and height) or 1
        local target = nil
        for lookahead = lookstart, lookstop, step do

            if map[lookahead][col] == nil and target == nil then
                target = lookahead

            elseif map[lookahead][col] == "#" then
                target = nil
                
            elseif map[lookahead][col] == "O" and target ~= nil then
                map[target][col] = map[lookahead][col]
                map[lookahead][col] = nil
                target = target + step
            end
        end
    end
end

local function collapseEastWest(dir)

    local step = (dir == "W" and 1) or -1
    for row = 1, height do

        local lookstart = (dir == "W" and 1) or width
        local lookstop = (dir == "W" and width) or 1
        local target = nil
        for lookahead = lookstart, lookstop, step do

            if map[row][lookahead] == nil and target == nil then
                target = lookahead

            elseif map[row][lookahead] == "#" and lookahead < height then
                target = nil

            elseif map[row][lookahead] == "O" and target ~= nil then
                map[row][target] = map[row][lookahead]
                map[row][lookahead] = nil
                target = target + step
            end
        end
    end
end

local function scoremap()
    local score = 0
    for y=1,height do
        for x=1,width do
            if map[y][x] == "O" then
                score = score + height-y+1
            end
        end
    end
    return score
end

local function cycle()
    collapseNorthSouth("N")
    if P1 == 0 then P1 = scoremap() end
    collapseEastWest("W")
    collapseNorthSouth("S")
    collapseEastWest("E")
end

print(mapstring(map))

local cache = {}
local cyclelength
for i=1,1000000000 do
    cycle()
    local hash = md5.sumhexa(mapstring(map))
    if cache[hash] ~= nil and 1000000000 % i == 0 then
        cyclelength = i
        break
    else
        cache[hash] = true
    end
end

print(mapstring(map))

print("cycle length is", cyclelength)
P2 = scoremap()

print('\nDay Fourteen')
print(string.format('Part 1 - Answer %d',P1)) -- 105249
print(string.format('Part 2 - Answer %d', P2)) -- 88680
