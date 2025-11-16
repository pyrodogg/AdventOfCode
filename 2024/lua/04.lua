package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local search = {}
for i = 1, 8, 1 do
    search[i] = {}
end

local width, height = #lines[1], #lines

for y = 1, height, 1 do
    -- horiz forward
    table.insert(search[1], lines[y])
    --horiz back
    table.insert(search[2], string.reverse(lines[y]))
    for x = 1, width, 1 do
        --v 
        --if search[3][y] == nil then search[3][y] = "" end
        search[3][y] = (search[3][y] or "") .. lines[x]:sub(y,y)
        --v-r
        --if search[4][y] == nil then search[3][y] = "" end
        search[4][y] = lines[x]:sub(y,y) .. (search[4][y] or "")
    end
end

--dr x=1
for y = 1, height, 1 do
    local stack = lines[y]:sub(1,1)

    --start y=y,x=1
    --zigdr to end
    local x=1
    for dy=y+1, height, 1 do
        x=x+1
        stack = stack .. lines[dy]:sub(x,x)
        if x == width then
            break
        end
    end
    --print(stack)

    table.insert(search[5],stack)
    table.insert(search[6],string.reverse(stack))
end

--dr y=1,x>1
for x = 2, width, 1 do
    local stack = lines[1]:sub(x,x)

    local y=1
    for dx = x+1, width, 1 do
        y = y+1

        stack = stack .. lines[y]:sub(dx,dx)
    end

    --print(stack)
    table.insert(search[5],stack)
    table.insert(search[6],string.reverse(stack))
end

--ur x=1 (x+, y-)
for y= height, 1, -1 do
    local stack = lines[y]:sub(1,1)

    local x = 1
    for dy=y-1, 1, -1 do
        x =x+1
        stack = stack .. lines[dy]:sub(x,x)
    end

       -- print(stack)
        table.insert(search[7],stack)
        table.insert(search[8],string.reverse(stack))
end

--ur y=height, x>1 (x+,y-)
for x = 2, width, 1 do
    local stack = lines[height]:sub(x,x)

    local y=height
    for dx=x+1, width, 1 do
        y = y-1
        stack = stack ..lines[y]:sub(dx,dx)
    end
    --print(stack)
    table.insert(search[7],stack)
    table.insert(search[8],string.reverse(stack))
end

for sk, s in pairs(search) do
    for k,v in pairs(s) do 
        local matches = unroll(v:gmatch("XMAS"))

        --print("wat"..#matches)
        P1 = P1 + #matches
    end
end

for k,v in pairs(lines) do
    if k > 1 and k < height then
        --print(v)
        for p, a in v:gmatch("()(%w)") do
            if a == "A" then
                --dr
                if (lines[k-1]:sub(p-1,p-1) == "S" and lines[k+1]:sub(p+1,p+1) == "M") or
                (lines[k-1]:sub(p-1,p-1) == "M" and lines[k+1]:sub(p+1,p+1) == "S") then
                    --ur
                    if (lines[k+1]:sub(p-1,p-1) == "S" and lines[k-1]:sub(p+1,p+1) == "M") or
                    (lines[k+1]:sub(p-1,p-1) == "M" and lines[k-1]:sub(p+1,p+1) == "S") then
                        P2 = P2+1
                    end
                end
            end
        end
    end
end

print('\n2024 Day Four')
print(string.format('Part 1 - Answer %s',P1)) -- 
print(string.format('Part 2 - Answer %d', P2)) --