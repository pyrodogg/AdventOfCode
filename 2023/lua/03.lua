require "util"
local lpeg = require "lpeg"

print('Day Three')

local file = '../input/03.txt'
local lines = lines_from(file)
local gears = {}
local P1, P2 = 0, 0


-- function checkLine(k,v,i)

--     -- check line
--     local s = v:sub(v_off,i+#j)
--     if s:match('[^.%d]') then
--         P1 = P1 + tonumber(j)
--     end
--     if k == 67 then print('line',s) end
--     for gi, _ in s:gmatch('()'..'[*]'..'') do 
--         -- for all adjacent gears
--         -- gi is offset from i which is abs index of line v
--         if gears[k][v_off+gi-1] == nil then gears[k][v_off+gi-1] = {} end
--         -- print('found gear at ' ..i-1+gi ..'adding ' ..j)
--         table.insert(gears[k][v_off+gi-1],tonumber(j))
--     end
-- end
local inspect_line = 65
for k,v in pairs(lines) do
    if gears[k] == nil then gears[k] = {} end
    if gears[k+1] == nil then gears[k+1] = {} end

    --Iter numbers
    for i, j in v:gmatch('()'..'(%d+)'..'') do
        --print(lines[k]:sub(i-1,#j+1))

        local v_off = i
        if v_off > 1 then v_off = v_off -1 end

        if k > 1 then 
            --get prev
            local prev = lines[k-1]:sub(i-1, i+#j)
            if prev:match('[^.%d]') then
                P1 = P1 + tonumber(j)
                --print('zing!' ..s)
            end
            if k == inspect_line then print('prevp', prev) end
            for gi, _ in prev:gmatch('()'..'[*]'..'') do 
                -- for all adjacent gears
                -- gi is offset from i which is abs index of line v
                if gears[k-1][v_off+gi-1] == nil then gears[k-1][v_off+gi-1] = {} end
                -- print('found gear at ' ..i-1+gi ..'adding ' ..j)
                if k == inspect_line then print('found gear at ' ..(k-1)..'-'..v_off+gi-1 ..' adding ' ..j) end
                table.insert(gears[k-1][v_off+gi-1],tonumber(j))
            end

        end

        -- check line
        local s = v:sub(i-1,i+#j)
        if s:match('[^.%d]') then
            P1 = P1 + tonumber(j)
        end
        if k == inspect_line then print('line',s) end
        for gi, _ in s:gmatch('()'..'[*]'..'') do 
            -- for all adjacent gears
            -- gi is offset from i which is abs index of line v
            if gears[k][v_off+gi-1] == nil then gears[k][v_off+gi-1] = {} end
            -- print('found gear at ' ..i-1+gi ..'adding ' ..j)
            if k == inspect_line then print('found gear at ' ..k..'-'..v_off+gi-1 ..' adding ' ..j) end
            table.insert(gears[k][v_off+gi-1],tonumber(j))
        end

        if k < #lines then
            -- get next
            local next = lines[k+1]:sub(i-1, i+#j)
            if next:match('[^.%d]') then
                P1 = P1 + tonumber(j)
            end
            if k == inspect_line then print('next', next) end

            for gi, _ in next:gmatch('()'..'[*]'..'') do 
                -- for all adjacent gears
                -- gi is offset from i which is abs index of line v
                if gears[k+1][v_off+gi-1] == nil then gears[k+1][v_off+gi-1] = {} end
                 --print('found gear at ' ..i-1+gi ..' adding ' ..j)
                 if k == inspect_line then print('found gear at ' ..(k+1)..'-'..v_off+gi-1 ..' adding ' ..j) end
                table.insert(gears[k+1][v_off+gi-1],tonumber(j))
            end
        end

        --print()
        --print(lines[k+1]:sub(i-1, i+#j+1))
       
    end

    --if k > 10 then break end
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

for k, v in pairs(gears) do
    -- print('ROW ' ..k)
    -- print(dump(gears[k]))
    for i, j in pairs(gears[k]) do
        if #gears[k][i] == 2 then
           -- print(k, i, 'yeeting ',gears[k][i][1], gears[k][i][2], 'onto the pile', (gears[k][i][1] * gears[k][i][2]))
            P2 = P2 + (gears[k][i][1] * gears[k][i][2])
        end
    end
    --break
end

print(string.format('Part 1 - Answer %d\n',P1)) -- 556367
print(string.format('Part 2 - Answer %d\n', P2)) --89471771
-- wrong guesses
-- 89415295 (too low?)
-- 1117507 (forgot to remove debug statemenst)