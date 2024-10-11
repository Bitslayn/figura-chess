-- Define the chessboard model and anchor it to world
c = models.chess.chess
c.board:setParentType("WORLD")

function initializePieces()
  -- Create copies of models
  for UUID, data in pairs(chessPieces) do
    local texture
    local rotation
    if data.color == "white" then
      texture = "textures/block/stripped_birch_log.png"
      rotation = 0
    else
      texture = "textures/block/stripped_dark_oak_log.png"
      rotation = 180
    end
    c.board[data.piece]:copy(UUID):moveTo(c.board):setVisible(true):setPrimaryTexture("Resource",
      texture):setRot(0, rotation, 0)
  end
  -- Move models
  for row, list in pairs(chessIndex) do
    for column, UUID in pairs(list) do
      c.board[UUID]:setPos((string.byte(row) - 64) * 8, 0, column * 8)
    end
  end
end

-- Function that moves models from the chess table to the side
-- Removes UUID table entry from chessboard
---@param uuid string
function take(uuid)
  if chessPieces[uuid] then
    -- Remove from chessIndex
    local breakTable = false
    for column, table in pairs(chessIndex) do
      for row, u in pairs(table) do
        if uuid == u then
          breakTable = true
          chessIndex[column][row] = nil
          break
        end
      end
      if breakTable then break end
    end
    -- Insert uuid into designated table
    if chessPieces[uuid].color == "white" then
      table.insert(takenPiecesWhite, uuid)
      -- Move pieces to sides of board
      for i, u in pairs(takenPiecesWhite) do
        c.board[u]:setPos((7 - i + (#takenPiecesWhite / 2)) * 8, -1.75, (-1 - math.random()) * 8)
            :setRot(0, math.random(0, 360), 0)
      end
    else
      table.insert(takenPiecesBlack, uuid)
      -- Move pieces to sides of board
      for i, u in pairs(takenPiecesBlack) do
        c.board[u]:setPos((2 + i - (#takenPiecesBlack / 2)) * 8, -1.75, (10 + math.random()) * 8)
            :setRot(0, math.random(0, 360), 0)
      end
    end
  end
end

-- ---@param x number
-- ---@param z number
-- ---@param dx number
-- ---@param dz number
-- function move(x, z, dx, dz)
--   pings.move(string.char(x * 8 + z - 9), string.char(dx * 8 + dz - 9))
-- end

-- ----@param from string
-- ----@param to string
function pings.move(x, z, dx, dz)
  -- local x, z, dx, dz

  -- Piece that's moving
  local uuid = chessIndex[string.char(x + 64)][z]
  -- Piece in destination
  local existing = chessIndex[string.char(dx + 64)][dz]
  if uuid then
    if existing then
      -- If there's a piece in destination, take
      take(existing)
      print(pieceNotation[chessPieces[uuid].piece].symbol ..
        " " .. pieceNotation[chessPieces[uuid].piece].letter .. "x" .. string.char(dx + 97) .. dz)
    else
      print(pieceNotation[chessPieces[uuid].piece].symbol ..
        " " .. pieceNotation[chessPieces[uuid].piece].letter .. string.char(dx + 97) .. dz)
    end
    -- Clear last position
    chessIndex[string.char(x + 64)][z] = nil
    -- Move piece to new space
    chessIndex[string.char(dx + 64)][dz] = uuid
    c.board[uuid]:setPos(vec(dx, 0, dz) * 8)
    -- Sets piece as moved
    chessPieces[uuid].hasMoved = true
    -- Play sounds :3
    sounds:playSound("minecraft:block.wood.place", c.board[uuid]:partToWorldMatrix()[4].xyz, 0.5, 2)
    sounds:playSound("minecraft:block.wooden_button.click_on",
      c.board[uuid]:partToWorldMatrix()[4].xyz, 0.5, 2)

    -- Pawn promotion
    if chessPieces[uuid].piece == "pawn" and (dx == 1 or dx == 8) then
      print("Pawn promoting!")
    end
  end
end

---@param x number?
---@param z number?
function pings.select(x, z)
  if x and z then
    uuid = chessIndex[string.char(x + 64)][z]
    if uuid then
      selected = vec(x, 0, z)
      print("Selected " ..
        chessPieces[uuid].color ..
        " " .. chessPieces[uuid].piece .. " at " .. string.char(x + 64) .. z)
    else
      selected = vec(0, 0, 0)
      print("Deselected")
    end
  else
    selected = vec(0, 0, 0)
    print("Deselected")
  end
end
