package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
--local rex = require"rex_pcre2"
---@type Vec2D | v2call
local Vec2D = require "lib.vec2d"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
local dir_vec = {Vec2D{0,-1},Vec2D{1,0},Vec2D{0,1},Vec2D{-1,0}}

local function reverse_pad(pad)
    local rev = {}
    for y=1,#pad do
        for x=1,#pad[1] do
            rev[tostring(pad[y][x])] = Vec2D(x,y)
        end
    end
    return rev
end

local door = {{7,8,9},{4,5,6},{1,2,3},{false,0,"A"}}
local control = {{false,"^","A"},{"<","v",">"}}
local door_rev = reverse_pad(door)
local control_rev = reverse_pad(control)

local cache = {}

--[[ 1 human, 2 robots, door_keypad ]]
local function expand(seq,pad_type)
    local nseq --, npos
    --local pad = pad_type == "door" and door or control
    local pad_rev = pad_type == "door" and door_rev or control_rev

    if seq == "A" then
        nseq = ""
    else
        nseq = expand(seq:sub(2),pad_type)
        local first_char = seq:sub(1,1)
        local second_char = seq:sub(2,2)
        local first_pos = pad_rev[first_char]
        local second_pos = pad_rev[second_char]
        if cache[first_char..","..second_char] then
            --print("cache hit",first_char,second_char, cache[first_char..","..second_char])
            nseq = cache[first_char..","..second_char].."A"..nseq
        else
            local d = second_pos - first_pos
            local prefix = ""
            if pad_type == "door" then
                -- minimize moves
                -- prefer to move left once
                -- prefer final move to be up or right, next down, last left
                -- can we go left? go left
                -- can we go down? go down
                -- can we go up/right? go up/right
                
                local strat = ""
                if d.x < 0 and (first_pos.y ==4 and second_pos.x == 1) then
                    strat = "yfirst"
                elseif d.x < 0 then
                    -- can we go (all the way) left? go left
                    strat = "xfirst"
                elseif d.y > 0 and (second_pos.y == 4 and first_pos.x ==1) then
                    strat = "xfirst"
                elseif d.y > 0 then
                    -- can we go down? go down
                    strat = "yfirst"
                else
                    strat = "xfirst"
                end

                if strat == "xfirst" then
                    if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                    if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end

                else
                    if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end
                    if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                end
            else
                if second_pos.y == 1 or first_pos.y == 1 then
                    --special rules
                     -- door_down or controller_up = x,y door_up or controller_down = y,x
                    if (pad_type =="door" and d.y >= 0) or (pad_type=="control" and d.y <= 0) then
                        if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                        if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end
                    else
                        -- controller_down or door_up
                        if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end
                        if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                    end
                else
                    --normal rules
                    if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                    if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end 
                end
            end
            cache[first_char..","..second_char] = prefix
            nseq = prefix.."A"..nseq
            print(string.format("%s to %s = %s -> %s",first_char,second_char,prefix,nseq))
        end
    end

    return nseq
end

for _,v in pairs(lines) do
    local seqn = v:match("(%d+)")

    local bot1seq = expand("A"..v,"door")
    local bot2seq = expand("A"..bot1seq,"control")
    local handseq = expand("A"..bot2seq,"control")
    print(handseq,#handseq,seqn,seqn * #handseq)
    print(bot2seq)
    print(bot1seq)
    print(v)
    local p2seq = bot1seq
    -- for i=1,25 do
    --     print(i)
    --     p2seq = expand("A"..p2seq,"")
    --     --print(p2seq)
    -- end

    P1 = P1 + seqn * #handseq
    P2 = P2 + seqn * #p2seq
end

local function assert_cache(k,v)
    if cache[k] then
        assert(cache[k] == v,string.format("cache[%s] is %s expected %s",k,cache[k],v))
    end
end

-- print(inspect(cache))

assert_cache("A,1","^<<")
assert_cache("8,6","v>")
assert_cache("A,4","^^<<")
assert_cache("4,0",">vv")
assert_cache("<,^",">^")
assert_cache("^,<","v<")

print('\n2024 Day Twenty One')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %s', P2)) --

--[[


]]