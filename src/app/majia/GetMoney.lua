GetMoney = class("GetMoney",function()
    return cc.Layer:create()
end)

function GetMoney:ctor()
    local layerColor = CCLayerColor:create(ccc4(0,0,0, 150),display.width,display.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    self:addChild(layerColor)
    layerColor:setOpacity(200)

    local scX = display.width/layerColor:getContentSize().width
    local scY = display.height/layerColor:getContentSize().height
    layerColor:setScaleX(scX)
    layerColor:setScaleY(scY)
    
    local bg = cc.Sprite:create("majia/img/getmoney.png")
    bg:setPosition(cc.p(display.cx, display.cy))
    layerColor:addChild(bg)

    local btn_get = ccui.Button:create("majia/img/btn_get.png","","" )
    btn_get:setPosition(display.cx, 230)
    btn_get:addTouchEventListener(function(sender , event)
        if event==2 then
            self:removeFromParent()
        end
    end)
    self:addChild(btn_get)
   
end

return GetMoney
