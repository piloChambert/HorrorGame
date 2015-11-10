require "gameState"

canvasResolution = {w = 320, h = 180}
screenScale = 3
fullscreen = false

function testPointInQuad(x, y, qx, qy, qw, qh)
	if x >= qx and x < qx + qw and y >= qy and y < qy + qh then
		return true
	end

	-- else
	return false
end

UIElement = {}
UIElement.__index = UIElement

function UIElement.new(x, y, image, overImage, activeImage, target, callback)
	local self = setmetatable({}, UIElement)

	self.active = false -- normal
	self.over = false

	self.x = x
	self.y = y

	local w, h = image:getDimensions()
	self.width = w
	self.height = h

	self.image = image
	self.overImage = overImage
	self.activeImage = activeImage

	self.target = target
	self.callback = callback

	self.currentImage = self.image

	return self
end

function UIElement:draw()
	local img = self.image

	if self.active then
		img = self.activeImage
	end

	if self.over and self.overImage then
		img = self.overImage
	end

	love.graphics.draw(img, self.x, self.y)
end

function UIElement:mousemoved(x, y, dx, dy)
	self.over = testPointInQuad(x, y, self.x, self.y, self.width, self.height)
end

function UIElement:mousepressed(x, y, button)
	if testPointInQuad(x, y, self.x, self.y, self.width, self.height) and button == "l" then
		if self.target ~= nil and self.callback ~= nil then
			self.callback(self.target, self)
		end
	end
end

setmetatable(UIElement, { __call = function(_, ...) return UIElement.new(...) end })

titleState = {}
function titleState:load()
	self.backgroundImage = love.graphics.newImage("titleBackground.png")

	self.startButton = UIElement(213, 135, love.graphics.newImage("startOff.png"), love.graphics.newImage("startOn.png"), nil, self, self.startCallback)
	self.optionsButton = UIElement(48, 135, love.graphics.newImage("optionButtonOff.png"), love.graphics.newImage("optionButtonOn.png"), nil, self, self.optionsCallback)

	self.elements = {}
	table.insert(self.elements, self.startButton)
	table.insert(self.elements, self.optionsButton)

end

function titleState:startCallback(sender)
	changeState(introState)
end

function titleState:optionsCallback(sender)
	changeState(optionState)
end


function titleState:unload()
end

function titleState:update(dt)
end

function titleState:draw()
	-- draw background
	love.graphics.draw(self.backgroundImage, 0, 0)

	for i, v in ipairs(self.elements) do
		v:draw()
	end
end

function titleState:mousemoved(x, y, dx, dy)
	for i, v in ipairs(self.elements) do
		v:mousemoved(x, y, dx, dy)
	end
end

function titleState:mousepressed(x, y, button)
	for i, v in ipairs(self.elements) do
		v:mousepressed(x, y, button)
	end
end

function titleState:keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

optionState = {}
function optionState:load()
	self.backgroundImage = love.graphics.newImage("optionsBackground.png")

	self.fullscreenCheck = UIElement(160, 61, love.graphics.newImage("checkOff.png"), nil, love.graphics.newImage("checkOn.png"), self, self.checkCallback)
	self.plusButton = UIElement(238, 82, love.graphics.newImage("plusButtonOff.png"), nil, love.graphics.newImage("plusButtonOn.png"), self, self.resolutionCallback)
	self.minusButton = UIElement(160, 82, love.graphics.newImage("minusButtonOff.png"), nil, love.graphics.newImage("plusButtonOff.png"), self, self.resolutionCallback)

	self.elements = {}
	table.insert(self.elements, self.fullscreenCheck)
	table.insert(self.elements, self.plusButton)
	table.insert(self.elements, self.minusButton)

end

function optionState:checkCallback(sender)
	self.fullscreenCheck.active = not self.fullscreenCheck.active
end

function optionState:resolutionCallback(sender)
end


function optionState:unload()
end

function optionState:update(dt)
end

function optionState:draw()
	-- draw background
	love.graphics.draw(self.backgroundImage, 0, 0)

	for i, v in ipairs(self.elements) do
		v:draw()
	end
end

function optionState:mousemoved(x, y, dx, dy)
	for i, v in ipairs(self.elements) do
		v:mousemoved(x, y, dx, dy)
	end
end

function optionState:mousepressed(x, y, button)
	for i, v in ipairs(self.elements) do
		v:mousepressed(x, y, button)
	end
end

function optionState:keypressed(key)
	if key == "escape" then
		changeState(titleState)
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