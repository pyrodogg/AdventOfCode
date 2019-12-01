
-- Separately count IDs matching the following criteria
    -- Exactly two of any letter
    -- Exactly three of any letter
-- Multiply the counts together to get the checksum

require "util"



print("Day 2 - Part 1")
local part1Start = os.clock()

local file = "02 - Input.txt"
local lines = lines_from(file)

local twoes = 0
local threes = 0


for k,v in pairs(lines) do
    
    local freq = {}
    for i=1, #v do
        local char = v:sub(i,i)
        if freq[char] ==  nil then
            freq[char] = 1
        else
            freq[char] = freq[char] + 1
        end
    end
    local foundTwo = false
    local foundThree = false
    for k,v in pairs(freq) do
        if v == 2 and foundTwo == false then
            foundTwo = true
            twoes = twoes + 1
        elseif v == 3 and foundThree == false then
            foundThree = true
            threes = threes + 1
        end
        if foundTwo and foundThree then 
            break
        end
    end
    print('Line ['..k..'] ' ..v.. ' 2: ' ..twoes.. ' 3?: ' ..threes)
end

local part1Answer  = twoes  * threes
print('\nDay 2 - Part 1 - Answer\n\t' ..part1Answer.. '\n')
local part1Stop = os.clock()
print(string.format('Time elapsed: %.2f\n\n', part1Stop - part1Start))


print('Day 2 - Part 2')
local part2Start = os.clock()
local part2Answer = ''

-- Iterate through each line and check for matches with a levenstein distance of 1
local stop = false
for k,strA in pairs(lines) do
    for i=k+1,#lines do
        local strB = lines[i]
        local dist = levenshtein(strA,strB)
        if dist == 1 then
            stop = true
            print('line ['..k..'] ' ..strA.. ' - ['..i..'] ' ..strB.. ' = ' ..dist)

            for j=1,#strA do 
                if strA:sub(j,j) == strB:sub(j,j) then
                    part2Answer = part2Answer .. strA:sub(j,j)
                end
            end
            break
        end
    end
    if stop then break end
end

print('\nDay 2 - Part 2 - Answer\n\t' ..part2Answer.. '\n')
local part2Stop = os.clock()
print(string.format('Time elapsed: %.2f\n\n', part2Stop - part2Start))