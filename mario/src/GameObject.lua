--[[
    GD50
    -- Super Mario Bros. Remake --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def)
    self.x = def.x
    self.y = def.y
    self.texture = def.texture
    self.width = def.width
    self.height = def.height
    self.frame = def.frame
    self.solid = def.solid
    self.collidable = def.collidable
    self.consumable = def.consumable
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.hit = def.hit

    -- flag for if this object is a lockblock; used to conditionally clear the lockblock
    -- if the key has been collected and spawn a levelup_flag
    self.lockblock = def.lockblock

    -- flag for animation
    self.animated = def.animated

    -- we only have one object that is animated (our flags), so if 'animated' is true then
    -- initialize it with the proper flag frames
    if self.animated then
        self.animation = Animation {
            frames = {def.frame, def.frame + 1},
            interval = 0.25
        }
    end
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
            target.y > self.y + self.height or self.y > target.y + target.height)
end

function GameObject:update(dt)
    if self.animated then
        self.animation:update(dt)
    end
end

function GameObject:render()
    -- if a block is 'hit', then render it's hit variant (frame + 1)
    if self.hit then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame + 1], self.x, self.y)
    -- if our object is animated (only the flag), render the proper frame
    elseif self.animated then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation:getCurrentFrame()], self.x, self.y)
    -- render all other static objects
    else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    end
end