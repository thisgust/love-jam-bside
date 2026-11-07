local max_velocity = 800.0
local gravity = 50.0
local move_speed = 150.0

function love.load()

	-- Setting up a basic player object
	player = {}
	player.x = 50 
	player.y = 50
	player.vx = 0
	player.vy = 0
	player.sprite = love.graphics.newImage("assets/Jump (32x32).png")
end

function love.update(dt)
	applyGravity(dt)
	movePlayer(dt)
	applyVelocity(dt)
end

function love.draw()
	love.graphics.draw(player.sprite, player.x, player.y, 0.0, 1, 1, 0.0, 0.0)
end

function applyVelocity(dt)
	player.x = player.x + player.vx * dt
	player.y = player.y + player.vy * dt
end

function applyGravity(dt)
	player.vy = player.vy + gravity 
	if player.vy > max_velocity then
		player.vy = max_velocity
	end
end

function movePlayer(dt)
	if love.keyboard.isDown("right") then
		player.vx = move_speed
	elseif love.keyboard.isDown("left") then
		player.vx = -move_speed
	else
		player.vx = 0
	end
end
