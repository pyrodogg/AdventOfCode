local P = {}   -- package
aoc = P

--Return W, H, oob(x,y) or oob({x,y}) for file table
local function bounds(lines)

    local W = #lines[1] --works if string or array of x positions in grid[y][x] format
    local H = #lines
    local function oob(x,y)

        if type(x) == "table" then
            return oob(x.x or x[1] ,x.y or x[2])
        end

        return  (x < 1 or x > W or y < 1 or y > H)
    end

    return W, H, oob
end
aoc.bounds = bounds

local pow10 = {
            1,
            10,
            100,
            1000,
            10000,
            100000,
            1000000,
            10000000,
            100000000,
            1000000000,
            10000000000,
            100000000000,
            1000000000000,
            10000000000000,
        }
aoc.pow10 = pow10

function aoc.logfile(slug,...)

    assert(slug ~= nil and slug ~= "")
    local f = assert(io.open("log/"..slug,"w"))
        f:write(...)
        f:close()
end

function aoc.intsFromLine(line, match, sep)
    if match == nil or match == "" then
        match = "[-]*%d+"
    end
    sep = sep or ""
    return map(unroll(line:gmatch("("..match..")"..sep)),tobase10)
end

function aoc.charsFromLine(line)
    return unroll(line:gmatch("."))
end

function aoc.charGridFromLines(lines)
    local grid = {}
    for k,v in pairs(lines) do
       grid[k] = aoc.charsFromLine(v)
    end
    return grid
end

function aoc.GaussJordan(a,n)

    local j = 1
    local c
    local flag = 0

    for i = 1, n do
        if a[i][i] == 0 then
            c = 1
            while ((i + c) <= n and a[i+c][i] == 0) do
                c = c + 1
            end
            if i+c == n then
                flag = 1
                break
            end
            j = i
            --print("swap "..j.." "..j+c)
            for k = 1, n+1 do
                -- swap
                local temp = a[j][k]
                a[j][k] = a[j+c][k]
                a[j+c][k] = temp;
            end
        end

        for j = 1, n do
            if i ~= j then
                local p = a[j][i] / a[i][i];
                print('p'..p..' '..a[j][i]..' '..a[i][i]..' i'..i..' j'..j)
                print("reduce "..j..' by '..i..' factor '..string.format("%f",p))
                for k =1, n+1 do
                    a[j][k] = a[j][k] - (a[i][k] * p)
                end
            end
        end

        --Printbn(a)
    end

    return a, flag
end

function aoc.renderGrid(grid)
    local out = ""
    local W, H = aoc.bounds(grid)
    for y=1,H,1 do
        for x=1,W do
            out = out..(grid[y][x] or " ")
        end
        out = out.."\n"
    end
    return out
end

return aoc