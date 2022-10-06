--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        holdable = false,
        projectile = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 14,
        width = 16,
        height = 16,
        solid = true,
        consumable = false,
        holdable = true,
        held = false,
        projectile = false,
        defaultState = 'unbroken',
        states = {
            ['unbroken'] = {
                frame = 14
            },
            ['broken'] = {
                frame = 14
            }
        }
    },
    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        consumable = true,
        holdable = false,
        projectile = false,
        defaultState = 'default',
        states = {
            ['default'] = {
                frame = 5
            }
        }
    }
}