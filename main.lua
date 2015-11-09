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
	playerPosition = {x = 15, y = 0, z = 15},
	playerAngular = {x = 0, y = 0, z = 0}, -- angle
	footstepSound = nil,

	sounds = {}
}

showDebugMap = false

mouseSensibility = 0.005
indicatorVisibleTime = 0.1
indicatorFadeTime = 0.1

wallInvVisibility = 22

playerRadius = 1

gameState.level = {
	data = {
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 0, 2, 2, 2, 2, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 0, 0, 1, 0, 2, 2, 2, 2, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
		},
		width = 20,
		height = 20
}

function gameState:load()
	table.insert(self.sounds, StaticSound("water_fall.wav", 40, 0, 0, 5, 10))
	--table.insert(self.sounds, StaticSound("engine.wav", 80, 0, 20, 5, 10))
	--table.insert(self.sounds, StaticSound("siren.wav", 0, 0, 50, 5, 10))
	--table.insert(self.sounds, StaticSound("water_fall.wav", 90, 0, 100, 5, 10))
	--table.insert(self.sounds, StaticSound("monster.wav", 90, 0, 190, 15, 0))
	table.insert(self.sounds, StaticSound("fireplace.wav", 110, 0, 60, 5, 0))
	table.insert(self.sounds, StaticSound("door.wav", 50, 0, 10, 2, 0))

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
	local ptx = math.floor(self.playerPosition.x / wallLength)
	local pty = math.floor(self.playerPosition.z / wallLength)

	local playerDisplacement = {x = 0; y = 0, z = 0}
	if love.keyboard.isDown("z") then
	   	playerDisplacement.x = playerForward.x * 8.0 * dt
   		playerDisplacement.z = playerForward.z * 8.0 * dt 	
   		footstepVolume = 1
	elseif love.keyboard.isDown("s") then
	   	playerDisplacement.x = -playerForward.x * 8.0 * dt
   		playerDisplacement.z = -playerForward.z * 8.0 * dt 			
   		footstepVolume = 1
	end

	if love.keyboard.isDown("q") then
	   	playerDisplacement.x = playerDisplacement.x + playerSideVector.x * 8.0 * dt
   		playerDisplacement.z = playerDisplacement.z + playerSideVector.z * 8.0 * dt 	
  		footstepVolume = 1
	elseif love.keyboard.isDown("d") then
	   	playerDisplacement.x = playerDisplacement.x - playerSideVector.x * 8.0 * dt
   		playerDisplacement.z = playerDisplacement.z - playerSideVector.z * 8.0 * dt 			
  		footstepVolume = 1
	end

	-- clamp displacement
	if playerDisplacement.x < 0 and self.level.data[(ptx - 1 + pty * self.level.width) + 1] ~= 0 then
		playerDisplacement.x = math.max(playerDisplacement.x, ptx * wallLength - self.playerPosition.x + playerRadius)
	end

	if playerDisplacement.x > 0 and self.level.data[(ptx + 1 + pty * self.level.width) + 1] ~= 0 then
		playerDisplacement.x = math.min(playerDisplacement.x, (ptx + 1) * wallLength - self.playerPosition.x - playerRadius)
	end

	if playerDisplacement.z < 0 and self.level.data[(ptx + (pty - 1) * self.level.width) + 1] ~= 0 then
		playerDisplacement.z = math.max(playerDisplacement.z, pty * wallLength - self.playerPosition.z + playerRadius)
	end

	if playerDisplacement.z > 0 and self.level.data[(ptx + (pty + 1) * self.level.width) + 1] ~= 0 then
		playerDisplacement.z = math.min(playerDisplacement.z, (pty + 1) * wallLength - self.playerPosition.z - playerRadius)
	end


	-- update position
	self.playerPosition.x = self.playerPosition.x + playerDisplacement.x
	self.playerPosition.z = self.playerPosition.z + playerDisplacement.z

	-- update foot steps volume
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

function gameState:drawWall(x1, z1, x2, z2, min, max)
	--local winW, winH = love.window.getDimensions()
	local winW, winH = love.graphics.getCanvas():getDimensions()


	local p1 = self:transformPoint({x = x1, y = 0, z = z1})
	local p2 = self:transformPoint({x = x2, y = 0, z = z2})

	-- clamped point
	local _p1 = p1
	local _p2 = p2

	if p1.z < 0 and p2.z < 0 then
		_p1 = p1
		_p2 = p2

		--love.graphics.setColor(255, 255, 255, 255)
	end

	if p1.z < 0 and p2.z > 0 then
		local l =  (-p1.z * 0.999) / (-p1.z + p2.z)
		local clampedPoint = {}
		clampedPoint.x = l * (p2.x - p1.x) + p1.x
		clampedPoint.z = l * (p2.z - p1.z) + p1.z

		_p1 = p1
		_p2 = clampedPoint

	--love.graphics.setColor(255, 0, 0, 255)
	end

	if p1.z > 0 and p2.z < 0 then
		local l =  (-p2.z * 0.999) / (-p2.z + p1.z)
		local clampedPoint = {}

		clampedPoint.x = l * (p1.x - p2.x) + p2.x
		clampedPoint.z = l * (p1.z - p2.z) + p2.z

		_p1 = clampedPoint
		_p2 = p2

		--love.graphics.setColor(0, 0, 255, 255)
	end

	-- draw if visible
	if not (p1.z >= 0 and p2.z >= 0) then
		-- project points
		local A = projectPoint({x = _p1.x, y = min, z = _p1.z}, winW / 2)
		local B = projectPoint({x = _p1.x, y = max, z = _p1.z}, winW / 2)
		local C = projectPoint({x = _p2.x, y = min, z = _p2.z}, winW / 2)
		local D = projectPoint({x = _p2.x, y = max, z = _p2.z}, winW / 2)

		--love.graphics.polygon('line', A.x, A.y, C.x, C.y, D.x, D.y, B.x, B.y)

		local mesh = love.graphics.newMesh({ { A.x, A.y, 0, 0, 255, 255, 255, math.max(255 - A.z * wallInvVisibility, 0)},
											 { C.x, C.y, 1, 0, 255, 255, 255, math.max(255 - C.z * wallInvVisibility, 0)},
											 { D.x, D.y, 1, 1, 255, 255, 255, math.max(255 - D.z * wallInvVisibility, 0)},
											 { B.x, B.y, 0, 1, 255, 255, 255, math.max(255 - B.z * wallInvVisibility, 0)}}, nil)
		love.graphics.draw(mesh)
	end
end

wallLength = 10
function gameState:drawBlock(x, y)
	-- max 4 wall to draw
	--[[
	*----- 3 -----*
	|             |
	|             |
	1             2
	|             |
	|             |
	*----- 4 -----*
	]]

	-- nothing to draw
	if self.level.data[(x + y * self.level.width) + 1] == 0 then
		return
	end

	local min = -5
	local max = 5

	if self.level.data[(x + y * self.level.width) + 1] == 2 then
		min = 0
	end

	-- else block == 1
	if x > 0 and self.level.data[(x - 1 + y * self.level.width) + 1] == 0 and self.playerPosition.x <= x * wallLength then
		self:drawWall(x * wallLength, y * wallLength, x * wallLength, (y + 1) * wallLength, min, max)
	end

	if x < self.level.width - 1 and self.level.data[(x + 1 + y * self.level.width) + 1] == 0 and self.playerPosition.x >= (x + 1) * wallLength then
		self:drawWall((x + 1) * wallLength, y * wallLength, (x + 1) * wallLength, (y + 1) * wallLength, min, max)
	end

	if y > 0 and self.level.data[(x + (y - 1) * self.level.width) + 1] == 0 and self.playerPosition.z <= y * wallLength then
		self:drawWall(x * wallLength, y * wallLength, (x + 1) * wallLength, y * wallLength, min, max)
	end

	if y < self.level.height - 1 and self.level.data[(x + (y + 1) * self.level.width) + 1] == 0 and self.playerPosition.z >= (y + 1) * wallLength then
		self:drawWall(x * wallLength, (y + 1) * wallLength, (x + 1) * wallLength, (y + 1) * wallLength, min, max)
	end


end

function gameState:draw()
	love.graphics.setColor(255, 255, 255, 255)
	--local winW, winH = love.window.getDimensions()
	local winW, winH = love.graphics.getCanvas():getDimensions()

	-- map debug draw
	if showDebugMap then
		love.graphics.push()
		love.graphics.translate(winW - 128, winH - 128)

		-- player
		local playerPos = self:transformPoint(self.playerPosition)
		love.graphics.point(playerPos.x, playerPos.z)
		love.graphics.line(playerPos.x, playerPos.z, playerPos.x, playerPos.z - 15)

		love.graphics.push()
		love.graphics.rotate(-self.playerAngular.y)
		love.graphics.translate(-self.playerPosition.x, -self.playerPosition.z)

		-- map
		for y = 0, self.level.height - 1 do
			for x = 0, self.level.width - 1 do
				if self.level.data[x + y * self.level.width + 1] == 1 then
					love.graphics.polygon("fill", x * wallLength, y * wallLength, (x+1) * wallLength, y * wallLength, (x+1) * wallLength, (y+1) * wallLength, x * wallLength, (y+1) * wallLength)
				end
			end
		end

		-- objects
		love.graphics.setColor(255, 0, 0, 255)
		for k, v in pairs(self.sounds) do
			love.graphics.point(v.position.x + 0.5, v.position.z + 0.5)
		end


		love.graphics.pop()


		love.graphics.pop()
	end

	-- draw walls
	love.graphics.push()
	love.graphics.translate(winW / 2, winH / 2)

	for y = 0, self.level.height - 1 do
		for x = 0, self.level.width - 1 do
			self:drawBlock(x, y)
		end
	end
	love.graphics.pop()


	-- draw rotation indicator
	local indicatorAlpha = 255
	if self.indicatorTimer > indicatorVisibleTime then
		indicatorAlpha = 255 * math.max(1 - (self.indicatorTimer - indicatorVisibleTime) / indicatorFadeTime, 0)
	end

	love.graphics.setColor(255, 255, 255, indicatorAlpha)
	love.graphics.draw(self.indicator, 96 / 4, winH - 96 / 4, self.indicatorRotation, 0.25, 0.25, 64, 64)

end

-- Love callback
local mainCanvas

function love.load()
	love.window.setMode(1920, 1080, {fullscreen=true})

	love.mouse.setGrabbed(true)
	love.mouse.setRelativeMode(true)

	love.audio.setDistanceModel("exponent")

	mainCanvas = love.graphics.newCanvas(1920 / 4, 1080 / 4)

	gameState:load()
end

function love.update(dt)
	gameState:update(dt)
end

function love.draw()
	love.graphics.setCanvas(mainCanvas)
	mainCanvas:clear()

    gameState:draw()

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setCanvas()
	love.graphics.draw(mainCanvas, 0, 0, 0, 4, 4)
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