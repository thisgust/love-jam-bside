local isMainMenu = true
local scale = 2 
local flipped = true
local gravity = 50.0
local max_velocity = 100.0
local player_speed = 250.0
local jump_force = -25.0

function love.load()
	-- Loading required libraries
	anim8 = require 'libraries/anim8'
	sti = require 'libraries/sti'
	-- wf = require 'libraries'
	
	love.graphics.setDefaultFilter("nearest", "nearest")
	mainMenuSource = love.audio.newSource("assets/Jelly Disco.ogg", "stream")

	player = {}
	player.x = 0.0
	player.y = 0.0
	player.vx = 0.0
	player.vy = 0.0
	player.idleCycleSs = love.graphics.newImage('assets/player_idle.png')
	player.idleGrid = anim8.newGrid(56, 55, player.idleCycleSs:getWidth(), player.idleCycleSs:getHeight())
	player.runCycleSs = love.graphics.newImage('assets/player_run.png')
	player.runGrid = anim8.newGrid(56, 51, player.runCycleSs:getWidth(), player.runCycleSs:getHeight())

	player.animations = {}
	player.animations.run = anim8.newAnimation( player.runGrid('1-8', 1), 0.1)
	player.animations.runFlipped = player.animations.run:clone():flipH() 
	player.animations.idle = anim8.newAnimation( player.idleGrid('1-7', 1), 0.2)
	player.animations.idleFlipped = player.animations.idle:clone():flipH() 

	player.currentAnim = player.animations.idle
	player.currentAnimSs = player.idleCycleSs
end

function love.update(dt)
	if isMainMenu and not mainMenuSource:isPlaying() then
		love.audio.play(mainMenuSource)
	end

	player.currentAnim:update(dt)
	applyGravity(dt)
	movePlayer(dt)
	applyVelocity()

	if player.vx > 0 or player.vx < 0 then
		if not flipped then
			player.currentAnim = player.animations.run
			player.currentAnimSs = player.runCycleSs
		else
			player.currentAnim = player.animations.runFlipped
			player.currentAnimSs = player.runCycleSs
		end
	else
		if not flipped then
			player.currentAnim = player.animations.idle
			player.currentAnimSs = player.idleCycleSs
		else
			player.currentAnim = player.animations.idleFlipped
			player.currentAnimSs = player.idleCycleSs
		end
	end
end

function love.draw()
	love.graphics.clear(206 / 255, 229 / 255, 237 / 255)
	player.currentAnim:draw(player.currentAnimSs, player.x, player.y)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		player.vy = player.vy + jump_force
	end
end

function applyGravity(dt)
	player.vy = player.vy + gravity * dt
	if player.vy >= max_velocity then
		player.vy = max_velocity
	end
end

function movePlayer(dt)
	if love.keyboard.isDown('right') then
		player.vx = player_speed * dt
		flipped = false
	elseif love.keyboard.isDown('left') then
		player.vx = -player_speed * dt
		flipped = true
	else
		player.vx = 0
	end
end

function applyVelocity()
	player.x = player.x + player.vx
	player.y = player.y + player.vy
end
