local C = class("RoomItemClass")
RoomItemClass = C

--游戏房间列表csb配置
C.ROOMS_CSB = {
    [GAMEID_BRNN] = {
            "base/rooms/BrnnRoom_1.csb",
            "base/rooms/BrnnRoom_2.csb",
        },
    [GAMEID_DDZ] = {
            "base/rooms/DdzRoom_1.csb",
            "base/rooms/DdzRoom_2.csb",
            "base/rooms/DdzRoom_3.csb",
        },
    [GAMEID_CPDDZ] = {
            "base/rooms/CpddzRoom_1.csb",
            "base/rooms/CpddzRoom_2.csb",
            "base/rooms/CpddzRoom_3.csb",
        },
    [GAMEID_QZNN] = {
            "base/rooms/QznnRoom_1.csb",
            "base/rooms/QznnRoom_2.csb",
            "base/rooms/QznnRoom_3.csb",
            "base/rooms/QznnRoom_4.csb",
        },
    [GAMEID_ZJH] = {
            "base/rooms/ZjhRoom_1.csb",
            "base/rooms/ZjhRoom_2.csb",
            "base/rooms/ZjhRoom_3.csb",
            "base/rooms/ZjhRoom_4.csb",
        },
    [GAMEID_FISH] = {
            "base/rooms/JsbyRoom_1.csb",
            "base/rooms/JsbyRoom_2.csb",
            "base/rooms/JsbyRoom_3.csb",
            "base/rooms/JsbyRoom_4.csb",
        },
    [GAMEID_FRUIT] = {
            "base/rooms/FruitRoom_1.csb",
            "base/rooms/FruitRoom_2.csb",
            "base/rooms/FruitRoom_3.csb",
            "base/rooms/FruitRoom_4.csb",
        },
    [GAMEID_FRUIT] = {
            "base/rooms/FruitRoom_1.csb",
            "base/rooms/FruitRoom_2.csb",
            "base/rooms/FruitRoom_3.csb",
            "base/rooms/FruitRoom_4.csb",
        },
    [GAMEID_BRQZNN] = {
        "base/rooms/BrqznnRoom_1.csb",
        "base/rooms/BrqznnRoom_2.csb",
        "base/rooms/BrqznnRoom_3.csb",
        "base/rooms/BrqznnRoom_4.csb",
    },
    [GAMEID_JSMJ] = {
        "base/rooms/JsmjRoom_1.csb",
        "base/rooms/JsmjRoom_2.csb",
        "base/rooms/JsmjRoom_3.csb",
        "base/rooms/JsmjRoom_4.csb",
    },
    [GAMEID_HB] = {
        "base/rooms/HbRoom_1.csb",
    },
    [GAMEID_XLCH] = {
            "base/rooms/ZjhRoom_1.csb",
            "base/rooms/ZjhRoom_2.csb",
            "base/rooms/ZjhRoom_3.csb",
            "base/rooms/ZjhRoom_4.csb",
        },
}

C.node = nil
C.roomIndex = 1
C.roomInfo = nil
C.callback = nil
C.matchImg = nil
C.matchLightImg = nil

function C:ctor(roomIndex, roomInfo, callback)
    self.roomIndex = roomIndex
    self.roomInfo = roomInfo
    self.callback = callback
    self.node = ccui.Layout:create()
    self.node:setContentSize(cc.size(230, 338))
    self.node:setAnchorPoint(cc.p(0.5, 0))
    self:initUI()
end

function C:initUI()
    if self.roomInfo == nil then
        return
    end
    local roomResArr = self.ROOMS_CSB[self.roomInfo.gameid]
    if roomResArr == nil or #roomResArr == 0 then
        return
    end
    local index = self.roomIndex
    if index < 1 then
        index = 1
    end
    if index > #roomResArr then
        index = #roomResArr
    end
    local roomNode = cc.CSLoader:createNode(roomResArr[index])
    self.matchImg = roomNode:getChildByName("match_img")
    self.matchLightImg = self.matchImg:getChildByName("light_img")
    roomNode:setPosition(cc.p(115, 169))
    self.node:addChild(roomNode)
    self:hideMatching()

    local btn = ccui.Layout:create()
    btn:setTouchEnabled(true)
    btn:setContentSize(cc.size(230, 338))
    self.node:addChild(btn)
    btn:onTouch(
        function(event)
            self:onTouchBtn(event)
        end
    )

    if self.roomInfo.gameid == GAMEID_BRNN then
        return
    end

    --底分
    local difenLabel = roomNode:getChildByName("difen_label")
    local num = 0.001
    if self.roomInfo.name ~= "体验场" then
        local str = string.gsub(self.roomInfo.name, "底分", "")
        num = tonumber(str)
        local difenStr = string.format("%0.0f元底分", num)
        if num < 1 then
            difenStr = tostring(num).."元底分"
        end
        if self.roomInfo.gameid == GAMEID_FISH then
            difenStr = string.gsub(difenStr,"底分","炮场")
        end
        difenLabel:setString(difenStr)
    else
        difenLabel:setString(self.roomInfo.name)
    end
    
    --入场限制
    local limitLabel = roomNode:getChildByName("limit_label")
    local text = "入场限制"..string.format("%0.0f元", self.roomInfo.money / MONEY_SCALE)
    limitLabel:setString(text)

    if self.roomInfo.gameid == GAMEID_FISH then
        --炮倍
        local paobeiImg = roomNode:getChildByName("paobei_img")
        local paobeiLabel = paobeiImg:getChildByName("label")
        local paobeiString = tostring(num/10).."-"..tostring(num).."元"
        if self.roomInfo.name == "体验场" then
            paobeiString = num .."元"
        end
        paobeiLabel:setString(paobeiString)
        local x = -(paobeiLabel:getPositionX()+paobeiLabel:getContentSize().width)/2
        paobeiImg:setPositionX(x)
    end
end

function C:onTouchBtn(event)
    if event.name == "began" then
        self.node:setScale(1.05)
    elseif event.name == "moved" then
    elseif event.name == "ended" then
        PLAY_SOUND_CLICK()
        self.node:setScale(1)
        if self.callback then
            self.callback(self.roomInfo)
        end
    elseif event.name == "cancelled" then
        self.node:setScale(1)
    end
end

function C:showMatching()
    if self.matchImg == nil or self.matchLightImg == nil then
        return
    end
    self.matchImg:stopAllActions()
    self.matchLightImg:stopAllActions()
    self.matchImg:setVisible(true)
    local array = {}
    array[#array+1] = cc.CallFunc:create(function()
        self.matchLightImg:setPosition(4,26)
        self.matchLightImg:setVisible(true)
        local arr = {}
        arr[#arr+1] = cc.MoveTo:create(0.5,cc.p(66,26))
        arr[#arr+1] = cc.CallFunc:create(function()
            self.matchLightImg:setVisible(false)
        end)
        self.matchLightImg:runAction(transition.sequence(arr))
    end)
    array[#array+1] = cc.DelayTime:create(1)
    array[#array+1] = cc.ScaleTo:create(0.2,1.2) --0.2秒由最小到最大
    array[#array+1] = cc.ScaleTo:create(0.1,0.9) --0.1秒由最大到第二小
    array[#array+1] = cc.ScaleTo:create(0.1,1.1) --0.1秒由第二小到第二大
    array[#array+1] = cc.ScaleTo:create(0.1,1) --0.1秒由第二大到正常
    array[#array+1] = cc.DelayTime:create(4)
    local action = transition.sequence(array)
    self.matchImg:runAction(cc.RepeatForever:create(action))
end

function C:hideMatching()
    if self.matchImg == nil or self.matchLightImg == nil then
        return
    end
    self.matchImg:stopAllActions()
    self.matchLightImg:stopAllActions()
    self.matchImg:setVisible(false)
end

return RoomItemClass

