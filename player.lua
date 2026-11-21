anim8 = require('libraries/anim8')

player = {}

function player:load()
   self.x = 50
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
   self.attackTime = 0
   self.attackLength = 1.0
   self.iFrameLength = 1.0 
   self.iFrameTime = 0

   self.hp = 3
   self.dead = false

   self.grounded = false

   self.spritesheets = {}
   self.spritesheets.idle = love.graphics.newImage('assets/player_idle.png')
   self.spritesheets.run = love.graphics.newImage('assets/player_run.png')
   self.spritesheets.attack = love.graphics.newImage('assets/player_attack.png')
   self.spritesheets.jumpfall = love.graphics.newImage('assets/player_jumpfall.png')
   self.spritesheets.hurt = love.graphics.newImage('assets/player_hurt.png')

   self.grids = {}
   self.grids.idle = anim8.newGrid(56, 55, self.spritesheets.idle:getWidth(), self.spritesheets.idle:getHeight())
   self.grids.run = anim8.newGrid(56, 50, self.spritesheets.run:getWidth(), self.spritesheets.run:getHeight())
   self.grids.attack = anim8.newGrid(98, 71, self.spritesheets.attack:getWidth(), self.spritesheets.attack:getHeight())
   self.grids.jumpfall = anim8.newGrid(57, 72, self.spritesheets.jumpfall:getWidth(), self.spritesheets.jumpfall:getHeight())
   self.grids.hurt = anim8.newGrid(44, 54, self.spritesheets.hurt:getWidth(), self.spritesheets.hurt:getHeight())

   self.animations = {}
   self.animations.idle = anim8.newAnimation(self.grids.idle('1-7', 1), 0.1)
   self.animations.run = anim8.newAnimation(self.grids.run('1-8', 1), 0.1)
   self.animations.attack = anim8.newAnimation(self.grids.attack('1-10', 1), 0.1)
   self.animations.jump = anim8.newAnimation(self.grids.jumpfall('1-6', 1), 0.1, 'pauseAtEnd')
   self.animations.fall = anim8.newAnimation(self.grids.jumpfall('7-10', 1), 0.1)
   self.animations.hurt = anim8.newAnimation(self.grids.hurt(1, 1), 0.7)

   self.state = "idle"
   self.stateSpritesheet = "idle"

   self.direction = "right"

   self.sounds = {}
   self.sounds.hurt = love.audio.newSource("assets/Player_Damage.ogg", "static")
   self.sounds.jump = love.audio.newSource("assets/Player_Jump.ogg", "static")
   self.sounds.swing = love.audio.newSource("assets/Swing.ogg", "static")

   self.physics = {}
   self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
   self.physics.fixture:setUserData(self)
end

function player:update(dt)
   self:syncPhysics()
   self:move(dt)
   self:applyGravity(dt)
   self:setState()
   self:setDirection()
   self:decreaseAttackTime(dt)
   self:decreaseIframeTime(dt)
   self.animations[self.state]:update(dt)
end

function player:decreaseIframeTime(dt)
	if self.iFrameTime > 0 then
		self.iFrameTime = self.iFrameTime - dt
	end
end

function player:decreaseAttackTime(dt)
	if self.attackTime > 0 then
		self.attackTime = self.attackTime - dt
	end
end

function player:setState()
    if not self.grounded then
        self.stateSpritesheet = "jumpfall"

        if self.vy < 0 then
            self.state = "jump"
        else
            self.state = "fall"
        end

    elseif self.attackTime > 0 then
        self.state = "attack"
        self.stateSpritesheet = "attack"

    elseif self.vx == 0 then
        self.state = "idle"
        self.stateSpritesheet = "idle"

    else
        self.state = "run"
        self.stateSpritesheet = "run"
    end
end

function player:setDirection()
	if self.vx < 0 then
		self.direction = "left"
	elseif self.vx > 0 then
		self.direction = "right"
	end
end

function player:applyGravity(dt)
   if not self.grounded then
      self.vy = self.vy + self.gravity * dt
   end
end

function player:move(dt)
	if self.dead then return end
	if self.attackTime > 0 then
		self.vx = 0
		return
	end

   	if love.keyboard.isDown("d", "right") then
		self.vx = math.min(self.vx + self.acceleration * dt, self.maxSpeed)
   elseif love.keyboard.isDown("a", "left") then
	   self.vx = math.max(self.vx - self.acceleration * dt, -self.maxSpeed)
   else
      self:applyFriction(dt)
   end
end

function player:applyFriction(dt)
   if self.vx > 0 then
	   self.vx = math.max(self.vx - self.friction * dt, 0)
   elseif self.vx < 0 then
	   self.vx = math.min(self.vx + self.friction * dt, 0)
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
	if self.dead then return end
	  self.sounds.jump:play()
      self.vy = self.jumpAmount
      self.grounded = false
   elseif key == "e" then
	   if self.dead then return end
	   self.sounds.swing:play()
	   self.attackTime = self.attackLength
   elseif key == "r" and self.dead then
	   love.event.push("quit", "restart")
	end
end

function player:takeDamage(damage)
	if self.dead then return end

	self.sounds.hurt:play()
	self.hp = self.hp - damage
	self.iFrameTime = self.iFrameLength
	if self.hp <= 0 then
		self.dead = true
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
	if self.dead then love.graphics.print("You are dead! Press R to restart", 400, 200) return end

	local width, height = self.animations[self.state]:getDimensions()
	local scaleX = 1

	if self.direction == "right" then
		scaleX = 1
	else
		scaleX = -1
	end

	self.animations[self.state]:draw(self.spritesheets[self.stateSpritesheet], self.x, self.y, 0, scaleX, 1, width / 2, (height / 2) - 5)
end

return player
