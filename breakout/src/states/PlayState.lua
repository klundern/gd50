--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.recoverPoints = params.recoverPoints
    self.upsizePaddle = params.upsizePaddle

    -- timer and flag for powerups; flag is only 'true' when
    -- a powerup should be drawn on screen ('falling')
    self.start = love.timer.getTime()
    local powerup = false
    key_triggered = false

    -- give initial ball a random starting velocity
    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        if ball.inPlay then
            ball:update(dt)
        end
    end

    -- update PowerUps, if any are in play
    if powerup then
        self.powerup:update(dt)
    end

    -- check for collisions between each ball in our table and the paddle
    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
        
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

    end

    -- monitor for collisions between powerups and paddles
    if powerup and self.powerup:collides(self.paddle) then
        -- Reset powerup flag to false
        powerup = false

        -- Update position to avoid repeat collisions
        self.powerup.x = 0
        self.powerup.y = 0

        -- turn inPlay flag to 'false' so it is no longer updated or rendered
        self.powerup.inPlay = false

        -- if the skin is '2', trigger 'triple ball' powerup
        if self.powerup.skin == 2 then
            --replace the table with a new table
            self.balls = triple(self.balls)
            gSounds['powerup_triggered']:play()

        -- if the skin is '10', unlock the locked brick
        elseif self.powerup.skin == 10 then
            unlockBrick(self.bricks)

            -- add 500 points to the score
            self.score = self.score + 500

            -- play unlock sound
            gSounds['unlock']:play()
        end

    end

    -- clear powerup if it reaches the bottom of the screen
    if powerup and self.powerup.y >= VIRTUAL_HEIGHT then
        powerup = false
        self.powerup.inPlay = false
    end

    -- detect collision across all bricks AND accross all balls
    for k, brick in pairs(self.bricks) do

        for k, ball in pairs(self.balls) do

            -- only check collision if we're in play, and the brick is unlocked
            if brick.inPlay and ball:collides(brick) then

                --check if enough time has passed to trigger a powerup (20s)
                self.time_passed = love.timer.getTime() - self.start
                if self.time_passed > 20 and not brick.locked then
                    -- reset the 'start' time to the current time
                    self.start = love.timer.getTime()

                    -- Initialize a powerup, with the brick's x and y
                    powerup = true
                    self.powerup = Powerup(brick.x, brick.y)

                    gSounds['powerup_initial']:play()
                end

                -- add to score, but only if the brick isn't locked
                if not brick.locked then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                end

                -- trigger the brick's hit function, which removes it from play
                -- but only if it's unlocked
                if not brick.locked then
                    brick:hit()
                end

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- if we have enough points, upsize the paddle by one
                if self.score > self.upsizePaddle then
                    -- trigger upsize function (defined in Paddle class)
                    self.paddle:upsize()

                    -- multiple upsize points by 2
                    self.upsizePaddle = (self.upsizePaddle * 2)
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()
                    powerup = false

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls,
                        recoverPoints = self.recoverPoints,
                        upsizePaddle = self.upsizePaddle
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
            
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
            
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
            
                -- bottom edge if no X collisions or top collision, last possibility
                else
                
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for k, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT and ball.inPlay then
            ball.inPlay = false
            powerup = false

            self.health = self.health - 1

            -- trigger downsize function (defined in Paddle class)
            self.paddle:downsize()

            gSounds['hurt']:play()

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints,
                    upsizePaddle = self.upsizePaddle
                })
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    -- render any falling powerups
    if powerup then
        self.powerup:render()
    end

    self.paddle:render()

    -- render all balls
    for k, ball in pairs(self.balls) do
        if ball.inPlay then
            ball:render()
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- if a key powerup has been triggered, then draw the key in the top left
    if key_triggered then
        renderKey()
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end