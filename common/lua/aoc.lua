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

function aoc.logfile(slug,...)

    assert(slug ~= nil and slug ~= "")
    local f = assert(io.open("log/"..slug,"w"))
        f:write(...)
        f:close()
end

function aoc.intsFromLine(line, match, sep)
    if match == nil or match == "" then
        match = "%d+"
    end
    sep = sep or ""
    return map(unroll(line:gmatch("("..match..")"..sep)),tobase10)
end

return aoc