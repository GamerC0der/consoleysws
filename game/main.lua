function love.load()
    gameState = "menu"
    skyImage = love.graphics.newImage("sky.png")
    skyImage:setFilter("nearest", "nearest")
    skyData = love.image.newImageData("sky.png")
    bottomRed, bottomGreen, bottomBlue = skyData:getPixel(0, skyImage:getHeight() - 1)
    fighterImage = love.graphics.newImage("fighter.png")
    enemyImage = love.graphics.newImage("fighter_orange.png")
    fireballImage = love.graphics.newImage("fireball.png")
    
    screenWidth = love.graphics.getWidth() 
    screenHeight = love.graphics.getHeight()
    imageScale = math.max(screenWidth / skyImage:getWidth(), screenHeight / skyImage:getHeight())
    verticalOffset = -0.1 * skyImage:getHeight() * imageScale
    scale = math.min(screenWidth / 800, screenHeight / 600)

    scrollPosition = 0
    fighterX = screenWidth / 2
    fighterY = screenHeight - fighterImage:getHeight() * 0.3 * scale
    bullets = {}
    spacePressedTime = 0
    lastShotTime = 0
    spaceHeld = false

    enemies = {}
    waves = {3, 5, 2, 1}
    currentWave = 1
    waveSpawnTimer = 0

    quests = {
        {
            name = "Aerial Command",
            description = "Move for 2.5s",
            progress = 0,
            maxProgress = 2.5,
            completed = false,
            unlocked = true
        },
        {
            name = "Rapid Fire",
            description = "Shoot 3 times",
            progress = 0,
            maxProgress = 3,
            completed = false,
            unlocked = false
        },
        {
            name = "Total Victory",
            description = "Defeat all enemies",
            progress = 0,
            maxProgress = 11,
            completed = false,
            unlocked = false
        }
    }
    movementTime = 0
    lastMovementTime = 0
    shotsFired = 0
    enemiesDefeated = 0
end

function love.keypressed() gameState = "playing" end

function love.resize(width, height)

    screenWidth = width
    screenHeight = height
    imageScale = math.max(screenWidth / skyImage:getWidth(), screenHeight / skyImage:getHeight()) 
    verticalOffset = -0.1 * skyImage:getHeight() * imageScale
    scale = math.min(screenWidth / 800, screenHeight / 600)
end

function love.update(dt)
    scrollPosition = scrollPosition + 50 * scale * dt
    if scrollPosition >= skyImage:getWidth() * imageScale then
        scrollPosition = scrollPosition - skyImage:getWidth() * imageScale
    end
    if gameState ~= "playing" then return end

    local isMoving = false
    if love.keyboard.isDown("left") then
        fighterX = math.max(fighterImage:getWidth() * 0.15 * scale, fighterX - 200 * scale * dt)
        isMoving = true
    end
    if love.keyboard.isDown("right") then
        fighterX = math.min(screenWidth - fighterImage:getWidth() * 0.15 * scale, fighterX + 200 * scale * dt)
        isMoving = true
    end
    if love.keyboard.isDown("up") then
        fighterY = math.max(0, fighterY - 200 * scale * dt)
        isMoving = true
    end
    if love.keyboard.isDown("down") then
        fighterY = math.min(screenHeight - fighterImage:getHeight() * 0.3 * scale, fighterY + 200 * scale * dt)
        isMoving = true
    end

    if isMoving then
        movementTime = movementTime + dt
    end
    if quests[1].unlocked and not quests[1].completed then
        quests[1].progress = math.min(quests[1].maxProgress, movementTime)
        if movementTime >= quests[1].maxProgress then
            quests[1].completed = true
            quests[2].unlocked = true
            quests[3].unlocked = true
        end
    end

    if love.keyboard.isDown("space") then
        if not spaceHeld then
            spacePressedTime = love.timer.getTime()
            spaceHeld = true
            table.insert(bullets, {x = fighterX, y = fighterY - fighterImage:getHeight() * 0.3 * scale * 0.5})
            lastShotTime = love.timer.getTime()
            shotsFired = shotsFired + 1
        elseif love.timer.getTime() - spacePressedTime > 1.5 and love.timer.getTime() - lastShotTime > 0.15 then
            table.insert(bullets, {x = fighterX, y = fighterY - fighterImage:getHeight() * 0.3 * scale * 0.5})
            lastShotTime = love.timer.getTime()
            shotsFired = shotsFired + 1
        end
    else
        spaceHeld = false
    end

    for i = #bullets, 1, -1 do
        bullets[i].y = bullets[i].y - 400 * scale * dt
        if bullets[i].y < -10 then
            table.remove(bullets, i)
        end
    end

    local bulletsToRemove = {}
    local enemiesToRemove = {}

    for i, bullet in ipairs(bullets) do
        for j, enemy in ipairs(enemies) do
            local shipWidth = fighterImage:getWidth() * 0.3 * scale
            local shipHeight = fighterImage:getHeight() * 0.3 * scale 
            if math.abs(bullet.x - enemy.x) < (shipWidth/2 + 15 * scale) * 2 and math.abs(bullet.y - enemy.y) < shipHeight/2 + 15 * scale then
                table.insert(bulletsToRemove, i)
                table.insert(enemiesToRemove, j)
                break
            end
        end
    end

    for i = #bulletsToRemove, 1, -1 do
        table.remove(bullets, bulletsToRemove[i])
    end
    for i = #enemiesToRemove, 1, -1 do
        table.remove(enemies, enemiesToRemove[i])
        enemiesDefeated = enemiesDefeated + 1
    end

    if #enemies == 0 then
        waveSpawnTimer = waveSpawnTimer + dt
        if waveSpawnTimer >= 1 then
            for i = 1, waves[currentWave % #waves + 1] do
                local enemyX = love.math.random(fighterImage:getWidth() * 0.3 * scale, screenWidth - fighterImage:getWidth() * 0.3 * scale)
                table.insert(enemies, {
                    x = enemyX,
                    initialX = enemyX,
                    y = screenHeight * 0.25,
                    angle = math.pi,
                    time = love.math.random() * math.pi * 2,
                    direction = 1,
                    speedX = love.math.random(-150, 150) * scale,
                    speedY = love.math.random(80, 120) * scale 
                })
            end
            currentWave = currentWave + 1
            waveSpawnTimer = 0
        end

    end

    for _, enemy in ipairs(enemies) do
        enemy.time = enemy.time + dt
        enemy.x = enemy.x + enemy.speedX * dt
        enemy.y = enemy.y + (screenHeight * 0.3 / 30) * dt * 1.5

        local shipWidth = fighterImage:getWidth() * 0.3 * scale
        local leftLimit = enemy.initialX - screenWidth * 0.15
        local rightLimit = enemy.initialX + screenWidth * 0.15
        if enemy.x < leftLimit or enemy.x > rightLimit then
            enemy.speedX = -enemy.speedX
        end
        enemy.x = math.max(leftLimit, math.min(rightLimit, enemy.x))

        if enemy.time % 2 < 1 then
            enemy.speedX = enemy.speedX + (love.math.random() - 0.5) * 100 * dt
            enemy.speedX = math.max(-450 * scale, math.min(450 * scale, enemy.speedX))
        end

        if enemy.y > screenHeight * 0.8 then
            enemy.y = screenHeight * 0.25
            enemy.x = enemy.initialX
        end
    end

    for i, enemy1 in ipairs(enemies) do
        for j, enemy2 in ipairs(enemies) do
            if i ~= j then
                local dx = enemy1.x - enemy2.x
                local dy = enemy1.y - enemy2.y
                local distance = math.sqrt(dx * dx + dy * dy)
                local minDistance = 150 * scale

                if distance < minDistance and distance > 0 then
                    local separation = (minDistance - distance) * 0.5
                    local nx = dx / distance
                    local ny = dy / distance

                    enemy1.x = enemy1.x + nx * separation
                    enemy1.y = enemy1.y + ny * separation
                    enemy2.x = enemy2.x - nx * separation
                    enemy2.y = enemy2.y - ny * separation 
                end
            end
        end
    end

    if quests[2].unlocked and not quests[2].completed then
        quests[2].progress = math.min(quests[2].maxProgress, shotsFired)
        if shotsFired >= quests[2].maxProgress then
            quests[2].completed = true
        end
    end

    if quests[3].unlocked and not quests[3].completed then
        quests[3].progress = math.min(quests[3].maxProgress, enemiesDefeated)
        if enemiesDefeated >= quests[3].maxProgress then
            quests[3].completed = true
        end
    end
end

function love.draw()
    love.graphics.draw(skyImage, -scrollPosition, verticalOffset, 0, imageScale, imageScale)
    love.graphics.draw(skyImage, -scrollPosition + skyImage:getWidth() * imageScale, verticalOffset, 0, imageScale, imageScale)

    if gameState == "menu" then
        love.graphics.setFont(love.graphics.newFont("Jersey10-Regular.ttf", 48))
        love.graphics.printf("Attack", 0, screenHeight/2 - 24, screenWidth, "center")
        love.graphics.printf("Press any key to play", 0, screenHeight - 60, screenWidth, "center")
        love.graphics.setFont(love.graphics.getFont())
        return
    end

    local qx, qy = screenWidth - 220, 10
    local questHeight = quests[2].unlocked and 81 or 40
    local unlockedCount = 0
    for _, quest in ipairs(quests) do
        if quest.unlocked and not quest.completed then
            unlockedCount = unlockedCount + 1
        end
    end
    local totalHeight = 30 + (unlockedCount * questHeight)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", qx, qy, 200, totalHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", qx, qy, 200, totalHeight)
    love.graphics.setFont(love.graphics.newFont("Jersey10-Regular.ttf", 16))
    love.graphics.print("Quest Log", qx + 5, qy + 5)
    love.graphics.setFont(love.graphics.newFont("Jersey10-Regular.ttf", 12))

    local visibleIndex = 0
    for i, quest in ipairs(quests) do
        if quest.unlocked and not quest.completed then
            local questY = qy + 20 + (visibleIndex * questHeight)
            love.graphics.setColor(quest.completed and 0 or 1, 1, quest.completed and 0 or 1)
            love.graphics.print(quest.name, qx + 5, questY + 5)
            love.graphics.print(quest.description, qx + 5, questY + 20)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", qx + 5, questY + 35, 180, 8)
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", qx + 5, questY + 35, 180 * quest.progress / quest.maxProgress, 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", qx + 5, questY + 35, 180, 8)
            visibleIndex = visibleIndex + 1
        end
    end
    love.graphics.setFont(love.graphics.getFont())

    love.graphics.setColor(bottomRed, bottomGreen, bottomBlue)
    love.graphics.rectangle("fill", 0, screenHeight * 0.9, screenWidth, screenHeight * 0.1)
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(fighterImage, fighterX - (fighterImage:getWidth() * 0.3 * scale) / 2, fighterY, 0, 0.3 * scale, 0.3 * scale)

    for _, enemy in ipairs(enemies) do
        love.graphics.draw(enemyImage, enemy.x - (enemyImage:getWidth() * 0.3 * scale) / 2, enemy.y, enemy.angle, 0.3 * scale, 0.3 * scale)
    end

    for _, bullet in ipairs(bullets) do
        love.graphics.draw(fireballImage, bullet.x - fireballImage:getWidth() / (24 / scale), bullet.y - fireballImage:getHeight() / (24 / scale), 0, (1/12) * scale, (1/12) * scale)
    end
end