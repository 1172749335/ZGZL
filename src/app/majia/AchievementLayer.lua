AchievementLayer = class("AchievementLayer",function()
    return cc.Layer:create()
end)

local size = cc.Director:getInstance():getWinSize()
function AchievementLayer:ctor()
    self:createMaskLayer()

    local bg = cc.Sprite:create("majia/img/AchievementLayerBG.png")
    bg:setPosition(cc.p(display.cx, size.height/2))
    self:addChild(bg)


    local identity = cc.UserDefault:getInstance():getIntegerForKey("identity")  
    if identity < 1 then
        identity = 1
    end
    local AchievementLayer = cc.Sprite:create("majia/img/AchievementLayer"..identity ..".png")
    AchievementLayer:setPosition(cc.p(display.cx - 150, size.height/2 + 70))
    self:addChild(AchievementLayer)

    -- 身份
    local identityTb = {"士兵", "统帅", "团长", "城主", "领主"}
    local txt = cc.Label:createWithTTF("身份:" .. identityTb[identity], "majia/font/font.ttf", 40)
    txt:setPosition(cc.p(display.cx , size.height/2 + 70))
    self:addChild(txt)

    -- 胜利场次
    local victoryField = cc.UserDefault:getInstance():getIntegerForKey("victoryField")
    if victoryField < 1 then
        victoryField = 0
    end

    -- 最高连胜
    local victoryAlways = cc.UserDefault:getInstance():getIntegerForKey("victoryAlways")
    if victoryAlways < 1 then
        victoryAlways = 0
    end

    -- 总场次
    local totalField = cc.UserDefault:getInstance():getIntegerForKey("totalField")
    if totalField < 1 then
        totalField = 0
    end

    -- 胜率
    local res = tonumber(victoryField) / tonumber(totalField) * 100
    res = math.floor(res)
    if totalField < 1 then
        res = 100
    end

    -- 胜利场数
    local txt = cc.Label:createWithTTF("胜利场数:" .. victoryField, "majia/font/font.ttf", 30)
    txt:setPosition(cc.p(display.cx - 200 , size.height/2))
    txt:setAnchorPoint(0, 0.5)
    self:addChild(txt)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF)) 

    -- 胜率
    local txt = cc.Label:createWithTTF("胜率:" ..  res .. "%", "majia/font/font.ttf", 30)
    txt:setPosition(cc.p(display.cx - 200, size.height/2 - 100))
    txt:setAnchorPoint(0, 0.5)
    self:addChild(txt)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF)) 

    -- 连胜场数
    --[[local txt = cc.Label:createWithTTF("连胜场数:" .. victoryAlways, "majia/font/font.ttf", 30)
    txt:setPosition(cc.p(display.cx + 40 , size.height/2))
    txt:setAnchorPoint(0, 0.5)
    self:addChild(txt)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF))]] 

    -- 总场数
    local txt = cc.Label:createWithTTF("总场数:" .. totalField, "majia/font/font.ttf", 30)
    --txt:setPosition(cc.p(display.cx + 40, size.height/2 - 100))
    txt:setPosition(cc.p(display.cx + 40 , size.height/2))
    txt:setAnchorPoint(0, 0.5)
    self:addChild(txt)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF)) 


end
function AchievementLayer:createMaskLayer()

    local layerColor = CCLayerColor:create(ccc4(0,0,0, 150),size.width,size.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    self:addChild(layerColor)
    layerColor:setOpacity(200)

    local function onTouchBegan( touch, event )
        return true
    end 
    local function onTouchEnded( touch, event )
        self:removeFromParent()
    end 

    local function onTouchMoved(touch, event)

    end

    local listener1 = cc.EventListenerTouchOneByOne:create()  --创建一个单点事件监听
    listener1:setSwallowTouches(true)  --是否向下传递
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher() 
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layerColor) --分发监听事件
end
return AchievementLayer
