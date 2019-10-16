

WebLayer = class("WebLayer",function()
    return cc.Layer:create()
end)

WebLayer.url = ""
WebLayer.titleId = 1
WebLayer.title = {"技术支持" , "个人隐私"}
local size = cc.Director:getInstance():getWinSize()
function WebLayer:ctor()
    self:createMaskLayer()

    local bg = cc.Sprite:create("majia/img/webViewBg.png")
    --bg:setAnchorPoint(cc.p(0,0.5))
    bg:setPosition(cc.p(display.cx, size.height/2))
    self:addChild(bg)

    local txt = cc.Label:createWithTTF(WebLayer.title[WebLayer.titleId], "majia/font/font.ttf", 40)
    txt:setPosition(cc.p(display.cx, 556))
    self:addChild(txt)

    local platform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_ANDROID ~= platform and cc.PLATFORM_OS_IPHONE ~= platform then
        return
    end

    local webView1 = ccexp.WebView:create()
    webView1:setContentSize(cc.size(bg:getContentSize().width-60 , bg:getContentSize().height-60))
    webView1:setPosition(cc.p(bg:getContentSize().width/2 + 4 , bg:getContentSize().height/2 - 25))
    webView1:loadURL(WebLayer.url)
    bg:addChild(webView1,1000)



    self:runAction(cc.Sequence:create(cc.DelayTime:create(1) , cc.CallFunc:create(function()
      --  self:removeFromParent()
    end) ) )
end
function WebLayer:createMaskLayer()

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
return WebLayer
