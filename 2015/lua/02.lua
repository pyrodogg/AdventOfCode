package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
for k,v in pairs(lines) do

    local dims = sort(map(unroll(v:gmatch('(%d+)')),tobase10))
    P1 = P1 + 2*(dims[1]*dims[2] + dims[2]*dims[3] + dims[1]*dims[3]) + dims[1]*dims[2]
    
    P2 = P2 + 2*(dims[1]+dims[2]) + dims[1]*dims[2]*dims[3]
end

print('\nDay Two')
print(string.format('Part 1 - Answer %d',P1)) -- 1586300
print(string.format('Part 2 - Answer %d', P2)) -- 3737498
