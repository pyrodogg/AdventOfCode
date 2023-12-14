package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

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


-- for k,v in pairs(lines) do
--     map[k] = {}
--     for i=1, 100 do 
--         local char = v:sub(i,i)
--         if char == '#' or char == 'O' then
--             if k == 1  or char == "#" then
--                 -- first row and # are stuck in place
--                 --print('adding at ', k, i, v:sub(i,i))
--                 map[k][i] = v:sub(i,i)
--                 -- if char == "O" then
--                 --     P1 = P1 + 100
--                 -- end
--             else
--                 local floor = 0
--                 for j=k-1, 1, -1 do 
--                     if map[j][i] ~= nil then
--                         floor = j
--                         break
--                     end
--                 end
--                 map[floor+1][i] = v:sub(i,i)
--                 --P1 = P1 + (100-(floor+1)+1)
--             end
--         end
--     end

--     --if k >= 10 then break end
-- end


local function collapseNorthSouth(dir)
    local step = (dir == "N" and 1) or -1

    for col = 1, width do

        local lookstart = (dir == "N" and 1) or height
        local lookstop = (dir == "N" and height) or 1
        local target = nil
        for lookahead = lookstart, lookstop, step do

            if map[lookahead][col] == nil then
                if target == nil then 
                    target = lookahead
                end
            elseif map[lookahead][col] == "#" then
                target = nil
                -- target = lookahead + step
                -- if map[target][col] ~= nil and lookahead < height then
                --     for i=1,height do
                --         --try find empty spot
                --         target = target + step
                --         if target > height or map[target][col] == nil then
                --             break
                --         end
                --     end
                -- end
            elseif map[lookahead][col] == "O" and target ~= nil then
                map[target][col] = map[lookahead][col]
                map[lookahead][col] = nil
                target = target + step
            end
            --if lookahead >= 10 then break end
        end
        --if col >= 3 then break end
    end
end

local function collapseEastWest(dir)

    local step = (dir == "W" and 1) or -1
    for row = 1, height do

        local lookstart = (dir == "W" and 1) or width
        local lookstop = (dir == "W" and width) or 1
        local target = nil
        for lookahead = lookstart, lookstop, step do

            if map[row][lookahead] == nil then
                if target == nil then 
                    target = lookahead
                end
            elseif map[row][lookahead] == "#" and lookahead < height then
                target = nil
                -- target = lookahead + step
                -- if map[row][target] ~= nil and lookahead < height then
                --     for i=1,height do
                --         --try find empty spot
                --         target = target + step
                --         if target > height or map[row][target] == nil then
                --             break
                --         end
                --     end
                -- end
            elseif map[row][lookahead] == "O" and target ~= nil then
                map[row][target] = map[row][lookahead]
                map[row][lookahead] = nil
                target = target + step
            end
            --print('stat', lookahead, target)
            --if lookahead >= 10 then break end
        end
        --if col >= 3 then break end
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
for i=1,1000000000 do

    cycle()
    if i%100000 == 0 then print(string.format("Cycle #%d P1 Score %d P2 Score %d", i, P1, scoremap())) end

end
print(mapstring(map))

P2 = scoremap()



print('\nDay Fourteen')
print(string.format('Part 1 - Answer %d',P1)) -- 105249
print(string.format('Part 2 - Answer %d', P2)) -- 88680

--[[
    P1 
    6702153 too high

    P2 
    88772 too high, 100,000 cycles (0.01%)
    88765 ?? 200,000 cycles
    88711 ?? 300,000 cycles
    88680 ?? 400,000 cycles (A Christmas fucking miracle)

    I have a feeling it's another LCM ish trick
    Track each bolder to see how long it takes to cycle
    If cycle length is steady, position in future can be calculated

]]