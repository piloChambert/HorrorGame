StaticSound = {}
StaticSound.__index = StaticSound
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

monsterAppearTime = 5
monsterAttackTime = 5
monsterMinIdle = 20
monsterMaxIdle = 45

Monster = {}
Monster.__index = Monster
function Monster.new()
	local self = setmetatable({}, Monster)

	self.timer = 0
	self.sound = love.audio.newSource("monster.mp3", "static")
	self.sound:setAttenuationDistances(3, 0)

	self.attackSound = love.audio.newSource("attack.mp3", "static")
	self.attackSound:setAttenuationDistances(3, 0)


	self.state = 0 -- hidden state
	self.hiddentTime = love.math.random(monsterMinIdle, monsterMaxIdle) -- generate a new wait time
	self.position = {x = 0, y = 0, z = 0}

	return self
end

function Monster:update(dt, gameState)
	self.timer = self.timer + dt

	if self.state == 0 then
		if self.timer > self.hiddentTime then
			--print("monster appear")
			self.state = 1 --appear state
			self.timer = 0

			-- next to the player!
			self.position.x = gameState.playerPosition.x
			self.position.z = gameState.playerPosition.z
			self.sound:setPosition(self.position.x, self.position.y, self.position.z)

			-- appearing, play the sound
			self.sound:play()
		end
	elseif self.state == 1 then
		if self.timer > monsterAppearTime then
			--print("monster attack")

			self.timer = 0
			self.state = 2 -- attack!
		end

	elseif self.state == 2 then
		-- move to the player
		local dx = gameState.playerPosition.x - self.position.x
		local dz = gameState.playerPosition.z - self.position.z
		local len = math.sqrt(dx * dx + dz * dz)

		dx = dx / len
		dz = dz / len

		self.position.x = self.position.x + dx * math.min(12.0 * dt, len)
		self.position.z = self.position.z + dz * math.min(12.0 * dt, len)

		-- if close enough, attack
		if len < 2 then
			-- play attack sound
			self.attackSound:play()
			self.sound:stop()

			-- switch to attack state
			self.timer = 0
			self.state = 3

			-- decrease healt
			gameState.health = gameState.health - 1	
		end

		if self.timer > monsterAttackTime then
			-- disappear
			self.timer = 0
			self.state = 0
			self.hiddentTime = love.math.random(monsterMinIdle, monsterMaxIdle) -- generate a new wait time
			self.sound:stop()
		end
	elseif self.state == 3 then -- Attacking
		-- stick to the player
		self.position.x = gameState.playerPosition.x
		self.position.z = gameState.playerPosition.z

		if self.timer > 3 then
			self.timer = 0
			self.state = 0
			self.hiddentTime = love.math.random(monsterMinIdle, monsterMaxIdle) -- generate a new wait time
			self.sound:stop()			
			self.attackSound:stop()
		end
	end

	self.sound:setPosition(self.position.x, self.position.y, self.position.z)
end

setmetatable(Monster, { __call = function(_, ...) return Monster.new(...) end })

showDebugMap = false

mouseSensibility = 0.005
indicatorVisibleTime = 0.1
indicatorFadeTime = 0.1

wallInvVisibilityIdle = 20
wallInvVisibilityWalk = 24
wallInvVisibilityRun = 48
wallInvVisibilityChangeRateUp = 16 -- per seconds
wallInvVisibilityChangeRateDown = 16 -- per seconds
wallInvVisibility = 12

wallWireframe = false

playerRadius = 1

gameState = State()
function gameState:load()
	self.playerPosition = {x = 15, y = 0, z = 15}
	self.playerAngular = {x = 0, y = 0, z = 0} -- angle

	self.sounds = {}


	table.insert(self.sounds, StaticSound("engine.wav", 155, 0, 120, 5, 10))
	table.insert(self.sounds, StaticSound("water_fall.wav", 90, 0, 100, 5, 10))
	--table.insert(self.sounds, StaticSound("monster.wav", 90, 0, 190, 15, 0))

	table.insert(self.sounds, StaticSound("water_fall.wav", 40, 0, 0, 5, 10))
	table.insert(self.sounds, StaticSound("fireplace.wav", 110, 0, 60, 5, 0))
	table.insert(self.sounds, StaticSound("door.wav", 50, 0, 10, 2, 0))
	table.insert(self.sounds, StaticSound("siren.wav", 185, 0, 115, 5, 10))

	self.footstepSound = StaticSound("footsteps_wood.wav", 0, 0, 0, 0, 0)
	self.footstepSound.source:setVolume(0)

	self.footstepRunSound = StaticSound("footsteps_run_wood.wav", 0, 0, 0, 0, 0)
	self.footstepRunSound.source:setVolume(0)


	self.indicator = love.graphics.newImage("indicator.png")
	self.indicatorRotation = 0
	self.indicatorTimer = 0

	love.mouse.setGrabbed(true)
	love.mouse.setRelativeMode(true)

	self.monster = Monster()

	self.health = 5

	self.level = {
		data = {
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 0, 2, 2, 2, 2, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1,
			1, 1, 0, 0, 1, 0, 2, 2, 2, 2, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1,
			1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1,
			1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1,
			1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1,
			1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1,
			1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
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
end

function gameState:unload()
	-- stop every sound
	self.footstepSound.source:stop()
	self.footstepRunSound.source:stop()

	for k, v in pairs(self.sounds) do
		v.source:stop()
	end

	self.monster.sound:stop()

	love.mouse.setGrabbed(false)
	love.mouse.setRelativeMode(false)
end

function gameState:update(dt)
	-- update monster
	self.monster:update(dt, self)

	-- the end?
	if self.health == 0 then
		changeState(gameoverState)
	end

	local ptx = math.floor(self.playerPosition.x / wallLength)
	local pty = math.floor(self.playerPosition.z / wallLength)

	if ptx == 18 and pty == 11 then
		changeState(endState)
	end

	local playerForward = {x = math.sin(self.playerAngular.y), y = 0, z = -math.cos(self.playerAngular.y)}
	local playerSideVector = {x = playerForward.z, y = 0, z = -playerForward.x}

	local footstepVolume = 0
	local playerDisplacement = {x = 0; y = 0, z = 0}

	local fwdKey = "w"
	local backKey = "s"
	local leftKey = "a"
	local rightKey = "d"
	if azerty then 
		fwdKey = "z" 
		leftKey = "q"
	end

	local isMoving = false
	local isRunning = false
	local playerSpeed = 8.0

	-- is player running?
	if love.keyboard.isDown("lshift") then
		isRunning = true
		playerSpeed = 14.0
	end

	if love.keyboard.isDown(fwdKey) then
	   	playerDisplacement.x = playerForward.x * playerSpeed * dt
   		playerDisplacement.z = playerForward.z * playerSpeed * dt 	
   		isMoving = true
	elseif love.keyboard.isDown(backKey) then
	   	playerDisplacement.x = -playerForward.x * playerSpeed * dt
   		playerDisplacement.z = -playerForward.z * playerSpeed * dt 			
   		isMoving = true
	end

	if love.keyboard.isDown(leftKey) then
	   	playerDisplacement.x = playerDisplacement.x + playerSideVector.x * playerSpeed * dt
   		playerDisplacement.z = playerDisplacement.z + playerSideVector.z * playerSpeed * dt 	
  		isMoving = true
	elseif love.keyboard.isDown(rightKey) then
	   	playerDisplacement.x = playerDisplacement.x - playerSideVector.x * playerSpeed * dt
   		playerDisplacement.z = playerDisplacement.z - playerSideVector.z * playerSpeed * dt 			
  		isMoving = true
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
	local targetVisibility = wallInvVisibilityIdle
	if isMoving then
		if isRunning then
			self.footstepSound.source:setVolume(0)
			self.footstepRunSound.source:setVolume(1)
			targetVisibility = wallInvVisibilityRun
		else
			self.footstepSound.source:setVolume(1)
			self.footstepRunSound.source:setVolume(0)
			targetVisibility = wallInvVisibilityWalk
		end
	else
		-- idle
		-- no footstep sound
		self.footstepSound.source:setVolume(0)
		self.footstepRunSound.source:setVolume(0)
		targetVisibility = wallInvVisibilityIdle
	end

	-- update audio listener position
	love.audio.setPosition(self.playerPosition.x, self.playerPosition.y, self.playerPosition.z)
	love.audio.setOrientation(playerForward.x, playerForward.y, playerForward.z, 0, 1, 0)

	-- update visibility
	local change = math.max(math.min(targetVisibility - wallInvVisibility, wallInvVisibilityChangeRateDown * dt), -wallInvVisibilityChangeRateUp * dt)
	wallInvVisibility = wallInvVisibility + change
	
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

function gameState:keypressed(key)
	if key == "escape" then
		changeState(titleState)
	end
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

		if wallWireframe then
			love.graphics.polygon('line', A.x, A.y, C.x, C.y, D.x, D.y, B.x, B.y)
		end

		local Ai = math.max(255 - A.z * wallInvVisibility, 0)
		local Bi = math.max(255 - B.z * wallInvVisibility, 0)
		local Ci = math.max(255 - C.z * wallInvVisibility, 0)
		local Di = math.max(255 - D.z * wallInvVisibility, 0)

		local mesh = love.graphics.newMesh({ { A.x, A.y, 0, 0, Ai, Ai, Ai, 255},
											 { C.x, C.y, 1, 0, Ci, Ci, Ci, 255},
											 { D.x, D.y, 1, 1, Di, Di, Di, 255},
											 { B.x, B.y, 0, 1, Bi, Bi, Bi, 255}}, nil)
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

function gameState.drawFloor()
	local winW, winH = love.graphics.getCanvas():getDimensions()

	local floorIntensity = 64

	local z0 = 255 / wallInvVisibility
	local yFloor0 = 5 / z0 * winW / 2
	local yCeil0 = -5 / z0 * winW / 2

	local mesh = love.graphics.newMesh({ 
		-- floor
		{ -winW / 2, yFloor0, 0, 0, 0, 0, 0, 255},
		{ winW / 2, yFloor0, 1, 0, 0, 0, 0, 255},
		{ winW / 2, winH / 2, 1, 1, floorIntensity, floorIntensity, floorIntensity, 255},

		{ -winW / 2, yFloor0, 0, 0, 0, 0, 0, 255},
		{ winW / 2, winH / 2, 1, 1, floorIntensity, floorIntensity, floorIntensity, 255},		
		{ -winW / 2, winH / 2, 0, 1, floorIntensity, floorIntensity, floorIntensity, 255},

		-- roof
		{ -winW / 2, -winH / 2, 0, 0, floorIntensity, floorIntensity, floorIntensity, 255},
		{ winW / 2, -winH / 2, 1, 0, floorIntensity, floorIntensity, floorIntensity, 255},
		{ winW / 2, yCeil0, 1, 1, 0, 0, 0, 255},

		{ -winW / 2, -winH / 2, 0, 0, floorIntensity, floorIntensity, floorIntensity, 255},
		{ winW / 2, yCeil0, 1, 1, 0, 0, 0, 255},		
		{ -winW / 2, yCeil0, 0, 1, 0, 0, 0, 255}
		}, nil, "triangles")
	love.graphics.draw(mesh)
end

function gameState:draw()
	love.graphics.setColor(255, 255, 255, 255)
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
		love.graphics.setColor(0, 255, 0, 255)
		for k, v in pairs(self.sounds) do
			love.graphics.point(v.position.x + 0.5, v.position.z + 0.5)
		end

		-- monster
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.point(self.monster.position.x + 0.5, self.monster.position.z + 0.5)

		love.graphics.pop()

		love.graphics.pop()
	end

	-- draw walls
	love.graphics.push()
	love.graphics.translate(winW / 2, winH / 2)

	-- draw floor
	self:drawFloor()

	-- drawing order
	local yStart = 0
	local yEnd = self.level.height - 1
	local yInc = 1

	local xStart = 0
	local xEnd = self.level.width - 1
	local xInc = 1

	local drawRow = true

	if self.playerAngular.y > 0 then
		xStart = xEnd
		xEnd = 0
		xInc = -1
	end

	if self.playerAngular.y < math.pi * -0.5 or self.playerAngular.y > math.pi * 0.5 then
		yStart = yEnd
		yEnd = 0
		yInc = -1
	end

	-- row of column or column of row?
	if (self.playerAngular.y > 0.25 * math.pi and self.playerAngular.y < 0.75 * math.pi) or (self.playerAngular.y < -0.25 * math.pi and self.playerAngular.y > -0.75 * math.pi) then
		drawRow = false
	end
	if drawRow then
		for y = yStart, yEnd, yInc do
			for x = xStart, xEnd, xInc do
				self:drawBlock(x, y)
			end
		end
	else -- draw columen
		for x = xStart, xEnd, xInc do			
			for y = yStart, yEnd, yInc do
				self:drawBlock(x, y)
			end
		end
	end		
	love.graphics.pop()

	love.graphics.print(wallInvVisibility, 0, 0)

	-- draw rotation indicator
	local indicatorAlpha = 255
	if self.indicatorTimer > indicatorVisibleTime then
		indicatorAlpha = 255 * math.max(1 - (self.indicatorTimer - indicatorVisibleTime) / indicatorFadeTime, 0)
	end

	love.graphics.setColor(255, 255, 255, indicatorAlpha)
	love.graphics.draw(self.indicator, 96 / screenScale, winH - 96 / screenScale, self.indicatorRotation, 1 / screenScale , 1 / screenScale, 64, 64)
end