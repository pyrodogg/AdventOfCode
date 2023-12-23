function T(t)
  return setmetatable(t, {__index = table})
end

-- http://lua-users.org/wiki/FileInputOutput
-- Return true if file exists and is readable.
function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
  end
    
  -- get all lines from a file, returns an empty 
  -- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function tobase10(n)
  return tonumber(n,10)
end

function table.shallow_copy(t)
  local a = {}
  for k,v in pairs(t) do
      a[k] = v
  end
  return a
end

  -- Levenshtein implementation from
--https://github.com/kennyledet/Algorithm-Implementations/blob/master/Levenshtein_distance/Lua/Yonaba/levenshtein.lua
function matrix(row,col)
  local m = {}
  for i = 1,row do m[i] = {}
      for j=1,col do m[i][j] = 0 end
  end
  return m
end

local function matrixtostring(M)

  local s = ''
  for k,v in pairs(M) do
      for i=1, #v do 
          s = s..v[i]
      end
      s = s..'\n'
  end
  return s
end

function levenshtein(strA,strB)
  local M = matrix(#strA+1,#strB+1)
  local i,j,cost
  local row,col = #M,#M[1]
  for i = 1,row do M[i][1] = i-1 end
  for j = 1,col do M[1][j] = j-1 end
  for i = 2,row do
      for j = 2,col do
          if (strA:sub(i-1,i-1) == strB:sub(j-1,j-1)) then cost = 0
          else cost = 1
          end
          M[i][j] = math.min(M[i-1][j]+1,M[i][j-1]+1,M[i-1][j-1]+cost)
      end
  end
  return M[row][col], M
end

function tokey(x,y)
  return x..':'..y
end

function fromkey(k)
  local n = map(flatten(unroll(k:gmatch('([%-]-%d+)%:([%-]-%d+)'))),tobase10)
  return table.unpack(n)
end

-- https://stackoverflow.com/a/27028488
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

-- Sorted pair iterator
function spairs(t, sortFunction)
  local keys = {}
  for k in pairs(t) do
      table.insert(keys,k)
  end

  table.sort(keys, function(a,b)
      if sortFunction == nil then
          return t[a] < t[b]
      else
          return sortFunction(t,a,b)
      end
  end)

  return coroutine.wrap(function()
      
      for k,v in pairs(keys) do
          coroutine.yield(v,t[v],k)
      end      
      coroutine.yield(nil)
  end)
end

function map(t, f)
  local res = {}
  for k,v in pairs(t) do
      table.insert(res,f(v,k,t))
  end
  return res
end

function maxBy(t,f)
  local maxVal
  local maxIndex = 0
  for k,v in pairs(t) do
      local g
      if type(f) == 'function' then
          g = f(v)
      elseif type(f) == 'string' and v[f] ~= nil then
          g = v[f]
      else --identity
          g = v
      end

      if maxVal == nil or g > maxVal then
          maxVal = g
          maxIndex = k
      end
  end
  return t[maxIndex], maxIndex
end

function minBy(t,f)
  local minVal
  local minIndex = 0
  for k,v in pairs(t) do
      local g
      if type(f) == 'function' then
          g = f(v)
      elseif type(f) == 'string' and v[f] ~= nil then
          g = v[f]
      else --identity
          g = v
      end

      if minVal == nil or g < minVal then
         minVal = g
         minIndex = k
      end
  end
  return t[minIndex], minIndex
end

function keyBy(t,f)
  local ret = {}

  for k,v in pairs(t) do
    local g
    if type(f) == 'function' then
      g = f(v)
    elseif type(g) == 'string' and v[f] ~= nil then
      g = v[f]
    else
      g = v
    end
    ret[g] = v
  end

  return ret
end

-- sumBy(table,function(a,v,k,t) end)
-- sumBy(table,'copies')
-- sumBy(table,'foo.bar') TODO
function sumBy(t, f)
  local ret = 0

  ret = reduce(t,function(a,v) 
    
    local g
    if type(f) == 'function' then
      g = f(v)
    elseif type(f) == 'string' and v[f] ~= nil then
      g = v[f]
    else
      g = v
    end

    return a + g
    
  end, 0)

  return ret
end

function sort(t,f)
  local res = {}
  for k,v in spairs(t,f) do
      table.insert(res,v)
  end
  return res
end


function groupBy(t,f)
  local res = {}
  for k,v in pairs(t) do
      local g
      if type(f) == 'function' then
          g = f(v)
      elseif type(f) == 'string' and v[f] ~= nil then
          g = v[f]
      else
          error('Invalid group parameter ['..f..']')
      end

      if res[g] == nil then
          res[g] = {}
      end
      table.insert(res[g],v)
  end
  return res
end

-- Curry and flaten from http://lua-users.org/wiki/CurriedLua
function curry(func, num_args)
  num_args = num_args or debug.getinfo(func, "u").nparams
  if num_args < 2 then return func end
  local function helper(argtrace, n)
    if n < 1 then
      local  foo = flatten(argtrace)
      return func(table.unpack(flatten(argtrace)))
    else
      return function (...)
        return helper({argtrace, ...}, n - select("#", ...))
      end
    end
  end
  return helper({}, num_args)
end

function flatten(t)
  local ret = {}
  for _, v in ipairs(t) do
    if type(v) == 'table' then
      for _, fv in ipairs(flatten(v)) do
        ret[#ret + 1] = fv
      end
    else
      ret[#ret + 1] = v
    end
  end
  return ret
end

function reduce(t,i,a)
  local res = a
  for k,v in pairs(t) do
    res = i(res,v,k,t)
  end
  return res
end

function table:reduce(i,a)
  return reduce(self,i,a)
end

function foldL(t,f,a)
  
  for i = 1, #t, 1 do
    a = f(a,t[i],i,t)
  end
  return a
end

function foldR(t,f,a)
  for i = #t, 1, -1 do
    a = f(a,t[i],i,t)
  end
  return a
end

function unroll(f,_s,_var)
  --iterate some function until exhausted (or safety?)
  --capture all returns to table.
  local res = {}
  local count = 1
  --Syntax sugar for a for loop,is reasonably safe if implemented soundly*
  while true do
      local r = {f(_s,_var)}
      _var = r[1]
      if _var == nil then break end
      if #r == 1 then --collapse simple table of 1 value
        r = r[1]
      end
      res[count] = r
      count = count + 1
      -- if count > 10000 then break end -- sanity check
  end
  return res
end
