package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function tprint(t)
    print(inspect(t))
end

--Direction 'bitmap'
local dir_bit = {[1]=2,[2]=4,[3]=8,[4]=16,N=2,E=4,S=8,W=16,All=30,Unset=0}

local map_grid = {}

local x,y = 0,0
local face = 1 -- up, right = 1, ...

for k,v in pairs(lines) do
    local p = v:match("()[%^]")
    if p then
        --print(k,p)
        x=p
        y=k
    end

    map_grid[k] = {}
    for x = 1, #v, 1 do
        map_grid[k][x] = v:sub(x,x)
    end
end
local initpos = {x=x, y=y}
local dir

local dir_tuples = {{x=0, y=-1},{x=1, y=0},{x=0, y=1},{x=-1, y=0}}
local function turnRight()

    face = face % 4 + 1
    dir = dir_tuples[face]

    -- if face == 1 then
    --     --up
    --     dir = {x=0, y=-1}
    -- elseif face == 2 then
    --     --right
    --     dir = {x=1, y=0}
    -- elseif face == 3 then
    --     --down
    --     dir = {x=0, y=1}
    -- elseif face == 4 then
    --     --left
    --     dir = {x=-1, y=0}
    -- else
    --     assert(false,"Invalid facing")
    -- end
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
    x = initpos.x
    y = initpos.y
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

local function writeMap(slug, content)

    local f = assert(io.open("log/6cycle-"..slug.."","w"))
    f:write(inspect(content):gsub("},","},\n"))
    f:close()

end

local function initVisit(visited, map_grid)
    if visited == nil then visited = {} end

    --for k,v in pairs(map_grid) do
    for k=1, #map_grid, 1 do
        --for j, _ in pairs(v) do
        for j = 1, #map_grid[k], 1 do
            if visited[k] == nil then visited[k] = {} end
            --tprint(visited[k][j])
            if visited[k][j] == nil or visited[k][j] > 0 then visited[k][j] = 0 end
            --visited[k][j] = 0x00
        end
    end

    return visited
end
local cycles = 1

local function testPatrolGrid(patrol_map, start,visited)

    visited = initVisit(visited, patrol_map)
    local uniq = 0
    x = start.x
    y = start.y
    face = 1
    dir = dir_tuples[face]--{x=0, y=-1}

    --local last = {x=start.x, y=start.y}

    while true do

        if y+dir.y < 1 or y+dir.y> #patrol_map or x+dir.x< 1 or x+dir.x > #patrol_map[1] then
            --out of grid, done
            if visited[y] == nil then visited[y] = {} end
            --visited[y][x] = {f={[face]=true}}
            visited[y][x] = visited[y][x] | dir_bit[face]
            uniq = uniq + 1
            return uniq, visited, false
        end

        --print(x,y)
        if patrol_map[y+dir.y] and patrol_map[y+dir.y][x+dir.x] == "#" then
            -- if visited[y][x] == 0 then
            --     --visited[y][x] = {f={}}
            --     --visited[y][x] = dir_bit[face]
            --     visited[y][x] = visited[y][x] | dir_bit[face]
            --     uniq = uniq + 1
            -- --elseif visited[y][x].f[face] == true then
            -- elseif (visited[y][x] & dir_bit[face]) == dir_bit[face] then
            --     --print("Cycle!")
            --     writeMap(cycles,visited)
            --     cycles = cycles + 1
            --     return uniq, visited, true
            -- else
            --     visited[y][x] = visited[y][x] | dir_bit[face]
            --     --print("passing by...",tprint(visited[y][x].f))
            -- end
            --visited[y][x] = (visited[y][x] | dir_bit[face])
            turnRight()
        else
            --if visited[y] == nil then visited[y] = {} end
            if visited[y][x] == 0 then
                --visited[y][x] = {f={}}
                --visited[y][x] = dir_bit[face]
                visited[y][x] = (visited[y][x] | dir_bit[face])
                uniq = uniq + 1
            --elseif visited[y][x].f[face] == true then
            elseif (visited[y][x] & dir_bit[face]) == dir_bit[face] then
                --print("Cycle!")
                if cycles <= 10 then writeMap(cycles,visited) end
                cycles = cycles + 1
                return uniq, visited, true
            else
                visited[y][x] = (visited[y][x] | dir_bit[face])
                --print("passing by...",tprint(visited[y][x].f))
            end
    
            x = x+dir.x
            y = y+dir.y
        end

        --printmap(patrol_map)
    end
end

local patrol, cycle
local visit_map = initVisit({},map_grid)
--P1, patrol, cycle =  testPatrol(lines)
P1, patrol, cycle =  testPatrolGrid(map_grid,initpos, visit_map)
--local test_map = table.shallow_copy(lines)

visit_map = initVisit({},map_grid)
--print(patrol)
--print(visit_map)


for y,v in pairs(patrol) do
    for x,_ in pairs(v) do
        
        if x==initpos.x and y==initpos.y then
            --skip
            --print('skip!')
        else
            --place obsticale
            --print(x,y)
            --printmap(test_map,false)

            --test_map[y] = test_map[y]:sub(1, x-1).."#"..test_map[y]:sub(x+1,-1)
            map_grid[y][x] = "#"
            --printmap(test_map,false)
            
            --and test for cycle
            local s, route
            --print(visit_map)
            s, _, cycle = testPatrolGrid(map_grid,initpos,visit_map)
            if cycle == true then
                P2 = P2 + 1
            else
                --print("nope")
            end
            --test_map[y] = test_map[y]:sub(1, x-1).."."..test_map[y]:sub(x+1,-1)
            map_grid[y][x] = "."

            --tprint(route)
            --assert(1==2)
        end
    end
end


print('\n2024 Day Six')
print(string.format('Part 1 - Answer %s',P1)) -- 
print(string.format('Part 2 - Answer %d', P2)) --