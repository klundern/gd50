--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- Initialize the medals
    local BRONZE_METAL = love.graphics.newImage('bronze.png')
    local SILVER_METAL = love.graphics.newImage('silver.png')
    local GOLD_METAL = love.graphics.newImage('gold.png')

    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    -- Award the player a medal based on score
    if self.score > 1 and self.score < 4 then
        love.graphics.printf('You earned Bronze!', 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(BRONZE_METAL, (VIRTUAL_WIDTH / 2) -  (BRONZE_METAL:getWidth() / 2), 125)
    elseif self.score > 3 and self.score < 10 then
        love.graphics.printf('You earned Silver!', 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(SILVER_METAL, (VIRTUAL_WIDTH / 2) - (SILVER_METAL:getWidth() / 2), 125)
    elseif self.score > 9 then
        love.graphics.printf('You earned Gold!', 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(GOLD_METAL, (VIRTUAL_WIDTH / 2) - (GOLD_METAL:getWidth() / 2), 125)
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 220, VIRTUAL_WIDTH, 'center')
end