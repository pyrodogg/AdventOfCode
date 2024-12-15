---@diagnostic disable: duplicate-set-field
---@class Vec2D
---@field x number
---@field y number
---@operator add(Vec2D): Vec2D
---@operator sub(Vec2D): Vec2D
---@operator mul(Vec2D): Vec2D
---@operator mul(number): Vec2D
Vec2D = {}
do
local mt = {
            __add = function (a, b)
                return Vec2D{a.x+b.x, a.y+b.y}
            end,
            __sub = function (a,b)
                return Vec2D(a.x-b.x, a.y-b.y)
            end,
            __mul =function (a, b)
                if type(a) == "number" then
                    return Vec2D(b):scale(a)
                elseif type(b) == "number" then
                    return Vec2D(a):scale(b)
                end
            end,
            __eq =function (a, b)
                return (a.x or a[1]) == (b.x or b[1]) and (a.y or a[2]) == (b.y or b[2])
            end,
            __len = function (a)
                return math.sqrt(a.x^2 + a.y^2)
            end,
            __tostring = function(a)
                return string.format("%d,%d",a.x,a.y)
            end,
            unpack = function(a)
                return a.x, a.y
            end
            }

    mt.__index = Vec2D
    -- mt.__metatable = "Vec2D" -- Lockdown metatable

    setmetatable(Vec2D,{
        --__index = Vec2D,
        ---@param self Vec2D
        ---@param initx number|table<string,number> X
        ---@param inity? number Y
        ---@return Vec2D
        __call = function(self,initx,inity)
            local o = setmetatable({},mt)
            if type(initx) == "table" then
                o.x = initx.x or initx[1] or 0
                o.y = initx.y or initx[2] or 0
            else
                o.x = initx or 0
                o.y = inity or 0
            end
    
            return o
        end
    })
end

-- Vec2D.__index = Vec2D

-- setmetatable(Vec2D,{
--     __call = function(self,initx,inity,rhc)
--         local o = {}
--         setmetatable(o,{__index=Vec2D,
--         __add = function (a, b)
--             return Vec2D{a.x+b.x, a.y+b.y}
--         end,
--         __sub = function (a,b)
--             return Vec2D(a.x-b.x, a.y-b.y)
--         end,
--         __mul =function (a, b)
--             if type(a) == "number" then
--                 return Vec2D(b):scale(a)
--             elseif type(b) == "number" then
--                 return Vec2D(a):scale(b)
--             end
--         end,
--         __eq =function (a, b)
--             return (a.x or a[1]) == (b.x or b[1]) and (a.y or a[2]) == (b.y or b[2])
--         end,
--         __tostring = function(a)
--             return string.format("%d,%d",a.x,a.y)
--         end,
--         unpack = function(a)
--             return a.x, a.y
--         end
--         })

--         if type(initx) == "table" then
--             o.x = initx.x or initx[1]
--             o.y = initx.y or initx[2]
--         else
--             o.x = initx or 0
--             o.y = inity or 0
--         end

--         return o
--     end
-- })

local rotation_method = 'lh' -- Left Hand
---@param method string lh/rh
---@return string #Rotation Method
function Vec2D.setRotationMethod(method)
    rotation_method = method == 'rh' and 'rh' or 'lh'
    return rotation_method
end

---@param a number Amount to scale x,y by
---@return Vec2D # A new vec2d
function Vec2D:scale(a)
    self.x = self.x * a
    self.y = self.y * a
    return self
end
local function round(x, n)
    n = 10^(n or 0) --math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

---@param degCW number Degrees clock-wise as positive number
---@return Vec2D # A new vec2d
function Vec2D:rotate(degCW,origin)
--[[ [ cos t  -sin t ] [x]
     [ sin t  cos t ]  [y]
]]
    --print("rotate "..degCCW)
    --origin = origin or Vec2D{0,0}
    
    local degCCW = -degCW
    local phi = math.rad(rotation_method == 'lh' and degCW or degCCW)
    local cos = round(math.cos(phi),10)
    local sin = round(math.sin(phi),10)
    local o = Vec2D{
        x = math.floor(cos*self.x - sin*self.y),
        y = math.floor(sin*self.x + cos*self.y)
    }
    -- print(string.format("\ncos*x %f*%d - sin*y %f*%d = %f",cos,self.x,sin,self.y,o.x))
    -- print(string.format("sin*x %f*%d + cos*y %f*%d = %f",sin,self.x,cos,self.y,o.y))

    -- print(phi,sin,cos,o.x,o.y)
    return o
end

return Vec2D