
local drone = component.proxy(component.list("drone")())
local nav = component.proxy(component.list("navigation")())

local nav_x, nav_y, nav_z

function correctionXYZ()
  nav_x, nav_y, nav_z = nav.getPosition()
end

function move(x, y, z, absolute)
  local absolute = absolute or false

  if absolute then
    correctionXYZ()
    x, y, z = x - nav_x, y - nav_y, z - nav_z
  end

  drone.move(x, y, z)
  while drone.getOffset() > 0.1 or drone.getVelocity() > 0.01 do
    drone.setStatusText(tostring(drone.getOffset()))
    computer.pullSignal(0.2)
  end
end

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
