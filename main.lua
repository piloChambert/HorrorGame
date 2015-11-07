StaticSound = {}

function StaticSound.new(filename, x, y, z, ref, max)
	local self = setmetatable({}, StaticSound)

	self.position = {x = x, y = y, z = z}
	self.source = love.audio.newSource(filename, "static")
	self.source:setPosition(x, y, z)
	self.source:setAttenuationDistances(ref, max)
	self.source:setLooping(true)
	self.source:play()

	return self
end

setmetatable(StaticSound, { __call = function(_, ...) return StaticSound.new(...) end })

gameState = {
	playerPosition = {x = 0, y = 0, z = 0},
	playerAngular = {x = 0, y = 0, z = 0}, -- angle
	footstepSound = nil,

	sounds = {}
}

function gameState:load()
	table.insert(self.sounds, StaticSound("water_fall.wav", 40, 0, 0, 10, 10))
	table.insert(self.sounds, StaticSound("engine.wav", 80, 0, 20, 5, 10))
	table.insert(self.sounds, StaticSound("siren.wav", 0, 0, 50, 5, 10))
	table.insert(self.sounds, StaticSound("water_fall.wav", 90, 0, 100, 10, 10))

	self.footstepSound = StaticSound("footsteps_wood.wav", 0, 0, 0, 0, 0)
	self.footstepSound.source:setVolume(0)
end

function gameState:update(dt)
	local playerOrientation = {x = math.cos(self.playerAngular.y), y = 0, z = math.sin(self.playerAngular.y)}
	local playerSideVector = {x = playerOrientation.z, y = 0, z = -playerOrientation.x}

	local footstepVolume = 0
	if love.keyboard.isDown("z") then
	   	self.playerPosition.x = self.playerPosition.x + playerOrientation.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z + playerOrientation.z * 8.0 * dt 	
   		footstepVolume = 1
	elseif love.keyboard.isDown("s") then
	   	self.playerPosition.x = self.playerPosition.x - playerOrientation.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z - playerOrientation.z * 8.0 * dt 			
   		footstepVolume = 1
	end

	if love.keyboard.isDown("q") then
	   	self.playerPosition.x = self.playerPosition.x + playerSideVector.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z + playerSideVector.z * 8.0 * dt 	
  		footstepVolume = 1
	elseif love.keyboard.isDown("d") then
	   	self.playerPosition.x = self.playerPosition.x - playerSideVector.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z - playerSideVector.z * 8.0 * dt 			
  		footstepVolume = 1
	end

	self.footstepSound.source:setVolume(footstepVolume)


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

	for k, v in pairs(self.sounds) do
		love.graphics.point(v.position.x, v.position.z)
	end

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