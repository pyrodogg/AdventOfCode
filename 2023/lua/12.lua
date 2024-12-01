package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function decending(t,a,b)
    if t[a] > t[b] then
        return true
    else
        return a > b
    end
end

local gears = {}
for k,v in pairs(lines) do
    local pattern = v:match("([%.%#%?]*)")
    local numbers = map(unroll(v:gmatch("(%d+)")),tobase10)

    table.insert(gears,{pattern=pattern, numbers=numbers})
    -- Sum number of possible patterns
    -- Fit largest number first,decending but keep position order

    -- ???.### total pattern length = 7
    -- 1,1,3   total groups 3, total damaged gears = 5
    -- needed one additional space to make 2 (7-5)
    -- chose 1 from 3 such that rules are met?

    -- Construct new sequence of 7 length with groups 1,1,3 in size
    -- "diff" the new sequence with the pattern?

    -- ?###???????? 3,2,1
    -- Need 3+ gaps, total of 6 spaces
    -- 'fitting' a number also means ensuring 'space around' it (maybe pre/pos add '.')
    -- fitting 3 means we're looking for a 5 wide '.###.' pattern
    -- Since it's first, nothing before but space after is at least 5 items (2 spaces, 3 gears) 

    -- Number gets 'fixed' to position if matching gear set (size, position) is found.
    -- .###.???????  <- sub divide same as ??????? 2,1
    -- .###.

    -- a choose 2 + b choose 1, where a+b == 7

    -- Super brtfs method, flip bits and test for valid pattern

end

local function toBits(num,bits)
    -- https://stackoverflow.com/a/9080080
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end

local function betteropts(size, gears, mingroup, maxgroup)

    -- Gears are one if consecutive, so multiple need to be separated by space
    -- Ex. size=5, gears=2 then there are 5 choose 2 choices
    -- Could be further restricted if we know that max group is 1

    -- Start all gears on the left, gradually shift each gear right
    return coroutine.wrap(function ()
    
        while true do

             --Shift
            --###... -> ##.#.. -> ##..#. -> ##...# (etc.)
            local stuff ={}
            for i=0, size do
                -- fill with gear or space?


            end

            local opt = stuff.concat()

            coroutine.yield(opt)
        end
        coroutine.yield(nil)
    end)
end

local function genopts(n_opts)
    
    return coroutine.wrap(function()
        -- for each binary digit of i do true/false
        
        for i = 0, 2^n_opts-1 do
            local opts = toBits(i,n_opts)
            coroutine.yield(i,opts)
        end
        coroutine.yield(nil)
    end)
end

local function testpattern(patt, groups, guess)

    if #guess ~= #patt then return false end
    local guessbad = unroll(guess:gmatch("()([%#]+)"))
    -- correct length of guess

    if #guessbad ~= #groups then return false end
    -- correct number of bad groups

    for i=1,#groups do
        if #guessbad[i][2] ~= groups[i] then
            return false
        end
    end

    return true
end

local time = os.time()
--local f = assert(io.open("log/12-out"..time..".txt","w"))

--Part 1 brtue force from hell
for k, v in pairs(gears) do
    
    local length = #v.pattern
    local unknown = unroll(v.pattern:gmatch("()([%?])"))
    --local good = unroll(v.pattern:gmatch("()([%.])"))
    -- local bad = unroll(v.pattern:gmatch("()([%#])"))
    -- local groups = #v.numbers
    --print(k, #unknown, 2^#unknown , v.pattern, inspect(v.numbers))
    --print(inspect(unknown))

    local P1part = 0

    for i, opts in genopts(#unknown) do
        local guess=""
        local unknownindex = 1
        for j=1,length do
            if v.pattern:sub(j,j) == "." then
                guess = guess.."."
            end

            if v.pattern:sub(j,j) == "#" then
                guess = guess.."#"
            end

            if v.pattern:sub(j,j) == "?" then

                if opts[unknownindex] == 0 then
                    guess = guess.."."
                    
                else
                    guess = guess.."#"
                end

                unknownindex = unknownindex + 1
            end

        end

        -- Todo Test guess
        if testpattern(v.pattern, v.numbers, guess) then
            --print('P1', k, i, guess)
            P1 = P1 + 1
            P1part = P1part + 1
        end
    end

    -- local P2part = 0
    -- -- prefix with ? if ends with . or ? otherwise .
    -- -- To ensure spacing you don't know if bunch end gear is complete!!!
    -- -- print('fuuuck', v.pattern)
    -- local unkn = #unknown
    -- --print(v.pattern:sub(#v.pattern-v.numbers[#v.numbers]+1,#v.pattern))
    -- --print(v.pattern:sub(1,v.numbers[1]))
    -- if v.pattern:sub(#v.pattern-v.numbers[#v.numbers]+1,#v.pattern) == string.rep("#",v.numbers[#v.numbers]) then
    --     -- Part 1 was solved correctly meaning if string starts or ends with #
    --     -- Then it is a complete and correct gearset which cannot be changed
    --     v.pattern = "."..v.pattern.."."
    --     --unkn = unkn + 1
    -- elseif v.pattern:sub(1,v.numbers[1]) == string.rep("#", v.numbers[1]) then
    --     --print("FFFFUUUCK")
    --     v.pattern = "."..v.pattern.."."
    --     --unkn = unkn + 1
    -- else
    --     v.pattern = "?"..v.pattern.."?"
    --     unkn = unkn + 2
    -- end
    -- -- print(k, v.pattern)
    -- for i, opts in genopts(unkn) do
    --     local guess=""
    --     local unknownindex = 1
    --     for j=1,#v.pattern do
    --         if v.pattern:sub(j,j) == "." then
    --             guess = guess.."."
    --         end

    --         if v.pattern:sub(j,j) == "#" then
    --             guess = guess.."#"
    --         end

    --         if v.pattern:sub(j,j) == "?" then

    --             if opts[unknownindex] == 0 then
    --                 guess = guess.."."
                    
    --             else
    --                 guess = guess.."#"
    --             end

    --             unknownindex = unknownindex + 1
    --         end
    --     end
        
    --     -- Todo Test guess
    --     if testpattern(v.pattern, v.numbers, guess) then
    --         --print('P2', k, i, guess)
    --         --P1 = P1 + 1
    --         P2part = P2part + 1
    --     end
    -- end
    -- local logstring = string.format("Puzzle #%d P1part %d \tP2part1 %d \t P2part2 %d \t %s \t %s", k, P1part, P2part,P1part*P2part^4, v.pattern, inspect(v.numbers))
    -- print(logstring)
    -- f:write(logstring.."\n")
    -- P2 = P2 + (P1part * P2part^4)
    --if k >= 10 then break end
end

-- f:write(string.format("P1 %d\n", P1))
-- f:write(string.format("P2 %d\n", P2))
-- f:close()


print('\nDay Twelve')
print(string.format('Part 1 - Answer %d',P1)) -- 7221
print(string.format('Part 2 - Answer %d', P2)) -- 

--[[
P2 
4187844968761 TOO LOW!?!?!
4180195131332
4181209836508 (not submitted, stil to fucking low)

]]