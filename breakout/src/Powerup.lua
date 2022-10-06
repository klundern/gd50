--[[
	GD50
	Breakout Remake

	Author: Nolan Klunder
	Email: klundern@gmail.com

	Represents a PowerUp Class that can be implemented to add 
	new features to the game, including doubling the number
	of balls in play and keys to unlock specific 'locked' bricks.
	PowerUps are triggered after a certain number of bricks has been
	hit.
]]

Powerup = Class{}

--[[
	Our PowerUp will spawn from the center of the brick that triggered it;
	it will then fall towards the bottom of the screen towards the 
	player's paddle.
]]

function Powerup:init(x, y)
	self.width = 16
	self.height = 16
	
	-- initial position of the Powerup will be determined by the brick
	-- that it spawns from
	self.x = x + 8 -- add 8 to make it appear to spawn from the middle of the brick
	self.y = y

	-- Powerups will only move in one dimension (falling), so only one
	-- variable (dy) is needed
	self.dy = 50

	-- default skin is '2'
	self.skin = 2

	-- if a locked brick is in play, give the option to trigger a 'key' powerup by
	-- changing the skin to '10'
	if lockedbrick_inPlay == true and key_triggered == false then
		local rand_num = math.random(1, 3)
		if rand_num == 1 then
			self.skin = 10
		end
	end

	-- flag for render and update functions
	self.inPlay = true
end

-- Simple collision detection between PowerUp and paddle (target)
-- Utilizes the same collision code as the Ball and Paddle
function Powerup:collides(target)
	if self.x > target.x + target.width or target.x > self.x + self.width then
		return false
	end

	if self.y > target.y + target.height or target.y > self.y + self.height then
		return false
	end 

	return true
end

function Powerup:update(dt)
	if self.inPlay then
		self.y = self.y + self.dy * dt
	end
end

function Powerup:render()
	if self.inPlay then
		love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin], self.x, self.y)
	end
end
