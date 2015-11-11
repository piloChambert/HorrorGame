require "State"
require "gameState"

canvasResolution = {w = 320, h = 180}
screenScale = 3
fullscreen = false


titleState = State()
function titleState:load()
	self.backgroundImage = love.graphics.newImage("titleBackground.png")

	self.startButton = UIElement(213, 135, love.graphics.newImage("startOff.png"), love.graphics.newImage("startOn.png"), nil, self, self.startCallback)
	self.optionsButton = UIElement(48, 135, love.graphics.newImage("optionButtonOff.png"), love.graphics.newImage("optionButtonOn.png"), nil, self, self.optionsCallback)

	table.insert(self.elements, self.startButton)
	table.insert(self.elements, self.optionsButton)
end

function titleState:startCallback(sender)
	changeState(introState)
end

function titleState:optionsCallback(sender)
	changeState(optionState)
end

function titleState:keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

optionState = State()
function optionState:load()
	self.backgroundImage = love.graphics.newImage("optionsBackground.png")

	self.fullscreenCheck = UIElement(160, 61, love.graphics.newImage("checkOff.png"), nil, love.graphics.newImage("checkOn.png"), self, self.checkCallback)
	self.plusButton = UIElement(238, 82, love.graphics.newImage("plusButtonOff.png"), nil, love.graphics.newImage("plusButtonOn.png"), self, self.resolutionCallback)
	self.minusButton = UIElement(160, 82, love.graphics.newImage("minusButtonOff.png"), nil, love.graphics.newImage("plusButtonOff.png"), self, self.resolutionCallback)

	table.insert(self.elements, self.fullscreenCheck)
	table.insert(self.elements, self.plusButton)
	table.insert(self.elements, self.minusButton)
end

function optionState:checkCallback(sender)
	self.fullscreenCheck.active = not self.fullscreenCheck.active
end

function optionState:resolutionCallback(sender)
end

function optionState:keypressed(key)
	if key == "escape" then
		changeState(titleState)
	end
end

introState = State()
function introState:load()
	self.backgroundImage = love.graphics.newImage("intro.png")
end

function introState:mousemoved(x, y, dx, dy)

end

function introState:mousepressed(x, y, button)
	if button == "l" then
		changeState(gameState)
	end
end


gameoverState = State()
function gameoverState:load()
	self.backgroundImage = love.graphics.newImage("gameover.png")
end

function gameoverState:mousepressed(x, y, button)
	State.mousepressed(self, x, y, button)

	if button == "l" then
		changeState(titleState)
	end
end

endState = State()
function endState:load()
	self.backgroundImage = love.graphics.newImage("endscreen.png")
end


function endState:mousepressed(x, y, button)
	State.mousepressed(self, x, y, button)
	if button == "l" then
		changeState(titleState)
	end
end


-- Love callback
local mainCanvas
currentState = nil

function setupScreen() 
	love.window.setMode(canvasResolution.w * screenScale, canvasResolution.h * screenScale, {fullscreen=fullscreen})
	mainCanvas = love.graphics.newCanvas(canvasResolution.w, canvasResolution.h)
	mainCanvas:setFilter("nearest", "nearest")
end

function changeState(newState)
	if currentState ~= nil then
		currentState:unload()
	end

	currentState = newState
	currentState:load()
end

function love.load()
	setupScreen()

	love.audio.setDistanceModel("exponent")

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