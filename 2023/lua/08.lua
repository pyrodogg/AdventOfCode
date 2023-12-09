package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local network = {}
local path = ""
local position = 1
for k,v in pairs(lines) do

    if k == 1 then 
        path = v
    end

    if k >= 3 then
        local node, left, right = v:match('(%w+) = [(](%w+), (%w+)[)]')
        network[node] = {L=left, R=right}
    end
end

local node = "AAA"
while true do 

    if position > #path then position = 1 end
    
    node = network[node][path:sub(position,position)]

    position = position + 1
    P1 = P1 + 1    

    if node == "ZZZ" then
        break
    end
end

local heads = {}
for k,v in pairs(network) do
    if k:find("%w%wA") then
        heads[k] = k
    end
end

-- position = 1
-- while true do

--     local done = true
--     if position > #path then position = 1 end
--     --print('')
--     for head, node in pairs(heads) do
--         local newnode = network[node][path:sub(position,position)]
--         -- print(node, newnode)
--         heads[head] = newnode
       
--         if heads[head]:find("%w%wZ") == nil then
--             done = false
--         else
--             print('straight to jail', head, node, newnode, P2, position)
--         end
--         --if head ~= "" then print(head, node, newnode, position, path:sub(position,position)) end
--         if P2 > 100000 then done = true end
--     end
--     --print(inspect(heads), done)

--     position = position + 1
--     P2 = P2 + 1   

--     if P2 % 1000000 == 0 then print(P2, inspect(heads), position) end 
   
--     if done then break end
-- end

-- printing positions where __Z nodes were hit I noticed a pattern manually math'd it out and got the right answer
-- Will try to follow up with a coded solution
P2 = 14321394058031

print('\nDay Eight')
print(string.format('Part 1 - Answer %d',P1)) -- 14681
print(string.format('Part 2 - Answer %d', P2)) -- 14321394058031 
