--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    -- whether it is consumable or not and whether it has been consumed (initially false)
    self.consumable = def.consumable
    self.consumed = false

    -- whether it is holdable and whether it is currently held
    self.holdable = def.holdable
    self.held = def.held or false

    -- whether it can be a projetile, as well as dx and dy if it is
    self.projectile = def.projectile
    self.dx = 0
    self.dy = 0

    -- initial X and Y values when the pot is 'thrown'; used to clear pot after 4 tiles
    self.initX = x
    self.initY = y

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default empty collision callback
    self.onCollide = function() end

    -- default empty interact callback
    self.onInteract = function() end

    --default empty consume callback
    self.onConsume = function() end
end

function GameObject:update(dt)
    -- update object coordinates based on velocity each frame
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.projectile and not self.held then
        -- if pot has traveled more than 4 tiles (each 16 pixels), then it breaks
        if (math.abs(self.x - self.initX) or math.abs(self.y - self.initY)) > (TILE_SIZE * 4) then
            self.state = 'broken'
        end

        -- if pot is a projetile and collides with walls, then it is broken
        if 
            self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE or 
            self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 or 
            self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 or
            self.y + self.height >= (VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
                + MAP_RENDER_OFFSET_Y - TILE_SIZE)
        then
            self.state = 'broken'
        end
    end
end

--[[
    AABB with some slight shrinkage of the box on the top side for perspective; copied 
    from Entity class.
]]
function GameObject:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

--[[
    Allows our GameObject to be fired as a projectile.
]]
function GameObject:fire(direction)

    -- dx and dy depend on direction
    if direction == 'up' then
        self.dy = -200
    elseif direction == 'down' then
        self.dy = 200
    elseif direction == 'left' then
        self.dx = -200
    elseif direction == 'right' then
        self.dx = 200
    end
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end