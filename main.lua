local sti = require("libraries/sti")
require("player")

function love.load()
	map = sti("maps/level1.lua", {"box2d"})
	world = love.physics.newWorld(0, 0)
	world:setCallbacks(beginContact, endContact)
	map:box2d_init(world)
	map.layers.solid.visible = false
	player:load()
end

function love.update(dt)
	world:update(dt)
	player:update(dt)
end

function love.draw()
	player:draw()
	map:draw(0, 0, 1, 1)
end

function love.keypressed(key)
	player:jump(key)
end

function beginContact(a, b, collision)
	player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	player:endContact(a, b, collision)
end
