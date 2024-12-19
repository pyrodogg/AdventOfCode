package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
--local rex = require"rex_pcre2"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local towel = {}
local pattern = {}

for _,v in pairs(lines) do
    if v:find(",") then
        towel = unroll(v:gmatch("(%w+)"))

    elseif v~= "" then
        table.insert(pattern,v)
    end
end

local towel_rack = {}
local max_towel_length = 0
for k,v in pairs(towel) do
    if #v > max_towel_length then max_towel_length = #v end

    towel_rack[v] = true
end

-- Initial Regex solution to part 1
-- local rextest = "^(?:("..table.concat(towel,")|(").."))+?$"
-- local r = rex.new(rextest)

-- All operations bounded 1 to #v so reusing table
local step_ways = {}
local v_map = {}
for _,v in pairs(pattern) do
    -- local s,e,y =  r:find(v)

    -- if s==1 and e== #v then
    --     P1 = P1 + 1
        
        --[[
        Go through string once and check all of the 1-,2-,n- sub string matches
        from dictionary
        ]]
        for i = 1, #v do
            v_map[i] = {}
            for j = 0, math.min(max_towel_length-1,#v-i) do
                local stub = v:sub(i,i+j)
                if towel_rack[stub] then
                    table.insert(v_map[i],stub)
                end
            end
        end

        --[[
        Working backwards from end of string
        Assume index i has 1-,2,3- length matches
        Score for index i is score[i+1]+score[i+2],score[i+3]
        ]]
        step_ways[#v+1] = 1 --"empty space"
        for i = #v, 1, -1 do

            step_ways[i] = 0
            for j=1,#v_map[i],1 do
                step_ways[i] = step_ways[i] + step_ways[i+#v_map[i][j]]
            end
        end

        P2 = P2 + step_ways[1]
        if step_ways[1] > 0 then
            P1=P1+1
        end
        --end
    end

print('\n2024 Day Nineteen')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %s', P2)) --