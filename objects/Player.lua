require 'objects/GameObject'

Player = GameObject:extend()

function Player:new(area, x, y, opts)
  Player.super.new(self, area, x, y, opts)

  -- physics stuff
  self.w, self.h = 12, 12

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
  self.collider.setObject(self)

  -- velocity
  self.r = math.pi/2
  self.rv = 1.66*math.pi
  self.v = 0
  self.max_v = 100
  self.a = 100
  
  -- shooty
  self.timer:every(0.24, function()
      self:shoot()
  end)
  
end

function Player:update(dt)
  Player.super.update(self,dt)
  if input:down('left') then self.r = self.r - self.rv*dt end
  if input:down('right') then self.r = self.r + self.rv*dt end
  self:killOutside()
  self.v = math.min(self.v + self.a*dt, self.max_v)
  self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
end

function Player:shoot()
  local d = 1.2*self.w
  
  --bx = ax + distance*math.cos(angle)
  ax = 0.5*d*math.cos(self.r + math.pi/2)
  ay = 0.5*d*math.sin(self.r + math.pi/2)
  
  bx = 0.5*d*math.cos(self.r - math.pi/2)
  by = 0.5*d*math.sin(self.r - math.pi/2)

  self.area:addGameObject('ShootEffect', self.x + 1.2*self.w*math.cos(self.r), self.y + 1.2*self.w*math.sin(self.r), {player = self, d = d})
  
  self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r})
end

function Player:draw()
  local bx = self.x + 2*self.w*math.cos(self.r)
  local by = self.y + 2*self.w*math.sin(self.r)
  love.graphics.circle('line', self.x, self.y, self.w)
end

function Player:die()
  self.dead = true
end

function Player:killOutside()
    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end
end