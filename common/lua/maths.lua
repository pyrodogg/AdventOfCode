local P = {}
Maths = P

function Maths.add(a,b)
  return a+b
end

function Maths.sub(a,b)
  return a-b
end

function Maths.mul(a,b)
  return a*b
end

function Maths.div(a,b)
  return a/b
end

function Maths.idiv(a,b)
  return a//b
end
Maths.rem = Maths.idiv -- Remainder / floor division

function Maths.quot(a,b)
  return a%b
end


return Maths