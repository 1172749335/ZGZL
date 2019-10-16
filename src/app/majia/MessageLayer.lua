MessageLayer = class("MessageLayer",function()
    return cc.Layer:create()
end)


local size = cc.Director:getInstance():getWinSize()
function MessageLayer:ctor()
    self:createMaskLayer()
end

local stayTime = 1

function MessageLayer:createMaskLayer()

    local layerColor = CCLayerColor:create(ccc4(0,0,0, 0),size.width,size.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    self:addChild(layerColor)

    local bg = cc.Sprite:create("majia/img/messageBg.png")
    bg:setPosition(cc.p(display.cx, size.height/2))
    self:addChild(bg)

    self.txt = cc.Label:createWithTTF("sss", "majia/font/font.ttf", 30)
    self.txt:setPosition(cc.p(display.cx, display.cy))
    self:addChild(self.txt)
end

function MessageLayer:setMseeage(txt, time)
    if time ~= nil then
        stayTime = time
    end
    self.txt:setString(txt)
    self.txt:runAction(cc.Sequence:create(
        cc.DelayTime:create(stayTime),
        cc.CallFunc:create(function()
            self:removeFromParent()
        end)
    ))
end

return MessageLayer
