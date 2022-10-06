--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
    
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        if self.entity.holding_pot then
            self.entity:changeState('carry-pot')
        else
            self.entity:changeState('walk')
        end
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        self.entity:changeState('interact')
    end

    if love.keyboard.wasPressed('space') and not self.entity.holding_pot then
        self.entity:changeState('swing-sword')
    end
end