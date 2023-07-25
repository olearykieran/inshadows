local mazeData = require("maze_data")
local mazes = {
    mazeData.maze1,
    mazeData.maze2,
    mazeData.maze3,
    -- Add more maze configurations here
}
local gameStart = false -- Indicates whether the game has started
local showInstructions = false -- Indicates whether to show the instruction screen
local gameTitle = "Shadows" -- Game title
local gameTitleImage
local currentMazeIndex = -1
local enemySpeed = 5 -- speed of the enemy in grid cells per second
local grapplingRange = 1 -- Range of the grappling hook in grid cells
local maze = mazes[currentMazeIndex]
local enemyX, enemyY -- Enemy position
local mazeWidth, mazeHeight -- Store the maze dimensions
local cellSize -- Store the size of each maze cell
local offsetX, offsetY -- Store the offset to center the maze
local playerX, playerY -- Player position
local exitX, exitY -- Exit position
local movementCooldown = 0.15-- Cooldown period between movements
local elapsedTime = 0 -- Elapsed time since last movement
local gameWon = false -- Game state variable
local gameCompleted = false
local lastMoveX, lastMoveY = 0, 0 -- Player last move direction
local initialPlayerX, initialPlayerY = playerX, playerY
local initialEnemyX, initialEnemyY = enemyX, enemyY
local startScreenMusic
local levelMusic
local flameSprite1 = love.graphics.newImage('images/flame_real.png')
local flameSprite2 = love.graphics.newImage('images/pinkflame.png')
local flames = {}
local flameCount = 20 -- number of flames
local radius = 150 -- radius of circle
local gameTitleWidth = love.graphics.getFont():getWidth(gameTitle)
local gameTitleHeight = love.graphics.getFont():getHeight(gameTitle)
local titleX = (love.graphics.getWidth() - gameTitleWidth) / 2
local titleY = love.graphics.getHeight() / 2
local raindropDelay = 0.05 -- Adjust the delay between raindrops as needed
local accumulatedTime = 0
local swordSprite = love.graphics.newImage("images/sword.png")
local swordRotation = 0 -- Initial rotation of the sword
local swordRotationSpeed = 6 -- Speed of the sword rotation
local isSwinging = false -- Indicates whether the sword is currently swinging
local swingDuration = 0.3 -- Duration of the swing animation in seconds
local swingTimer = 0 -- Timer to track the progress of the swing animation
local isAttacking = false -- Indicates whether the attack button is being held down
local hasSword = false
local gameState = 1 -- 1 for the start screen, 2 for the game screen
local chestX, chestY
local trapDoorTouched = false
local enemyAlive = true -- Track whether the enemy is alive
local mazeGrid = {}
local playerLives = 2 -- Number of lives the player has
local fontSize = 12 -- Choose a suitable font size
local livesX = 450 -- X-coordinate for the lives display
local livesY = 55 -- Y-coordinate for the lives display
local gameOverMessage = "In shadows, your journey has ceased..."
local buttonX = 10
local buttonY = 100
local buttonWidth = 100
local buttonHeight = 30
local visibilityRadius = 4
local deathMessageTimer = 1 -- The duration in seconds for the death message to display
local deathMessageDuration = 0 -- The current duration of the death message display


-- Generate a new random maze
function generateMaze()
    
    -- Reset Variables
    enemyAlive = true
    trapDoorTouched = false
    
    -- Store the position of the exit door
    local exitPosX, exitPosY 

    -- Determine correct Maze
    currentMazeIndex = currentMazeIndex % #mazes + 1
    maze = mazes[currentMazeIndex]

    -- Reset Variables
    initialEnemyX, initialEnemyY = nil, nil
    enemyX, enemyY = nil, nil

    -- Determine the dimensions of the maze
    mazeWidth = maze:find("\n") - 1
    mazeHeight = maze:gsub("[^\n]", ""):len()

    -- Determine Grid Dimensions of Maze
    for y = 1, mazeHeight do
        mazeGrid[y] = {}
        for x = 1, mazeWidth do
            local char = maze:sub((y - 1) * (mazeWidth + 1) + x, (y - 1) * (mazeWidth + 1) + x)
            mazeGrid[y][x] = char
        end
    end

    -- Determine the size of each maze cell based on the screen size
    cellSize = math.floor(math.min(love.graphics.getWidth() / mazeWidth, love.graphics.getHeight() / mazeHeight)) 

    -- Store the adjusted maze dimensions
    local adjustedWidth = mazeWidth * cellSize
    local adjustedHeight = mazeHeight * cellSize

    -- Store the offset to center the maze
    offsetX = (love.graphics.getWidth() - adjustedWidth) / 2
    offsetY = (love.graphics.getHeight() - adjustedHeight) / 2

    -- Find player starting position and exit position in the maze
    for y = 1, mazeHeight do
        for x = 1, mazeWidth do
            local char = maze:sub((y - 1) * (mazeWidth + 1) + x, (y - 1) * (mazeWidth + 1) + x)
            if char == "@" then
                playerX, playerY = x, y
            elseif char == "E" then
                exitX, exitY = x, y
            end
        end
    end

    -- Determine exit door positioning
    exitSpriteX = offsetX + (exitX - 1) * cellSize
    exitSpriteY = offsetY + (exitY - 1) * cellSize

    -- Level 2 Chest logic
    if currentMazeIndex == 2 and not hasSword then
        -- Find the chest location in the maze
        local chestFound = false -- Track whether the chest is found in the maze
        for y = 1, mazeHeight do
            for x = 1, mazeWidth do
                local char = maze:sub((y - 1) * (mazeWidth + 1) + x, (y - 1) * (mazeWidth + 1) + x)
                if char == "C" then
                    chestX = x
                    chestY = y
                    chestFound = true
                    break
                end
            end
            if chestFound then
                break
            end
        end
    
        -- Draw the chest if it is found in the maze
        if chestFound then
            local chestPosX = offsetX + (chestX - 1) * cellSize
            local chestPosY = offsetY + (chestY - 1) * cellSize
            love.graphics.draw(chestSprite, chestPosX, chestPosY, 0, cellSize / chestSprite:getWidth(), cellSize / chestSprite:getHeight())
        end
    end

    -- Find enemy position in the maze
    if currentMazeIndex ~= 1 then
        for y = 1, mazeHeight do
            for x = 1, mazeWidth do
                local char = maze:sub((y - 1) * (mazeWidth + 1) + x, (y - 1) * (mazeWidth + 1) + x)
                if char == "X" then
                    enemyX, enemyY = x, y
                end
            end
        end
    end

     -- Store the initial positions of player and enemy
     initialPlayerX, initialPlayerY = playerX, playerY
     initialEnemyX, initialEnemyY = enemyX, enemyY
end


-- Load assets into game
function love.load()

    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    startScreenMusic = love.audio.newSource("music folder/theme song.mp3", "stream")
    levelMusic = love.audio.newSource("music folder/lvl song.mp3", "stream")
    startScreenMusic:setLooping(true) -- set the start screen music to loop
    levelMusic:setLooping(true) -- set the level music to loop
    gameTitleImage = love.graphics.newImage("images/in_shadows.png")
    initializeFlames()
    currentMazeIndex = 0 -- Start at maze index 0
    playerLives = 2 -- Set the initial number of lives to 2
    generateMaze()
    playerSprite = love.graphics.newImage("images/new_player.png")
    enemySprite = love.graphics.newImage("images/new_enemy.png")
    exitdoorSprite = love.graphics.newImage("images/exit_door.png")
    chestSprite = love.graphics.newImage("images/tchest.png")
    initialPlayerX, initialPlayerY = playerX, playerY
end


function resetGame()

    -- Reset positions
    playerX, playerY = initialPlayerX, initialPlayerY
    enemyX, enemyY = initialEnemyX, initialEnemyY
    
    enemyAlive = true

    -- Reset game state
    gameWon = false
    
    -- Reload current maze data
    maze = mazes[currentMazeIndex]

    if playerLives >= 0 then
        deathMessageDuration = deathMessageTimer
    end
    -- Check if the player has lives left
    if playerLives <= 0 then
        gameState = "gameOver"
        love.graphics.clear(0, 0, 0)
        playerLives = 2 -- Reset the number of lives to 2
    end
end


-- Function to check if a cell is within visibility range
local function isCellInVisibilityRange(x, y)
    local distanceToPlayer = math.sqrt((x - playerX) ^ 2 + (y - playerY) ^ 2)
    return distanceToPlayer <= visibilityRadius
end


-- Formula for enemy movement
local function manhattanDistance(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end


-- Updates based on in game frames
function love.update(dt)
    if not gameStart then
        if not startScreenMusic:isPlaying() then
            levelMusic:stop() -- stop the level music in case it's playing
            startScreenMusic:play() -- play the start screen music
        end
        return
    else
        if not levelMusic:isPlaying() then
            startScreenMusic:stop() -- stop the start screen music in case it's playing
            levelMusic:play() -- play the level music
        end
    end

    updateFlames(dt)

    elapsedTime = elapsedTime + dt

    local previousPlayerX, previousPlayerY = playerX, playerY -- Save previous player position

    -- Handle player movement with cooldown
    if love.keyboard.isDown("up") and elapsedTime >= movementCooldown then
        movePlayer(0, -1)
    elseif love.keyboard.isDown("down") and elapsedTime >= movementCooldown then
        movePlayer(0, 1)
    elseif love.keyboard.isDown("left") and elapsedTime >= movementCooldown then
        movePlayer(-1, 0)
    elseif love.keyboard.isDown("right") and elapsedTime >= movementCooldown then
        movePlayer(1, 0)
    end

    -- Check if player has moved
    local playerMoved = playerX ~= previousPlayerX or playerY ~= previousPlayerY

    -- Update the sword animation if swinging
    if isSwinging then
        swingTimer = swingTimer + dt

        -- Calculate the swing progress as a value between 0 and 1
        local swingProgress = swingTimer / swingDuration
        if swingProgress >= 1 then
            -- End the swing animation
            swingProgress = 1
            isSwinging = false

            -- Reset the sword rotation and disable the attack
            swordRotation = 0
            isAttacking = false
        end

        -- Calculate the rotation angle based on the swing progress
        swordRotation = math.sin(swingProgress * math.pi) * math.pi / 2
    end

    -- Calculate direction towards the player
    if enemyX and enemyY then
        local dx, dy = playerX - enemyX, playerY - enemyY
        local dirx, diry = 0, 0

        if dx > 0 then
            dirx = 1
        elseif dx < 0 then
            dirx = -1
        end
        if dy > 0 then
            diry = 1
        elseif dy < 0 then
            diry = -1
        end

         -- Move the enemy towards the player
        local newEnemyX, newEnemyY
        if love.timer.getTime() % (1 / enemySpeed) < dt then -- control the speed of the enemy
            newEnemyX = enemyX + dirx
            newEnemyY = enemyY + diry
        else
            newEnemyX = enemyX
            newEnemyY = enemyY
        end

        -- Check for collision with walls
        local newCell = maze:sub((newEnemyY - 1) * (mazeWidth + 1) + newEnemyX, (newEnemyY - 1) * (mazeWidth + 1) + newEnemyX)
        if newCell ~= "#" then
            -- Calculate the Manhattan distance between the new position and the player
            local distanceToPlayer = manhattanDistance(newEnemyX, newEnemyY, playerX, playerY)
    
            -- Calculate the Manhattan distance between the current position and the player
            local currentDistanceToPlayer = manhattanDistance(enemyX, enemyY, playerX, playerY)
    
            -- Move the enemy only if the new position is closer to the player
            if distanceToPlayer < currentDistanceToPlayer then
                enemyX, enemyY = newEnemyX, newEnemyY
            end
        else
            -- If the new position is a "#" cell, try alternative directions
    
            -- Try moving left/right
            newEnemyX = enemyX + dirx
            newEnemyY = enemyY
    
            local newCellLeftRight = maze:sub((newEnemyY - 1) * (mazeWidth + 1) + newEnemyX, (newEnemyY - 1) * (mazeWidth + 1) + newEnemyX)
            if newCellLeftRight ~= "#" then
                enemyX, enemyY = newEnemyX, newEnemyY
            else
                -- Try moving up/down
                newEnemyX = enemyX
                newEnemyY = enemyY + diry
    
                local newCellUpDown = maze:sub((newEnemyY - 1) * (mazeWidth + 1) + newEnemyX, (newEnemyY - 1) * (mazeWidth + 1) + newEnemyX)
                if newCellUpDown ~= "#" then
                    enemyX, enemyY = newEnemyX, newEnemyY
                else
                    -- If no alternative direction works, move away from the "#" cell
                    newEnemyX = enemyX - dirx
                    newEnemyY = enemyY - diry
    
                    -- Check if the new position (away from the "#" cell) is a valid cell to move
                    local newCellAwayFromObstacle = maze:sub((newEnemyY - 1) * (mazeWidth + 1) + newEnemyX, (newEnemyY - 1) * (mazeWidth + 1) + newEnemyX)
                    if newCellAwayFromObstacle ~= "#" then
                        enemyX, enemyY = newEnemyX, newEnemyY
                    end
                end
            end
        end

        -- Check if enemy hit the player
        if enemyX == playerX and enemyY == playerY then
            playerLives = playerLives - 1 -- Decrease the number of lives by 1
            resetGame()
        end
    end

    -- Update the death message timer
    if deathMessageDuration > 0 then
        deathMessageDuration = deathMessageDuration - dt
        if deathMessageDuration <= 0 then
            deathMessageDuration = 0
        end
    end

    -- Game completed logic
    if playerX == exitX and playerY == exitY and currentMazeIndex == #mazes then
        gameCompleted = true
    end

    -- Grappling hook
    if love.keyboard.isDown("g") and hasSword then
        -- Check if the enemy exists before calculating distance
        if enemyX and enemyY then
            local distanceToEnemy = math.sqrt((playerX - enemyX) ^ 2 + (playerY - enemyY) ^ 2)
            if distanceToEnemy <= grapplingRange then
                -- Kill the enemy
                enemyX, enemyY = nil, nil -- Remove the enemy by setting its coordinates to nil
            end
        end
    end

    -- Enemy death logic
    if hasSword and not enemyX and not enemyY then
        enemyAlive = false
    end

    
    if gameStarted then 
        resetGame()
      end
      
end


function startSwingAnimation()
    isSwinging = true
    swingTimer = 0
end


function initializeFlames()
    for i = 1, flameCount do
        local angle = (i - 1) * (2 * math.pi / flameCount)
        flames[i] = { angle = angle }
    end
end


function updateFlames(dt)
    for i = 1, flameCount do
        flames[i].angle = (flames[i].angle + dt) % (2 * math.pi)
    end
end


function drawFlames(dt)
    for i = 1, flameCount do
        local flame = flames[i]
        local isEven = i % 2 == 0
        local flameSprite = isEven and flameSprite1 or flameSprite2 -- choose the sprite based on the index
        local flameWidth = flameSprite:getWidth() * 0.08
        local flameHeight = flameSprite:getHeight() * 0.08
        local x = titleX + gameTitleWidth / 2 + radius * math.cos(flame.angle) - flameWidth / 2
        local y = titleY + radius * math.sin(flame.angle) - flameHeight / 2 + 12
        love.graphics.draw(flameSprite, x, y, 0, .08, .08)
        flame.angle = (flame.angle + dt) % (2 * math.pi)
    end
end


function love.draw()
    
    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Clear the screen
    love.graphics.clear(0,0,0,0)
    
    -- Before the game starts
    if not gameStart then
        -- Draw the title
        local imageWidth = gameTitleImage:getWidth() * .5
        local imageHeight = gameTitleImage:getHeight() * .5
        local imageX = (love.graphics.getWidth() - imageWidth) / 2
        local imageY = love.graphics.getHeight() / 2 - imageHeight / 2

        -- Draw the rainy background
        love.graphics.setColor(0, 0, 0, 1) -- Set the color with transparency
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight) -- Draw a rectangle covering the screen
        love.graphics.setColor(1, 1, 1) -- Reset the color
        love.graphics.draw(gameTitleImage, imageX, imageY, 0, .5, .5)
        drawFlames(love.timer.getDelta())

         -- Draw raindrops
        love.graphics.setColor(0.5, 0.5, 1)
        local raindropSize = 1
        accumulatedTime = accumulatedTime + love.timer.getDelta()
        while accumulatedTime >= raindropDelay do
            local x = math.random(0, love.graphics.getWidth())
            local y = math.random(0, love.graphics.getHeight())
            love.graphics.circle("fill", x, y, raindropSize)
            accumulatedTime = accumulatedTime - raindropDelay
        end
        love.graphics.setColor(1, 1, 1)

        -- Draw the buttons
        love.graphics.rectangle("line", 10, 60, 100, 30)
        love.graphics.print("Start", 15, 65)
        love.graphics.rectangle("line", 10, 100, 100, 30)
        love.graphics.print("Instructions", 15, 105)

        -- If the instructions screen is displayed
        if showInstructions then
            local text = "'g' is your best friend"
            local textWidth = love.graphics.getFont():getWidth(text)
            local x = love.graphics.getWidth() / 2 - textWidth / 2  -- Center the text horizontally
            local y = love.graphics.getHeight() / 2 + 100
            
            -- Move the text to the left by decreasing the x-coordinate
            local xOffset = 0
            x = x - xOffset
            local yOffset = 50
            y = y - yOffset
    
            love.graphics.print(text, x, y)
        end
        return -- Stop further drawing
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.clear(0, 0, 0, 0)
    -- Draw the maze
    for y = 1, mazeHeight do
        for x = 1, mazeWidth do
            local xPos = offsetX + (x - 1) * cellSize
            local yPos = offsetY + (y - 1) * cellSize
            local cell = mazeGrid[y][x]
            if isCellInVisibilityRange(x, y) then
                if cell == "#" then
                    love.graphics.rectangle("fill", xPos, yPos, cellSize, cellSize)
                elseif cell == "@" then
                    love.graphics.circle("line", xPos + cellSize / 2, yPos + cellSize / 2, cellSize / 4)
                elseif cell == "E" then
                    love.graphics.draw(exitdoorSprite, exitSpriteX, exitSpriteY, 0, cellSize / exitdoorSprite:getWidth(), cellSize / exitdoorSprite:getHeight())
                elseif cell == "C" then
                    love.graphics.draw(chestSprite, xPos, yPos, 0, cellSize / chestSprite:getWidth(), cellSize / chestSprite:getHeight())
                elseif cell == "D" then
                    if trapDoorTouched then
                        love.graphics.setColor(1, 0, 0) -- Set the color to red for the touched trap door
                    else
                        love.graphics.setColor(1, 1, 1) -- Reset the color to white for other cells
                    end
                    love.graphics.rectangle("fill", xPos, yPos, cellSize, cellSize)
                    love.graphics.setColor(1, 1, 1)
                elseif cell == "O" then
                    if enemyAlive then
                        love.graphics.setColor(1, 1, 0) -- Set the color to yellow if the enemy is alive
                    else
                        love.graphics.setColor(0, 0, 0) -- Set the color to black if the enemy is dead
                    end
                    love.graphics.rectangle("fill", xPos, yPos, cellSize, cellSize)
                    love.graphics.setColor(1, 1, 1) -- Reset the color back to white
                end
            end
        end
    end

    -- Draw the number of lives on the screen
    love.graphics.setColor(1, 1, 1) -- Set the color to white for the text
    love.graphics.print("Lives: " .. playerLives, livesX, livesY, 0, fontSize / 12, fontSize / 12)

    -- Draw the player
    local playerPosX = offsetX + (playerX - 1) * cellSize
    local playerPosY = offsetY + (playerY - 1) * cellSize
    love.graphics.draw(playerSprite, playerPosX, playerPosY, 0, cellSize / playerSprite:getWidth(), cellSize / playerSprite:getHeight())

    -- Draw the sword if attacking
    if isAttacking then
        local swordPosX = offsetX + (playerX - 1 + lastMoveX) * cellSize
        local swordPosY = offsetY + (playerY - 1 + lastMoveY) * cellSize
        love.graphics.draw(swordSprite, swordPosX, swordPosY, swordRotation, cellSize / swordSprite:getWidth(), cellSize / swordSprite:getHeight())
    end
    
    -- Draw the enemy if it exists
    if enemyX and enemyY then
        local enemyPosX = offsetX + (enemyX - 1) * cellSize
        local enemyPosY = offsetY + (enemyY - 1) * cellSize
        love.graphics.draw(enemySprite, enemyPosX, enemyPosY, 0, cellSize / enemySprite:getWidth(), cellSize / enemySprite:getHeight())
    end

    -- Draw the "You Died" message if the death message duration is greater than 0
    if deathMessageDuration > 0 then
        
        love.graphics.setColor(1, 0, 0) -- Set the color to red
        love.graphics.printf("You Died!", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "left")
        love.graphics.setColor(1, 1, 1) -- Reset the color back to white
    end

    -- Check for victory condition
    if playerX == exitX and playerY == exitY then
        gameWon = true
        if not gameCompleted then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("You won! Press R to generate a new maze.", 10, 10)
        end
    end

    -- Draw the game over screen
    if gameState == "gameOver" then
        love.graphics.clear(0, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(gameOverMessage, 10, 10)

        -- Draw the "Start Over" button
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight)
        love.graphics.print("Start Over", buttonX + 5, buttonY + 5)

        return -- Stop further drawing
    end

    -- Check if game is completed
    if gameCompleted then
        love.graphics.print("You saved the princess but too bad she already has a bf :(\nGood luck on your next journey!", 10, 10)
        love.graphics.rectangle("line", 10, 60, 100, 30)
        love.graphics.print("Next Journey", 15, 65)
        return -- stop further drawing
    end

end


function movePlayer(dx, dy)
    if gameWon then return end
    local newX = playerX + dx
    local newY = playerY + dy

    -- Check for collision with walls
    local newCell = maze:sub((newY - 1) * (mazeWidth + 1) + newX, (newY - 1) * (mazeWidth + 1) + newX)
    if newCell ~= "#" then
        if newCell == "D" then
            trapDoorTouched = true -- Set trapDoorTouched to true for the specific touched trap door
            playerLives = playerLives - 1 -- Decrease the number of lives by 1
            mazeGrid[newY][newX] = "D" -- Update the maze grid to remove the trap door
            
            -- Alternatively, if you want the trap door to stay after being touched, you can comment out the line above and use the following line instead:
            -- mazeGrid[newY][newX] = "D"

            resetGame() -- Player touched the trap door, reset the game
            return
        elseif newCell == "O" then
            print("notouchy")
            if enemyAlive then
                -- Prevent the player from passing through the door if the enemy is alive
                return
            end
        end
        playerX = newX
        playerY = newY
        elapsedTime = 0 -- Reset the movement cooldown

        lastMoveX = dx -- Save the last move direction
        lastMoveY = dy
    end

    if playerX == chestX and playerY == chestY then
        hasSword = true -- Player found the sword
        mazeGrid[chestY][chestX] = "."
    end

    if gameCompleted then
        love.graphics.print("You saved the princess but too bad she already has a bf :(\nGood luck on your next journey!", 10, 10)
        love.graphics.rectangle("line", 10, 60, 100, 30)
        love.graphics.print("Next Journey", 15, 65)
    end
end


function love.keypressed(key)
    -- Start the sword swing animation
    if key == "g" and hasSword then
        isAttacking = true
        startSwingAnimation()
    end

    -- Only reset the game and generate a new maze if the game is won and not completed
    if gameWon and not gameCompleted and key == "r" then
        gameWon = false
        gameCompleted = false
        generateMaze()
        playerX, playerY = initialPlayerX, initialPlayerY
    end
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' and gameState == 1 then
        -- Stop the title screen music
        titleMusic:stop()
        gameState = 2
    end
end


function love.keyreleased(key)
    -- Set isAttacking to false when the attack button is released
    if key == "g" then
        isAttacking = false
        swordRotation = 0
    end
end


function love.mousepressed(x, y, button, istouch, presses)
    if not gameStart then
        if x > 10 and x < 110 and y > 60 and y < 90 then
            -- Start the game
            gameStart = true
            startScreenMusic:stop()
            currentMazeIndex = 0 -- Ensure the first maze is loaded when the game starts
            generateMaze()
        elseif x > 10 and x < 110 and y > 100 and y < 130 then
            -- Show the instructions
            showInstructions = true
        end
    elseif gameCompleted and x > 10 and x < 110 and y > 60 and y < 90 then
        -- Reset the game to the start screen
        gameCompleted = false
        gameStart = false
        gameWon = false  -- Reset gameWon
        currentMazeIndex = 0
        showInstructions = false
        -- No need to call generateMaze here as it will be called when the game starts
    end

    if gameState == "gameOver" then
        if x > buttonX and x < buttonX + buttonWidth and y > buttonY and y < buttonY + buttonHeight then
            -- Reset the game to the start screen
            gameState = 1 -- Reset the game state to the start screen
            playerLives = 2 -- Reset the player lives
            gameStart = false
            gameWon = false
            currentMazeIndex = 0
            showInstructions = false
            generateMaze()
        end
    end
end








