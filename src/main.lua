require "State"
require "gameState"

-- screen configuration
canvasResolution = {width = 320, height = 180}
canvasScale = 1
windowedScreenScale = 4
canvasOffset = {x = 0, y = 0}
fullscreen = false
azerty = false

titleState = State()
function titleState:load()
	State.load(self)

	self.backgroundImage = love.graphics.newImage("titleBackground.png")

	self.startButton = UIElement(213, 135, love.graphics.newImage("startOff.png"), love.graphics.newImage("startOn.png"), nil, self, self.startCallback)
	self.optionsButton = UIElement(48, 135, love.graphics.newImage("optionButtonOff.png"), love.graphics.newImage("optionButtonOn.png"), nil, self, self.optionsCallback)

	self:addElement(self.startButton)
	self:addElement(self.optionsButton)
end

function titleState:startCallback(sender)
	changeState(introState)
end

function titleState:optionsCallback(sender)
	pushState(optionState)
end

function titleState:keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

optionState = State()
function optionState:load()
	State.load(self)

	self.backgroundImage = love.graphics.newImage("optionsBackground.png")

	self.fullscreenCheck = UIElement(160, 61, love.graphics.newImage("checkOff.png"), nil, love.graphics.newImage("checkOn.png"), self, self.fullscreenCallback)
	self.fullscreenCheck.active = fullscreen

	self.plusButton = UIElement(238, 82, love.graphics.newImage("plusButtonOff.png"), nil, love.graphics.newImage("plusButtonOn.png"), self, self.resolutionCallback)
	self.minusButton = UIElement(160, 82, love.graphics.newImage("minusButtonOff.png"), nil, love.graphics.newImage("plusButtonOff.png"), self, self.resolutionCallback)

	self.azertyButton = UIElement(160, 38, love.graphics.newImage("azertyOff.png"), nil, love.graphics.newImage("azertyOn.png"), self, self.keyboardCallback)
	self.azertyButton.active = azerty
	self.qwertyButton = UIElement(211, 38, love.graphics.newImage("qwertyOff.png"), nil, love.graphics.newImage("qwertyOn.png"), self, self.keyboardCallback)
	self.qwertyButton.active = not azerty

	self:addElement(self.fullscreenCheck)
	self:addElement(self.plusButton)
	self:addElement(self.minusButton)
	self:addElement(self.azertyButton)
	self:addElement(self.qwertyButton)
end

function optionState:fullscreenCallback(sender)
	fullscreen = not self.fullscreenCheck.active
	self.fullscreenCheck.active = fullscreen
	setupScreen()
end

function optionState:resolutionCallback(sender)
	if sender == self.plusButton then
		windowedScreenScale = math.min(windowedScreenScale + 1, 6)
	elseif sender == self.minusButton then
		windowedScreenScale = math.max(windowedScreenScale - 1, 1)
	end

	setupScreen()
end

function optionState:draw()
	State.draw(self)

	-- print resolution
	local scaleStr = string.format("%d", windowedScreenScale)
	local width = love.graphics.getFont():getWidth(scaleStr)
	love.graphics.print(scaleStr, 171 + (65 - width) * 0.5, 83)

end

function optionState:keyboardCallback(sender)
	if sender == self.azertyButton then
		azerty = true
		self.azertyButton.active = true
		self.qwertyButton.active = false
	elseif sender == self.qwertyButton then
		azerty = false
		self.azertyButton.active = false
		self.qwertyButton.active = true	
	end
end

function optionState:keypressed(key)
	if key == "escape" then
		popState()
	end
end

introState = State()
function introState:load()
	State.load(self)

	self.backgroundImage = love.graphics.newImage("intro.png")
	self.azertylayoutImage = love.graphics.newImage("introAzertyLayout.png")
	self.qwertylayoutImage = love.graphics.newImage("introQwertyLayout.png")
end

function introState:mousemoved(x, y, dx, dy)

end

function introState:mousepressed(x, y, button)
	if button == "l" then
		changeState(gameState)
	end
end

function introState:draw() 
	State.draw(self)

	if azerty then
		love.graphics.draw(self.azertylayoutImage, 0, 0)
	else
		love.graphics.draw(self.qwertylayoutImage, 0, 0)
	end
end

gameoverState = State()
function gameoverState:load()
	State.load(self)

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
	State.load(self)
	
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
function setupScreen()
	canvasScale = windowedScreenScale 

	if fullscreen then
		local dw, dh = love.window.getDesktopDimensions()
		--print(dw, dh)

		canvasScale = math.floor(math.min(dw / canvasResolution.width, dh / canvasResolution.height))
		canvasOffset.x = (dw - (canvasResolution.width * canvasScale)) * 0.5
		canvasOffset.y = (dh - (canvasResolution.height * canvasScale)) * 0.5
	else
		canvasOffset.x = 0
		canvasOffset.y = 0
	end

	local windowW = canvasResolution.width * canvasScale
	local windowH = canvasResolution.height * canvasScale
	love.window.setMode(windowW, windowH, {fullscreen=fullscreen})

	local formats = love.graphics.getCanvasFormats()
	if formats.normal then
		mainCanvas = love.graphics.newCanvas(canvasResolution.width, canvasResolution.height)
		mainCanvas:setFilter("nearest", "nearest")
	end
end

states = {}
function changeState(newState)
	if #states > 0 then
		-- disable
		states[#states]:disable()

		-- unload the state
		states[#states]:unload()
	end

	table.remove(states)
	table.insert(states, newState)

	-- load the new state
	states[#states]:load()

	-- enable it
	states[#states]:enable()
end

function pushState(newState)
	-- disable top state
	if #states > 0 then
		states[#states]:disable()
	end

	-- insert new state
	table.insert(states, newState)

	-- load it
	states[#states]:load()	

	-- enable it
	states[#states]:enable();
end

function popState()
	if #states > 0 then
		-- disable the state
		states[#states]:disable()

		-- unload it
		states[#states]:unload()

		-- remove it from the stack
		table.remove(states)
	end


	if #states > 0 then
		-- enable top state
		states[#states]:enable()
	end
end

function love.load()
	setupScreen()

	love.audio.setDistanceModel("exponent")

	changeState(titleState)

	-- load the default font
	local font = love.graphics.newImageFont("font.png"," !\"#$%&`()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}")
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)
end

function love.update(dt)
	states[#states]:update(dt)
end

function love.draw()
	-- if we have a canvas
	if mainCanvas ~= nil then
		love.graphics.setCanvas(mainCanvas)
		mainCanvas:clear()

    	states[#states]:draw()

		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.setCanvas()
		love.graphics.draw(mainCanvas, canvasOffset.x, canvasOffset.y, 0, canvasScale, canvasScale)
	else
		-- else print an error
	    local y = 0
    	for formatname, formatsupported in pairs(canvasformats) do
        	local str = string.format("Supports format '%s': %s", formatname, tostring(formatsupported))
        	love.graphics.print(str, 10, y)
        	y = y + 20
    	end
	end

end

function love.mousemoved(x, y, dx, dy)
	states[#states]:mousemoved((x - canvasOffset.x) / canvasScale, (y - canvasOffset.y) / canvasScale, dx, dy)
end

function love.mousepressed( x, y, button )
	states[#states]:mousepressed((x - canvasOffset.x) / canvasScale, (y - canvasOffset.y) / canvasScale, button)
end

function love.keypressed(key)
	-- key translation!
	local tkey = key
	if azerty then 
		if tkey == "a" then tkey = "q" end
		if tkey == "z" then tkey = "w" end
		if tkey == "q" then tkey = "a" end
		if tkey == "w" then tkey = "z" end
	end

	states[#states]:keypressed(tkey)
end