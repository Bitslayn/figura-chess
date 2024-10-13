-- #REGION Heartbeat
local heartbeat = 10 * 20
local initHeartbeat = 10 * 20
function pings.heartbeat()
  heartbeat = initHeartbeat
end

function events.tick()
  if heartbeat == 0 and not c.board["Heartbeat"] then
    c.board:newPart("Heartbeat", "CAMERA"):setPivot(0, 16, 0)
        :newText("Heartbeat"):setText(":ping1:"):setAlignment("CENTER")
  elseif heartbeat ~= 0 and c.board["Heartbeat"] then
    c.board["Heartbeat"]:remove()
  end
  if heartbeat > 0 then
    heartbeat = heartbeat - 1
  end
end

local lastHeartbeat = 5 * 20
local heartbeatTimer = 5 * 20
if host:isHost() then
  function events.tick()
    if lastHeartbeat > 0 then
      lastHeartbeat = lastHeartbeat - 1
    else
      pings.heartbeat()
      lastHeartbeat = heartbeatTimer
    end
  end
end

-- #ENDREGION

-- #REGION Permission warning
if not avatar:canRenderOffscreen() then
  c.board:newPart("Warning", "CAMERA"):setPivot(0, 24, 0)
      :newText("Warning"):setText("§4§lEʟᴇᴠᴀᴛᴇ ᴀᴠᴀᴛᴀʀ\nᴘᴇʀᴍɪssɪᴏɴs!"):setAlignment("CENTER")
end

-- #ENDREGION

-- #REGION Sidebar orbit
moveHistory = { white = {}, black = {} }
local sidebarText
function events.tick()
  sidebarText =
      "Player" .. "'s turn!\n" ..
      "00:00" .. "\n" ..
      "\n" ..
      "Move History\n" ..
      "...\n" ..
      "1.  " .. (moveHistory.white[1] or "") .. "   " .. (moveHistory.black[1] or "") .. "\n" ..
      "2.  " .. (moveHistory.white[2] or "") .. "   " .. (moveHistory.black[2] or "") .. "\n" ..
      "3.  " .. (moveHistory.white[3] or "") .. "   " .. (moveHistory.black[3] or "") .. "\n" ..
      "4.  " .. (moveHistory.white[4] or "") .. "   " .. (moveHistory.black[4] or "") .. "\n" ..
      "5.  " .. (moveHistory.white[5] or "") .. "   " .. (moveHistory.black[5] or "") .. "\n" ..
      "6.  " .. (moveHistory.white[6] or "") .. "   " .. (moveHistory.black[6] or "") .. "\n" ..
      "..."

  c.board.sidebar:newText("Sidebar"):setText(sidebarText):setAlignment("LEFT")
      :setBackgroundColor(
        vectors.hexToRGB("#00000040"))
end

function events.render()
  c.board.sidebar:setRot(0, -client:getCameraRot().y - c.board:getRot().y, 0):setScale(0.3 /
    c.board:getScale().x):setPivot(0, 41 / c.board:getScale().x, 0)
end

local viewer = client:getViewer()
function events.world_render(delta)
  local rDelta = viewer:getPos(delta) - c.board:getPos() / 16
  local angle = math.deg(math.atan2(rDelta.x, rDelta.z))
  c.board.sidebar:setPos(vectors.rotateAroundAxis(angle + 90 - c.board:getRot().y, vec(0, 0, 3 * 16),
    0, 1, 0))
end

-- #ENDREGION

-- #REGION Custom nameplates
-- White nameplate
c.whiteNameplate:setParentType("WORLD")
c.whiteNameplate.nametag1:setParentType("CAMERA")
c.whiteNameplate.icon1:setParentType("CAMERA")
c.whiteNameplate.icon1:newText("White"):setText('[{"color":"#ffffff","text":"   ♟"}]'):setAlignment(
  "LEFT"):setScale(0.8):setOutline(true):setSeeThrough(true):setOpacity(0.2)
-- Black nameplate
c.blackNameplate:setParentType("WORLD")
c.blackNameplate.nametag2:setParentType("CAMERA")
c.blackNameplate.icon2:setParentType("CAMERA")
c.blackNameplate.icon2:newText("Black"):setText('[{"color":"#000000","text":"   ♟"}]'):setAlignment(
  "LEFT"):setScale(0.8):setOutline(true):outlineColor(1, 1, 1):setSeeThrough(true):setOpacity(0.2)

function events.tick()
  c.whiteNameplate.nametag1:newText("White"):setText(
    '[{"color":"#ffffff","bold":true,"text":"       Wʜɪᴛᴇ\n"},{"color":"#ffffff","bold":false,"text":"         ' ..
    "00:00" .. '\n         "}]')
      :setAlignment("LEFT"):setScale(0.4):setOutline(true):setSeeThrough(true):setOpacity(0.2)
  -- c.blackNameplate.nametag2:newText("Black"):setText(
  --   '[{"color":"#000000","bold":true,"text":"       Bʟᴀᴄᴋ\n"},{"color":"#000000","bold":false,"text":"         ' ..
  --   "00:00" .. '\n         "}]')
  --     :setAlignment("LEFT"):setScale(0.4):setOutline(true):outlineColor(1, 1, 1):setSeeThrough(true):setOpacity(0.2)
end

function events.entity_init()
  function events.world_render(delta)
    c.whiteNameplate:setPivot((player:getPos(delta) + player:getEyeHeight() * vec(0, 1, 0)) * 16)
    c.whiteNameplate.nametag1:setPivot(c.whiteNameplate:getPivot())
    c.whiteNameplate.icon1:setPivot(c.whiteNameplate:getPivot())
  end
end

-- #ENDREGION
