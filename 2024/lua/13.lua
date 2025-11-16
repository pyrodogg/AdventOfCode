package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
-- local linear = require("linear")

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local game = {}
local gameindex = 1
for k,v in pairs(lines) do
    
    if #v>0 then
        local g = game[gameindex] or {}
        if v:match("A") then
            g.a = aoc.intsFromLine(v)
            game[gameindex] = g
            -- print(inspect(g.a))
        elseif v:match("B") then
            g.b = aoc.intsFromLine(v)
            game[gameindex] = g
        elseif v:match("Prize") then
            g.p = aoc.intsFromLine(v)
            game[gameindex] = g
            gameindex = gameindex+1
        end
    end
end

-- Initial solve was brute force, nice for verifying specific results
local function brute(k,v,part2)
        local limit = 100
        if part2 then limit = 10000000000000 end
        for a=0, limit, 1 do
            if v.score then break end
            
            for b=0,limit,1 do
                if a*v.a[1] + b * v.b[1] == v.p[1] and a * v.a[2] + b * v.b[2] == v.p[2] then

                    print(string.format("game %d brute a=%d b=%d score is %d",k,a,b,a*3+b))
                    v.score = a*3+b
                    P1 = P1 + v.score
                    return true
                end
            end
        end

end

-- https://stackoverflow.com/a/58411671
local function round_pedro(num)
    if math.abs(num) > 2^52 then
      return num
    end
    return num < 0 and num - 2^52 + 2^52 or num + 2^52 - 2^52
  end

local function smart(k,v, part2)

        local x_prize, y_prize = v.p[1],v.p[2]
        local x_a, x_b = v.a[1], v.b[1]
        local y_a, y_b = v.a[2], v.b[2]

        if part2 then
            x_prize = x_prize + 10000000000000
            y_prize = y_prize + 10000000000000
        end

        -- Solution with Lua Linear module, something to explore in the future
        -- local A = linear.tolinear({ { x_a, x_b }, { y_a, y_b } })
        -- local B = linear.matrix(2, 1)
        -- local q = linear.tvector(B, 1)  -- column vector
        -- q[1], q[2] = x_prize, y_prize
        -- linear.gesv(A, B)
        -- print("solutions", q[1], q[2])

        -- Manuall elimination calculation
        -- local a = (x_prize/x_a) - ((x_b/x_a)*y_prize-((x_b/x_a)*y_a*x_prize/x_a))/(y_b-(y_a*x_b/x_a))
        -- local b = ((y_prize-(y_a*x_prize/x_a))/(y_b-(y_a*x_b/x_a)))
        -- Inverse Matrix Formula / Cramer
        local a = (y_b*x_prize - x_b*y_prize)/(x_a*y_b - x_b*y_a)
        local b = (-y_a*x_prize + x_a*y_prize)/(x_a*y_b - x_b*y_a)
        -- Uncurse the floating point
        local a_trim = round_pedro(a)
        local b_trim = round_pedro(b)

        -- Test results
        local test1 = a_trim*x_a + b_trim*x_b == x_prize
        local test2 = a_trim*y_a + b_trim*y_b == y_prize

        --print(string.format("%d * %d + %d * %d = %d (%s)",a_trim,x_a,b_trim,x_b,x_prize,test1))
        -- print(string.format("%d * %d + %d * %d = %d (%s)",a_trim,y_a,b_trim,y_b,y_prize,test2))

        local score = test1 and test2 and a_trim*3+b_trim or 0
        -- print(string.format("game %d smart a=%f (%d)  b=%f (%d) \ntests %s and %s score is %d\n",k,a,a_trim,b,b_trim,test1,test2,score))
        -- print(string.format("Test results %s and %s",test1,test2))

        if test1 and test2 then
            return score
        else
            return 0
        end
end

for k,v in pairs(game) do
    -- if k > 2 then break end
    -- local b = brute(k,v,false)
    P1 = P1 + smart(k,v,false)
    P2 = P2 + smart(k,v,true)

end



print('\n2024 Day Thirteen')
print(string.format('Part 1 - Answer %d',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
