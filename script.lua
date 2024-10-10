-- Action Wheel
MainPage = action_wheel:newPage()
action_wheel:setPage(MainPage)

local moveBoard = MainPage:newAction()
    :setItem(
    'player_head[profile={properties:[{value:"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYWE5OTA1ZDQzNDBmZTExZmZlNWRlNGFjMjc4MGEwYzM3ZjdmZTI3ZGY5ZjYyMjdiMTlmNjk4MzAwZjdhNzgzZiJ9fX0=",name:textures}]}]')
    :setTitle("Move chess board")
    :onLeftClick(function()
      isMovingBoard = true
    end)
