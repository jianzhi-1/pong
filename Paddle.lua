--capitalise the name of classes in lua
--they have access because they are declared behind require class in main
Paddle = Class()

--each class need to have a function to create the object

--colon is equivalent to . in python for class

function Paddle:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dy = 0
end

function Paddle:update(dt)
  if self.dy < 0 then
    self.y = math.max(0, self.y + self.dy*dt)
  elseif self.dy > 0 then
    self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy*dt)
  end
end


function Paddle:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
