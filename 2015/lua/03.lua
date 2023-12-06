package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 1, 0


local map = {}
map[tokey(0,0)] = 1 --house origin starts with one present
local mapP2 = {}
mapP2[tokey(0,0)] = 2 --house origin starts with one present
local x,y = 0,0 --x=left,right, y=up,down
local rx,ry = 0,0
for k,v in pairs(lines) do
    
    for i,j in v:gmatch('()'..'([%^%<%v%>])'..'') do
       if j == '^' then y = y+1
       elseif j == '>' then x = x+1
       elseif j == '<' then x = x-1
       elseif j == 'v' then y = y-1
       end
       if map[tokey(x,y)] == nil then
        P1 = P1 + 1
       end
       map[tokey(x,y)] = (map[tokey(x,y)] or 0) + 1
    end
    x,y,rx,ry = 0,0,0,0
    for i,j,r in v:gmatch('()'..'([%^%<%v%>])([%^%<%v%>])'..'') do
        if j == '^' then y = y+1
        elseif j == '>' then x = x+1
        elseif j == '<' then x = x-1
        elseif j == 'v' then y = y-1
        end

        if r == '^' then ry = ry+1
        elseif r == '>' then rx = rx+1
        elseif r == '<' then rx = rx-1
        elseif r == 'v' then ry = ry-1
        end

        mapP2[tokey(x,y)] = (mapP2[tokey(x,y)] or 0) + 1
        mapP2[tokey(rx,ry)] = (mapP2[tokey(rx,ry)] or 0) + 1
        
     end
end

for i in pairs(mapP2) do P2 = P2 + 1 end

print('\nDay Three')
print(string.format('Part 1 - Answer %d',P1)) -- 2565
print(string.format('Part 2 - Answer %d', P2)) -- 2639
