
local drone = component.proxy(component.list("drone")())
local nav = component.proxy(component.list("navigation")())

-- conifg
local entrance_len_x = -3
local entrance_len_z = 0
local entrance_len_y = 0

-- entrance y axis value
-- note the y is world y not waypoint y
local farm_data = {
  { y = 117, down = 6, downOffset = -1 },
  { y = 111, down = 6, downOffset = 1 },
  { y = 107, down = 6, downOffset = -1 },
  { y = 101, down = 6, downOffset = 1 },
  { y = 97, down = 6, downOffset = -1 },
  { y = 91, down = 6, downOffset = 1 },
  { y = 87, down = 6, downOffset = -1 },
  { y = 81, down = 6, downOffset = 1 }
}

local farm_w, farm_h = 16, 11

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

function move(x, y, z, absolute, error_limit)
  local absolute = absolute or false
  local error_limit = error_limit or 0.1
  if absolute then
    correctionXYZ()
    x, y, z = x - nav_x, y - nav_y, z - nav_z
  end

  drone.move(x, y, z)
  while drone.getOffset() > error_limit or drone.getVelocity() > 0.01 do
    drone.setStatusText(tostring(drone.getOffset()))
    computer.pullSignal(0.2)
  end
end

function reverse(xyz)
  return { x = -xyz.x, y = -xyz.y, z = -xyz.z}
end

-- axis1 always at same level, length is farm_w
-- axis2 like a stairs, length is farm_h
-- increase is a vector
-- ex: increase_axis1 = { x = 1, y = 0, z = 0 }
-- inc1: increase axis1
-- inc2: increase axis2

function farming(inc1, inc2, stair_down_axis2, stair_offset)
  drone.move(farm_offset_x, 0 , farm_offset_z)
  local delay = 0.2
  drone.select()
  for axis2 = 1, farm_h, 1
  do
    drone.place(0)
    for axis1 = 1, farm_w - 1, 1
    do
      drone.move(inc1.x, inc1.y, inc1.z)
      computer.pullSignal(delay)
      drone.place(0)
    end
    inc1 = reverse(inc1)

    if axis2 ~= farm_h then
      drone.move(inc2.x, inc2.y, inc2.z)
      computer.pullSignal(delay)
    end

    if axis2 == stair_down_axis2 then
      drone.move(0, stair_offset, 0)
      computer.pullSignal(delay)
    end
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
  for key, value in pairs(farm_data) do
    -- set height
    drone.setLightColor(0xff0000)
    move(wp_x, value.y + 0.5, wp_z, true)

    -- into farm
    drone.setLightColor(0x00ff00)
    move(entrance_len_x, entrance_len_y, entrance_len_z)

    -- farm
    savePos()
    farming({ x = -1, y = 0, z = 0 }, { x = 0, y = 0, z = -1 }, value.down, value.downOffset)
    restorePos()

    -- out farm
    drone.setLightColor(0x0000ff)
    move(-entrance_len_x, -entrance_len_y, -entrance_len_z)
  end
end

init()
traversingFram()
