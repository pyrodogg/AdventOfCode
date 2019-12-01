-- Read input file
-- Parse each line into a number
-- Apply numbers in sequence

require "util"

print('Part 1')

local file = '01 - Input.txt'
local lines = lines_from(file)

local accumulator = 0

for k,v in pairs(lines) do
    print('Current frequency: ' ..accumulator.. ', adjusting by [' ..v.. ']')
    lines[k] = tonumber(v)
    accumulator = accumulator + lines[k]
end

print('Final frequency: ' ..accumulator)
print('\n\n')

print('Part 2')

local frequencies = {}
accumulator = 0
local stop = false

for i=1,10000 do
  print('Starting pass [' ..i.. '] with ' ..#frequencies.. ' tracked frequencies')
  for k,v in pairs(lines) do
    accumulator = accumulator + v
    if frequencies[accumulator] == nil then 
      frequencies[accumulator] = 1
    else
      print('First doubled frequency is: ' ..accumulator)
      stop = true
    end
    if stop then break end
  end 
  if stop then break end
end