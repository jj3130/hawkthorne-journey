local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local window = require 'window'
local scoreboard = require 'scoreboard'

local Cornelius = {}
Cornelius.__index = Cornelius

local image = love.graphics.newImage('images/cornelius_head_2.png')
local g = anim8.newGrid(148, 195, image:getWidth(), image:getHeight())

function Cornelius.new(node, collider)
    local cornelius = {}
    setmetatable(cornelius, Cornelius)
	cornelius.node = node
    cornelius.x = node.x
    cornelius.y = node.y
    cornelius.y_bob = 0
	cornelius.width = node.width
	cornelius.height = node.height
    cornelius.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    cornelius.animations = {
        talking = anim8.newAnimation('once', g('2,1', '3,1', '2,1', '3,1', '2,1', '1,1'), 0.2 ),
        idle = anim8.newAnimation('loop', g('1,1'), 1)
	}
	cornelius.state = 'idle'
    cornelius.bb.node = cornelius
    cornelius.collider = collider
	cornelius.x_offset = 30
	cornelius.y_offset = 20
	cornelius.hittable = true
	
    return cornelius
end

function Cornelius:collide( node, dt, mtv_x, mtv_y)
	if node and node.baseball and node.thrown then
		-- above
		if self.x < node.position.x and
		   self.x + self.width > node.position.x + node.width and
		   self.y > node.position.y then
			   node:rebound( false, true )
		elseif -- below
		   self.x < node.position.x and
		   self.x + self.width > node.position.x + node.width and
		   self.y < node.position.y then
			   node:rebound( false, true )
		else -- sides
			node:rebound( true, false )
		end
		--prevent multiple messages
		if self.hittable then
			scoreboard.score = scoreboard.score + 1000
			self.state = 'talking'
			sound.playSfx('audio/cornelius_thats_my_boy.ogg')
			Timer.add( .8, function()
				self.animations.talking:gotoFrame(1)
				self.state = 'idle'
			end)
		end
		self.hittable = false
		Timer.add( 1, function()
			self.hittable = true
		end)
	end
end

function Cornelius:update(dt)
    self.y_bob = (math.cos(((love.timer.getTime() - dt) / (4 / 2) + 1) * math.pi) + 1) * 10
    self:animation():update(dt)
end

function Cornelius:animation()
	return self.animations[self.state]
end

function Cornelius:draw()
    self:animation():draw( image, self.x - self.x_offset, self.y - self.y_offset + self.y_bob )
	love.graphics.print( scoreboard.score, window.width - 40, window.height - 40, 0, 0.5 )
end

function Cornelius:keypressed(key, player)
end

return Cornelius


