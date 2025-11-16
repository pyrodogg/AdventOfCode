package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local games = {}
local gamecount = 1
for k,v in pairs(lines) do

    if games[gamecount] == nil then games[gamecount] = {} end

    if v == "" then
        -- new game
        gamecount = gamecount  + 1
    else
        table.insert(games[gamecount],v)
    end
end

local function score(s)
    local r = 0
    -- print('scoring ', s)
    for i=1,#s do
        if s:sub(i,i) == '#' then
            -- print('found hash, adding ',i, #s-i, 2^(#s-i))
            r = r + 2^(#s-i)
        end
    end
    -- print('score is ', r)
    return r
end

local function getcol(g,i)
    local c = ''

    for j = 1, #g do
        c = c..g[j]:sub(i,i)
    end
    return c
end


local function run(threshold)

    local runscore = 0
    for k, g in pairs(games) do

        g.vrefcol = g.vrefcol or {}
        g.hreflines = g.hreflines or {}

        -- test distance from closes edge, #of matches to check
        -- 1 2 3 4 5 6 7 8 9
        local href = false
        local totalerror = 0
       
        for i = 2, #g do

            local rlev = levenshtein(g[i-1], g[i])
            local score1 = score(g[i-1])
            local score2 = score(g[i])
            
            -- rowscore[i] == rowscore[i-1] 
            --and (g.hreflines == nil or g.hreflines ~= i-1) 
            if rlev <= threshold  and g.hreflines[threshold-1] ~= i-1 then
                -- print("test match between rows ", i-1, i)
                totalerror = rlev
                
                -- potential "line" found between i and i-1
                -- check validity
                href = true
                g.hreflines[threshold] = i-1

                -- determine closest edge
                local disttoedge
                if i > math.ceil(#g/2) then
                    -- test to bottom
                    disttoedge = #g-i+1
                else
                    -- test to top
                    disttoedge = i-1
                end

                for t = 2, disttoedge do
                    local tlev = levenshtein(g[i-t], g[i+t-1])
                    -- print("testing rows ", k, i-t, i+t-1, tlev, totalerror)
                    totalerror = totalerror + tlev
                    if totalerror > threshold then
                        href = false
                        g.hreflines[threshold] = 0
                        break
                    end
                end
            end
            -- If found true reflection, stop breaks P2 since reflections can be on same axis
            if href == true then break end
        end

        if href then
            -- to verify P2 solution is different
            --print('wtf',k,hreflines)
            runscore = runscore + g.hreflines[threshold]*100
        end

        -- Check vertical 
        local vref = false
        local width = #g[1]
        totalerror = 0

        for i = 2, width do

            --print(levenshtein(getcol(g,i),getcol(g,i+1) or ''))
            local clev = levenshtein(getcol(g,i-1), getcol(g,i))

            local score1 = score(getcol(g,i-1))
            local score2 = score(getcol(g,i))

            if clev == 0 and score1 ~= score2 then
                print("score fuckery col", score1, score2)
            end

            --and (g.vrefcol == nil or g.vrefcol ~= i-1)
            if href == false and clev <= threshold and (g.vrefcol[threshold-1] ~= i-1)  then

                vref = true
                g.vrefcol[threshold] = i-1
                totalerror = clev

                local disttoedge            
                if i > math.ceil(width/2) then
                    -- test to right edge
                    disttoedge = width-i+1
                else
                    -- test to left edge
                    disttoedge = i-1
                end

                for t=2, disttoedge do
                    -- print("test col ", i-t, i+t-1)
                    local tlev = levenshtein(getcol(g,i-t), getcol(g,i+t-1))
                    totalerror = totalerror + tlev
                    if totalerror > threshold then
                        vref = false
                        g.vrefcol[threshold] = 0
                        break
                    end
                end

            end
            -- If found true reflection, stop
            if vref == true then break end
        end

        if vref then
            runscore = runscore + g.vrefcol[threshold]
        end

        
        if g.vrefcol[threshold] == nil and g.hreflines == nil then
            print("NO MATCH", k)
        end

        if g.hreflines[0] == g.hreflines[1] and g.hreflines[0] ~= nil then
            print("FOUND SAME Hmatch", k, g.hreflines[0])
        end

        --print(k, inspect(g.hreflines), inspect(g.vrefcol))
        
        
        --if k >= 2 then break end
    end

    return runscore
end

-- P2
--[[
Instead of just checking inequality, check the 'distance' between
the reflections. IF distance between a-b compare is > 1 then fail.
If distance is 0 then good reflection(P1). However if the distance
is off by only 1, then log as smudge candidate for P2.

Distance 1 candidates will have to be tested for all axis, since
new reflections are expected, they may not be covered by first scan

For map, given row, test reflection on axis, return P1, err
if err = 0 then score as P1
    if err = 1 then 'smudge' and rescore for P2
        if err > 1 then discard


]]

P1 = run(0)
print("P2")
P2 = run(1)


print('\nDay Thirteen')
print(string.format('Part 1 - Answer %d',P1)) -- 40006
print(string.format('Part 2 - Answer %d', P2)) -- 28627
