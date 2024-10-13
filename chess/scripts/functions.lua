-- Define the chessboard model and anchor it to world
c = models.chess.chess
c.board:setParentType("WORLD")

-- Reads from table and creates pieces from it
function initializePieces()
  -- Create copies of models
  for UUID, properties in pairs(chessPieces) do
    local texture
    local rotation
    if properties.color == "white" then
      texture = "textures/block/stripped_birch_log.png"
      rotation = 0
    else
      texture = "textures/block/stripped_dark_oak_log.png"
      rotation = 180
    end
    c.board[properties.piece]:copy(UUID):moveTo(c.board):setVisible(true):setPrimaryTexture(
      "Resource",
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

-- Changes the piece of uuid to the provided piece, for pawn promotion
---@param uuid string
---@param piece "pawn"|"rook"|"knight"|"bishop"|"queen"|"king"
function changePiece(uuid, piece)
  -- Previous piece type
  local previousPiece = chessPieces[uuid].piece

  -- Find piece
  local x, z
  for row, list in pairs(chessIndex) do
    for column, UUID in pairs(list) do
      if uuid == UUID then
        x, z = string.byte(row) - 64, column
        break
      end
    end
    if x and z then
      break
    end
  end

  -- Remove model
  c.board[uuid]:remove()

  -- Modify properties
  chessPieces[uuid].piece = piece

  -- Create model
  local properties = chessPieces[uuid]
  local texture
  local rotation
  if properties.color == "white" then
    texture = "textures/block/stripped_birch_log.png"
    rotation = 0
  else
    texture = "textures/block/stripped_dark_oak_log.png"
    rotation = 180
  end
  c.board[properties.piece]:copy(uuid):moveTo(c.board):setVisible(true):setPrimaryTexture("Resource",
    texture):setRot(0, rotation, 0):setPos(x * 8, 0, z * 8)

  print(pieceNotation[previousPiece].symbol ..
    " " ..
    pieceNotation[previousPiece].letter ..
    string.char(z + 96) ..
    x ..
    "=" ..
    pieceNotation[chessPieces[uuid].piece].letter ..
    " " .. pieceNotation[chessPieces[uuid].piece].symbol)
end

-- Moves a piece from x, z to dx, dz
--- @param x number
--- @param z number
--- @param dx number
--- @param dz number
function pings.move(x, z, dx, dz)
  -- Piece that's moving
  local uuid = chessIndex[string.char(x + 64)][z]
  -- Piece in destination
  local existing = chessIndex[string.char(dx + 64)][dz]
  if uuid then
    if existing then
      -- If there's a piece in destination, take
      take(existing)
      table.insert(moveHistory[chessPieces[uuid].color],
        pieceNotation[chessPieces[uuid].piece].symbol ..
        " " .. pieceNotation[chessPieces[uuid].piece].letter .. "x" .. string.char(dz + 96) .. dx)
      -- Play sounds :3
      sounds:playSound("minecraft:item.axe.strip",
        c.board[uuid]:partToWorldMatrix()[4].xyz, 0.5, 2)
        sounds:playSound("minecraft:block.wood.place", c.board[uuid]:partToWorldMatrix()[4].xyz, 0.5, 2)
        sounds:playSound("minecraft:block.wooden_button.click_on",
          c.board[uuid]:partToWorldMatrix()[4].xyz, 0.5, 2)
    else
      table.insert(moveHistory[chessPieces[uuid].color],
        pieceNotation[chessPieces[uuid].piece].symbol ..
        " " .. pieceNotation[chessPieces[uuid].piece].letter .. string.char(dz + 96) .. dx)
      -- Play sounds :3
      sounds:playSound("minecraft:block.wood.place", c.board[uuid]:partToWorldMatrix()[4].xyz, 0.5, 2)
      sounds:playSound("minecraft:block.wooden_button.click_on",
        c.board[uuid]:partToWorldMatrix()[4].xyz, 0.5, 2)
    end
    -- Clear last position
    chessIndex[string.char(x + 64)][z] = nil
    -- Move piece to new space
    chessIndex[string.char(dx + 64)][dz] = uuid
    c.board[uuid]:setPos(vec(dx, 0, dz) * 8)
    -- Sets piece as moved
    chessPieces[uuid].hasMoved = true

    -- Pawn promotion
    if chessPieces[uuid].piece == "pawn" and (dx == 1 or dx == 8) then
      changePiece(uuid, "queen")
    end
  end
  -- Switch person going and deselect
  colorTurn = colorTurn == "white" and "black" or "white"
  selected = vec(0, 0, 0)
end

-- Sets the selected square on the chess board
---@param x number?
---@param z number?
function pings.select(x, z)
  if x and z then
    uuid = chessIndex[string.char(x + 64)][z]
    if uuid then
      selected = vec(x, 0, z)
    else
      selected = vec(0, 0, 0)
    end
  else
    selected = vec(0, 0, 0)
  end
end
