function love.load()
    skyImage = love.graphics.newImage("sky.png")
    skyImage:setFilter("nearest", "nearest")
    skyData = love.image.newImageData("sky.png")
    bottomRed, bottomGreen, bottomBlue = skyData:getPixel(0, skyImage:getHeight() - 1)
    fighterImage = love.graphics.newImage("fighter.png")

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    imageScale = math.max(screenWidth / skyImage:getWidth(), screenHeight / skyImage:getHeight())
    verticalOffset = -0.1 * skyImage:getHeight() * imageScale

    scrollPosition = 0
    fighterX = screenWidth / 2
    fighterY = screenHeight - fighterImage:getHeight() * 0.3
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

    if love.keyboard.isDown("left") then fighterX = fighterX - 200 * dt end
    if love.keyboard.isDown("right") then fighterX = fighterX + 200 * dt end
    if love.keyboard.isDown("up") then fighterY = fighterY - 200 * dt end
    if love.keyboard.isDown("down") then fighterY = fighterY + 200 * dt end
end

function love.draw()
    love.graphics.draw(skyImage, -scrollPosition, verticalOffset, 0, imageScale, imageScale)
    love.graphics.draw(skyImage, -scrollPosition + skyImage:getWidth() * imageScale, verticalOffset, 0, imageScale, imageScale)

    love.graphics.setColor(bottomRed, bottomGreen, bottomBlue)
    love.graphics.rectangle("fill", 0, screenHeight * 0.9, screenWidth, screenHeight * 0.1)
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(fighterImage, fighterX - (fighterImage:getWidth() * 0.3) / 2, fighterY, 0, 0.3, 0.3)
end