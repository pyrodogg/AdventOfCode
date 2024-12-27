package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
--local rex = require"rex_pcre2"
---@type Vec2D | v2call
local Vec2D = require "lib.vec2d"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

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
-- Fist attempt at part 1
local function expand(seq,pad_type,pfx)
    local nseq --, npos
    --local pad = pad_type == "door" and door or control
    local pad_rev = pad_type == "door" and door_rev or control_rev

    if seq == "A" then
        return pfx
    else
        local first_char = seq:sub(1,1)
        local second_char = seq:sub(2,2)
        local first_pos = pad_rev[first_char]
        local second_pos = pad_rev[second_char]
        if false and cache[first_char..","..second_char] then
            --print("cache hit",first_char,second_char, cache[first_char..","..second_char])
            --return cache[first_char..","..second_char].."A"..expand(seq:sub(2),pad_type)
            return expand(seq:sub(2),pad_type,(pfx or "")..cache[first_char..","..second_char].."A")
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
                    strat = "yfirst"
                end

                if strat == "xfirst" then
                    if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                    if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end

                else
                    if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end
                    if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                end
            else

                local strat = ""
                if first_pos.y == 1 and second_pos.x == 1 then
                    --moving ^A to <
                    strat = "yfirst"
                elseif first_pos.x == 1 and second_pos.y ==1 then
                    strat = "xfirst"
                elseif d.x < 0 then
                    strat = "xfirst"
                else
                    strat = "yfirst"
                end

                if strat == "xfirst" then
                    if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                    if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end

                else
                    if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end
                    if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
                end

            end
            --cache[first_char..","..second_char] = prefix
            --print(string.format("%s to %s = %s -> %s",first_char,second_char,prefix,nseq))
            --return prefix.."A"..expand(seq:sub(2),pad_type)
            return expand(seq:sub(2),pad_type,(pfx or "")..prefix.."A")
        end
    end

    --return nseq
end

local function next_seq(seq)
    local pad_type = seq:find("%d") and "door" or "control"
    local pad_rev = seq:find("%d") and door_rev or control_rev
    local first_char, second_char = seq:sub(1,1), seq:sub(2,2)
    local first_pos, second_pos = pad_rev[seq:sub(1,1)], pad_rev[seq:sub(2,2)]
    local d = second_pos - first_pos
    local prefix = ""
    
    if cache[first_char..","..second_char] then
        return cache[first_char..","..second_char].."A"
    end
    local strat = ""
    if pad_type == "door" then
        -- minimize moves
        -- prefer to move left once
        -- prefer final move to be up or right, next down, last left
        -- can we go left? go left
        -- can we go down? go down
        -- can we go up/right? go up/right
        
        if first_pos.y == 4 and second_pos.x == 1 then
            strat = "yfirst"
        elseif second_pos.y == 4 and first_pos.x ==1 then
            strat = "xfirst"
        elseif d.x < 0 then
            -- can we go (all the way) left? go left
            strat = "xfirst"
        elseif d.y > 0 then
            -- can we go down? go down
            strat = "yfirst"
        else
            strat = "yfirst"
        end
    else
        if first_pos.y == 1 and second_pos.x == 1 then
            --moving ^A to <
            strat = "yfirst"
        elseif first_pos.x == 1 and second_pos.y ==1 then
            strat = "xfirst"
        elseif d.x < 0 then
            strat = "xfirst"
        else
            strat = "yfirst"
        end
    end

    if strat == "xfirst" then
        if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
        if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end
    else
        if d.y ~= 0 then prefix = prefix..string.rep(d.y>0 and "v" or "^",math.abs(d.y)) end
        if d.x ~= 0 then prefix = prefix..string.rep(d.x>0 and ">" or "<",math.abs(d.x)) end
    end

    cache[first_char..","..second_char] = prefix
    return prefix.."A"
end

local dfscache = {}
local function expanddfs(level, instr, limit)

    if dfscache[level..instr] then

        return dfscache[level..instr]
    end

    if level == limit then
     
        return #instr
    else
        local segments = unroll(instr:gmatch("([%dv<>^]*A)"))
        local l = 0
        for _,v in pairs(segments) do
            local seq = "A"..v
            for i=1,#seq-1 do
                local nseq = next_seq(seq:sub(i,i+1))
                l = l + expanddfs(level+1,nseq,limit)
            end
        end

        dfscache[level..instr] = l
        return dfscache[level..instr]
    end
end

for k,v in pairs(lines) do
    local seqn = v:match("(%d+)")

    -- local bot1seq = expand("A"..v,"door")
    -- local bot2seq = expand("A"..bot1seq,"control")
    -- local handseq = expand("A"..bot2seq,"control")
    -- local onextra = expand("A"..handseq,"control")
    -- if seqn == "964" then
    --     print(onextra,#onextra)
    --     print(handseq,#handseq,seqn,seqn * #handseq)
    --     print(bot2seq,#bot2seq,seqn,seqn * #bot2seq)
    --     print(bot1seq,#bot1seq,seqn,seqn * #bot1seq)
    --     print(v)
    -- end
    dfscache = {}
    P1 = P1 + seqn * expanddfs(0,v,3)
    dfscache = {}
    P2 = P2 + seqn * expanddfs(0,v,26) -- 25 bots plus human
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
assert_cache("v,A","^>")

print('\n2024 Day Twenty One')
print(string.format('Part 1 - Answer %d',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
