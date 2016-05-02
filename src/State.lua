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

	self.state = nil

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
		if self.target ~= nil and self.callback ~= nil then
			self.callback(self.target, self)
		end
	end
end

function UIElement:removeFromState()
	if self.state ~= nil then
		self.state:removeElement(self)
	end
end

setmetatable(UIElement, { __call = function(_, ...) return UIElement.new(...) end })

State = {}
State.__index = State

function State.new()
	local self = setmetatable({elements = {}}, State)
	return self
end

-- called when the state is first insert in the state stack
function State:load()
	self.elements = {}
end

-- called when the state is removed from the stack
function State:unload()
end

-- called when the state reach the top of the stack
function State:enable()
	-- reset elements
	for i, v in ipairs(self.elements) do
		v.over = false
	end
end

-- called when there's another push on top 
function State:disable()
end

-- add an ui element
function State:addElement(element)
	table.insert(self.elements, element)
	element.state = self
end

function State:removeElement(element)
	-- look for element index in element list
	local idx = -1
	for k, v in ipairs(self.elements) do
		if v == element then 
			idx = k
			break
		end
	end

	print(idx)
	-- if we got a valid index, remove it
	if idx ~= -1 then
		table.remove(self.elements, idx)
		element.state = nil
	end
end

function State:update(dt)
end

function State:draw()
	-- draw background
	if self.backgroundImage ~= nil then
		love.graphics.draw(self.backgroundImage, 0, 0)
	end

	-- draw ui elements
	for i, v in ipairs(self.elements) do
		v:draw()
	end
end

function State:mousemoved(x, y, dx, dy)
	for i, v in ipairs(self.elements) do
		v:mousemoved(x, y, dx, dy)
	end
end

function State:mousepressed(x, y, button)
	for i, v in ipairs(self.elements) do
		v:mousepressed(x, y, button)
	end
end

function State:keypressed(key)
end
setmetatable(State, { __call = function(_, ...) return State.new(...) end })