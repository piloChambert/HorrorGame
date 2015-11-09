require "gameState"

screenScale = 3


function testPointInQuad(x, y, qx, qy, qw, qh)
	if x >= qx and x < qx + qw and y >= qy and y < qy + qh then
		return true
	end

	-- else
	return false
end

titleState = {}
function titleState:load()
	self.backgroundImage = love.graphics.newImage("titleBackground.png")

	self.startOnImage = love.graphics.newImage("startOn.png")
	self.startOffImage = love.graphics.newImage("startOff.png")
	self.startButtonPosition = { x = 131, y = 130 }
end

function titleState:unload()
end

function titleState:update(dt)
end

function titleState:draw()
	-- draw background
	love.graphics.draw(self.backgroundImage, 0, 0)

	-- draw start
	local startImg = self.startOffImage
	local mx, my = love.mouse.getPosition()

	mx = mx / screenScale
	my = my / screenScale

	local w, h = self.startOnImage:getDimensions()
	if testPointInQuad(mx, my, self.startButtonPosition.x, self.startButtonPosition.y, 58, 20) then
		startImg = self.startOnImage
	end

	love.graphics.draw(startImg, self.startButtonPosition.x, self.startButtonPosition.y)

end

function titleState:mousemoved(x, y, dx, dy)

end

function titleState:mousepressed(x, y, button)
	if button == "l" and testPointInQuad(x, y, self.startButtonPosition.x, self.startButtonPosition.y, 58, 20) then
		changeState(introState)
	end
end

function titleState:keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

introState = {}
function introState:load()
	self.backgroundImage = love.graphics.newImage("intro.png")
end

function introState:unload()
end

function introState:update(dt)
end

function introState:draw()
	-- draw background
	love.graphics.draw(self.backgroundImage, 0, 0)
end

function introState:mousemoved(x, y, dx, dy)

end

function introState:mousepressed(x, y, button)
	if button == "l" then
		changeState(gameState)
	end
end

function introState:keypressed(key)
end

gameoverState = {}
function gameoverState:load()
	self.backgroundImage = love.graphics.newImage("gameover.png")
end

function gameoverState:unload()
end

function gameoverState:update(dt)
end

function gameoverState:draw()
	-- draw background
	love.graphics.draw(self.backgroundImage, 0, 0)
end

function gameoverState:mousemoved(x, y, dx, dy)

end

function gameoverState:mousepressed(x, y, button)
	if button == "l" then
		changeState(titleState)
	end
end

function gameoverState:keypressed(key)
end

endState = {}
function endState:load()
	self.backgroundImage = love.graphics.newImage("endscreen.png")
end

function endState:unload()
end

function endState:update(dt)
end

function endState:draw()
	-- draw background
	love.graphics.draw(self.backgroundImage, 0, 0)
end

function endState:mousemoved(x, y, dx, dy)

end

function endState:mousepressed(x, y, button)
	if button == "l" then
		changeState(titleState)
	end
end

function endState:keypressed(key)
end


-- Love callback
local mainCanvas
currentState = nil

function changeState(newState)
	if currentState ~= nil then
		currentState:unload()
	end

	currentState = newState
	currentState:load()
end

function love.load()
	love.window.setMode(320 * screenScale, 180 * screenScale, {fullscreen=false})

	--love.mouse.setGrabbed(true)
	--love.mouse.setRelativeMode(true)

	love.audio.setDistanceModel("exponent")

	mainCanvas = love.graphics.newCanvas(320, 180)
	mainCanvas:setFilter("nearest", "nearest")

	changeState(titleState)
end

function love.update(dt)
	currentState:update(dt)
end

function love.draw()
	love.graphics.setCanvas(mainCanvas)
	mainCanvas:clear()

    currentState:draw()

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setCanvas()
	love.graphics.draw(mainCanvas, 0, 0, 0, screenScale, screenScale)
end

function love.mousemoved(x, y, dx, dy)
	currentState:mousemoved(x / screenScale, y / screenScale, dx, dy)
end

function love.mousepressed( x, y, button )
	currentState:mousepressed(x / screenScale, y / screenScale, button)
end

function love.keypressed(key)
	currentState:keypressed(key)
end