function love.load()

	-- Setting up a basic player object
	player = {}
	player.x = 0
	player.y = 0
	player.vx = 0
	player.vy = 0
	player.sprite = love.graphics.newImage("assets/Jump (32x32).png")
end

function love.update(dt)
	applyGravity(dt)
	applyVelocity(dt)
end

function love.draw()
	love.graphics.draw(player.sprite, player.x, player.y, 0) 
end

function applyVelocity(dt)
	player.x = player.x + player.vx * dt
	player.y = player.y + player.vy * dt
end

function applyGravity(dt)
	player.vy = player.vy + 10
	if player.vy > 200 then
		player.vy = 200
	end
end
