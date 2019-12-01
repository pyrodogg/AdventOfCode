

require "util"


print('Day 5 - Part 1')

local input = '05 - Input.txt'
local polymer = {}
local units = {}

for i in io.lines(input)():gmatch('%a') do
    table.insert(polymer,i)
    local u = i:lower()
    if units[u] == nil then
        units[u]  = {unit = u}
    end
end 

print('Begin polymer reaction...')
print('Initial polymer length '..#polymer)


function react(polymer)

    local react = true
    local pass = 1

    while react do
        react = false
        for i=#polymer-1,1,-1 do 

            local unitA = polymer[i]
            local unitB = polymer[i+1]

            if (unitA ~= unitB) and (unitA:upper() == unitB or unitA:lower() == unitB) then
                table.remove(polymer,i+1)
                table.remove(polymer,i)
                react = true
            end 
        end
        --print('Polymer size after pass ['..pass..'] '..#polymer)
        pass = pass + 1
    end

    return polymer
end

local part1Answer = #react(polymer)

function removeUnit(polymer, unit)
    local ret = {}
    
    for k,v in pairs(polymer) do
        if v:lower() ~= unit:lower() then
            table.insert(ret,v)
        end
    end

    return ret
end


print('Day 5 - Part 1 - Answer\n'..part1Answer..'\n\n')

units = map(units, function(v,k,t) 

            v.res = #react(removeUnit(polymer,v.unit))
            return v
        end)

local bestUnit = minBy(units,'res')

print('Day 5 - Part 2 - Answer\n'..'Unit '..bestUnit.unit..' , final size = '..bestUnit.res)

