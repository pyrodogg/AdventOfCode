package.path = package.path .. ';../../?.lua'
require "util"
-- require "luarocks.loader"
local inspect = require "inspect"
local aoc = require "lib.aoc"
local maths = require "lib.maths"
local C = require "lib.combine"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local bitmap = {}
local function getMask(n,bits)
    if bitmap[n] then
        return bitmap[n]
    end
    local res = 0

    bitmap[n] = res
end

--create lookup table for octal to binary
local oct2bin = {
    ['0'] = '000',
    ['1'] = '001',
    ['2'] = '010',
    ['3'] = '011',
    ['4'] = '100',
    ['5'] = '101',
    ['6'] = '110',
    ['7'] = '111'
}
local function getOct2bin(a) return oct2bin[a] end
local function convertBin(n, bits)
    local s = string.format('%o', n)
    local s = string.format('%.4o', n)
    s = s:gsub('.', getOct2bin)
    return s:sub(-bits)
end

-- local function combinations(array, length, prev_arr) 
--     prev_arr = prev_arr or {}
--     if #prev_arr == length then
--         return prev_arr
--     end
--     combs = {}
--     for k,v in pairs(array) do
--        table.insert(prev_arr,v)
--        table.insert(combs, combinations(array[])
--     end
-- end 


for k,v in pairs(lines) do
    -- local l = unroll(v:match("%[(.+)]"):gmatch("."))
    local l = map(unroll(v:match("%[(.+)]"):gsub("[.]",0):gsub("#",1):gmatch(".")),tobase10)
    local b = map(unroll(v:gmatch("%b()")),function(v) 
        return aoc.intsFromLine(v) end)
    local j = aoc.intsFromLine(v:match("%{.*%}"))
    --print(inspect(l))
    --print(inspect(b))
    -- print(inspect(j))
    local states = {}
    --table.insert(states,l)

    for rank = 1, #b do
        -- get button(s) to flip
        local f = C.combn(b,rank)
        local done = false
        while true do
            local x = {f()}
            if #x == 0 then break end
            -- print(inspect(x))
            local t = table.shallow_copy(l)
            -- local jt = table.shallow_copy(j)

            -- 0 = x*A + y*B + z*C ...
            -- find x,y,z,...
            -- [ 0,0,0,1   * [x y z w] = {a,b,c,d}
            --   0,1,0,1
            --   0,0,1,0
            --   0,0,1,1
            --   1,0,1,0
            --   1,1,0,0 ]

            --[[
              ax + by + c = 0
              1x + 101y + 10z + 11w + 1010u + 1100t - 3547 = 0 (min x,y,z,w,u,t) all >0
              u + t - 3 = 0
              y + t - 5 = 0
              z + w + u - 4 = 0
              x + y + w - 7 = 0
            ]]

            for i=1,#x do -- for each button in button set
                --print(inspect(x[i]))
                
                -- do transform
                for b=1, #x[i] do-- for each channel in button
                   if t[x[i][b]+1] == 1 then
                    t[x[i][b]+1] = 0
                   else
                    t[x[i][b]+1] = 1
                   end

                --    jt[x[i][b]+1] = jt[x[i][b]+1] - 1
                end

                -- if goal increase P1
                if tobase10(table.concat(t)) == 0 then
                    --print(inspect(t))
                    done=true
                end
                -- break -- testing
            end
            if done then break end
        end
        if done == true then
            P1 = P1 + rank
            break
        end
    end

    local tj = {}
    for i=1, #b do
        tj[i] = table.shallow_copy(j)
    end
    for rank = 1, 100 do
        local done = false

        -- try rank number of button presses 
        for i,t in pairs(tj) do
            if #t == 0 then goto continue end

            print(inspect(t))
            local bad = false
            for j =1, #b do

                local btn = b[j]

                for c=1, #btn do
                    
                    t[btn[c]+1] = t[btn[c]+1] - 1
                    if t[btn[c]+1] < 0 then
                        -- Individual jolt went negative
                        tj[i] = {}
                        --print("BAD")
                        bad = true
                        break
                    end
                end

                if tobase10(table.concat(t)) == 0 then
                    P2 = P2 + rank
                    done = true
                    break
                end
                if bad then break end
                if done then break end
            end
            if done then break end
            ::continue::
        end
        if done then break end
    end
end


-- Fewest button pressess == shortes path through graph that keeps it odd
-- Initial state for all lamps is OFF, GOAL is provided
-- Buttons toggle ALL lights
-- !! Button light indexes are 0-based
-- !! XOR is associative and commutative!!!
-- ! TEST Combinations not all Permutations, can only be taken once and order doesn't matter!

-- print(inspect(points))

print('\n2025 Day Ten')
print(string.format('Part 1 - Answer %s',P1)) -- 505
print(string.format('Part 2 - Answer %d', P2)) -- 

