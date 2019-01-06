

require "util"

-- Part 1 
-- Return count of square inches overlapped by two or more claims
-- #1 @ 342,645: 25x20
-- #1 ID
--    @ left,top
--               WxH

function formatClaims(input)

    local rawClaims = lines_from(input)
    local claims = {}

    for k,v in pairs(rawClaims) do
        local iter = v:gmatch("%d+")
        claims[k] = {id=tonumber(iter()),left=tonumber(iter()),top=tonumber(iter()),width=tonumber(iter()),height=tonumber(iter())}
    end

    return  claims
end

function length(table)
    local length = 0
    for k,v in pairs(table) do
        length = length + 1
    end
    return length
end


function range(to)
    local next = 0
    return function ()
        if next == to then return nil end
        next = next + 1
    
        return next
    end
  end

function getCoords (left, top, width, height) 

    return coroutine.wrap(function()
        for x in range(width) do
            for y in range(height)do
                coroutine.yield(x+left..','..y+top);
            end 
        end
        return nil
    end)
end

--Format inspired by Ali Spittel on Dev.to
function overlapv2(claims)

    claimed = {}
    overlaps = {}

    for id,claim in pairs(claims) do

        for coord in getCoords(claim.left,claim.top,claim.width,claim.height) do
            if claimed[coord] ~= nil then
                if overlaps[coord] == nil then
                    overlaps[coord] = {}
                end
                table.insert(overlaps[coord],id)
            else
                claimed[coord] = claim.id
            end
        end
    end 

    return overlaps
end


function overlappedInches(claims)

    local fabric = matrix(1000,1000)
    local overlappedInches = 0

    for id, claim in pairs(claims) do

        for i = claim.left+1, claim.left+claim.width do
            for j = claim.top+1, claim.top+claim.height do

                if fabric[i][j] == 1 then
                    overlappedInches = overlappedInches + 1
                end
                fabric[i][j] = fabric[i][j] + 1
            end
        end
    end
    return overlappedInches
end

function wholeClaims(claims)
    local fabric = matrix(1000,1000)
    local wholeClaims = {}

    for id, claim in pairs(claims) do
        wholeClaims[id] = claim -- Assume all claims whole to start
        for i = claim.left+1, claim.left + claim.width do
            for j = claim.top+1, claim.top + claim.height do -- Check for collisions
                if fabric[i][j] == 0 then 
                    fabric[i][j] = id
                else
                   wholeClaims[id] = nil
                   wholeClaims[fabric[i][j]] = nil
                end
            end
        end
    end

    return wholeClaims
end


local input = "03 - Input.txt"

local claims = formatClaims(input)

local part1Answer = overlappedInches(claims)
local part1Answerv2 = length(overlapv2(claims))

print('\nDay 3 - Part 1 - Answer\n\t' ..part1Answer.. '\n')

print(part1Answerv2)

local whole = wholeClaims(claims)
local part2Answer = 0
for k,v in pairs(whole) do
    part2Answer = k
end

print('\nDay 3 - Part 1 - Answer\n\t' ..part2Answer.. '\n')

