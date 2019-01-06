

require 'util'

function manhattan(a,b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end

local input = '06 - Input.txt'
local coords = keyBy(map(lines_from(input), function(v,k,t) 
                    local point =  {
                        x = tonumber(v:match('(%d+),')), 
                        y = tonumber(v:match(', (%d+)')),
                        raw = v} 
                    return point
                end),'raw')

local mnhttn = curry(manhattan,2)

for x=1,1 do
    for y=1,1 do

        local dist = map(coords,  function(v)
                        v.dist = manhattan({x=x,y=y}, v)
                        return v
                    end)
                    
        local grp =  sort(groupBy(dist,'dist'),function(t,a,b) return a < b end)

        for k,v in pairs(grp) do
            print('Dist ['..k..'] '..#v)
        end


      --[[ local closest = minBy(map(coords,function(v) 
                            v.dist = manhattan({x=x,y=y},v) 
                            return v 
                        end),'dist')]]

       --print(closest.x..' '..closest.y)
                
    end
end

