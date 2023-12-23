
package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local fun = require "fun"
local tuple = require "tuple"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local dug = {}
local function linepit(part2)

    local pit = {}
    pit[1] = {}
    pit[1][1] = dug--tuple("#",1) --{d="#", color=""}
    local border = 0

    local minx,miny,maxx,maxy = 1,1,1,1
    local curx,cury = 1,1
    for k,v in pairs(lines) do
        
        --if k / 10 == 0 then print("Eval line ", k) end
        local dir, num, color
        if part2 == false then

            dir, num = v:match("(%w) (%d+)")
            num = tobase10(num)
        else

            _, _ , color = v:match("(%w) (%d+) [(]#(.*)[)]")
            num = tonumber(color:sub(1,5),16)
            if color:sub(6,6) == "0" then dir = "R" 
            elseif color:sub(6,6) == "1" then dir = "D"
            elseif color:sub(6,6) == "2" then dir = "L"
            elseif color:sub(6,6) == "3" then dir = "U"
            end
            -- print(k, dir,num,color)
        end

        if dir == "U" then
            for dy in fun.range(1, num) do
                if pit[cury -dy] == nil then pit[cury-dy] = {} end
                pit[cury-dy][curx] = dug --tuple("#",1) --{d="#", color=color}
            end
            cury = cury - num
            miny = math.min(miny,cury)
            border = border + num
        elseif dir == "D" then
            for dy in fun.range(1,num) do
                if pit[cury+dy] == nil then pit[cury+dy] = {} end
                pit[cury+dy][curx] = dug --tuple("#",1) --{d="#", color=color}
            end
            cury = cury + num
            maxy = math.max(maxy,cury)
            border = border + num

        elseif dir == "L" then
            for dx in fun.range(1,num) do
                pit[cury][curx-dx] = dug --tuple("#",1) --{d="#", c=1}
            end
            curx = curx - num
            minx = math.min(minx,curx)
            border = border + num

        elseif dir == "R" then
            for dx in fun.range(1,num) do
                pit[cury][curx+dx] = dug --tuple("#",1) --{d="#", c=1}
            end
            curx = curx + num
            maxx = math.max(maxx, curx)
            border = border + num
        end
    end
    return pit, minx,miny,maxx,maxy, border
end

local function getwalls(pit,minusone,level)
    local inside = false
    local filler = 0
    return coroutine.wrap(function()

        for x in spairs(pit[level], function(t,a,b) return a < b end) do
        -- for x in pairs(pit[level]) do
            filler = filler + 1
            if pit[minusone][x] == dug then
                inside = not inside
                coroutine.yield(x, inside, filler-1)
                filler = 0
            end
        end
        coroutine.yield(nil)
    end)
end

local function dox(pit,y)
    local area = 0
    local left
    for x, testinside, filler in getwalls(pit,y-1,y) do

        if testinside == true then
            -- Transitioning to inside
            left = x
        else
            -- Transitioning to outside
            area = area + (x-left-1) - filler
        end
    end
    return area
end

local function fillpit(pit,minx,miny,maxx,maxy)

    local area = 0
    for y = miny+1, maxy-1,1 do

        area = area + dox(pit,y)

        if math.abs(y % 100000) == 0 then
            print(y, math.floor(y/maxy*100), area, collectgarbage("count"))
            collectgarbage()
        end
    end

    return area
end

local function dopart(part2)

    print("line pit", part2)
    local pit, minx,miny,maxx,maxy, border = linepit(part2)
    print("fill pit", part2)
    local res  = fillpit(pit,minx,miny,maxx,maxy)
    return res + border
end

-- local pit, minx,miny,maxx,maxy, border = linepit(false)
-- P1 = fillpit(pit,minx,miny,maxx,maxy)
-- P1 = P1 + border
P1 = dopart(false)
print("P1 done", P1)

P2 = dopart(true)


print('\nDay Eighteen')
print(string.format('Part 1 - Answer %s',P1)) -- 106459
print(string.format('Part 2 - Answer %d', P2)) -- 63806916814808