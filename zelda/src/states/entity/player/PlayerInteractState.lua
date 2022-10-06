--[[
    GD50
    Legend of Zelda

    Author: Nolan Klunder
    klunden@gmail.com

    A state that allows us to interact with interactable objects; copies from SwingSwordState
]]

PlayerInteractState = Class{__includes = BaseState}

function PlayerInteractState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 0

    -- create hitbox based on where the player is and facing
    local direction = self.player.direction
    local hitboxX, hitboxY, hitboxWidth, hitboxHeight

    if direction == 'left' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x - hitboxWidth
        hitboxY = self.player.y + 2
    elseif direction == 'right' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x + self.player.width
        hitboxY = self.player.y + 2
    elseif direction == 'up' then
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y - hitboxHeight
    else
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y + self.player.height
    end

    -- separate interact hitbox; will only be active during this state
    self.interactHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
end

function PlayerInteractState:enter(params)

    -- restart pickup pot animation
    self.player.currentAnimation:refresh()
end

function PlayerInteractState:update(dt)

    -- only need to check for objects if our hands are empty
    if not self.player.holding_pot then
        -- create a table for all objects within the hitbox
        local objects = {}

        -- check if hitbox collides with any objects in the scene; add to table
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object:collides(self.interactHitbox) and object.holdable then
                table.insert(objects, object)
            end
        end
            
        -- if objects, play animation and mark player as holding and object as held
        if #objects > 0 then

            -- empty object table once animation is completed
            if self.player.currentAnimation.timesPlayed > 0 then
                self.player:changeState('carry-pot')
                self.player.currentAnimation.timesPlayed = 0
                self.player.holding_pot = true
                
                -- first object in table is held (prevents picking up two overlapping objects)
                objects[1].held = true

                -- empty objects table
                objects = {}
            else
                -- trigger picking-up pot animation
                self.player:changeAnimation('pickup-pot-' .. self.player.direction)
            end
        else
            -- there are no objects to interact with; return to idle state
            self.player:changeState('idle')
        end

    -- if we're holding a pot, throw it
    elseif self.player.holding_pot then
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object.held then
                object.held = false
                object.projectile = true
                object:fire(self.player.direction)

                object.initX = self.player.x
                object.initY = self.player.y

                self.player.holding_pot = false
                self.player:changeState('idle')
            end
        end
    end
end

function PlayerInteractState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

    --
    -- debug for player and hurtbox collision rects VV
    --

    --love.graphics.setColor(255, 0, 255, 255)
    --love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    --love.graphics.rectangle('line', self.interactHitbox.x, self.interactHitbox.y,
         --self.interactHitbox.width, self.interactHitbox.height)
    --love.graphics.setColor(255, 255, 255, 255)
end