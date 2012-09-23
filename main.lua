local gui = require "Quickie"

vector = require "hump.vector"
Camera = require "hump.camera"
Gamestate = require "hump.gamestate"

viewcam = nil
tilesize = 32

hscroll = 0
vscroll = 0

function love.load()
	love.graphics.setBackgroundColor(29,31,33)

	viewcam = Camera(0,0,1,0)
end

function love.draw()
	viewcam:attach()
	local height, width = love.graphics.getHeight(), love.graphics.getWidth()

	local startx, starty = viewcam:worldCoords(0, 0)
	local endx, endy = viewcam:worldCoords(width, height)

	local x = startx - startx % tilesize + tilesize
	local y = starty - starty % tilesize + tilesize

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
end