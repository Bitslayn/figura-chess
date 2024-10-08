require("chess.scripts.modelFunctions")
require("chess.scripts.hitbox")

A, B, C, D, E, F, G, H = "A", "B", "C", "D", "E", "F", "G", "H"

chessPieces = {}                                                                -- {UUID = {piece = "pawn", color = "white"}} Contains the data of every piece in no particular order according to their UUID
takenPiecesWhite, takenPiecesBlack = {}, {}
chessIndex = { A = {}, B = {}, C = {}, D = {}, E = {}, F = {}, G = {}, H = {} } -- {[A] = {[1] = UUID}} Square table of piece UUIDs according to their position on the board

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
    local UUID = client.intUUIDToString(a, b, c, d)
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

    chessIndex[string.char(row + 64)][column] = UUID
    chessPieces[UUID] = {
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
    if player:getName() == "BitslaynAlt" then
      if host:isHost() then
        doRaycast(player) -- Runs raycast returning hitbox variable
      end
      if player:getSwingTime() == 1 and (hitbox.x or hitbox.z) then
        if chessIndex[string.char(hitbox.x + 64)][hitbox.z] then
          take(chessIndex[string.char(hitbox.x + 64)][hitbox.z])
        end
      end
    end
  end
end
