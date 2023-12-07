package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local cards = {}


    --[[
7 Five of a kind, where all five cards have the same label: AAAAA
6 Four of a kind, where four cards have the same label and one card has a different label: AA8AA
5Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
High card, where all cards' labels are distinct: 23456]]
function pokarrank(s) 
    
    local charmap = {}
    for i=1, #s do
        local c = s:sub(i,i)
        --if charmap[c] == nil then charmap[c] = 0 end
        charmap[c] = (charmap[c] or 0) + 1
    end

    local maxp = 0
    local twos = 0
    for i,j in pairs(charmap) do
        maxp = math.max(maxp,j)
        if j == 2 then twos = twos + 1 end
    end
    if maxp == 5 then 
        return 7
    elseif maxp == 4 then
        return 6
    elseif maxp == 3 then 
        --check full house
        if twos == 1 then 
            return 5
        else
            return 4
        end
    elseif maxp == 2 then
        -- check two and one pair
        if twos == 2 then 
            return 3
        elseif twos == 1 then 
            return 2
        end
    elseif maxp == 1 then
        return 1
    end

    return 0
end

function pokarrank2(s) 
    
    local charmap = {}
    for i=1, #s do
        local c = s:sub(i,i)
        --if charmap[c] == nil then charmap[c] = 0 end
        charmap[c] = (charmap[c] or 0) + 1
    end

    local maxp = 0
    local twos = 0
    local jokers = charmap["J"] or 0
    for i,j in pairs(charmap) do
        if i == "J" then 
        else
            maxp = math.max(maxp,j)
            if j == 2 then twos = twos + 1 end   
        end
    end
    if maxp == 5 or (maxp == 4 and jokers == 1) or (maxp+jokers == 5) then
        -- upgrade with one wildcard but watch out for winner jokers already
        print('new seven', s, jokers)
        return 7
    elseif maxp == 4 or (maxp+jokers == 4) then
        --print('new six', s, jokers)
        return 6
    elseif maxp == 3 or (maxp+jokers == 3) then 
        --check full house
        if twos == 1 and maxp == 3 then 
            return 5
        elseif twos == 2 and jokers ==1 then
            return 5
        else
            -- three of a kind
            return 4
        end
    elseif maxp == 2 or (maxp+jokers == 2) then
        -- check two and one pair
        -- 2234J makes 3 of kind not two pair
        if twos == 2 then 
            return 3
        elseif twos == 1 then 
            return 2
        else
            return 2 --joker
        end
    elseif maxp == 1 then
        return 1
    end

    return 0
end

local rank = 0
for k,v in pairs(lines) do

    for hand, bid in v:gmatch('([%w%d]+) (%d+)') do
        local card = {hand=hand, bid=tonumber(bid,10), rank=0, handtype=pokarrank(hand), P2type = pokarrank2(hand)}
        assert(card.handtype~=0,"invalid hand type")
        table.insert(cards, card)
        rank = rank + 1
    end
end

-- P1
--local lexrank = {["A"]=13, ["K"]=12, ["Q"]=11, ["J"]=10, ["T"]=9, ["9"]=8, ["8"]=7, ["7"]=6, ["6"]=5, ["5"]=4, ["4"]=3, ["3"]=2, ["2"]=1}
-- cards = sort(cards, function(t,a,b)
--     local ha, hb = t[a], t[b]
--     --poker score then lex sort score (7 poker ranks)
--     --A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2.
--     if ha.handtype > hb.handtype then 
--         return true
--     elseif ha.handtype == hb.handtype then 
--         --check lex  
--         for i=1,#ha.hand do
--             local ca, cb
--             ca = ha.hand:sub(i,i)
--             cb = hb.hand:sub(i,i)
--             if lexrank[ca] > lexrank[cb] then
--                 --print('ca beats cb',ha.hand, hb.hand, ha.handtype, i)
--                 return true
--             elseif ca == cb then
--                 -- continue
--             else
--                 return false
--             end
--             --return a<b -- first card wins
--         end
--         return a<b
--     else
--         return false
--     end   
-- end)

local lexrank = {["A"]=13, ["K"]=12, ["Q"]=11, ["T"]=10, ["9"]=9, ["8"]=8, ["7"]=7, ["6"]=6, ["5"]=5,["4"]=4, ["3"]=3, ["2"]=2, ["J"]=1,}

cards = sort(cards, function(t,a,b)
    local ha, hb = t[a], t[b]
    --poker score then lex sort score (7 poker ranks)
    --A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2.
    if ha.P2type > hb.P2type then 
        return true
    elseif ha.P2type == hb.P2type then 
        --check lex  
        for i=1,#ha.hand do
            local ca, cb
            ca = ha.hand:sub(i,i)
            cb = hb.hand:sub(i,i)
            if lexrank[ca] > lexrank[cb] then
                --print('ca beats cb',ha.hand, hb.hand, ha.P2type, i)
                return true
            elseif ca == cb then
                -- continue
            else
                return false
            end
            --return a<b -- first card wins
        end
        return a<b
    else
        return false
    end   
end)


for _, c in pairs(cards) do
    c.rank = rank
    rank = rank - 1
    --P1 = P1 + c.rank * c.bid
    P2 = P2 + c.rank * c.bid
end

print(inspect(cards))


print('\nDay Seven')
print(string.format('Part 1 - Answer %d',P1)) -- 248422077
print(string.format('Part 2 - Answer %d', P2)) -- 249817836
--[[
    WRONG
    248468320
P2 
248266145 (too low)
250546679 (too high)

]]

--assert(pokarrank2('')==0)
assert(pokarrank2('55555')==7)
assert(pokarrank2('55J55')==7)

assert(pokarrank2('444497')==6)
assert(pokarrank2('444J97')==6)
assert(pokarrank2('44JJ97')==6)

assert(pokarrank2('44433')==5)
assert(pokarrank2('44J33')==5, pokarrank2('44J33'))
assert(pokarrank2('444J3')==6) -- preferrs four of a kind
assert(pokarrank2('444JJ')==7)


assert(pokarrank2('44435')==4)
assert(pokarrank2('44J35')==4)
assert(pokarrank2('4JJ35')==4)

assert(pokarrank2('33455')==3)
assert(pokarrank2('3345J')==4)
assert(pokarrank2('334J6')==4)

assert(pokarrank2('22345')==2)

assert(pokarrank2('AQ245')==1)






-- assert(pokarrank2('55J44')==5)
-- assert(pokarrank2('5JJ44')==0)
