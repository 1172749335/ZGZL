--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--region *.lua
--Date 2019/9/25
--此文件由[BabeLua]插件自动生成
local GameRobotLayer = {}
local CardSprite = require "app.majia.CardSprite"

function GameRobotLayer:createRobot()

    local cardCount = cc.UserDefault:getInstance():getStringForKey("cardCount") 

    local idxTable = {}
    math.randomseed(os.time())    
    table.insert(idxTable, math.random(1, cardCount))    
    while true do
        local idx = math.random(1, cardCount)
        local isHave = false
        for i = 1, #idxTable do
            if idxTable[i] == idx then
                isHave = true
            end
        end

        if not isHave then
             table.insert(idxTable, idx)    
        end

        if #idxTable >= 6 then
            break
        end
    end


    return idxTable
end


return GameRobotLayer
--endregion
