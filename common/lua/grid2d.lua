Grid2D = {}
do
    local mt = {
        __index = Grid2D
    }

    setmetatable(Grid2D,{
        __call = function (self,W,H,dense)
            
            local o = setmetatable({},mt)

            for i = 1, H, 1 do
                o[i] = {}
            end

            return o
        end
    })
end

return Grid2D