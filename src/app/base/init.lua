package.loaded["app.base.hall.HallCore"] = nil
package.loaded["app.base.hall.HallScene"] = nil

require("app.base.hall.HallCore")
require("app.base.hall.HallScene")

function ENTER_HALL()
	HallCore.new():run()
    SCENE_NAME = "Hall"
    eventManager:publish("ExitGame")
end

function ENTER_HALL_ROOM( gameId )
	HallCore.new(gameId):run()
    SCENE_NAME = "Hall"
    eventManager:publish("ExitGame")
end

function ENTER_LOGIN()
	-- LoginCore.new():run()
 --    SCENE_NAME = "Login"
 --    eventManager:publish("ExitGame")
end

function ENTER_GAME(gameId,roomInfo)
	local game = require(GAMECORE_CONFIGS[gameId]).new(roomInfo)

    if game == nil then
        print(GAMECORE_CONFIGS[gameId].." is invalid")
    else
        print(GAMECORE_CONFIGS[gameId].." require success")
    end
    
    SCENE_NAME = "Game"
    game:run()
    return game
end