package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
for k,v in pairs(lines) do

    for j,i in v:gmatch('()'..'([()])'..'') do
       if i == '(' then
        P1 = P1 + 1
       else
        P1 = P1 - 1
       end
       if P1 == -1 and P2 == 0 then
        P2 = j
       end
    end
end


print('\nDay One')
print(string.format('Part 1 - Answer %d',P1)) -- 280
print(string.format('Part 2 - Answer %d', P2)) -- 
