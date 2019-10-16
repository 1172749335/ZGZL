GameRule = class("GameRule",function()
    return cc.Layer:create()
end)

function GameRule:ctor()
    local layerColor = CCLayerColor:create(ccc4(0,0,0, 150),display.width,display.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    self:addChild(layerColor)
    layerColor:setOpacity(200)

    local scX = display.width/layerColor:getContentSize().width
    local scY = display.height/layerColor:getContentSize().height
    layerColor:setScaleX(scX)
    layerColor:setScaleY(scY)   
     
    local bg = cc.Sprite:create("majia/img/rule.png")
    bg:setPosition(cc.p(display.cx, display.cy))
    layerColor:addChild(bg)

    local isNext = false

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
function GameRule:createMaskLayer()

end
return GameRule
