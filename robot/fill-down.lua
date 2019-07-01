local robot = require("robot")
local sides = require("sides")
local component = require("component")

function fill_line()
  local height_count = 0
  while robot.down() do
    height_count = height_count + 1
  end

  print("height: "..height_count)

  while height_count > 0 do
    height_count = height_count - 1
    robot.up()

    while robot.count() == 0 and robot.select() ~= 16 do
      robot.select(robot.select() + 1)
    end

    robot.placeDown()
  end

  robot.back()
end

for i = 1, 16 do
  robot.select(1)
  fill_line()
end

