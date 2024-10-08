-- #REGION Inner hitbox
-- #REGION Raycast
raycastBox = { nil, nil }
rate = 0
rateLimit = 4

-- Function calculates hitbox from raycast
-- Ping is ratelimited to every x ticks, and only when hitbox variable awaits change
---@class doRaycast
---@param player Player The player to run the raycast from
function doRaycast(player)
  local boardPos = c.board:getPos() / 16
  local boardAngle = c.board:getRot()

  local eyePos = player:getPos() + vec(0, player:getEyeHeight(), 0)
  local eyeEnd = eyePos + (player:getLookDir() * 4.5)

  -- Absolute board corner coordinates
  local boardCorners = {
    vectors.rotateAroundAxis(-boardAngle.y, vec(-2, 0, -2), vec(0, 1, 0)), -- Lower-left
    vectors.rotateAroundAxis(-boardAngle.y, vec(2, 0, -2), vec(0, 1, 0)),  -- Upper-left
    vectors.rotateAroundAxis(-boardAngle.y, vec(2, 0, 2), vec(0, 1, 0)),   -- Upper-right
    vectors.rotateAroundAxis(-boardAngle.y, vec(-2, 0, 2), vec(0, 1, 0)),  -- Lower-right
  }

  -- Extremes for aabb bounding box
  local maxZ, minX, minZ, maxX =
      math.max(boardCorners[1].z, boardCorners[2].z, boardCorners[3].z, boardCorners[4].z), -- Up
      math.min(boardCorners[1].x, boardCorners[2].x, boardCorners[3].x, boardCorners[4].x), -- Left
      math.min(boardCorners[1].z, boardCorners[2].z, boardCorners[3].z, boardCorners[4].z), -- Down
      math.max(boardCorners[1].x, boardCorners[2].x, boardCorners[3].x, boardCorners[4].x)  -- Right

  -- aabb bounding box
  local hitLocation = {
    {
      vec(minX, 0, minZ) + boardPos,
      vec(maxX, 0.109375, maxZ) + boardPos,
    },
  }
  local aabb, hitPos, side = raycast:aabb(eyePos, eyeEnd, hitLocation)

  if hitPos ~= nil then
    local localHitPos = vectors.rotateAroundAxis(-boardAngle.y, hitPos - boardPos, vec(0, 1, 0))
    local x, z = math.floor((localHitPos.x + 2) * 2) + 1, math.floor((localHitPos.z + 2) * 2) + 1

    local entity = player:getTargetedEntity()
    local block = player:getTargetedBlock()

    if not entity and (not block or block:getPos().y < boardPos.y) and (0 < x and x < 9 and 0 < z and z < 9) then
      if side == "up" and hitPos then
        raycastBox = { x, z }
      end
      if rate == 0 and aabb and (raycastBox[1] ~= hitbox.x or raycastBox[2] ~= hitbox.z) and not isMovingBoard then
        pings.hitbox(tonumber(raycastBox[1] .. raycastBox[2]))
        rate = rateLimit
      end
    elseif raycastBox[1] ~= nil and raycastBox[2] ~= nil and not isMovingBoard then
      -- Nil if inside aabb but outside chess table
      raycastBox = { nil, nil }
      pings.hitbox(nil)
    end
  elseif raycastBox[1] ~= nil and raycastBox[2] ~= nil and not isMovingBoard then
    -- Nil if outside aabb
    raycastBox = { nil, nil }
    pings.hitbox(nil)
  end

  if rate > 0 then
    rate = rate - 1
  end
end

-- #ENDREGION

-- #REGION Hitbox model
-- Hitbox visibility
c.board.hitbox:setVisible(false)

-- Hitbox models
local solid = textures:newTexture("solid", 1, 1):setPixel(0, 0, vectors.vec3(1, 1, 1))
c.board.hitbox
    :setPrimaryTexture("CUSTOM", textures["solid"])
    :setPrimaryRenderType("EMISSIVE_SOLID")
    :setSecondaryRenderType("LINES_STRIP")
c.boardHitbox:setVisible(false):setSecondaryTexture("CUSTOM", textures["solid"])
    :setSecondaryRenderType("EMISSIVE_SOLID")
    :setPrimaryRenderType("LINES_STRIP")
    :setParentType("WORLD")
-- #ENDREGION

-- #REGION Ping
hitbox = { x = nil, z = nil }

-- Hitbox ping synced and used for placement logic
-- Inputs and outputs should always be a two digit number (not a string)
-- Ping hitbox.x, hitbox.y = conjoined XY number
function pings.hitbox(coords)
  if coords ~= nil then
    hitbox = { x = tonumber(string.sub(coords, 1, 1)), z = tonumber(string.sub(coords, 2, 2)) }
    c.board.hitbox:setPos(vec(hitbox.x * 8, 0, hitbox.z * 8)):setVisible(true)
  else
    hitbox = { x = nil, z = nil }
    c.board.hitbox:setVisible(false)
  end
end

-- #ENDREGION
-- #ENDREGION


-- TODO Write docs
-- #REGION Edge hitbox
isMovingBoard, canPlaceBoard = nil, nil

function events.tick()
  for _, player in pairs(world:getPlayers()) do
    if player:getName() == client:getViewer():getName() and player:getName() == "Bitslayn" then
      -- #REGION Raycast
      local isHovering = false

      local boardPos = c.board:getPos() / 16
      local boardAngle = c.board:getRot()

      local eyePos = player:getPos() + vec(0, player:getEyeHeight(), 0)
      local eyeEnd = eyePos + (player:getLookDir() * 4.5)

      -- Absolute board corner coordinates
      local boardCorners = {
        vectors.rotateAroundAxis(-boardAngle.y, vec(-2.25, 0, -2.25), vec(0, 1, 0)), -- Lower-left
        vectors.rotateAroundAxis(-boardAngle.y, vec(2.25, 0, -2.25), vec(0, 1, 0)),  -- Upper-left
        vectors.rotateAroundAxis(-boardAngle.y, vec(2.25, 0, 2.25), vec(0, 1, 0)),   -- Upper-right
        vectors.rotateAroundAxis(-boardAngle.y, vec(-2.25, 0, 2.25), vec(0, 1, 0)),  -- Lower-right
      }

      -- Extremes for aabb bounding box
      local maxZ, minX, minZ, maxX =
          math.max(boardCorners[1].z, boardCorners[2].z, boardCorners[3].z, boardCorners[4].z), -- Up
          math.min(boardCorners[1].x, boardCorners[2].x, boardCorners[3].x, boardCorners[4].x), -- Left
          math.min(boardCorners[1].z, boardCorners[2].z, boardCorners[3].z, boardCorners[4].z), -- Down
          math.max(boardCorners[1].x, boardCorners[2].x, boardCorners[3].x, boardCorners[4].x)  -- Right

      -- aabb bounding box
      local hitLocation = {
        {
          vec(minX, 0, minZ) + boardPos,
          vec(maxX, 0, maxZ) + boardPos,
        },
      }
      local _, hitPos = raycast:aabb(eyePos, eyeEnd, hitLocation)

      local localHitPos
      local x, z
      if hitPos then
        localHitPos = vectors.rotateAroundAxis(-boardAngle.y, hitPos - boardPos, vec(0, 1, 0))
        x, z = math.floor((localHitPos.x + 2) * 2) + 1, math.floor((localHitPos.z + 2) * 2) + 1
      end

      if localHitPos then
        local entity = player:getTargetedEntity()
        local block = player:getTargetedBlock()
        if -2.25 < localHitPos.x and localHitPos.x < 2.25 and -2.25 < localHitPos.z and localHitPos.z < 2.25 and (hitbox.x == nil and hitbox.z == nil) and (not entity or not block) then
          isHovering = true
        else
          isHovering = false
        end
      end
      -- #ENDREGION

      -- #REGION Board moving
      if isMovingBoard == nil or canPlaceBoard == nil then
        isMovingBoard = false
        canPlaceBoard = false
      end
      if isMovingBoard == false then
        c.boardHitbox:setVisible(isHovering)
        c.boardHitbox:setPos(c.board:getPos()):setRot(c.board:getRot())
        if player:getSwingTime() == 1 and player:getPose() == "CROUCHING" and isHovering then
          isMovingBoard = true
        end
      else
        c.boardHitbox:setVisible(true)
        local _, movingHitPos, side = raycast:block(eyePos, eyePos + (player:getLookDir() * 8),
          "OUTLINE",
          "NONE")
        if player:getPose() == "CROUCHING" then
          c.boardHitbox:setRot(vec(0, -player:getRot().y, 0)):setPos(movingHitPos * 16)
        else
          c.boardHitbox:setRot(vec(0, -math.round(player:getRot().y / 22.5) * 22.5, 0)):setPos(
            math.round(movingHitPos.x * 2) * 8,
            math.round(movingHitPos.y * 2) * 8,
            math.round(movingHitPos.z * 2) * 8
          )
        end
        if side == "up" then
          c.boardHitbox:setColor(1, 1, 1)
          canPlaceBoard = true
        else
          c.boardHitbox:setColor(1, 0, 0)
          canPlaceBoard = false
        end
        if player:getSwingTime() == 1 and canPlaceBoard == true then
          pings.board(
            math.round((c.boardHitbox:getPos().x / 16) * 100),
            math.round((c.boardHitbox:getPos().y / 16) * 100),
            math.round((c.boardHitbox:getPos().z / 16) * 100),
            math.round(math.fmod(c.boardHitbox:getRot().y - 90, 360))
          )
          isMovingBoard = false
        end
      end
      -- #ENDREGION
    end
  end
end

-- #REGION Ping
---@param x number
---@param y number
---@param z number
---@param rot number
function pings.board(x, y, z, rot)
  c.board:setPos(vec(x, y, z) / 100 * 16):setRot(vec(0, rot, 0))
end

-- #ENDREGION
-- #ENDREGION

return {
  doRaycast = doRaycast,
}
