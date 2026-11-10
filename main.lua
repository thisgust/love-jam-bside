local gravity = 50.0
local max_velocity = 100.0
local player_speed = 250.0
local jump_force = -25.0

function love.load()
	player = {}
	player.x = 0.0
	player.y = 0.0
	player.vx = 0.0
	player.vy = 0.0
	player.sprite = love.graphics.newImage('assets/Jump (32x32).png')
end

function love.update(dt)
	applyGravity(dt)
	movePlayer(dt)
	applyVelocity()
end

function love.draw()
	love.graphics.draw(player.sprite, player.x, player.y, 0)
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
	elseif love.keyboard.isDown('left') then
		player.vx = -player_speed * dt
	else
		player.vx = 0
	end
end

function applyVelocity()
	player.x = player.x + player.vx
	player.y = player.y + player.vy
end
