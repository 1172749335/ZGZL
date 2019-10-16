SetLayer = class("SetLayer",function()
    return cc.Layer:create()
end)

function SetLayer:ctor()
    print(" setlayer ")
    local layerColor = CCLayerColor:create(ccc4(0,0,0, 200),display.width, display.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    self:addChild(layerColor)
    
    local scX = display.width/layerColor:getContentSize().width
    local scY = display.height/layerColor:getContentSize().height
    layerColor:setScaleX(scX)
    layerColor:setScaleY(scY)
    
    local bg = cc.Sprite:create("majia/img/set_bg.png")
    bg:setPosition(cc.p(display.cx, display.cy - 20))
    self:addChild(bg)

    local musicSpr = cc.Sprite:create("majia/img/music.png")
    musicSpr:setPosition(display.cx - 70 , 230)
    musicSpr:addTo(self)

    local musicBtn = ccui.Button:create( "majia/img/on.png","","" )
    if not MainScene.isOpenMusic then
       musicBtn:loadTextures("majia/img/off.png","majia/img/off.png")
    end
    musicBtn:setPosition(display.cx + 100, 230)
    musicBtn:addTouchEventListener(function(sender , event)
        if event==2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            if MainScene.isOpenMusic then
                MainScene.isOpenMusic = false
                musicBtn:loadTextureNormal("majia/img/off.png")
                cc.UserDefault:getInstance():setBoolForKey("isOpenMusic" , MainScene.isOpenMusic)
                cc.SimpleAudioEngine:getInstance():pauseMusic()
            else
                MainScene.isOpenMusic = true
                musicBtn:loadTextureNormal("majia/img/on.png")
                cc.UserDefault:getInstance():setBoolForKey("isOpenMusic" , MainScene.isOpenMusic)
                cc.SimpleAudioEngine:getInstance():resumeMusic()
            end
        end

    end)
    self:addChild(musicBtn)

--控制音效

    local effectSpr = cc.Sprite:create("majia/img/effects.png")
    effectSpr:setPosition(display.cx - 70 , 300)
    effectSpr:addTo(self)
    local effectBtn = ccui.Button:create( "majia/img/on.png","","" )
    if not MainScene.isOpenEffect then
       effectBtn:loadTextures("majia/img/off.png","majia/img/off.png")
    end
    effectBtn:setPosition(display.cx + 100, 300)
    effectBtn:addTouchEventListener(function(sender , event)
        if event==2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            if MainScene.isOpenEffect then
                MainScene.isOpenEffect = false
                effectBtn:loadTextureNormal("majia/img/off.png")
                cc.UserDefault:getInstance():setBoolForKey("isOpenEffect" , MainScene.isOpenEffect)
                
            else
                MainScene.isOpenEffect = true
                effectBtn:loadTextureNormal("majia/img/on.png")
                cc.UserDefault:getInstance():setBoolForKey("isOpenEffect" , MainScene.isOpenEffect)
                
            end
        end

    end)
    self:addChild(effectBtn)


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
    local eventDispatcher = layerColor:getEventDispatcher() 
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layerColor) --分发监听事件

    --return layerColor

end
return SetLayer
