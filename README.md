# GD50: Project Files
### For [Harvard's CS50: Introduction to Game Development](https://cs50.harvard.edu/games/2018/) course, projects 0-7 (Lua/LOVE2D coursework).

Below I've described the features that I implemented as part of each respective assignment, plus some future idea that would be fun to add. There are a few further course assignments that utilitize Unity (projects 8-11); however at this time I'm not sure I will complete them as I intend to focus on my Godot projects instead.

**Note**: for students who are currently enrolled in GD50, the code herein is not meant for you to copy. Feel free to view my approaches if it will help you solve a problem. Good luck!

___

### 0. Pong
* Implemented AI on left paddle so that player can play against the computer; automaticlly seeks ball
* **Future Ideas**: various AI difficulty levels


#### 1. Flappy
* Pipes are spawned at varying vertical and horizontal distances
* Bronze, Silver, and Gold medals awarded based on player performance
* Game can be paused
* **Future Ideas**: game speeds up over time; ScoreState displays medal associated with each score


#### 2. Breakout
* *Triple Ball* powerup that will create two additional duplicate balls with same behavior as original
* Paddle with shrink in size upon death, grow in size upon achievement of certain score
* Locked bricks exist and must be unlocked with a key powerup before it can be destroyed
* **Future Ideas**: more powerups (speed up, slow down, 'bomb' ball, etc.)


#### 3. Match
* 1 second will be added to the time for each tile in a match
* Tiles change based on current level (higher levels -> patterned tiles with higher point values)
* Shiny tiles that will destroy an entire column/row if included in a match
* Tiles are only swappable when it results in a match; if no tile matches are present, the board will be automatically reset
* Mouse pointer implemented
* **Future Ideas**: none (did quite enough on this project already)


#### 4. Mario
* Player always spawns above solid ground
* Key and lockblock are spawned on each level; player must collect the key to destroy the lockblock
* Once lockblock is destroyed, a goalpost will spawn at the end of the level
* When player makes contact with this goalpost, it will respawn a new longer level
* **Future Ideas**: various enemy types with different behavior; powerups (grow, shrink, jump higher, fireballs, etc.)


#### 5. Zelda
* Enemies will spawn hearts when destroyed; collected hearts heal player health
* Pots randomly spawn in each room and can be picked up and carried by the player
* While held, pots can be thrown and will be destroyed upon a) collision with an ememy or wall or b) after traveling the distance of 4 tiles
* **Future Ideas**: equipment (weapons, armor) that change player health and/or damage stats; inventory with other items that can be held; intelligent dungeon design with endpoint and/or boss fight


#### 6. Angry
* Player alien will split into 3 (all with same behavior) if spacebar is pressed after launch and before any collisions 
* **Future Ideas**: richer level design; various launchable aliens with different powerups

#### 7. Pokemon
* Upon level-up of pokemon, a menu will appear that shows their old stat, the stat change, and their new stat for each pokemon attribute (hp, attack, defense, speed)
* **Future Ideas**: pokemon types, including move types with varying amounts of damage; party system for use of more than 1 pokemon during battle; intelligent world design with boss fight or other trainer battle

____

Thank you for visiting this GitHub respository. Feel free to explore my [GitHub page](https://www.github.com/klundern) to see the other projects I'm working on.