package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local tuple = require "tuple"
-- local bn = require "nums.bn"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local stones = {}
local function parsestone(s)

    local stone = {}
    local proto = map(unroll(s:gmatch("([-]-%d+)")),tobase10)
    stone.p = {x=proto[1], y=proto[2], z=proto[3]}
    stone.v = {x=proto[4], y=proto[5], z=proto[6]}
    -- print(inspect(stone))
    return stone
end

for k,v in pairs(lines) do

    local stone = parsestone(v)
    stone.id = k
    stones[k] = stone
end

local tests = 0
local loss = 0
local win = 0
local testmin = 200000000000000.0
local testmax = 400000000000000.0
-- local testmin = 7
-- local testmax = 27

local function normalize2D(v)
    local len = math.sqrt(v.x^2 + v.y^2)
    return {x=v.x/len, y=v.y/len}
end

local function normalize3D(v)
    local len = math.sqrt(v.x^2+ v.y^2 + v.z^2)
    return {x=v.x/len, y=v.y/len, z=v.z/len}
end

local function round(n,d)
    local d = d or 3
    local pad = 10^d
    n = n *pad
    n = n + (2^52 + 2^51) - (2^52 + 2^51)
    n = n / pad
    return n
end

local function vectorintersection2D(v1, v2)

end

local parallelsets = {}
local mark = false
local function checkVectorCollision2D(i,j)
    local s1 = type(i) == "number" and stones[i] or i
    local s2 = type(i) == "number" and stones[j] or j
    local u1 = normalize2D(s1.v)
    local u2 = normalize2D(s2.v)

    tests = tests +1
    -- more tests 
    -- They definitely collide, but 
        -- Is it 'in the future'?
        -- Is it in the test range?
    local a1 = s1.v.y+0.0
    local b1 = -1 * s1.v.x
    local c1 = s1.v.x*(0.0+s1.p.y) - s1.v.y*(0.0+s1.p.x)
    -- print("1 a,b,c", a1, b1, c1)

    local a2 = s2.v.y+0.0
    local b2 = -1 * s2.v.x
    local c2 = s2.v.x*(0.0+s2.p.y) - s2.v.y*(0.0+s2.p.x)
    -- print("2 a,b,c", a2,b2,c2)

    local d = (a1*b2 - a2*b1)
    local cx = (b1*c2 - b2*c1) / d
    local cy = (c1*a2 - c2*a1) / d

    local t1x = round((cx - s1.p.x) / s1.v.x,4)
    local t1y = round((cy - s1.p.y) / s1.v.y,4)

    if u1.x == u2.x and u1.y == u2.y then
    --     print("Paths are parallel", s1.id, s2.id)
    --     -- print(inspect(s1), inspect(s2))
    --     -- print("1 a,b,c", a1, b1, c1)
    --     -- print("2 a,b,c", a2,b2,c2)
    --     -- print(a1/a2, b1/b2,c1/c2)
        s1.u2 = normalize2D(s1.v)
        s2.u2 = normalize2D(s2.v)
        s1.u3 = normalize3D(s1.v)
        s2.u3 = normalize3D(s2.v)
        table.insert(parallelsets, {s1,s2})
    elseif u1.x == -u2.x and u1.y == -u2.y then
    --     print("OPPOSITES?!")
    --     assert(false,"look into it")
    else

        -- print(t1x, t1y, math.abs(t1x-t1y))
        -- if math.abs(t1x -t1y) > 0.1 then
        --     --print(cx,cy)
        --     --assert(t1x == t1y, "X and y should agree")
        --     print(s1.id, s2.id, t1x, cx, s1.p.x, s1.v.x)
        --     print(s1.id, s2.id, t1y, cy, s1.p.y, s1.v.y)

        --     print(inspect(s1), inspect(s2), inspect(u1), inspect(u2))
        --     print("1 a,b,c", a1, b1, c1)
        --     print("2 a,b,c", a2,b2,c2)

        --     print(b1)
        --     print(c2)
        --     print(b1*c2)

        --     mark = true
        --     -- assert(false)
        -- end
    end
    if a1/a2 == b1/b2 and a1/a2 ~= c1/c2 then
        -- print("parellel, different", s1.id, s2.id, a1/a2, inspect(normalize2D(s1.v)), inspect(normalize2D(s2.v)))
    elseif a1/a2 == b1/b2 and a1/a2 == c1/c2 then
        -- print("ITS THE SAME LINE", s1.id, s2.id)
        -- assert(false,"ITS THE SAME LINE?!")
    else
    end

    local minx1, maxx1, miny1, maxy1
    local minx2, maxx2, miny2, maxy2

    if s1.v.x > 0 then minx1 = s1.p.x else maxx1 = s1.p.x end
    if s1.v.y > 0 then miny1 = s1.p.y else maxy1 = s1.p.y end

    if s2.v.x > 0 then minx2 = s2.p.x else maxx2 = s2.p.x end
    if s2.v.y > 0 then miny2 = s2.p.y else maxy2 = s2.p.y end
    
    
    if (minx1 ~= nil and cx <= minx1) then
        -- print("past s1 <x", s1.id, s2.id, cx, minx1+0.0)
        loss = loss +1
    elseif (maxx1 ~= nil and cx >= maxx1) then
        -- print("past s1 >x", s1.id, s2.id, cx, maxx1+0.0)
        loss = loss +1
    elseif (miny1 ~= nil and cy <= miny1) then
        -- print("past s1 <y", s1.id, s2.id, cy, miny1+0.0)
        loss = loss +1
    elseif (maxy1 ~= nil and cy >= maxy1) then
        -- print("past s1 >y", s1.id, s2.id, cy, maxy1+0.0)
        loss = loss +1
    elseif (minx2 ~= nil and cx <= minx2) then
        -- print("past s2 <x", s1.id, s2.id, cx, minx2+0.0)
        loss = loss +1
    elseif (maxx2 ~= nil and cx >= maxx2) then
        -- print("past s2 >x", s1.id, s2.id, cx, maxx2+0.0)
        loss = loss +1
    elseif (miny2 ~= nil and cy <= miny2) then
        -- print("past s2 <y", s1.id, s2.id, cy, miny2+0.0)
        loss = loss +1
    elseif (maxy2 ~= nil and cy >= maxy2) then
        -- print("past s2 >y", s1.id, s2.id, cy, maxy2+0.0)
        loss = loss +1
    else
        if cx < testmin then
            -- print("cx too low", s1.id, s2.id, cx, testmin)
            loss = loss +1
        elseif cx > testmax then
            -- print("cx too high", s1.id, s2.id, cx, testmax)
            loss = loss +1
        elseif cy < testmin then
            -- print("cy too low", s1.id, s2.id, cy, testmin)
            loss = loss +1
        elseif cy > testmax then
            -- print("cy too high", s1.id, s2.id, cy, testmax)
            loss = loss +1
        else
            -- In the test area
            -- print("winner    ", s1.id, s2.id, cx, cy)
            -- P1 = P1 + 1
            win = win+1
            s1.c = s1.c or {}
            table.insert(s1.c, s2.id)
            s2.c = s2.c or {}
            table.insert(s2.c, s1.id)
            return true, cx, cy, t1x
            -- assert(mark ==false, "RREEEEE")
        end
    end
    return false
end

local function vectorintersection3D(v1,v2)

end

local cxsample = {}
local cysample = {}
for i = 1, #stones-1 do
    for j = i+1, #stones do
   
        local res, cx,cy = checkVectorCollision2D(i,j)
        if res then
            P1 = P1 + 1
            table.insert(cxsample, cx)
            table.insert(cysample, cy)
        end
        -- break
    end
    -- if i >= 2 then break end
end

-- print(string.format("Avg cx %.5f cy %.5f", sumcx/P1, sumcy/P1))


local function stdev(samples)
    local ans = 0

    local sum = 0

    for _, s in pairs(samples) do
        sum = sum + s
    end
    local mean = sum/#samples

    local sumstdev = 0
    for _,s in pairs(samples) do
        
        sumstdev = sumstdev + (s-mean)^2
    end

    ans = sumstdev / #samples
    ans = math.sqrt(ans)

    return ans, mean, (ans/mean)*100
end

-- print("Stdev Cx", stdev(cxsample))

-- local maxcol = 0
-- local maxcolrock = 0
-- for k, s in pairs(stones) do
    
--     if #s.c > maxcol then
--         maxcol = #s.c
--         maxcolrock = k
--     end
-- end

-- print("Most collisions", maxcolrock, maxcol)



--[[
The math
Need to compare 3 stones a-b and a-c. Each comparison yields 3 linear equations. 
With the six equations from two comparisons we can solve for the 6 unknowns, the 
parameters of the stone being thrown.

X Y Z DX DY DZ are the unknowns

x dx, x' dx' ... are the position and velocity components of a hailstone comparison.

(1) (dy'-dy) X + (dx-dx') Y + (y-y') DX + (x'-x) DY = x' dy' - y' dx' - x dy + y dx
(2) (dz'-dz) X + (dx-dx') Z + (z-z') DX + (x'-x) DZ = x' dz' - z' dx' - x dz + z dx
(3) (dy'-dy) Z + (dz-dz') Y + (y-y') DZ + (z'-z) DY = z' dy' - y' dz' - z dy + y dz
https://www.reddit.com/r/adventofcode/comments/18q40he/2023_day_24_part_2_a_straightforward_nonsolver/keyy7pv/
]]
function Printbn(a) 

    for i = 1, #a do
        local line = ""
        for j = 1, #a[1] do
            line = line ..'\t'..string.format("%f",a[i][j])
            --print('['..i..']['..j..']'..a[i][j])
        end
        print(line)
    end
end

local function bn(a)
    return a
end

local A = stones[1]
local B = stones[2]
local C = stones[3]
-- X Y Z DX DY DZ c
-- Force floating point to avoid integer roll over when multiplying large positions
local matrix = {
    {B.v.z-A.v.z, 0, A.v.x-B.v.x, A.p.z-B.p.z, 0, B.p.x-A.p.x, (B.p.x+0.0)*B.v.z - (B.p.z+0.0)*B.v.x - (A.p.x+0.0)*A.v.z + (A.p.z+0.0)*A.v.x}, -- A-B (2) xz
    {B.v.y-A.v.y, A.v.x-B.v.x, 0, A.p.y-B.p.y, B.p.x-A.p.x, 0, (B.p.x+0.0)*B.v.y - (B.p.y+0.0)*B.v.x - (A.p.x+0.0)*A.v.y + (A.p.y+0.0)*A.v.x}, -- A-B (1) xy
    {0, B.v.z-A.v.z, A.v.y-B.v.y, 0, A.p.z-B.p.z, B.p.y-A.p.y, (B.p.y+0.0)*B.v.z - (B.p.z+0.0)*B.v.y - (A.p.y+0.0)*A.v.z + (A.p.z+0.0)*A.v.y}, -- A-B (3) zy
    {C.v.y-A.v.y, A.v.x-C.v.x, 0, A.p.y-C.p.y, C.p.x-A.p.x, 0, (C.p.x+0.0)*C.v.y - (C.p.y+0.0)*C.v.x - (A.p.x+0.0)*A.v.y + (A.p.y+0.0)*A.v.x}, -- A-C (1) xy
    {C.v.z-A.v.z, 0, A.v.x-C.v.x, A.p.z-C.p.z, 0, C.p.x-A.p.x, (C.p.x+0.0)*C.v.z - (C.p.z+0.0)*C.v.x - (A.p.x+0.0)*A.v.z + (A.p.z+0.0)*A.v.x}, -- A-C (2) xz
    {0, C.v.z-A.v.z, A.v.y-C.v.y, 0, A.p.z-C.p.z, C.p.y-A.p.y, (C.p.y+0.0)*C.v.z - (C.p.z+0.0)*C.v.y - (A.p.y+0.0)*A.v.z + (A.p.z+0.0)*A.v.y}, -- A-C (3) zy
}

for i=1, #matrix do
    for j=1, #matrix[1] do
        --matrix[i][j] = bn(matrix[i][j])
        matrix[i][j] = matrix[i][j]+0.0
    end
end

 Printbn(matrix)
 print('')

function GaussJordan(a,n)

    local j = 1
    local c
    local flag = 0

    for i = 1, n do
        if a[i][i] == 0 then
            c = 1
            while ((i + c) <= n and a[i+c][i] == 0) do
                c = c + 1
            end
            if i+c == n then
                flag = 1
                break
            end
            j = i
            --print("swap "..j.." "..j+c)
            for k = 1, n+1 do
                -- swap
                local temp = a[j][k]
                a[j][k] = a[j+c][k]
                a[j+c][k] = temp;
            end
        end

        for j = 1, n do
            if i ~= j then
                local p = a[j][i] / a[i][i];
                -- print('p'..p..' '..a[j][i]..' '..a[i][i]..' i'..i..' j'..j)
                --print("reduce "..j..' by '..i..' factor '..string.format("%f",p))
                for k =1, n+1 do
                    a[j][k] = a[j][k] - (a[i][k] * p)
                end
            end
        end

        --Printbn(a)
    end

    return a, flag
end

local b, flag = GaussJordan(matrix, 6)
-- todo check flag
assert(flag == 0, "check consistency")
Printbn(b)
print('flag '..flag)

function FormatResult(m)
    P2 = bn(0)
    for i = 1, #m do
        print(string.format('%f',b[i][#b[1]] / b[i][i]))
        --P2 = P2 + math.floor(b[i][#b[1]] / b[i][i])
        if i <= 3 then
            P2 = P2 + b[i][#b[1]] / b[i][i]
        end
    end
end

FormatResult(b)
print(string.format("%f",P2))

-- Part 2, find the line that intersects EVERY hail stone at some positive time t
-- It's suspected that each t should be unique (unknown if any collisions would happen with Z now ivolved)

-- get lowest and higest hailstones

-- get two hailstones, find line that fits them. 

-- print(inspect(parallelsets))

-- local rock = {}
-- rock.p = {x=277986003324108, y=295859091701056, z=100} -- Avg of stone start positions
-- rock.p = {x=278295911595037, y=300409104016331, z=100} -- Avg of P1 collisions
-- rock.v = {x=-1, y=1, z=10}

-- local sumx = 0
-- local sumy = 0
-- local maxinitz = 0
-- for i=1, #stones do
--     -- sumx = sumx + stones[i].p.x
--     -- sumy = sumy + stones[i].p.y
--     -- maxinitz = math.max(maxinitz, (stones[i].v.z>0 and stones[i].p.z or 0))


--     -- for j=i+1, #stones do
--     -- end
--     local res, cx, cy, t1 = checkVectorCollision2D(stones[i],rock)
--     if res then
--         -- print(cx,cy, t1)
--         P2 = P2 + 1
--     end
-- end



-- local shotput = {} --shotput[step][stone] = {x,y,z}
-- for step = 1, 10 do
--     shotput[step] = {}
--     for k, s in pairs(stones) do

--         local shot = {x= s.p.x + step*s.v.x, y=s.p.y + step*s.v.y, z= s.p.z + step*s.v.z}
--         shotput[step][k]= shot
--     end
-- end

-- diff[step][stone1][stone2]
-- local diff = {}
-- for step = 10,10 do
--     diff[step] = {}
--     for k, s in pairs(shotput[step]) do
        
--         diff[step][k] = diff[step][k] or {}
--         local current = s

--         for i=1,#stones do
--             if i == k then 
--                 --skip it
--             else
--                 local last = shotput[step-9][i]
--                 diff[step][k][i] = {x=current.x - last.x, y=current.y-last.y, z=current.z - last.z}
--             end
--         end

--         -- print(k, inspect(s))
--         -- break
--     end
--     -- break
-- end

-- local diffheatmap = {}
-- for step = 10, 10 do
--     for stone = 1, #stones do
--         for comp = 1, #stones do
--             local c =  diff[step][stone][comp]
--             if c ~= nil then
--                 local t = tuple(c.x, c.y, c.z)
--                 if diffheatmap[t] == nil then diffheatmap[t] = 0 end
--                 diffheatmap[t] = diffheatmap[t] + 1
--             end
--             -- break
--         end
--         -- break
--     end
--     -- break
-- end

-- local f = assert(io.open("log/24-diffheatmap.txt","w"))
-- for k,v in pairs(diffheatmap) do
--     if v > 1 then
--         f:write(string.format("(%.0f,%.0f,%.0f)\t %d\n",k[1],k[2],k[3],v))
--     end
-- end
-- f:close()

-- local f = assert(io.open("log/24-shotput.txt","w"))
-- f:write(inspect(shotput))
-- f:close()


-- print(rock.p.x)
-- print(rock.p.x+rock.p.y+rock.p.z)
-- P2 = rock.p.x+rock.p.y+rock.p.z
-- print(string.format("avg init x %.0f", sumx/#stones))
-- print(string.format("avg init y %.0f", sumy/#stones))
-- print("maxinitz", maxinitz)


-- print("# tests", tests, (win+loss)==tests)

print('\nDay Twenty Four')
print(string.format('Part 1 - Answer %s',P1)) -- 23760
print(string.format('Part 2 - Answer %d', P2)) -- 888708704663413

--[[ 



]]