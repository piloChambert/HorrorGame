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

mouseSensibility = 0.005
indicatorVisibleTime = 0.1
indicatorFadeTime = 0.1

levelWalls = {  {x = -50, y = 0, z = -50},
			 	{x = -40, y = 0, z = -50},
			 	{x = -30, y = 0, z = -50},
			 	{x = -20, y = 0, z = -50},
			 	{x = -10, y = 0, z = -50},
			 	{x = 0, y = 0, z = -50},
			 	{x = 10, y = 0, z = -50},
			 	{x = 20, y = 0, z = -50},
			 	{x = 30, y = 0, z = -50},
			 	{x = 40, y = 0, z = -50},
			 	{x = 50, y = 0, z = -50},
			 	{x = 50, y = 0, z = 50},
			 	{x = -50, y = 0, z = 50},
			 	{x = -50, y = 0, z = -50}
			 }

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

-- transform a point in eye space
function gameState:transformPoint(p)
	local tx = p.x - self.playerPosition.x
	local ty = p.y - self.playerPosition.y
	local tz = p.z - self.playerPosition.z

	-- rotate on y
	rx = {x = math.cos(-self.playerAngular.y), y = 0, z = math.sin(-self.playerAngular.y)}
	rz = {x = -math.sin(-self.playerAngular.y), y = 0, z = math.cos(-self.playerAngular.y)}

	local x = rx.x * tx + rz.x * tz
	local y = ty
	local z = rx.z * tx + rz.z * tz

	return {x = x, y = y, z = z}
end

function projectPoint(p, zoom)
	local projectedPoint = {}

	projectedPoint.x = p.x / -p.z * zoom
	projectedPoint.y = p.y / -p.z * zoom	
	projectedPoint.z = -p.z -- distance to camera

	return projectedPoint
end

function gameState:draw()
	love.graphics.setColor(255, 255, 255, 255)
	local winW, winH = love.window.getDimensions()

	-- map debug draw
	if true then
		love.graphics.push()
		love.graphics.translate(winW / 2, winH / 2)

		-- player
		local playerPos = self:transformPoint(self.playerPosition)
		love.graphics.point(playerPos.x, playerPos.z)
		love.graphics.line(playerPos.x, playerPos.z, playerPos.x, playerPos.z - 15)

		-- objects
		for k, v in pairs(self.sounds) do
			local p = self:transformPoint(v.position)
			love.graphics.point(p.x, p.z)
		end

		-- walls
		local prevPoint = nil
		for k, v in pairs(levelWalls) do
			local p = self:transformPoint(v)

			if not (prevPoint == nil) then
				love.graphics.line(prevPoint.x, prevPoint.z, p.x, p.z)
			end

			prevPoint = p
		end


		love.graphics.pop()
	end

	-- draw walls
	love.graphics.push()
	love.graphics.translate(winW / 2, winH / 2)

	local prevPoint = nil
	for k, v in pairs(levelWalls) do
		-- y = 0, because it's just 2D point on x/z plane
		local currentPoint = self:transformPoint(v)

		local p1 = nil
		local p2 = nil

		--love.graphics.line(x, y1, x, y2)
		if not (prevPoint == nil)  then
			if currentPoint.z < 0 and prevPoint.z < 0 then
				p1 = currentPoint
				p2 = prevPoint

				--love.graphics.setColor(255, 255, 255, 255)
			end

			if currentPoint.z < 0 and prevPoint.z > 0 then
				local l =  (-currentPoint.z * 0.999) / (-currentPoint.z + prevPoint.z)
				local clampedPoint = {}
				clampedPoint.x = l * (prevPoint.x - currentPoint.x) + currentPoint.x
				clampedPoint.z = l * (prevPoint.z - currentPoint.z) + currentPoint.z

				p1 = currentPoint
				p2 = clampedPoint

				--love.graphics.setColor(255, 0, 0, 255)
			end

			if currentPoint.z > 0 and prevPoint.z < 0 then
				local l =  (-prevPoint.z * 0.999) / (-prevPoint.z + currentPoint.z)
				local clampedPoint = {}

				clampedPoint.x = l * (currentPoint.x - prevPoint.x) + prevPoint.x
				clampedPoint.z = l * (currentPoint.z - prevPoint.z) + prevPoint.z

				p1 = clampedPoint
				p2 = prevPoint

				--love.graphics.setColor(0, 0, 255, 255)
			end

			-- draw if visible
			if not (currentPoint.z >= 0 and prevPoint.z >= 0) then
				-- project points
				local A = projectPoint({x = p1.x, y = -5, z = p1.z}, winW / 2)
				local B = projectPoint({x = p1.x, y = 5, z = p1.z}, winW / 2)
				local C = projectPoint({x = p2.x, y = -5, z = p2.z}, winW / 2)
				local D = projectPoint({x = p2.x, y = 5, z = p2.z}, winW / 2)

				--love.graphics.polygon('line', A.x, A.y, C.x, C.y, D.x, D.y, B.x, B.y)

				local wallInvVisibility = 26
				local mesh = love.graphics.newMesh({ { A.x, A.y, 0, 0, 255, 255, 255, math.max(255 - A.z * wallInvVisibility, 0)},
													 { C.x, C.y, 1, 0, 255, 255, 255, math.max(255 - C.z * wallInvVisibility, 0)},
													 { D.x, D.y, 1, 1, 255, 255, 255, math.max(255 - D.z * wallInvVisibility, 0)},
													 { B.x, B.y, 0, 1, 255, 255, 255, math.max(255 - B.z * wallInvVisibility, 0)}}, nil)
				love.graphics.draw(mesh)
			end
		end
		--end

		prevPoint = currentPoint
	end
	love.graphics.pop()


	-- draw rotation indicator
	local indicatorAlpha = 255
	if self.indicatorTimer > indicatorVisibleTime then
		indicatorAlpha = 255 * math.max(1 - (self.indicatorTimer - indicatorVisibleTime) / indicatorFadeTime, 0)
	end

	love.graphics.setColor(255, 255, 255, indicatorAlpha)
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