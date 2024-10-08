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
      for row, UUID in pairs(table) do
        if uuid == UUID then
          breakTable = true
          chessIndex[column][row] = {}
          break
        end
      end
      if breakTable then break end
    end
    -- Insert uuid into designated table
    if chessPieces[uuid].color == "white" then
      table.insert(takenPiecesWhite, uuid)
      -- Move pieces to sides of board
      for i, UUID in pairs(takenPiecesWhite) do
        c.board[UUID]:setPos((7 - i + (#takenPiecesWhite / 2)) * 8, -1.75, (-1 - math.random()) * 8):setRot(0, math.random(0, 360), 0)
      end
    else
      table.insert(takenPiecesBlack, uuid)
      -- Move pieces to sides of board
      for i, UUID in pairs(takenPiecesBlack) do
        c.board[UUID]:setPos((2 + i - (#takenPiecesBlack / 2)) * 8, -1.75, (10 + math.random()) * 8):setRot(0, math.random(0, 360), 0)
      end
    end
  end
end

-- Function that moves the piece model from a space to a space
-- Pieces will be named like (Color, Piece, Notation) "wPawnB1" and renamed to the space they move to
-- If the piece is captured, it will be renamed to (Color, Accumulating number) "w1", "w2" irrespective of what piece it is
-- IF BOARD DESYNC, USE removePieces()!!! ALL COPIES MUST BE FLUSHED BEFORE RECOPYING!!!
---@param piece "pawn"|"rook"|"knight"|"bishop"|"queen"|"king"
---@param color "white"|"black"
---@param from Vector2|nil If nil then this is a new piece
---@param to Vector2|nil If nil then this piece is captured
function movePiece(piece, color, from, to)
  -- Function
end

function removePieces()
  -- Function
end

return {
  movePiece = movePiece,
}
