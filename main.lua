local gui = require "Quickie"

vector = require "hump.vector"
Camera = require "hump.camera"
Gamestate = require "hump.gamestate"

Editor = require "editor"

viewcam = nil
tilesize = 32
map = nil


hscroll = 0
vscroll = 0

Tile = {}

TileMap = {}

function TileMap:new()
	local t = {}
	self.__index = self
	setmetatable(t, self)

	t.map = {}
	return t
end

function TileMap:setTile(x, y, tile)
	if self.map[y] == nil then
		self.map[y] = {}
	end
	self.map[y][x] = tile
end

function TileMap:getTile(x, y)
	if self.map[y] then
		return self.map[y][x]
	end
end

function TileMap:draw()
	love.graphics.setColor(200,200,200)
	for y,row in pairs(self.map) do
		for x, Tile in pairs(row) do
			--love.graphics.circle("fill", x*tilesize, y*tilesize, 5)
			love.graphics.rectangle("line", x * tilesize + 2, y * tilesize +2, tilesize -4, tilesize -4)
		end
	end
end

function getTileCoords(x,y)
	local tx, ty = math.floor(x/tilesize), math.floor(y/tilesize)
	print(string.format("in %d, %d, out %d, %d", x, y, tx, ty))

	return tx, ty
end

local mousedown = false
local tx, ty = 0,0

function testdraw(window)
	if mousedown then
		love.graphics.setColor(255,0,0)
		love.graphics.circle("fill", tx, ty, 10)
	end
end

function toolmousepress(window, x,y,btn)
	print("down", x,y)
	mousedown = true
	tx, ty = x, y
	window:drawcontent(testdraw)
end

function toolmouserelease(window, x,y,btn)
	print("up", x,y)
	mousedown = false
end

function toolmousemove(window, x,y,btn)
	tx, ty = x,y
	window:drawcontent(testdraw)
end

function love.load()
	love.graphics.setBackgroundColor(29,31,33)
	love.graphics.setLineWidth(1)
	viewcam = Camera(0.5,0.5,1,0)
	map = TileMap:new()

	editor = Editor()

	window = editor:newWindow("test", 200, 150)
	window.x = 100
	window.y = 100

	window:drawcontent(testdraw)
	window:setMouseHandlers(toolmousepress, toolmouserelease, toolmousemove)
end

function love.draw()
	viewcam:attach()
	local height, width = love.graphics.getHeight(), love.graphics.getWidth()

	local startx, starty = viewcam:worldCoords(0, 0)
	local endx, endy = viewcam:worldCoords(width, height)

	local x = startx - startx % tilesize + tilesize
	local y = starty - starty % tilesize + tilesize

	love.graphics.setLine(1, "rough")

	love.graphics.setColor(128,32,32)
	love.graphics.circle("line", 0, 0, tilesize/4)

	love.graphics.setColor(100,100,100)

	while x < endx do
		love.graphics.line(x, starty, x, starty + height)
		x = x + tilesize
	end

	while y < endy do
		love.graphics.line(startx, y, startx + width, y)
		y = y + tilesize
	end

	map:draw()

	viewcam:detach()
end

function love.update(dt)

	if love.keyboard.isDown("right") then
		hscroll = hscroll + dt * 10
	elseif love.keyboard.isDown("left") then
		hscroll = hscroll - dt * 10
	else
		hscroll = 0
	end

	if love.keyboard.isDown("down") then
		vscroll = vscroll + dt * 10
	elseif love.keyboard.isDown("up") then
		vscroll = vscroll - dt * 10
	else
		vscroll = 0
	end

	local dx, dy = 0, 0

	if hscroll > 0 then
		dx = math.ceil(hscroll)
	else
		dx = math.floor(hscroll)
	end

	if vscroll > 0 then
		dy = math.ceil(vscroll)
	else
		dy = math.floor(vscroll)
	end

	viewcam:move(dx,dy)

end

function love.keyreleased(k)

end

function love.mousepressed(x, y, btn)
	local tx, ty = getTileCoords(viewcam:worldCoords(x,y))

	map:setTile(tx,ty, true)
end