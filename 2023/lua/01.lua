require "util"
local lpeg = require "lpeg"

-- 2023 Advent of Code Puzzle 1
--
-- Part 1
-- Read input file
-- Each line find first and last digit, concatenate into number like '1','2' makes 12
-- Sum all such numbers

-- From stack overflow
function findLast(haystack, needle)
  local i = haystack:match(".*"..needle.."()")
  if i==nil then return nil else return i-1 end
end

local Cp = lpeg.Cp()
function anywhere (p)
  return lpeg.P{ Cp * p * Cp + 1 * lpeg.V(1)}
end 

print('Part 1')

local file = '../input/01.txt'
local lines = lines_from(file)

local values_part1 = {}
values_part1[1] = "1"
values_part1[2] = "2"
values_part1[3] = "3"
values_part1[4] = "4"
values_part1[5] = "5"
values_part1[6] = "6"
values_part1[7] = "7"
values_part1[8] = "8"
values_part1[9] = "9"

local values_part2 = values_part1
values_part2[10] = "one"
values_part2[11] = "two"
values_part2[12] = "three"
values_part2[13] = "four"
values_part2[14] = "five"
values_part2[15] = "six"
values_part2[16] = "seven"
values_part2[17] = "eight"
values_part2[18] = "nine"


function reverseTableValues(t) 
  local o = {}
  for k,v in pairs(t) do
    o[k] = v:reverse()
  end
  return o
end

local values_part2_rev = reverseTableValues(values_part2)


local accumulator = 0 
for k, v in pairs(lines) do 

  --Find first and last digit
  local first_index = v:match("()".."%d"..".*")
  local last_index = findLast(v,'%d')
  local first = tonumber(v:sub(first_index,first_index))
  local second = tonumber(v:sub(last_index, last_index))

  -- local numbers = lpeg.R("09")
  -- local one = lpeg.P("one")
  -- local seven = lpeg.P("seven")
  -- local eight = lpeg.P("eight")

  -- local patt_forward = numbers + one + seven + eight
  -- local any_p_f = anywhere(patt_forward)

  --Sum to accumulator
  accumulator = accumulator + first*10 +second

  --if k > 6 then break end
end

print('Part 1 Accumulator: ' ..accumulator)


-- Part 2
-- Also need to consider numbers "one,"two", etc up to "nine"
-- "No Zero", No Ten or higher
-- Watch out for "overlapping" words like oneight
-- Sixteen is only a six
--
print ('Part 2')

function findFirstValue(t,s)
  local r = nil
  local first = 999999
  local ans
  for k, v in pairs(t) do
    r = s:match("()"..v..".*")
    if (r or 999999) < first then 
      if k < 10 then
        ans = k
      else 
        ans = k-9
      end
      first = r 
    end
  end
  return ans
end


local accumulator_pt2 = 0

for k,v in pairs(lines) do
  local first = findFirstValue(values_part2, v)
  local last = findFirstValue(values_part2_rev, v:reverse())

  accumulator_pt2 = accumulator_pt2 + first*10 + last

end

print('Part 2 Accumulator: ' ..accumulator_pt2)
