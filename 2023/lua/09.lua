package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

-- for _,v in pairs(lines) do

--     local seq = {}
--     seq[1] = map(unroll(v:gmatch("([-]*%d+)")),tobase10)

--     local level = 2
--     while true do 
--         local allzero = true
--         seq[level] = {}
--         for k= 1, #seq[level-1] - 1 do
            
--             local diff = seq[level-1][k+1] - seq[level-1][k]
--             if diff ~= 0 then allzero = false end
--             table.insert(seq[level], diff)
--         end
--         level = level  +1
--         if allzero then break end
--     end

--     for k = #seq, 1, -1 do 
--         local newdiff = 0
--         if k == #seq then 
--             newdiff = 0
--         else
--             newdiff = seq[k][#seq[k]] + seq[k+1][#seq[k+1]]
--         end
--         table.insert(seq[k],newdiff)
--     end

--     P1 = P1 + seq[1][#seq[1]]
-- end

-- -- Part 2
-- for _,v in pairs(lines) do
    
--     local seq = {}
--     seq[1] = map(unroll(v:gmatch("([-]*%d+)")),tobase10)

--     local level = 2
--     while true do 
--         local allzero = true
--         seq[level] = {}
--         for k = 1, #seq[level-1] - 1 do
            
--             local diff = seq[level-1][k+1] - seq[level-1][k]
--             if diff ~= 0 then allzero = false end
--             table.insert(seq[level], diff)
--         end
--         level = level  + 1
--         if allzero then break end
--     end

--     for k = #seq, 1, -1 do 
--         local newdiff = 0
--         if k == #seq then 
--             newdiff = 0
--         else
--             newdiff = seq[k][1] - seq[k+1][1]
--         end
--         table.insert(seq[k],1,newdiff)
--     end

--     P2 = P2 + seq[1][1]
-- end

-- Recursive method
local function extrapolate(seq,fwd)
    if fwd == nil then fwd = true end
    local sign = (fwd and 1) or -1
    local allzero = true
    for _, v in ipairs(seq) do
        if v ~= 0 then
           allzero = false
        end
    end
    if allzero then 
        return 0
    end

    local next = {}
    for i = 1, #seq-1 do
        next[i] = seq[i+1] - seq[i]
    end

    --last = ((last or 0)*sign + seq[((fwd and #seq) or 1)])
    return seq[((fwd and #seq) or 1)] + extrapolate(next, fwd) * sign
end

P1, P2 = 0,0
for _, v in pairs(lines) do
    
    local seq = map(unroll(v:gmatch("([-]*%d+)")),tobase10)
    P1 = P1 + extrapolate(seq)
    P2 = P2 + extrapolate(seq, false)

end

print('\nDay Nine')
print(string.format('Part 1 - Answer %d',P1)) -- 1921197370
print(string.format('Part 2 - Answer %d', P2)) -- 1124
