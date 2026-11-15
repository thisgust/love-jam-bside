anim8 = require('libraries/anim8')

player = {}

function player:load()
   self.x = 100
   self.y = 100
   self.width = 20
   self.height = 60
   self.vx = 0
   self.vy = 0
   self.maxSpeed = 200
   self.acceleration = 4000
   self.friction = 3500
   self.gravity = 1500
   self.jumpAmount = -500

   self.grounded = false

   self.spritesheets = {}
   self.spritesheets.idle = love.graphics.newImage('assets/player_idle.png')
   self.spritesheets.run = love.graphics.newImage('assets/player_run.png')
   self.spritesheets.attack = love.graphics.newImage('assets/player_attack.png')
   self.spritesheets.jumpfall = love.graphics.newImage('assets/player_jumpfall.png')
   self.spritesheets.hurt = love.graphics.newImage('assets/player_hurt.png')

   self.grids = {}
   self.grids.idle = anim8.newGrid(56, 55, self.spritesheets.idle:getWidth(), self.spritesheets.idle:getHeight(), 1, 1)
   self.grids.run = anim8.newGrid(57, 52, self.spritesheets.run:getWidth(), self.spritesheets.run:getHeight(), 1, 1)
   self.grids.attack = anim8.newGrid(98, 71, self.spritesheets.attack:getWidth(), self.spritesheets.attack:getHeight(), 1, 1)
   self.grids.jumpfall = anim8.newGrid(57, 72, self.spritesheets.jumpfall:getWidth(), self.spritesheets.jumpfall:getHeight(), 1, 1)
   self.grids.hurt = anim8.newGrid(56, 55, self.spritesheets.hurt:getWidth(), self.spritesheets.hurt:getHeight(), 1, 1)

   self.animations = {}
   self.animations.idle = anim8.newAnimation(self.grids.idle('1-7'), 0.1)
   self.animations.run = anim8.newAnimation(self.grids.run('1-8'), 0.1)
   self.animations.attack = anim8.newAnimation(self.grids.attack('1-10'), 0.1)
   self.animations.jump = anim8.newAnimation(self.grids.jumpfall('1-3'), 0.1)
   self.animations.fall = anim8.newAnimation(self.grids.jumpfall('1-3'), 0.1)
   self.animations.hurt = anim8.newAnimation(self.grids.hurt('1'), 1.0)

   self.currentAnimation = self.animations.idle
   self.currentAnimationSpritesheet = self.spritesheets.idle

   self.physics = {}
   self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function player:update(dt)
   self:syncPhysics()
   self:move(dt)
   self:applyGravity(dt)
   self.currentAnimation:update(dt)
end

function player:applyGravity(dt)
   if not self.grounded then
      self.vy = self.vy + self.gravity * dt
   end
end

function player:move(dt)
   if love.keyboard.isDown("d", "right") then
	  self.currentAnimation = self.animations.run
	  self.currentAnimationSpritesheet = self.spritesheets.run
      if self.vx < self.maxSpeed then
         if self.vx + self.acceleration * dt < self.maxSpeed then
            self.vx = self.vx + self.acceleration * dt
         else
            self.vx = self.maxSpeed
         end
      end
   elseif love.keyboard.isDown("a", "left") then
	  self.currentAnimation = self.animations.run:clone():flipH()
	  self.currentAnimationSpritesheet = self.spritesheets.run
      if self.vx > -self.maxSpeed then
         if self.vx - self.acceleration * dt > -self.maxSpeed then
            self.vx = self.vx - self.acceleration * dt
         else
            self.vx = -self.maxSpeed
         end
      end
   else
      self:applyFriction(dt)
   end
end

function player:applyFriction(dt)
   if self.vx > 0 then
      if self.vx - self.friction * dt > 0 then
         self.vx = self.vx - self.friction * dt
      else
         self.vx = 0
      end
   elseif self.vx < 0 then
      if self.vx + self.friction * dt < 0 then
         self.vx = self.vx + self.friction * dt
      else
         self.vx = 0
		 self.currentAnimation = self.animations.idle
		 self.currentAnimationSpritesheet = self.spritesheets.idle
      end
   end
end

function player:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.vx, self.vy)
end

function player:beginContact(a, b, collision)
   if self.grounded == true then return end
   local nx, ny = collision:getNormal()
   if a == self.physics.fixture then
      if ny > 0 then
         self:land(collision)
      end
   elseif b == self.physics.fixture then
      if ny < 0 then
         self:land(collision)
      end
   end
end

function player:land(collision)
   self.currentGroundCollision = collision
   self.vy = 0
   self.grounded = true
end

function player:jump(key)
   if (key == "space" or key == "up") and self.grounded then
      self.vy = self.jumpAmount
      self.grounded = false
   end
end

function player:endContact(a, b, collision)
   if a == self.physics.fixture or b == self.physics.fixture then
      if self.currentGroundCollision == collision then
         self.grounded = false
      end
   end
end

function player:draw()
	self.currentAnimation:draw(self.currentAnimationSpritesheet, self.x, self.y)
end
