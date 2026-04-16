local greeting = "hello"
local target = "world"
local code = nil
{print(table.concat({tostring((greeting)), " ", tostring((target))}))}
;(function() local _v = code; print(_v); return _v end)()
local items = {a, b, c}
;(function() local _v = nil; print(_v); return _v end)()
{before, (items), after}
;(function() local _v = nil; print(_v); return _v end)()
{before, (items), after}
local x = 42
;(function() local _v = nil; print(_v); return _v end)()
{outer, {inner, (x)}}
local function unless(cond, body)
  return {_NONE, (body)}
end
if not (((1 > 10))) then
  print("math works")
end
local function defn(name, params, body)
  return {(tonumber(name) or name), _NONE, (params), (body)}
end
defn("square", {n}, {(n * n)})
print(square)
7
local function traced(label, body)
  local result = nil
  {print(table.concat({"[", tostring((label)), "] start"}))}
  _append(result, body(_append(result, nil)))
  {print(table.concat({"[", tostring((label)), "] end"}))}
  return result
end
traced("demo", {print("doing work")})
local mode = "interpreter"
print(mode)
local function double(x)
  return (x * 2)
end
local function triple(x)
  return (x * 3)
end
local function quadruple(x)
  return (x * 4)
end
print(double(5))
print(triple(5))
print(quadruple(5))
local function get_name(obj)
  return _select(obj("name"), nil)
end
local function get_hp(obj)
  return _select(obj("hp"), nil)
end
local function get_attack(obj)
  return _select(obj("attack"), nil)
end
local hero = {
  name = "Kai",
  hp = 100,
  attack = 25
}
print(get_name(hero))
print(get_hp(hero))
print(get_attack(hero))
local max_enemies = 16
print(max_enemies)
