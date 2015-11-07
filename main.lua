

gameState = {
	playerPosition = {x = 0, y = 0, z = 0},
	playerAngular = {x = 0, y = 0, z = 0}, -- angle

	testSound = nil
}

function gameState:load()
	self.testSound = { pos = {x = 40, y = 0, z = 0}}

	self.testSound.source = love.audio.newSource("water_fall.wav", "static")
	self.testSound.source:setPosition(self.testSound.pos.x, self.testSound.pos.y, self.testSound.pos.z)
	self.testSound.source:setAttenuationDistances(10, 10)
	self.testSound.source:setLooping(true)
	self.testSound.source:play()

end

function gameState:update(dt)
	local playerOrientation = {x = math.cos(self.playerAngular.y), y = 0, z = math.sin(self.playerAngular.y)}
	local playerSideVector = {x = playerOrientation.z, y = 0, z = -playerOrientation.x}

	if love.keyboard.isDown("z") then
	   	self.playerPosition.x = self.playerPosition.x + playerOrientation.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z + playerOrientation.z * 8.0 * dt 	
	elseif love.keyboard.isDown("s") then
	   	self.playerPosition.x = self.playerPosition.x - playerOrientation.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z - playerOrientation.z * 8.0 * dt 			
	end

	if love.keyboard.isDown("q") then
	   	self.playerPosition.x = self.playerPosition.x + playerSideVector.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z + playerSideVector.z * 8.0 * dt 	
	elseif love.keyboard.isDown("d") then
	   	self.playerPosition.x = self.playerPosition.x - playerSideVector.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z - playerSideVector.z * 8.0 * dt 			
	end


	love.audio.setPosition(self.playerPosition.x, self.playerPosition.y, self.playerPosition.z)

	love.audio.setOrientation(playerOrientation.x, playerOrientation.y, playerOrientation.z, 0, 1, 0)
end

function gameState:mousemoved(x, y, dx, dy)
	--print(x, y, dx, dy)

	self.playerAngular.y = self.playerAngular.y + dx * 0.01

	if self.playerAngular.y > math.pi then
		self.playerAngular.y = self.playerAngular.y - 2 * math.pi
	end

	if self.playerAngular.y < -math.pi then
		self.playerAngular.y = self.playerAngular.y + 2 * math.pi
	end

	--print(dx, self.playerAngular.y)
end

function gameState:draw()
	love.graphics.push()
	love.graphics.translate(100, 100)

	love.graphics.point(self.playerPosition.x, self.playerPosition.z)
	local playerOrientation = {x = math.cos(self.playerAngular.y), y = 0, z = math.sin(self.playerAngular.y)}

	love.graphics.line(self.playerPosition.x, self.playerPosition.z, self.playerPosition.x + playerOrientation.x * 15, self.playerPosition.z + playerOrientation.z * 15)

	love.graphics.point(self.testSound.pos.x, self.testSound.pos.z)

	love.graphics.pop()
end

-- Love callback
function love.load()
	love.mouse.setGrabbed(true)
	love.mouse.setRelativeMode(true)

	love.audio.setDistanceModel("exponent")

	gameState:load()
end

function love.update(dt)
	gameState:update(dt)
end

function love.draw()
    gameState:draw()
end

function love.mousemoved(x, y, dx, dy)
	gameState:mousemoved(x, y, dx, dy)
end

function love.mousepressed( x, y, button )
end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end