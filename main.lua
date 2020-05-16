WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--what we want our virtual rastor to be
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--200 pixels per second
PADDLE_SPEED_ONE = 200
PADDLE_SPEED_TWO = 200

--looks for push.lua file
Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

function love.load()

  math.randomseed(os.time())

  sounds = {
    ['paddle_hit'] = love.audio.newSource('blip.wav', 'static'),
    ['point_scored'] = love.audio.newSource('explosion.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('hurt.wav', 'static'),
  }

  love.window.setTitle('Pong')

  love.graphics.setDefaultFilter('nearest', 'nearest')
  smallFont = love.graphics.newFont('font.ttf', 8)

  --score font
  scoreFont = love.graphics.newFont('font.ttf', 32)
  victoryFont = love.graphics.newFont('font.ttf', 24)

  player1Score = 0
  player2Score = 0
  winningPlayer = 0

  servingPlayer = math.random(2) == 1 and 1 or 2


  paddle1 = Paddle(5, 20, 5, 20)
  paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 20)
  ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 5, 5)

  if (servingPlayer == 1) then
    ball.dx = 100
  else
    ball.dx = -100
  end

  gameState = 'start'

  --push is an object, calling a method inside itself
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    vsync = true,
    resizable = true,
  })

end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)

  if gameState == 'play' then

    if (ball.x <= 0) then
      player2Score = player2Score + 1
      sounds['point_scored']:play()
      if (player2Score >= 3) then
        gameState = 'victory'
        winningPlayer = 2
      else
        gameState = 'serve'
      end
      ball:reset()
      ball.dx = 100
      servingPlayer = 1
    end
    if (ball.x >= VIRTUAL_WIDTH - 4) then
      player1Score = player1Score + 1
      sounds['point_scored']:play()
      if (player1Score >= 3) then
        gameState = 'victory'
        winningPlayer = 1
      else
        gameState = 'serve'
      end
      ball:reset()
      ball.dx = -100
      servingPlayer = 1
    end
  end

  if ball:collide(paddle1) then
    ball.dx = -ball.dx
    sounds['paddle_hit']:play()
  end

  if ball:collide(paddle2) then
    ball.dx = -ball.dx
    sounds['paddle_hit']:play()
  end

  if (ball.y <= 0) then
    ball.dy = -ball.dy
    ball.y = 0
    sounds['wall_hit']:play()
  end

  if (ball.y >= VIRTUAL_HEIGHT - 4) then
    ball.dy = -ball.dy
    ball.y = VIRTUAL_HEIGHT - 4
    sounds['wall_hit']:play()
  end

  paddle1:update(dt)
  paddle2:update(dt)

  if love.keyboard.isDown('w') then
    paddle1.dy = -PADDLE_SPEED_ONE
    --player1Y = math.max(0, player1Y - PADDLE_SPEED_ONE*dt)
  elseif love.keyboard.isDown('s') then
    paddle1.dy = PADDLE_SPEED_ONE
    --player1Y = math.min(player1Y + PADDLE_SPEED_ONE*dt, VIRTUAL_HEIGHT - 20)
  else
    paddle1.dy = 0
  end

  if love.keyboard.isDown('up') then
    paddle2.dy = -PADDLE_SPEED_TWO
    --player2Y = math.max(0, player2Y - PADDLE_SPEED_TWO*dt)
  elseif love.keyboard.isDown('down') then
    paddle2.dy = PADDLE_SPEED_TWO
    --player2Y = math.min(player2Y + PADDLE_SPEED_TWO*dt, VIRTUAL_HEIGHT - 20)
  else
    paddle2.dy = 0
  end

  if (gameState == 'play') then
    ball:update(dt)
  end

end

function love.keypressed(key)
  if (key == 'escape') then
    love.event.quit()
  elseif (key == 'enter' or key == 'return') then
    --for macs is return, windows is enter
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'victory' then
      gameState = 'start'
      player1Score = 0
      player2Score = 0
    elseif gameState == 'serve' then
      gameState = 'play'
    end
  end
end

function love.draw()

  --push is like a switch, switch on to draw it the push way
  push:apply('start')

  --only takes in value between 0 and 1
  love.graphics.clear(40/255, 45/255, 52/255, 255/255)
  love.graphics.setFont(smallFont)

  if (gameState == 'start') then
    love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Play!", 0, 20, VIRTUAL_WIDTH, 'center')
  elseif (gameState == 'serve') then
    love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Play!", 0, 20, VIRTUAL_WIDTH, 'center')
  elseif (gameState == 'victory') then
    love.graphics.setFont(victoryFont)
    love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press Enter to reset!", 0, 42, VIRTUAL_WIDTH, 'center')
  end



  -- font size is 12 pixels, so -6 gets the font in the middle of screen.
  -- all things in love are drawn relative to top left

  displayScore()

  --ball
  ball:render()

  --paddles
  paddle1:render()
  paddle2:render()

  displayFPS()

  push:apply('end')

end

function displayFPS()
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.setFont(smallFont)
  --.. is the string concatenation operator
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
  love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)
end
