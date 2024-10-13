-- #REGION Selection
-- This doesn't need to be run all the time
local lastSelected
function events.tick()
  if lastSelected ~= selected then
    c.board.highlight
        :setVisible(selected ~= vec(0, 0, 0))
        :setPos(selected * 8)
        :setPrimaryRenderType("TRANSLUCENT_CULL")
        :setPrimaryColor(vectors.hexToRGB("#FFFF55"))
    lastSelected = selected
  end
end

-- #ENDREGION
