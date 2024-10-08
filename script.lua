-- Action Wheel
MainPage = action_wheel:newPage()
action_wheel:setPage(MainPage)

local moveBoard = MainPage:newAction()
:onLeftClick(function()
  pings.board(
    math.round(player:getPos().x) * 100,
    math.round(player:getPos().y) * 100,
    math.round(player:getPos().z) * 100,
    0
  )
end)
