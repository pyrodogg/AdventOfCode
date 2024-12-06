package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function tprint(t)
    print(inspect(t))
end

local x,y = 0,0
local face = 1 -- up, right = 1, ...
-- print((1)%4+1)
-- print((2)%4+1)
-- print((3)%4+1)
-- print((4)%4+1)

for k,v in pairs(lines) do
    local p = v:match("()[%^]")
    if p then
        --print(k,p)
        x=p
        y=k
    end
end
local start = {x=x, y=y}
local dir = {x=0, y=-1}

local function turnRight()

    face = face % 4 + 1

    if face == 1 then
        --up
        dir = {x=0, y=-1}
    elseif face == 2 then
        --right
        dir = {x=1, y=0}
    elseif face == 3 then
        --down
        dir = {x=0, y=1}
    elseif face == 4 then
        --left
        dir = {x=-1, y=0}
    else
        assert(false,"Invalid facing")
    end
end

local function printmap(patrol_map, showpos)

    print(x,y,P1)
    for k,v in pairs(patrol_map) do

        if k == y and showpos == true then
            print(string.sub(v,1,x-1)..'@'..string.sub(v,x+1,-1))
        else
            print(v)
        end
    end
    print()
end

--print(x,y,face, tprint(dir))

local function testPatrol(patrol_map)

    local visited = {}
    local uniq = 1
    x = start.x
    y = start.y
    face = 1
    dir = {x=0, y=-1}

    while true do

        if y+dir.y < 1 or y+dir.y > #patrol_map or x+dir.x < 1 or x+dir.x > #patrol_map[1] then
            --out of grid, done
            if visited[y] == nil then visited[y] = {} end
            visited[y][x] = {f={[face]=true}}
            return uniq, visited, false
        end
    
        if patrol_map[y+dir.y]:sub(x+dir.x,x+dir.x) == "#" then
            turnRight()
        else
            if visited[y] == nil then visited[y] = {} end
            if visited[y][x] == nil then
                visited[y][x] = {f={}}
                visited[y][x].f[face] = true
                --P1 = P1 + 1
                uniq = uniq + 1
            elseif visited[y][x].f[face] == true then
                --print("Cycle!")
                return uniq, visited, true
            else
                visited[y][x].f[face] = true
                --print("passing by...",tprint(visited[y][x].f))
            end
    
            x = x+dir.x
            y = y+dir.y
        end
        --printmap(patrol_map)
    end
    return uniq, visited, false
end

local patrol, cycle
P1, patrol, cycle =  testPatrol(lines)

for y,v in pairs(patrol) do
    for x,_ in pairs(v) do
        
        if x==start.x and y==start.y then
            --skip
            --print('skip!')
        else
            --place obsticale
            local test_map = table.shallow_copy(lines)
            --print(x,y)
            --printmap(test_map,false)

            test_map[y] = test_map[y]:sub(1, x-1).."#"..test_map[y]:sub(x+1,-1)
            --printmap(test_map,false)
            
            --and test for cycle
            local s, route
            s, route, cycle = testPatrol(test_map)
            if cycle == true then
                P2 = P2 + 1
            end
            --tprint(route)
            --assert(1==2)
        end
    end
end

print('\n2024 Day Six')
print(string.format('Part 1 - Answer %s',P1)) -- 
print(string.format('Part 2 - Answer %d', P2)) --