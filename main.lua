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
end

function love.draw()
    love.graphics.draw(skyImage, -scrollPosition, verticalOffset, 0, imageScale, imageScale)
    love.graphics.draw(skyImage, -scrollPosition + skyImage:getWidth() * imageScale, verticalOffset, 0, imageScale, imageScale)

    love.graphics.setColor(bottomRed, bottomGreen, bottomBlue)
    love.graphics.rectangle("fill", 0, screenHeight * 0.9, screenWidth, screenHeight * 0.1)
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(fighterImage, fighterX - (fighterImage:getWidth() * 0.3) / 2, fighterY, 0, 0.3, 0.3)

    for _, bullet in ipairs(bullets) do
        love.graphics.draw(fireballImage, bullet.x - fireballImage:getWidth() / 24, bullet.y - fireballImage:getHeight() / 24, 0, 1/12, 1/12)
    end
end