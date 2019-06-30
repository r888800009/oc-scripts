
local drone = component.proxy(component.list("drone")())

function farming()
  local dx, dy, dz = 1, 0, 0
  local delay = 0.2
  drone.select()
  for x = 0, 5, 1
  do
    drone.place(0)
    for y = 0, 5, 1
    do
      drone.move(dx, dy, dz)
     computer.pullSignal(delay)
      drone.place(0)

    end
    dx, dy, dz = -dx, -dy, -dz

    drone.move(0, 0, 1)
    computer.pullSignal(delay)
  end
end
