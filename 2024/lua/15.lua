package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"
local aoc = require "lib.aoc"
local Vec2D = require"lib.vec2d"
-- local tuple = require "tuple"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0
local dir_map = {["^"]=1,[">"]=2,["v"]=3,["<"]=4,[1]="^",[2]=">",[3]="v",[4]="<"}
local dir_tuples = {{x=0, y=-1},{x=1, y=0},{x=0, y=1},{x=-1, y=0}}
local dir_vec = {Vec2D{0,-1},Vec2D{1,0},Vec2D{0,1},Vec2D{-1,0}}

local grid = {}
local widegrid = {}
local move = {}
local bot2
local bot
for k,v in pairs(lines) do
    if v ~= "" then
        if v:find("[#O]") then
            grid[k] = grid[k] or {}
            widegrid[k] = widegrid[k] or {}
            for x = 1, #v, 1 do
                local char = v:sub(x,x)
 
                if char == "@" then
                    bot = Vec2D{x=x,y=k}
                    bot2 = Vec2D{x=x*2-1,y=k}
                    grid[k][x] = nil
                    widegrid[k][x*2-1] = nil
                elseif char == "O" then
                    grid[k][x] = char
                    widegrid[k][x*2-1] = "["
                    widegrid[k][x*2] = "]"
                elseif char == "#" then
                    grid[k][x] = char
                    widegrid[k][x*2-1] = "#"
                    widegrid[k][x*2] = "#"
                end
            end
        else
            for i = 1, #v, 1 do
                table.insert(move,dir_map[v:sub(i,i)])
            end
        end
    end
end

local function renderGrid(grid,bot)
    local out = ""
    local W, H = aoc.bounds(grid)
    for y=1,H,1 do
        for x=1,W,1 do
            if x == bot.x and y == bot.y then
                out = out.."@"
            else
                out = out..(grid[y][x] or " ")
            end
        end
        out = out.."\n"
    end
    return out
end

local function scoreGPS(grid,char)
    --! 0-based scoring
    char = char or "O"
    local W,H = aoc.bounds(grid)
    local score = 0
    for y=1,H,1 do
        for x=1,W,1 do
            if grid[y][x] == char then
                score = score + (y-1)*100+(x-1)
            end
        end
    end
    return score
end

local function checkintegrity(k,grid,bot)
    local W,H = aoc.bounds(grid)
    for y=1,H,1 do
        for x=1,W,1 do
            if grid[y][x] == "[" and grid[y][x+1]~="]" then
                assert(false,"barrel karate chop\n",k,renderGrid(widegrid,bot2))
            end
        end
    end
end

local function trymove(grid,bot,dir, part)

    local W,H = aoc.bounds(grid)
    local limit = W
    local barrels = {}
    --stack
    local pos_to_check = {{x=bot.x+dir_tuples[dir].x, y=bot.y+dir_tuples[dir].y}}
    -- for i =1,limit,1 do
    while #pos_to_check > 0 do

        -- local check_pos = {x=bot.x+i*dir_tuples[dir].x, y=bot.y+i*dir_tuples[dir].y}
        local check_pos = table.remove(pos_to_check) -- destack
        -- print(part,inspect(check_pos))
        -- print(inspect(tgrid[check_pos.y]))
        local check_char = grid[check_pos.y][check_pos.x]
        -- print(part, check_pos.x,check_pos.y, check_char)

        if check_char == "O" then
            table.insert(barrels, {x=check_pos.x,y=check_pos.y})
            table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x,
                                       y=check_pos.y+dir_tuples[dir].y})
            
        elseif check_char == "[" then
            table.insert(barrels, {x=check_pos.x,y=check_pos.y}) --!dedupe

            if dir==1 or dir==3 then
                --N/S
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x,
                                           y=check_pos.y+dir_tuples[dir].y})
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x+1,
                                           y=check_pos.y+dir_tuples[dir].y})
            elseif dir ==2 then
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x+1,
                                           y=check_pos.y+dir_tuples[dir].y})
            elseif dir ==4 then
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x,
                                           y=check_pos.y+dir_tuples[dir].y})
            end
        elseif check_char == "]"  then
            table.insert(barrels, {x=check_pos.x-1,y=check_pos.y}) --!dedupe

            if dir==1 or dir==3 then
                --N/S
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x,
                                           y=check_pos.y+dir_tuples[dir].y})
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x-1,
                                           y=check_pos.y+dir_tuples[dir].y})
            elseif dir ==2 then
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x-1,
                                           y=check_pos.y+dir_tuples[dir].y})
            elseif dir ==4 then
                table.insert(pos_to_check,{x=check_pos.x+dir_tuples[dir].x,
                                           y=check_pos.y+dir_tuples[dir].y})
            end
        
        elseif check_char == nil then
            if #barrels <= 0 then
                return true -- immediate free space
            else
                -- Do nothing, if all check spaces are nill, then no more spaces get 
                -- added to search and we fall out of the loop
            end
        elseif check_char == "#" then
            return false --hit wall
        else
            assert(false)
        end
    end
    if part == 1 then
        for j=#barrels,1,-1 do
            local move_x = barrels[j].x + dir_tuples[dir].x
            local move_y = barrels[j].y + dir_tuples[dir].y
            grid[move_y][move_x] = "O"
        end
        grid[barrels[1].y][barrels[1].x] = nil -- remove last barrel
        -- print(string.format("Moved %d barrels",#barrels))
        return true -- free space after stack of barrels
        -- return false
    else
        -- print("puuush!", inspect(barrels))
        --sort to put 'deepest' barrels at 1,2,3...
        table.sort(barrels,function(a,b)
            local compa, compb = dir%2==0 and a.x or a.y, dir%2==0 and b.x or b.y
            if dir == 1 then
                return a.y < b.y
            elseif dir == 2 then
                return a.x > b.x
            elseif dir == 3 then
                return a.y > b.y
            else
                return a.x < b.x
            end
        end)
        for j=1,#barrels,1 do
            local b = barrels[j]
            local move_x = b.x + dir_tuples[dir].x
            local move_x2 = b.x+1 + dir_tuples[dir].x
            local move_y = b.y + dir_tuples[dir].y

            grid[b.y][b.x] = nil
            grid[b.y][b.x+1] = nil
            grid[move_y][move_x] = "["
            grid[move_y][move_x2] = "]"
        end
        return true, #barrels
    end
end

-- print("Starting Grid")
-- print(renderGrid(grid,bot))
-- print(renderGrid(widegrid,bot2))

for k,v in pairs(move) do
    -- print("turn", k,#grid,#widegrid, #widegrid[1])
    -- print(string.format("Turn %d. Attempt move %d",k,v))
    if trymove(grid,bot,v,1) then
       bot = bot + dir_vec[v]
    end
    local moved, n = trymove(widegrid,bot2,v,2)
    if moved then
        bot2 = bot2 + dir_vec[v]
        -- if n and n > 0 then
        --     print(string.format("Turn %d. Attempt move %d",k,v))
        --     print(renderGrid(widegrid,bot2))
        -- end
    end
    --print(renderGrid(widegrid,bot2))
    checkintegrity(k,widegrid,bot2)
end

P1 = scoreGPS(grid)
P2 = scoreGPS(widegrid,"[")

-- print("Final Grid")
-- print(renderGrid(grid,bot))
-- print(renderGrid(widegrid,bot2))

print('\n2024 Day Fifteen')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --
