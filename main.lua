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

mouseSensibility = 0.01
indicatorVisibleTime = 0.1
indicatorFadeTime = 0.1

function gameState:load()
	table.insert(self.sounds, StaticSound("water_fall.wav", 40, 0, 0, 10, 10))
	table.insert(self.sounds, StaticSound("engine.wav", 80, 0, 20, 5, 10))
	table.insert(self.sounds, StaticSound("siren.wav", 0, 0, 50, 5, 10))
	table.insert(self.sounds, StaticSound("water_fall.wav", 90, 0, 100, 10, 10))

	self.footstepSound = StaticSound("footsteps_wood.wav", 0, 0, 0, 0, 0)
	self.footstepSound.source:setVolume(0)

	self.indicator = love.graphics.newImage("indicator.png")
	self.indicatorRotation = 0
	self.indicatorTimer = 0
end

function gameState:update(dt)
	local playerForward = {x = math.sin(self.playerAngular.y), y = 0, z = -math.cos(self.playerAngular.y)}
	local playerSideVector = {x = playerForward.z, y = 0, z = -playerForward.x}

	local footstepVolume = 0
	if love.keyboard.isDown("z") then
	   	self.playerPosition.x = self.playerPosition.x + playerForward.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z + playerForward.z * 8.0 * dt 	
   		footstepVolume = 1
	elseif love.keyboard.isDown("s") then
	   	self.playerPosition.x = self.playerPosition.x - playerForward.x * 8.0 * dt
   		self.playerPosition.z = self.playerPosition.z - playerForward.z * 8.0 * dt 			
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

	-- update audio listener position
	love.audio.setPosition(self.playerPosition.x, self.playerPosition.y, self.playerPosition.z)
	love.audio.setOrientation(playerForward.x, playerForward.y, playerForward.z, 0, 1, 0)

	-- update indicator timer
	self.indicatorTimer = self.indicatorTimer + dt
end

function gameState:mousemoved(x, y, dx, dy)
	--print(x, y, dx, dy)

	self.playerAngular.y = self.playerAngular.y + dx * mouseSensibility

	if self.playerAngular.y > math.pi then
		self.playerAngular.y = self.playerAngular.y - 2 * math.pi
	end

	if self.playerAngular.y < -math.pi then
		self.playerAngular.y = self.playerAngular.y + 2 * math.pi
	end

	if self.indicatorTimer < indicatorVisibleTime + indicatorFadeTime then
		self.indicatorRotation = self.indicatorRotation + dx * mouseSensibility
		self.indicatorTimer = 0
	else 
		self.indicatorRotation = dx * mouseSensibility
		self.indicatorTimer = 0		
	end

	--print(dx, self.playerAngular.y)
end

function gameState:projectPoint(p)
	local tx = p.x - self.playerPosition.x
	local ty = p.y - self.playerPosition.y
	local tz = p.z - self.playerPosition.z

	-- rotate on y
	rx = {x = math.cos(-self.playerAngular.y), y = 0, z = math.sin(-self.playerAngular.y)}
	rz = {x = -math.sin(-self.playerAngular.y), y = 0, z = math.cos(-self.playerAngular.y)}

	local x = rx.x * tx + rz.x * tz
	local y = ty
	local z = rx.z * tx + rz.z * tz

	return x, y, z
end

function gameState:draw()
	love.graphics.setColor(255, 255, 255, 255)

	-- debug draw
	if true then
		love.graphics.push()
		love.graphics.translate(256, 256)

		local px, py, pz = self:projectPoint(self.playerPosition)
		love.graphics.point(px, pz)
		love.graphics.line(px, pz, px, pz - 15)

		for k, v in pairs(self.sounds) do
			x, y, z = self:projectPoint(v.position)
			love.graphics.point(x, z)
		end
		love.graphics.pop()
	end

	-- draw rotation indicator
	local indicatorAlpha = 255
	if self.indicatorTimer > indicatorVisibleTime then
		indicatorAlpha = 255 * math.max(1 - (self.indicatorTimer - indicatorVisibleTime) / indicatorFadeTime, 0)
	end

	love.graphics.setColor(255, 255, 255, indicatorAlpha)
	winW, winH = love.window.getDimensions()
	love.graphics.draw(self.indicator, 96, winH - 96, self.indicatorRotation, 1, 1, 64, 64)

end

-- Love callback
function love.load()
	love.window.setMode(1920, 1080, {fullscreen=true})

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