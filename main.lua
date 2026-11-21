local sti = require("libraries/sti")
require("player")
local slime = require("slime")

slimes = {}
won = false

function love.load()
	map = sti("maps/level1.lua", {"box2d"})

	mainMusic = love.audio.newSource("assets/Main_JellyNBass(loop).ogg", "stream")
	endingMusic = love.audio.newSource("assets/Ending_JellyJazz.ogg", "stream")

	world = love.physics.newWorld(0, 0)
	world:setCallbacks(beginContact, endContact)
	map:box2d_init(world)

	map.layers.solid.visible = false
	map.layers.entity.visible = false


	player:load()

	spawnEntities()
end

function love.update(dt)
	world:update(dt)
	player:update(dt)

	if not mainMusic:isPlaying() then
		love.audio.play( mainMusic )
	end

	for _, slime in ipairs(slimes) do
    slime:update(dt)
	end


	win()
end

function love.draw()
	love.graphics.clear(6 / 255, 148 / 255, 148 / 255)
	player:draw()
	map:draw(0, 0, 1, 1)

	if won then 
	love.graphics.print("You win! You can quit now, there's uh, nothing else", 200, 200) 
	end

	love.graphics.print("HP:" .. player.hp, 0, 0, 0)
	love.graphics.print("Press E to attack the slimes!", 50, 0, 0)
	for _, slime in ipairs(slimes) do
    slime:draw()
	end
end

function love.keypressed(key)
	player:jump(key)
end

function beginContact(a, b, collision)
	player:beginContact(a, b, collision)

    for _, slime in ipairs(slimes) do
        slime:beginContact(a, b, collision)
    end

end

function endContact(a, b, collision)
	player:endContact(a, b, collision)
end

function spawnEntities()
    local slimeObjects = {}
    local flipperObjects = {}

    for _, obj in ipairs(map.layers.entity.objects) do
        if obj.type == "slime" then
            table.insert(slimeObjects, obj)

        elseif obj.type == "flipper" then
            table.insert(flipperObjects, obj)
        end
    end

    for _, obj in ipairs(slimeObjects) do
        local leftBound = nil
        local rightBound = nil

        local leftDistance = math.huge
        local rightDistance = math.huge

        for _, flipper in ipairs(flipperObjects) do
            local distance = math.abs(flipper.x - obj.x)
            if flipper.x < obj.x and distance < leftDistance then
                leftDistance = distance
                leftBound = flipper.x

            elseif flipper.x > obj.x and distance < rightDistance then
                rightDistance = distance
                rightBound = flipper.x
            end
        end

        if leftBound and rightBound then
            table.insert(
                slimes,
                slime:new(obj.x, obj.y, leftBound, rightBound)
            )
        end
    end
end

function win()
	for _, slime in ipairs(slimes) do
		if not slime.dead then
			return
		end
	end

	won = true
	love.audio.stop( mainMusic )
	love.audio.play( endingMusic )
end
