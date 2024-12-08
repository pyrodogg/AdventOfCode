package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function manhattan(a,b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y), b.x - a.x,  b.y-a.y
end

local W,H,oob = aoc.bounds(lines)

local attn = {}
for k,v in pairs(lines) do
    for i = 1, #v, 1 do
        
        local a = v:sub(i,i)
        if a ~= '.' then
            if attn[a] == nil then attn[a] = {} end
            
            table.insert(attn[a],{x=i,y=k})
        end
    end
end

local function waves(part)
    local anode = {}
    local acc = 0
    for f, v in pairs(attn) do
        if true then
            for i = 1, #v-1, 1 do
                for j = i+1, #v, 1 do
                    --compare i and j
                    local d, dx, dy = manhattan(v[i],v[j])
                    --print(f,inspect(v[i]),inspect(v[j]),d,dx,dy)
                    local a1pos = {}
                    local a2pos = {}
    
                    for q = ((part==1 and 1) or 0) , ((part==1 and 1) or 50), 1 do
                        if dx >= 0 then
                            -- j is right of i
                            a1pos.x = v[i].x - dx*q
                            a2pos.x = v[j].x + dx*q
                        else
                            -- j is left of i
                            a1pos.x = v[i].x + math.abs(dx)*q
                            a2pos.x = v[j].x - math.abs(dx)*q
                        end

                        if dy >= 0 then
                            -- j is below i
                            a1pos.y = v[i].y - dy*q
                            a2pos.y = v[j].y + dy*q
                        else
                            -- j is above i
                            assert(false, "due to parsing top down")
                            a1pos.y = v[i].y + math.abs(dy)*q
                            a2pos.y = v[j].y - math.abs(dy)*q
                        end

                        if not oob(a1pos) then
                            if anode[a1pos.y] == nil then anode[a1pos.y] = {} end
                            if anode[a1pos.y][a1pos.x] == nil then
                                anode[a1pos.y][a1pos.x] = {}
                                acc = acc + 1
                            end
                            table.insert(anode[a1pos.y][a1pos.x], f)
                        end

                        if not oob(a2pos) then
                            if anode[a2pos.y] == nil then  anode[a2pos.y] = {} end
                            if anode[a2pos.y][a2pos.x] == nil then
                                anode[a2pos.y][a2pos.x] = {}
                                acc = acc + 1
                            end

                            table.insert(anode[a2pos.y][a2pos.x], f)
                        end
                    end --for
                end
            end
        end
    end

    return acc, anode
end

local function anodemap(map)

    local res = ""
    for y=1, H, 1 do
        for x=1, W, 1 do
            
            if map[y][x] ~= nil then
                res = res .. "@"
            else
                res = res ..'.'
            end
        end
        res = res ..'\n'
    end
    return res
end

local anode
P1, anode = waves(1)
aoc.logfile('8-anode-1',anodemap(anode))

P2, anode = waves(2)
aoc.logfile('8-anode-2',anodemap(anode))



print('\n2024 Day Eight')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
