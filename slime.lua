local anim8 = require("libraries/anim8")
local player = require('player')

local scaleX = 2

local slime = {}

function slime:new(x, y, leftBound, rightBound)
    local obj = {}

    setmetatable(obj, self)
    self.__index = self

    obj.width = 20
    obj.height = 20

    obj.speed = 30
    obj.direction = 1

    obj.leftBound = leftBound
    obj.rightBound = rightBound

	obj.hp = 3
    obj.dead = false

    obj.spritesheet = love.graphics.newImage("assets/slimes.png")

    obj.grid = anim8.newGrid(20, 14, obj.spritesheet:getWidth(), obj.spritesheet:getHeight())

    obj.animations = {}
    obj.animations.green = anim8.newAnimation(obj.grid("1-8", 1), 0.3)
    obj.animations.purple = anim8.newAnimation(obj.grid("1-8", 2), 0.3)
    obj.animations.red = anim8.newAnimation(obj.grid("1-8", 3), 0.3)
    obj.animations.blue = anim8.newAnimation(obj.grid("1-8", 4), 0.3)

	obj.sounds = {}
	obj.sounds.hit = love.audio.newSource("assets/Jelly_Damage.ogg", "static")
	obj.sounds.dead = love.audio.newSource("assets/Jelly_Death.ogg", "static")
    local colors = {"green", "purple", "red", "blue"}
    obj.color = colors[math.random(#colors)]

    obj.animation = obj.animations[obj.color]

    obj.body = love.physics.newBody(world, x, y, "kinematic")
    obj.body:setFixedRotation(true)

    obj.shape = love.physics.newRectangleShape(20, 14)

    obj.fixture = love.physics.newFixture(obj.body, obj.shape)
    obj.fixture:setUserData(obj)

    return obj
end

function slime:update(dt)
    if self.dead then return end

    local x = self.body:getX()

    if self.direction == 1 and x >= self.rightBound then
        self.direction = -1
    elseif self.direction == -1 and x <= self.leftBound then
        self.direction = 1
    end

    self.body:setLinearVelocity(self.speed * self.direction, 0)
    self.animation:update(dt)
end

function slime:kill()
    if self.dead then return end

    self.dead = true
	self.sounds.dead:play()
	self.body:destroy()
end

function slime:beginContact(a, b, collision)
    if self.dead then return end

    local other = nil

    if a == self.fixture then
        other = b:getUserData()
    elseif b == self.fixture then
        other = a:getUserData()
    end

    if other == player then
		if player.attackTime > 0 then
			self:takeDamage(1)
		else
			if not (player.iFrameTime > 0) then
        		player:takeDamage(1)
			else
				return
			end
		end
    end
end

function slime:takeDamage(amount)
    if self.dead then return end

	self.sounds.hit:play()
    self.hp = self.hp - amount

    if self.hp <= 0 then
        self:kill()
    end
end

function slime:draw()
    if self.dead then return end

    local x, y = self.body:getPosition()
	scaleX = scaleX * self.direction

    self.animation:draw(self.spritesheet, x, y, 0, self.direction, 2, 10, 7)
	love.graphics.print(self.hp, x, y - 10)
end

return slime
