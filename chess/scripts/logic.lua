require("chess.scripts.functions")
require("chess.scripts.hitbox")

A, B, C, D, E, F, G, H = "A", "B", "C", "D", "E", "F", "G", "H"

pieceNotation = {
  pawn = { symbol = "♟", letter = "" },
  rook = { symbol = "♜", letter = "R" },
  knight = { symbol = "♞", letter = "N" },
  bishop = { symbol = "♝", letter = "B" },
  queen = { symbol = "♚", letter = "Q" },
  king = { symbol = "♛", letter = "K" },
}

selected = vec(0, 0, 0)
colorTurn = "white"
chessPieces = {}                                                                -- {UUID = {piece = "pawn", color = "white"}} Contains the data of every piece in no particular order according to their UUID
takenPiecesWhite, takenPiecesBlack = {}, {}
chessIndex = { A = {}, B = {}, C = {}, D = {}, E = {}, F = {}, G = {}, H = {} } -- {[A] = {[1] = UUID}} Square table of piece UUIDs according to their position on the board

-- This should never change and is strictly used for setting up the board
chessTable = {
  [8] = { "Br", "Bn", "Bi", "Bq", "Bk", "Bi", "Bn", "Br" }, -- A8 to H8
  [7] = { "Bp", "Bp", "Bp", "Bp", "Bp", "Bp", "Bp", "Bp" },

  [2] = { "Wp", "Wp", "Wp", "Wp", "Wp", "Wp", "Wp", "Wp" },
  [1] = { "Wr", "Wn", "Wi", "Wq", "Wk", "Wi", "Wn", "Wr" }, -- A1 to H1
}
-- Populate chessPieces and chessIndex tables in relation to chessTable
for row, list in pairs(chessTable) do
  for column, piece in pairs(list) do
    local a, b, c, d = client:generateUUID()
    local uuid = client.intUUIDToString(a, b, c, d)
    local p, t

    -- Read piece
    if string.sub(piece, 2, 2) == "p" then
      p = "pawn"
    elseif string.sub(piece, 2, 2) == "r" then
      p = "rook"
    elseif string.sub(piece, 2, 2) == "n" then
      p = "knight"
    elseif string.sub(piece, 2, 2) == "i" then
      p = "bishop"
    elseif string.sub(piece, 2, 2) == "q" then
      p = "queen"
    elseif string.sub(piece, 2, 2) == "k" then
      p = "king"
    end

    -- Read color
    if string.sub(piece, 1, 1) == "W" then
      t = "white"
    else
      t = "black"
    end

    chessIndex[string.char(row + 64)][column] = uuid
    chessPieces[uuid] = {
      piece = p,
      color = t,

      hasMoved = false,
      isDefendingKing = false,
      isAttackingKing = false,
      taken = false,

      -- moves = {},
      -- attacks = {},
    }
  end
end

initializePieces()

function events.tick()
  for _, player in pairs(world:getPlayers()) do
    -- Player whose turn it is
    if player:getName() == "Bitslayn" then
      if host:isHost() then
        doRaycast(player) -- Runs raycast returning hitbox variable
      end
      -- Piece moving/selection logic
      if player:getSwingTime() == 1 and (hitbox.x or hitbox.z) then
        if selected ~= vec(0, 0, 0) and (not chessIndex[string.char(hitbox.x + 64)][hitbox.z] or chessPieces[chessIndex[string.char(hitbox.x + 64)][hitbox.z]].color ~= colorTurn) then
          -- Run if there's a piece selected, and the highlighted space is either an enemy piece or empty
          pings.move(selected.x, selected.z, hitbox.x, hitbox.z)
        elseif chessPieces[chessIndex[string.char(hitbox.x + 64)][hitbox.z]] and chessPieces[chessIndex[string.char(hitbox.x + 64)][hitbox.z]].color == colorTurn then
          -- Run if highlighting a friendly piece
          if hitbox.x == selected.x and hitbox.z == selected.z then
            -- If the selected piece is selected twice, deselect
            pings.select()
          else
            -- If the highlighted piece is a different friendly piece, select that piece instead (If no piece selected, select this piece)
            pings.select(hitbox.x, hitbox.z)
          end
        end
      end
    end
  end
end
