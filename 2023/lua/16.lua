package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local function mapstring(m)

    local s = ""
    for y=1,#m do
        for x=1,100 do
            s = s..(m[y][x] or ' ')
        end
        s = s..'\n'
    end
    return s
end

local bcount = 0
local function step()
    bcount = bcount + 1
    return bcount
end

local function isOneOf(t,a)

    for k,v in ipairs(t) do
        if a == v then return true end
    end
    return false
end

local width, height = #lines[1], #lines

local grid = {}

local function resetgrid()
    for k,v in pairs(lines) do
        grid[k] = {}
        for i, c in v:gmatch("()(.)") do
            if c == "." then
                c = " "
            end
            grid[k][i] = {t=c,b={}}
        end
    end
end

resetgrid()

local function evalBeams(beams)

    for _, beam in pairs(beams) do

        while true do     
            --print(inspect(beam))
            -- beam starts at pos x, reads next position in direction y
            -- moves there and 'does a thing'
            -- if split, beam ends and adds two new beams to be iterated
            if beam.dir == "right" then
                beam.x = beam.x+1
            elseif beam.dir == "down" then
                beam.y = beam.y + 1
            elseif beam.dir == "left" then
                beam.x = beam.x - 1
            elseif beam.dir == "up" then
                beam.y = beam.y - 1
            else
                assert(false, "Invalid beam direction")
            end
            if beam.x < 1 or beam.x > width then 
                -- print("byeee!")
                break end
            if beam.y < 1 or beam.y > height then 
                -- print("Byeee!")
            break end

            local next = grid[beam.y][beam.x]

            local onpath
            for _, dir in pairs(next.b) do
                if dir == beam.dir then
                    -- On known path, exit
                    onpath = true
                    break
                end
            end
            if onpath then
                break
            else
                table.insert(next.b,beam.dir)
            end

            if next.t == "\\" then
                -- Turn
                if beam.dir == "right" then beam.dir = "down"
                elseif beam.dir == "down" then beam.dir = "right"
                elseif beam.dir == "left" then beam.dir = "up"
                elseif beam.dir == "up" then beam.dir = "left" end

            elseif next.t == "/" then
                -- Turn
                if beam.dir == "right" then beam.dir = "up"
                elseif beam.dir == "down" then beam.dir = "left"
                elseif beam.dir == "left" then beam.dir = "down"
                elseif beam.dir == "up" then beam.dir = "right" end
                    
            elseif next.t == "|" and (beam.dir == "left" or beam.dir == "right") then
                -- Split
                beam.dir = "up"
                table.insert(beams, {x=beam.x, y=beam.y, dir="down"})
            elseif next.t == "-" and (beam.dir == "up" or beam.dir == "down") then
                beam.dir = "left"
                table.insert(beams, {x=beam.x, y=beam.y, dir="right"})
            end
            -- Test if now on established path, exit early. 
            -- Beware! Loops!
            -- print(inspect(beam))
            -- if step() >= 3 then break end
        end
    end
end

evalBeams{{x=0,y=1,dir='right'}}

local function getemergizedmap()
    local energizedmap = ""
    local power = 0
    for y=1, height do
        for x=1, width do
            if #grid[y][x].b > 0 then
                energizedmap = energizedmap.."#"
                power = power + 1
            else
                energizedmap = energizedmap.."."
            end
        end
        energizedmap = energizedmap.."\n"
    end
    return energizedmap, power
end

local energizedmap
energizedmap, P1 = getemergizedmap()

local maxpower = 0
local function test(x,y,dir)
    resetgrid()
    evalBeams{{x=x,y=y,dir=dir}}
    local emap, power = getemergizedmap()
    if power > maxpower then
        energizedmap = emap
        maxpower = power
    end
end

for x = 1, width do
    test(x,0,"down")
    test(x,height+1,"up")
end

for y = 1, height do
    test(0,y,"right")
    test(width+1,y,"left")
end

P2 = maxpower

print(energizedmap)


print('\nDay Sixteen')
print(string.format('Part 1 - Answer %s',P1)) -- 7517
print(string.format('Part 2 - Answer %d', P2)) -- 

--[[


]]