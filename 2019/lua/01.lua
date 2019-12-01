require "util"

print('Part 1')

local file = '../inputs/01.txt'
local lines = lines_from(file)

local accumulator = 0

for k, v in pairs(lines) do
    -- Divide by 3, round down, subtract 2

    accumulator = accumulator + math.floor(tonumber(v)/3) - 2
end

print('Part 1 Solution: ' ..accumulator)

accumulator = 0 -- reset 

for k, v in pairs(lines) do
    -- account for extra mass of added fuel
    local extraFuel = tonumber(v)

    while extraFuel > 0 do
        extraFuel = math.floor(tonumber(extraFuel)/3) -2

        if extraFuel > 0 then 
            accumulator = accumulator + extraFuel
        end
    end

end 

print('Part 2 Solution: ' ..accumulator)