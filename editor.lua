local core = {
	border = 2,
	margin = 2,
	barheight = 20,
}
core.__index = core

local font = nil

local window = {
}
window.__index = window

function window:new(title, width, height)
	local t = {}
	setmetatable(t, window)
	t:init(title, width, height)
	return t
end

function window:init(title, width, height)
	self.title = title
	self.width = width
	self.height = height
	self.x = 0
	self.y = 0
	self.color = { 49,51,53 }
	self.outline = { 255,255,255}
	self.canvas = love.graphics.newCanvas(width, height)
	--love.graphics.setCanvas(self.canvas)

	--draw outlines of window


	--love.graphics.setCanvas()
end

function window:setMouseHandlers(press,release,move)
	self.mouseHandlers = {}
	self.mouseHandlers["press"] = press
	self.mouseHandlers["release"] = release
	self.mouseHandlers["move"] = move
	
end

function window:shouldCaptureClick(mx,my)
	local x = self.x
	local y = self.y

	--print("got event", event)
	local w = self.width + core.border * 2 + core.margin * 2
	local h = self.height + core.border * 3 + core.margin * 2 + core.barheight

	if mx >= x and mx <= x + w and my >= y and my <= y + h then
		return true
	end
end

function window:handleMouseEvent(mx, my, b, event)
	local startx = self.x + core.border + core.margin
	local starty = self.y + core.border*2 + core.margin + core.barheight

	if self.mouseHandlers and self.mouseHandlers[event] then
		self.mouseHandlers[event](self,mx - startx,my - starty,b)
	end
end

function window:drawcontent(drawfunc)
	love.graphics.setCanvas(self.canvas)

	drawfunc(self)

	love.graphics.setCanvas()
end

function window:draw()
	local lw = core.border
	local w = self.width + lw * 2 + core.margin * 2
	local h = self.height + core.barheight + core.margin * 2 + lw * 3

	love.graphics.push()
	love.graphics.translate(self.x, self.y)

	--background
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", 0, 0, w, h)

	love.graphics.setColor(self.outline)
	love.graphics.setLine(lw, "rough")

	local halfborder = lw/2 

	--window outline
	--tl -> bl
	love.graphics.line(halfborder, halfborder, halfborder, h)
	--tl -> tr
	love.graphics.line(0, halfborder, w, halfborder)
	--bl -> br
	love.graphics.line(0, h, w, h )
	--tr -> br
	love.graphics.line(w - halfborder, halfborder, w - halfborder, h)

	--title bar separator
	love.graphics.line(0, core.barheight, w, core.barheight)

	--title
	--love.translate(5, core.barheight)
	love.graphics.setFont(font)
	love.graphics.print(self.title, 6, 4)

	love.graphics.translate( core.margin + lw, core.margin + core.barheight + lw * 2 )
	love.graphics.draw(self.canvas, 0, 0)

	love.graphics.pop()
end

local loveFuncs = { 'draw', 'update', 'mousepressed', 'mousereleased' }

local function new()
	local t = {}

	--one time setup
	if font == nil then
		font = love.graphics.newFont("Anonymous Pro.ttf", 15)
	end

	t.windows = {}
	t.hooks = {}

	for i,v in ipairs(loveFuncs) do
		t.hooks[v] = love[v]
		love[v] = function(...) t[v](t,...) end
	end

	setmetatable(t, core)

	return t
end

function core:newWindow(...)
	local w = window:new(...)

	table.insert(self.windows, w)

	return w
end

function core:draw()
	self.hooks["draw"]()

	for i,w in ipairs(self.windows) do
		w:draw()
	end
end

function core:update(dt)
	--check our mouse first
	local press = self.activepress
	if press then
		local x,y = love.mouse.getPosition()
		press.window:handleMouseEvent(x, y, btn, "move")
		return
	end

	self.hooks["update"](dt)
end

function core:mousepressed(x,y,btn)

	for i,window in ipairs(self.windows) do
		if window:shouldCaptureClick(x,y) then
			window:handleMouseEvent(x,y,btn,"press")
			self.activepress = { window = window, btn = btn, x = x, y = y }
			return
		end
	end
	self.hooks["mousepressed"](x,y,btn)
end

function core:mousereleased(x,y,btn)

	if self.activepress then
		self.activepress.window:handleMouseEvent(x,y,btn,"release")
		self.activepress = nil
		return
	end

	if self.hooks["mousereleased"] then
		self.hooks["mousereleased"](x,y,btn)
	end
end


return setmetatable({new = new},
	{__call = function(_, ...) return new(...) end})
