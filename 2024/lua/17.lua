
package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
-- ---@alias v2call fun(x:number|table, y:number?): Vec2D
-- ---@type Vec2D | v2call
-- local Vec2D = require "lib.vec2d"
local tuple = require "tuple"
local binaryheap = require 'binaryheap'

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function parseInput(lines)
    local registers = {}
    local instr = {}
    for k,v in pairs(lines) do
        local reg, val = v:match("Register (%a): (%d+)")
        if reg then
            registers[reg] = tobase10(val)
        elseif v ~= "" then
            instr = map(unroll(v:gmatch("%d")),tobase10)
        end
    end

    return registers, instr
end

local function decodeOperand(operand,mem)
    assert(operand >= 0 and operand < 7, "Invalid operand",operand,"out:", table.concat(mem.out,","))

    if operand <= 3 then
        return operand
    elseif operand == 4 then
        return mem.A
    elseif operand == 5 then
        return mem.B
    elseif operand == 6 then
        return mem.C
    end
end

local function executeInstr(instr,mem, part2)
    part2 = part2 or false
    local instr_pointer = 1
    mem.out = {}
    
    while true do
    
        local opcode = instr[instr_pointer]
        local operand = instr[instr_pointer+1]
        if opcode == nil or operand == nil then 
        --    print("HALT!") 
            break
        end
    
        --[[
            000 0 adv a=a//2^Coperand
            001 1 bxl 
            010 2 bst 
            011 3 jnz
            100 4 bxc
            101 5 out
            110 6 bdv
            111 7 cdv
        ]]
        if opcode == 0 then
            mem.A = mem.A//(2^decodeOperand(operand,mem))
            --instr_pointer =  instr_pointer + 2
        elseif opcode == 1 then
            mem.B = mem.B ~ operand
        elseif opcode == 2 then
            -- mem.B=decodeOperand(operand, mem)%8
            mem.B=decodeOperand(operand, mem)&7

        elseif opcode == 3 then
            if mem.A ~= 0 then
                instr_pointer = operand+1
                goto continue
            end
        elseif opcode == 4 then
            mem.B = mem.B ~ mem.C
        elseif opcode == 5 then
            local r = decodeOperand(operand,mem)%8
            local o = string.format("%d",r)
            -- print(o)
            table.insert(mem.out,r)
            if part2 then
                --validate out
                -- if instr[#instr-#mem.out+1] ~= r then
                --     -- print(instr[#instr-#mem.out+1],r)
                --     -- print("P2 HALT!",r)
                --     -- print("instr:",table.concat(instr,","))
                --     -- print("mem:", table.concat(mem.out,","))
                --     return "", false
                --     --break
                -- end
            end
            
        elseif opcode == 6 then
            mem.B = mem.A//(2^decodeOperand(operand, mem))
        elseif opcode == 7 then
            mem.C = mem.A//(2^decodeOperand(operand, mem))
        end
        -- print(instr_pointer, inspect(mem))
        
        instr_pointer =  instr_pointer + 2
        ::continue::
    end
    --Halted

    return table.concat(mem.out,","), true
end

local mem, instr = parseInput(lines)
print("P1 out:",executeInstr(instr,mem))
--print(inspect(mem))

print(string.format("%d",4*8^15),string.format("%d",7*8^15))
-- assert(false)

mem, instr = parseInput(lines) --50000000
local maxlen=0
local low,high = 0,8
local matchidx = 0
local checkinstr

for loop = 0,#instr-1 do
    -- from low to high test low+i 
    -- if find instr[matchidx] then low = A*8, high = ((a+1)*8)-1
    -- loop
    local loopok = false
    checkinstr = {}
    for j=#instr-loop,#instr do
        table.insert(checkinstr,instr[j])
    end

    -- print(inspect(checkinstr))

    -- print("low-high",low,high)
    for testA = low, high do

        local testMem = table.shallow_copy(mem)
        testMem.A = testA

        --print("Test:",testA,inspect(testMem))
        local testOut, testOK = executeInstr(instr,testMem,true)
        --if testA % 10000 == 0 then print("Test:",testA,testA,table.concat(testMem.out,",")) end
        if true or #testMem.out > maxlen then
            maxlen=#testMem.out
            print(testA,table.concat(testMem.out,",",1,#testMem.out))
        end

        local seqok = true
        if #testMem.out ~= #checkinstr then seqok = false end
        if seqok then
            -- print("why",inspect(checkinstr),inspect(testMem.out))
            for i=1,#checkinstr do
                if checkinstr[i] ~= testMem.out[i] then
                    seqok = false
                end
            end
        end
        if seqok then
            print("OK!")
            
            low= testA*8-1
            high=((testA)*8*8)-1
            print(string.format("Found %d low-high %d-%d",testA,low,high))
            loopok = true
            break
        end

        -- if #testMem.out == #instr then
        --     local allok = true
        --     print(#testMem.out,#instr)
        --     for i=1,#testMem.out,1 do
        --         if testMem.out[i] == (instr[i].."") then
        --             --OK
        --             -- print("match",testMem.out[i],instr[i])
        --         else
        --             -- print("match",testMem.out[i],instr[i])
                    
        --             allok = false
        --         end
        --     end
        --     if allok then
        --         P2 = testA
        --         print("P2",testA,table.concat(testMem.out,","))
        --         break
        --     end
        -- end
    end
    if not loopok then
        break
    end
end

-- print("P2 out:",mem.A,executeInstr(instr,mem))




print('\n2024 Day Seventeen')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
