---@diagnostic disable: duplicate-set-field, duplicate-doc-field
---@class Set
---@field keys table<any,boolean>
---@operator add(Set): Set
---@operator sub(Set): Set
---@overload fun(table?): Set
Set = {}
do
    local mt
    mt = {
        __index = Set,
        __add = function(a,b)
            if getmetatable(a) == mt and getmetatable(b) == mt then
                local res = a:copy()
                res:append(b:values())
                return res
            else
                assert(false,"Not supported")
            end
        end,
        __sub = function(a,b)
            if getmetatable(a) == mt and getmetatable(b) == mt then
                local res = a:copy()
                for k, _ in pairs(b.keys) do
                    res:remove(k)
                end
                return res
            else
                assert(false,"Not supported")
            end
        end
    }

    setmetatable(Set, {
        ---@param self Set
        ---@param t table? initial values
        ---@return Set
        __call = function(self,t)
            local o = setmetatable({},mt)

            o.keys = {}
            if t then
                for _, v in ipairs(t) do
                    o.keys[v] = true
                end
            end
            return o
        end
    })

end

function Set:add(k)
    self.keys[k] = true
end

function Set:append(t)
    for _, v in ipairs(t) do
        self:add(v)
    end
end

function Set:remove(k)
    self.keys[k] = nil
end

function Set:copy()
    return Set(self:values())
end

function Set:clear()
    self.keys = {}
end

function Set:contains(k)
    return self.keys[k]
end

function Set:values()
    local res = {}
    for k, _ in pairs(self.keys) do
        table.insert(res,k)
    end
    return res
end

return Set