-- Kintsugi runtime support
math.randomseed(os.time())
local unpack = unpack or table.unpack
local _NONE = setmetatable({}, {__tostring = function() return "none" end})
local function _is_none(v) return v == nil or v == _NONE end
local function _add(a, b)
  if type(a) == "string" or type(b) == "string" then return tostring(a) .. tostring(b)
  else return a + b end
end
local function _equals(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  if #a ~= #b then return false end
  for i = 1, #a do if not _equals(a[i], b[i]) then return false end end
  return true
end
local function _has(t, v)
  for _, x in ipairs(t) do if _equals(x, v) then return true end end
  return false
end
local function _make(proto, overrides, typeName)
  local inst = {}
  for k, v in pairs(proto) do inst[k] = v end
  if overrides then for k, v in pairs(overrides) do inst[k] = v end end
  if typeName then inst._type = typeName end
  return inst
end
local Ability = {
  name = nil,
  power = nil,
  kind = nil
}
local slash = _make(Ability, {
  name = "Slash",
  power = 25,
  kind = "physical"
}, "ability")
local fireball = _make(Ability, {
  name = "Fireball",
  power = 30,
  kind = "fire"
}, "ability")
local heal = _make(Ability, {
  name = "Heal",
  power = 20,
  kind = "heal"
}, "ability")
local poison = _make(Ability, {
  name = "Poison",
  power = 8,
  kind = "dot"
}, "ability")
local Unit = {
  name = nil,
  hp = nil,
  max_hp = nil,
  attack = nil,
  defense = nil,
  speed = nil,
  abilities = nil
}
local function make_warrior(n)
  return _make(Unit, {
    name = n,
    hp = 100,
    max_hp = 100,
    attack = 15,
    defense = 10,
    speed = 8,
    abilities = {"slash"}
  }, "unit")
end
local function make_mage(n)
  return _make(Unit, {
    name = n,
    hp = 70,
    max_hp = 70,
    attack = 8,
    defense = 5,
    speed = 12,
    abilities = {"fireball", "poison"}
  }, "unit")
end
local function make_healer(n)
  return _make(Unit, {
    name = n,
    hp = 80,
    max_hp = 80,
    attack = 6,
    defense = 8,
    speed = 10,
    abilities = {"heal", "slash"}
  }, "unit")
end
local function is_alive(unit)
  return (unit.hp > 0)
end
local function clamp(val, lo, hi)
  if (val < lo) then
    return lo
  end
  if (val > hi) then
    return hi
  end
  return val
end
local function calc_damage(attacker, ability, defender)
  local dmg = (_add(attacker.attack, ability.power) - defender.defense)
  if (dmg < 1) then
    dmg = 1
  end
  return dmg
end
local function apply_ability(user, ability, target)
  if ability.kind == "heal" then
    local amount = clamp(ability.power, 0, ((target.max_hp - target.hp)))
    target.hp = _add(target.hp, amount)
    print(table.concat({"  ", tostring(user.name), " heals ", tostring(target.name), " for ", tostring(amount), " HP", " (", tostring(target.hp), "/", tostring(target.max_hp), ")"}))
  elseif ability.kind == "dot" then
    local dmg = ability.power
    target.hp = (target.hp - dmg)
    if (target.hp < 0) then
      target.hp = 0
    end
    print(table.concat({"  ", tostring(user.name), " poisons ", tostring(target.name), " for ", tostring(dmg), " damage", " (", tostring(target.hp), "/", tostring(target.max_hp), ")"}))
  else
    local dmg = calc_damage(user, ability, target)
    target.hp = (target.hp - dmg)
    if (target.hp < 0) then
      target.hp = 0
    end
    print(table.concat({"  ", tostring(user.name), " uses ", tostring(ability.name), " on ", tostring(target.name), " for ", tostring(dmg), " damage", " (", tostring(target.hp), "/", tostring(target.max_hp), ")"}))
  end
end
local function pick_enemy(enemies)
  local living = (function()
    local _collect_r = {}
    for _, e in ipairs(enemies) do
      if is_alive(e) then
        _collect_r[#_collect_r+1] = (function()
          return e
        end)()
      end
    end
    return _collect_r
  end)()
  if (#living == 0) then
    return nil
  end
  return living[(_add(((math.random(#living) - 1)), 1))]
end
local function pick_wounded(allies)
  local wounded = (function()
    local _collect_r = {}
    for _, a in ipairs(allies) do
      if (not not (is_alive(a) and (a.hp < a.max_hp))) then
        _collect_r[#_collect_r+1] = (function()
          return a
        end)()
      end
    end
    return _collect_r
  end)()
  if (#wounded == 0) then
    return nil
  end
  return wounded[(_add(((math.random(#wounded) - 1)), 1))]
end
local function pick_action(unit, allies, enemies)
  if _has(unit.abilities, "heal") then
    local w = pick_wounded(allies)
    if not _is_none(w) then
      return {
        ability = heal,
        target = w
      }
    end
  end
  local ability_name = unit.abilities[(_add(((math.random(#unit.abilities) - 1)), 1))]
  local target = pick_enemy(enemies)
  if _is_none(target) then
    return nil
  end
  if ability_name == "slash" then
    return {
      ability = slash,
      target = target
    }
  elseif ability_name == "fireball" then
    return {
      ability = fireball,
      target = target
    }
  elseif ability_name == "poison" then
    return {
      ability = poison,
      target = target
    }
  elseif ability_name == "heal" then
    return {
      ability = heal,
      target = target
    }
  else
    return {
      ability = slash,
      target = target
    }
  end
end
local function turn_order(all_units)
  return (function() local _key = function(u)
    return -(u.speed)
  end; table.sort(all_units, function(a, b) return _key(a) < _key(b) end); return all_units end)()
end
local function count_alive(team)
  local n = 0
  for _, u in ipairs(team) do
    if is_alive(u) then
      n = _add(n, 1)
    end
  end
  return n
end
local team_a = {make_warrior("Kael"), make_mage("Lyra"), make_healer("Mira")}
local team_b = {make_warrior("Grok"), make_mage("Zara"), make_healer("Nix")}
local all_units = {team_a[1], team_a[2], (function() local _t = team_a; return _t[#_t] end)(), team_b[1], team_b[2], (function() local _t = team_b; return _t[#_t] end)()}
local function name_of(unit)
  return unit.name
end
local function print_team(label, team)
  print(table.concat({tostring(label), tostring((name_of((team[1])))), ", ", tostring((name_of((team[2])))), ", ", tostring((name_of(((function() local _t = team; return _t[#_t] end)()))))}))
end
print("=== BATTLE START ===")
print_team("Team A: ", team_a)
print_team("Team B: ", team_b)
print("")
local turn = 0
while true do
  turn = _add(turn, 1)
  print(table.concat({"--- Round ", tostring(turn), " ---"}))
  local ordered = turn_order(all_units)
  for _, unit in ipairs(ordered) do
    if is_alive(unit) then
      local is_team_a = (not not ((unit.name == name_of((team_a[1]))) or (unit.name == name_of((team_a[2]))) or (unit.name == name_of(((function() local _t = team_a; return _t[#_t] end)())))))
      local allies = (function()
        if is_team_a then
          return team_a
        else
          return team_b
        end
      end)()
      local enemies = (function()
        if is_team_a then
          return team_b
        else
          return team_a
        end
      end)()
      if ((count_alive(enemies)) > 0) then
        local action = pick_action(unit, allies, enemies)
        if not _is_none(action) then
          apply_ability(unit, action.ability, action.target)
          if not (is_alive(action.target)) then
            print(table.concat({"  ** ", tostring(action.target.name), " is knocked out! **"}))
          end
        end
      end
    end
  end
  local a_alive = count_alive(team_a)
  local b_alive = count_alive(team_b)
  print(table.concat({"  Team A alive: ", tostring(a_alive), "  Team B alive: ", tostring(b_alive)}))
  print("")
  if (a_alive == 0) then
    print("=== TEAM B WINS ===")
    break
  end
  if (b_alive == 0) then
    print("=== TEAM A WINS ===")
    break
  end
  if (turn >= 20) then
    print("=== DRAW (20 rounds) ===")
    break
  end
end
