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

  -- Levenshtein implementation from
--https://github.com/kennyledet/Algorithm-Implementations/blob/master/Levenshtein_distance/Lua/Yonaba/levenshtein.lua
function matrix(row,col)
  local m = {}
  for i = 1,row do m[i] = {}
      for j=1,col do m[i][j] = 0 end
  end
  return m
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
          coroutine.yield(v,t[v])
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