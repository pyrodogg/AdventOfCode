package.path = package.path .. ';../../?.lua'
require "util"
local inspect = require "inspect"

local lines = lines_from(arg[1] or ('../input/'..string.gsub(arg[0],'lua','txt')))
local P1, P2 = 0, 0

local drive = lines[1]


local blocks_total = {file=0,space=0,total=0}
for i = 1, #drive, 1 do
    local size = tobase10(drive:sub(i,i))
    if i % 2 == 0 then
        blocks_total.space = blocks_total.space + size
    else
        blocks_total.file = blocks_total.file + size
    end
    blocks_total.total = blocks_total.total + size
end

local getBlockId = coroutine.wrap(function()
    local blocks_sent = 0
    for i = #drive, 1, -1 do
        local size = tobase10(drive:sub(i,i))
        if i % 2 == 0 then
            --space
            blocks_sent = blocks_sent + size
        else
            local id = i//2
    
            for j = 1, size, 1 do
                blocks_sent = blocks_sent + 1
                if blocks_sent > blocks_total.space then
                    --print("DONE")
                    coroutine.yield(0)
                else
                    coroutine.yield(id)
                end
            end
        end
    end
    return nil
end)

local files = {}
local space = {}
local acc = 0
local blocks_curr = {}
local file_blocks = 0
local space_blocks = 0
for i = 1, #drive, 1 do
    --!! ID is 0-based i//2
    local size = tobase10(drive:sub(i,i))
    if i % 2 == 0 and size > 0 then
        --space (after)
        --table.insert(space,{s=size,a=(i-1)//2})
        space_blocks = space_blocks + size

        for j = 0, size-1, 1 do
            local free_block = getBlockId()
            if free_block == 0 then
                --print("NO FREE")
                break
            else
                --checksum for moved blocks
                P1 = P1 + free_block*(acc+j)
            end
        end
    else
        --file
        local id = i//2
        --table.insert(files,{id=i//2,s=size,p=i//2})
        
        for j = 0, size-1, 1 do
            --print(id..' '..acc+j-1)
            --checksum for 'unmoved' files
            P1 = P1 + (id*(acc+j))

            if acc+j+1 == blocks_total.file then
                break
            end
        end
        
        file_blocks = file_blocks + size
    end

    acc = acc + size
    --print('blocks '..file_blocks..' space '..space_blocks..' acc '..acc)
    if acc >= blocks_total.file then
        --print("BREAK!"..blocks_total.file)
        break
    end
end

local d = {}
for i = 1, #drive, 1 do
    if i % 2 == 0 then
        d[i] = tonumber(drive:sub(i,i))
    else
        d[i] = {n=tonumber(drive:sub(i,i)),id=i//2}
    end
end

local i = #d
local lastfound = {}
local moved = math.maxinteger
while i >= 1 do
    local id = d[i].id
    local n = d[i].n
    local extra
    if id >= moved then
        goto continue
    end
    --print(i.." fit "..d[i].n..'x '..d[i].id.."'s somewhere")

    lastfound[n] = lastfound[n] or 2
    for s=lastfound[n],i,2 do
        if d[s] >= d[i].n then
            moved = id
            lastfound[n] =s
            --print("found "..d[s].." space at "..s..' to fit '..d[i].n..'x '..d[i].id.."'s")
            extra = d[s] - d[i].n
            d[s] = 0
            table.insert(d,s+1,{n=n,id=id})
            table.insert(d,s+2,extra)
            d[i+1] = d[i+1]+n
            d[i+2] = 0
            i = i + 2
            break
        end
    end

    ::continue::
    i = i - 2
end

local test = ""
local acc2 = 0
for i=1, #d, 1 do
    if i%2==0  then
        if  d[i] > 0 then
            -- for j = 1, d[i], 1 do
            --     test = test..'.'
            -- end
            acc2 = acc2+d[i]
        end
    else
        if type(d[i]) == "table" then
            for j = 0, d[i].n-1, 1 do
                P2 = P2 + ((acc2+j)*d[i].id)
                -- test = test..d[i].id
                --print('p2'..#test..' '..d[i].id)
            end
            acc2 = acc2 + d[i].n
        else
        end
    end
end

print('\n2024 Day Nine')
print(string.format('Part 1 - Answer %s',P1)) --
print(string.format('Part 2 - Answer %d', P2)) --