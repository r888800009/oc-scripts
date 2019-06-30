
local drone = component.proxy(component.list("drone")())
local nav = component.proxy(component.list("navigation")())

-- conifg
local entrance_len_x = -3
local entrance_len_z = 0
local entrance_len_y = 0

-- entrance y axis value
-- note the y is world y not waypoint y
local farm_entrance_data = {
  117, 111, 107, 101, 97, 91, 87, 81
}

-- offset is farmland x: 0 z: 0 relative entrance
local farm_offset_x = 0
local farm_offset_z = 1

local nav_x, nav_y, nav_z
local wp_x, wp_y, wp_z
local wp_range = 256
local wp_name = "Robot Pipe"

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

local s_x, s_y, s_z

function savePos()
  s_x, s_y, s_z = nav.getPosition()
end

function restorePos()
  x, y, z = nav.getPosition()
  if s_y > y then -- y first
    move(x, s_y, z, true, 0.3)
    move(s_x, s_y, z, true, 0.3)
    move(s_x, s_y, s_z, true, 0.3)
  else -- y last
    move(s_x, y, z, true, 0.3)
    move(s_x, y, s_z, true, 0.3)
    move(s_x, s_y, s_z, true, 0.3)
  end
end

function initWaypoint()
  local wps = nav.findWaypoints(wp_range)
  for i = 1, wps.n do
    if wps[i].label == wp_name then
      move(wps[i].position[1], wps[i].position[2], wps[i].position[3])
      correctionXYZ()
      wp_x, wp_y, wp_z = nav.getPosition()
    end
  end
end

function init()
  initWaypoint()
end

function traversingFram()
  for key, value in pairs(farm_entrance_data) do
    -- set height
    drone.setLightColor(0xff0000)
    move(wp_x, value.y + 0.5, wp_z, true)

    -- into farm
    drone.setLightColor(0x00ff00)
    move(entrance_len_x, entrance_len_y, entrance_len_z)

    -- out farm
    drone.setLightColor(0x0000ff)
    move(-entrance_len_x, -entrance_len_y, -entrance_len_z)
  end
end

init()
traversingFram()
