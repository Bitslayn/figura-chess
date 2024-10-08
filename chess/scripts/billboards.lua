-- Heartbeat
local heartbeat = 10 * 20
local initHeartbeat = 10 * 20
function pings.heartbeat()
  heartbeat = initHeartbeat
end

function events.tick()
  if heartbeat == 0 and not c.board["Billboard"] then
    c.board:newPart("Billboard", "CAMERA"):setPivot(0, 16, 0)
        :newText("Heartbeat"):setText(":ping1:"):setAlignment("CENTER")
  elseif heartbeat ~= 0 and c.board["Billboard"] then
    c.board["Billboard"]:remove()
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