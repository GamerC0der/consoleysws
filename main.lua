function love.load()
    skyImage = love.graphics.newImage("sky.png")
    skyData = love.image.newImageData("sky.png")
    bottomRed, bottomGreen, bottomBlue = skyData:getPixel(0, skyImage:getHeight() - 1)

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    imageScale = math.max(screenWidth / skyImage:getWidth(), screenHeight / skyImage:getHeight())
    verticalOffset = -0.1 * skyImage:getHeight() * imageScale

    scrollPosition = 0
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
end

function love.draw()
    love.graphics.draw(skyImage, -scrollPosition, verticalOffset, 0, imageScale, imageScale)
    love.graphics.draw(skyImage, -scrollPosition + skyImage:getWidth() * imageScale, verticalOffset, 0, imageScale, imageScale)

    love.graphics.setColor(bottomRed, bottomGreen, bottomBlue)
    love.graphics.rectangle("fill", 0, screenHeight * 0.9, screenWidth, screenHeight * 0.1)
    love.graphics.setColor(1, 1, 1)
end