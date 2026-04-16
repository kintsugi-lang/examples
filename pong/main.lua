-- Kintsugi runtime support
math.randomseed(os.time())
local _pair_mt = {}
_pair_mt.__add = function(a, b) return setmetatable({x=a.x+b.x, y=a.y+b.y}, _pair_mt) end
_pair_mt.__sub = function(a, b) return setmetatable({x=a.x-b.x, y=a.y-b.y}, _pair_mt) end
_pair_mt.__mul = function(a, b)
  if type(a) == "number" then return setmetatable({x=a*b.x, y=a*b.y}, _pair_mt) end
  if type(b) == "number" then return setmetatable({x=a.x*b, y=a.y*b}, _pair_mt) end
  return setmetatable({x=a.x*b.x, y=a.y*b.y}, _pair_mt)
end
_pair_mt.__div = function(a, b)
  if type(b) == "number" then return setmetatable({x=a.x/b, y=a.y/b}, _pair_mt) end
  return setmetatable({x=a.x/b.x, y=a.y/b.y}, _pair_mt)
end
_pair_mt.__unm = function(a) return setmetatable({x=-a.x, y=-a.y}, _pair_mt) end
_pair_mt.__eq  = function(a, b) return a.x == b.x and a.y == b.y end
local function _pair(x, y) return setmetatable({x=x, y=y}, _pair_mt) end

local lg = love.graphics
local le = love.event
local lw = love.window
local lk = love.keyboard
local SCREEN_W = 800
local SCREEN_H = 600
local PADDLE_W = 12
local PADDLE_H = 80
local PADDLE_SPEED = 400
local BALL_SIZE = 8
local BALL_SPEED = 300
local game = {
  paused = true,
  font = nil
}
local player = {
  pos = _pair(20, 260),
  score = 0,
  speed = PADDLE_SPEED
}
local cpu = {
  pos = _pair(768, 260),
  score = 0,
  speed = PADDLE_SPEED
}
local ball = {
  pos = _pair(396, 296),
  vel = _pair(1, 1),
  speed = BALL_SPEED
}
local function reset_ball()
  ball.pos = _pair(396, 296)
  if ball.vel.x > 0 then
    ball.vel.x = -1
  else
    ball.vel.x = 1
  end
  if math.random(2) == 1 then
    ball.vel.y = 1
  else
    ball.vel.y = -1
  end
  ball.speed = BALL_SPEED
  game.paused = true
  return game.paused
end
love.load = function()
  lw.setMode(SCREEN_W, SCREEN_H)
  lw.setTitle("Kintsugi Pong")
  game.font = lg.newFont(24)
end
love.keypressed = function(key)
  if key == "space" then
    game.paused = not (game.paused)
  elseif key == "r" then
    player.score = 0
    cpu.score = 0
    reset_ball()
  elseif key == "escape" then
    le.quit()
  end
end
love.update = function(dt)
  if not (game.paused) then
    if lk.isDown("w") then
      player.pos.y = player.pos.y - (player.speed * dt)
    end
    if lk.isDown("s") then
      player.pos.y = player.pos.y + (player.speed * dt)
    end
    if player.pos.y < 0 then
      player.pos.y = 0
    end
    if player.pos.y > (SCREEN_H - PADDLE_H) then
      player.pos.y = SCREEN_H - PADDLE_H
    end
    local cpu_center = cpu.pos.y + (PADDLE_H / 2)
    if cpu_center < (ball.pos.y - 20) then
      cpu.pos.y = cpu.pos.y + (cpu.speed * dt * 0.7)
    end
    if cpu_center > (ball.pos.y + 20) then
      cpu.pos.y = cpu.pos.y - (cpu.speed * dt * 0.7)
    end
    if cpu.pos.y < 0 then
      cpu.pos.y = 0
    end
    if cpu.pos.y > (SCREEN_H - PADDLE_H) then
      cpu.pos.y = SCREEN_H - PADDLE_H
    end
    ball.pos = ball.pos + (ball.vel * ball.speed * dt)
    if ball.pos.y < 0 then
      ball.pos.y = 0
      ball.vel.y = -(ball.vel.y)
    end
    if ball.pos.y > (SCREEN_H - BALL_SIZE) then
      ball.pos.y = SCREEN_H - BALL_SIZE
      ball.vel.y = -(ball.vel.y)
    end
    if (ball.vel.x < 0 and ball.pos.x < (player.pos.x + PADDLE_W) and ball.pos.y > (player.pos.y - BALL_SIZE) and ball.pos.y < (player.pos.y + PADDLE_H)) then
      ball.pos.x = player.pos.x + PADDLE_W
      ball.vel.x = -(ball.vel.x)
      ball.speed = ball.speed + 20
    end
    if (ball.vel.x > 0 and ball.pos.x > (cpu.pos.x - BALL_SIZE) and ball.pos.y > (cpu.pos.y - BALL_SIZE) and ball.pos.y < (cpu.pos.y + PADDLE_H)) then
      ball.pos.x = cpu.pos.x - BALL_SIZE
      ball.vel.x = -(ball.vel.x)
      ball.speed = ball.speed + 20
    end
    if ball.pos.x < 0 then
      cpu.score = cpu.score + 1
      reset_ball()
    end
    if ball.pos.x > SCREEN_W then
      player.score = player.score + 1
      reset_ball()
    end
  end
end
love.draw = function()
  lg.setColor(0.3, 0.3, 0.4, 1)
  lg.rectangle("fill", 398, 0, 4, SCREEN_H)
  lg.setColor(0.9, 0.9, 1, 1)
  lg.rectangle("fill", player.pos.x, player.pos.y, PADDLE_W, PADDLE_H)
  lg.rectangle("fill", cpu.pos.x, cpu.pos.y, PADDLE_W, PADDLE_H)
  lg.setColor(1, 0.8, 0.2, 1)
  lg.circle("fill", ball.pos.x, ball.pos.y, BALL_SIZE)
  lg.setFont(game.font)
  lg.setColor(1, 1, 1, 1)
  lg.print(tostring(player.score), 340, 20)
  lg.print(tostring(cpu.score), 440, 20)
  if game.paused then
    lg.setColor(1, 1, 1, 0.6)
    lg.print("SPACE to start  |  W/S to move  |  R to reset", 200, 560)
  end
end
