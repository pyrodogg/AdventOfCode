package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

--North=1, East=2...
local dir_tuples = {{x=0, y=-1},{x=1, y=0},{x=0, y=1},{x=-1, y=0}}
local W,H,oob = aoc.bounds(lines)
local map = {}

local trailheads = {}
for k,v in pairs(lines) do
    map[k] = map[k] or {}
    for i =1, #v, 1 do
        map[k][i] = tobase10(v:sub(i,i))
        if map[k][i] == 0 then
            table.insert(trailheads,{x=i,y=k})
        end
    end
    --print(inspect(map[k]))
end

local outs = {}
for y= 1, H, 1 do
    outs[y] = outs[y] or {}
    for x = 1, W, 1 do
        outs[y][x] = outs[y][x] or {}
        if y > 1 then
            if map[y-1][x] == map[y][x]+1 then
                table.insert(outs[y][x],dir_tuples[1]) --up
            end
        end
        if y < H then
            if map[y+1][x] == map[y][x]+1 then
                table.insert(outs[y][x],dir_tuples[3]) --down
            end
        end
        if x > 1 then
            if map[y][x-1] == map[y][x]+1 then 
                table.insert(outs[y][x],dir_tuples[4]) -- left
            end
        end
        if x < W then
            if map[y][x+1] == map[y][x]+1 then
                table.insert(outs[y][x],dir_tuples[2]) -- right
            end
        end
    end
end

local uniq = {}
local function path(head,og)

    local score = 0

    -- print(inspect(head))
    uniq[og.y] = uniq[og.y] or {}
    uniq[og.y][og.x] = uniq[og.y][og.x] or {}
    uniq[og.y][og.x][head.y] = uniq[og.y][og.x][head.y] or {}
    if uniq[og.y][og.x][head.y][head.x] == true then
        P2 = P2 + 1
        return 0
    end
    if map[head.y][head.x] == 9 then
        uniq[og.y][og.x][head.y][head.x] = true
        P2 = P2 + 1
        return 1
    end

    for _, o in pairs(outs[head.y][head.x]) do
        -- print('o'..inspect(o))
        local nh = {x=(head.x+o.x),y=(head.y+o.y)}
        score = score + path(nh,og)
    end

    return score
end

for k,v in pairs(trailheads) do
    
    local score = path(v,v)
    --print(string.format("starting {%d,%d} score %d",v.x,v.y, score))
    P1 = P1 + score

end

print('\n2024 Day Ten')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --