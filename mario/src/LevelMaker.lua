--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- flags for spawning lock-blocks and keys
    local lockblock_spawned = false
    local key_spawned = false

    -- flag for if our key has been collected, as well as selecting a random color
    local key_collected = false
    local lockblock_color = math.random(5, 8)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    -- save space at the end (5) for 'winner's platform' where flag will be spawned
    for x = 1, (width - 6) do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            --chance to spawn a lock-block, if one has not been spawned yet
            if not lockblock_spawned then
                -- gives us a random distribution of where the locked block spawns
                if math.random(width) == 1 then
                    table.insert(objects,

                        GameObject {
                            texture = 'keys_and_locks',
                            x = (x - 1) * TILE_SIZE,
                            y = (blockHeight - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            frame = lockblock_color,
                            collidable = true,
                            consumable = false,
                            solid = true,
                            hit = false,
                            lockblock = true,

                            -- collision function takes itself; when 'hit' and 'lockblock'
                            -- flags are true the object will be cleared in the 'PlayerJumpState'
                            onCollide = function(obj)
                                -- if our key has been collected...
                                if key_collected then
                                    -- clear the block
                                    obj.hit = true
                                    gSounds['lockblock_cleared']:play()

                                    -- spawn our goal post to advance to the next level

                                    -- random variants of poles and flags
                                    local pole = math.random(6)
                                    local flag = math.random(4)

                                    -- spawn our pole first, one piece at a time (4 total)
                                    for x = 1, 4 do
                                        table.insert(objects,
                                            GameObject {
                                                texture = 'flags',
                                                x = (width - 3) * TILE_SIZE,
                                                y = (x + 2) * TILE_SIZE,
                                                width = 16,
                                                height = 16,

                                                frame = pole + ((x - 1) * 9),
                                                consumable = true,

                                                -- onConsume function passes params to our StateMachine
                                                onConsume = function(player, object)
                                                    gStateMachine:change('play', {
                                                        levelnum = player.levelnum + 1,
                                                        score = player.score,
                                                        width = math.floor(width * 1.5)
                                                    })

                                                    -- play a 'levelup' sound
                                                    gSounds['levelup']:play()
                                                end
                                            }
                                        )
                                    end

                                    -- spawn our flag
                                    table.insert(objects,
                                        GameObject {
                                            texture = 'flags',
                                            x = ((width - 2) * TILE_SIZE) - 5,
                                            y = (3 * TILE_SIZE),
                                            width = 16,
                                            height = 16,

                                            frame = ((flag - 1) * 9) + 7,
                                            solid = true,
                                            collidable = true,
                                            animated = true,

                                            -- onConsume function passes params to our StateMachine
                                            onCollide = function(player, object)
                                                gStateMachine:change('play', {
                                                    levelnum = player.levelnum + 1,
                                                    score = player.score,
                                                    width = math.floor(width * 1.5)
                                                })

                                                -- play a 'levelup' sound
                                                gSounds['levelup']:play()
                                            end
                                        }
                                    )
                                -- else just play an empty block sound
                                else
                                    gSounds['empty-block']:play()
                                end
                            end
                        }
                    )

                    -- set our flag to true
                    lockblock_spawned = true

                    -- skip regular block spawn to prevent spawning a block in the same spot
                    goto continue
                end
            end

            -- chance to spawn a key, if one has not been spawned yet
            if not key_spawned then
                -- gives us a random distribution of where the key spawns
                if math.random(width) == 1 then
                    table.insert(objects,

                        GameObject {
                            texture = 'keys_and_locks',
                            x = (x - 1) * TILE_SIZE,
                            y = (blockHeight + 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            frame = lockblock_color - 4,
                            collidable = true,
                            consumable = true,
                            solid = false,

                            -- when the player collides with the key, set our flag to true
                            onConsume = function(player, object)
                                key_collected = true
                                gSounds['pickup']:play()
                            end
                        }
                    )

                    -- set key_spawned flag to true
                    key_spawned = true
                end
            end

            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant, but only of 'non-hit' frames
                        frame = JUMP_BLOCKS[math.random(#JUMP_BLOCKS)],
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end

            -- continue flag to skip spawning a block over our key/locked block
            ::continue::
        end
    end

    --add 5 level blocks to the end of each level where the flag can spawn; think
    -- of it like a 'winner's platform'
    for x = (width - 5), width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space, just like above
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- switch to spawning ground blocks
        tileID = TILE_ID_GROUND

        -- fill in the rest of each column with ground blocks
        for y = 7, height do
            table.insert(tiles[y],
                Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
        end
    end

    -- if we've spawed both a key and lockblock, then go ahead and return the GameLevel
    if key_spawned and lockblock_spawned then

        local map = TileMap(width, height)
        map.tiles = tiles

        return GameLevel(entities, objects, map)
    -- else keep trying to spawn levels that contain keys and lockblocks
    else
        return LevelMaker.generate(width, height)
    end
end