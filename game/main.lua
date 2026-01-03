function love.load()
    skyImage = love.graphics.newImage("sky.png")
    skyImage:setFilter("nearest", "nearest")
    skyData = love.image.newImageData("sky.png")
    bottomRed, bottomGreen, bottomBlue = skyData:getPixel(0, skyImage:getHeight() - 1)
    fighterImage = love.graphics.newImage("fighter.png")
    fireballImage = love.graphics.newImage("fireball.png")
    

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    imageScale = math.max(screenWidth / skyImage:getWidth(), screenHeight / skyImage:getHeight())
    verticalOffset = -0.1 * skyImage:getHeight() * imageScale

    scrollPosition = 0
    fighterX = screenWidth / 2
    fighterY = screenHeight - fighterImage:getHeight() * 0.3
    bullets = {}
    spacePressedTime = 0
    lastShotTime = 0
    spaceHeld = false

    enemies = {}
    for i = 1, 4 do
        table.insert(enemies, {
            x = screenWidth / 2 + (i - 2) * 60,
            y = screenHeight * 0.05,
            angle = math.pi,
            time = i * 0.5,
            direction = 1
        })
    end
end

function love.resize(width, height)
    screenWidth = width
    screenHeight = height
    imageScale = math.max(screenWidth / skyImage:getWidth(), screenHeight / skyImage:getHeight())
    verticalOffset = -0.1 * skyImage:getHeight() * imageScale
end

function love.update(dt)
    scrollPosition = scrollPosition + 50 * dt
    if scrollPosition >= skyImage:getWidth() * imageScale then
        scrollPosition = scrollPosition - skyImage:getWidth() * imageScale
    end

    if love.keyboard.isDown("left") then fighterX = math.max(fighterImage:getWidth() * 0.15, fighterX - 200 * dt) end
    if love.keyboard.isDown("right") then fighterX = math.min(screenWidth - fighterImage:getWidth() * 0.15, fighterX + 200 * dt) end
    if love.keyboard.isDown("up") then fighterY = math.max(0, fighterY - 200 * dt) end
    if love.keyboard.isDown("down") then fighterY = math.min(screenHeight - fighterImage:getHeight() * 0.3, fighterY + 200 * dt) end

    if love.keyboard.isDown("space") then
        if not spaceHeld then
            spacePressedTime = love.timer.getTime()
            spaceHeld = true
            table.insert(bullets, {x = fighterX, y = fighterY - fighterImage:getHeight() * 0.3 * 0.5})
            lastShotTime = love.timer.getTime()
        elseif love.timer.getTime() - spacePressedTime > 1.5 and love.timer.getTime() - lastShotTime > 0.15 then
            table.insert(bullets, {x = fighterX, y = fighterY - fighterImage:getHeight() * 0.3 * 0.5})
            lastShotTime = love.timer.getTime()
        end
    else
        spaceHeld = false
    end

    for i = #bullets, 1, -1 do
        bullets[i].y = bullets[i].y - 400 * dt
        if bullets[i].y < -10 then
            table.remove(bullets, i)
        end
    end

    local bulletsToRemove = {}
    local enemiesToRemove = {}

    for i, bullet in ipairs(bullets) do
        for j, enemy in ipairs(enemies) do
            local shipWidth = fighterImage:getWidth() * 0.3
            local shipHeight = fighterImage:getHeight() * 0.3
            if math.abs(bullet.x - enemy.x) < shipWidth/2 + 15 and math.abs(bullet.y - enemy.y) < shipHeight/2 + 15 then
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
    end

    for _, enemy in ipairs(enemies) do
        enemy.time = enemy.time + dt
        enemy.x = screenWidth / 2 + math.cos(enemy.time) * 100 + math.sin(enemy.time * 2) * 50
        enemy.y = enemy.y + 100 * dt * enemy.direction
        enemy.angle = math.pi

        local shipWidth = fighterImage:getWidth() * 0.3
        enemy.x = math.max(shipWidth / 2, math.min(screenWidth - shipWidth / 2, enemy.x))

        if enemy.y > screenHeight / 2 and enemy.direction == 1 then
            enemy.direction = -1
        elseif enemy.y < screenHeight * 0.05 and enemy.direction == -1 then
            enemy.direction = 1
            enemy.time = 0
        end
    end

    for i, enemy1 in ipairs(enemies) do
        for j, enemy2 in ipairs(enemies) do
            if i ~= j then
                local dx = enemy1.x - enemy2.x
                local dy = enemy1.y - enemy2.y
                local distance = math.sqrt(dx * dx + dy * dy)
                local minDistance = 150

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
end

function love.draw()
    love.graphics.draw(skyImage, -scrollPosition, verticalOffset, 0, imageScale, imageScale)
    love.graphics.draw(skyImage, -scrollPosition + skyImage:getWidth() * imageScale, verticalOffset, 0, imageScale, imageScale)

    love.graphics.setColor(bottomRed, bottomGreen, bottomBlue)
    love.graphics.rectangle("fill", 0, screenHeight * 0.9, screenWidth, screenHeight * 0.1)
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(fighterImage, fighterX - (fighterImage:getWidth() * 0.3) / 2, fighterY, 0, 0.3, 0.3)

    for _, enemy in ipairs(enemies) do
        love.graphics.draw(fighterImage, enemy.x - (fighterImage:getWidth() * 0.3) / 2, enemy.y, enemy.angle, 0.3, 0.3)
    end

    for _, bullet in ipairs(bullets) do
        love.graphics.draw(fireballImage, bullet.x - fireballImage:getWidth() / 24, bullet.y - fireballImage:getHeight() / 24, 0, 1/12, 1/12)
    end
end