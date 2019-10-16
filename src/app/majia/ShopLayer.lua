--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CardSprite = require "app.majia.CardSprite"
local MessageLayer = require "app.majia.MessageLayer"
ShopLayer = class("ShopLayer",function()
    return cc.Layer:create()
end)

ShopLayer.pos = { x = 200, y = 530}

ShopLayer.txt = "注: 当已解锁的卡牌足够多时,出战的卡牌最多可选6张，但出战卡牌最少需要4张"

local plistName = "majia/images/game/card.plist"

function ShopLayer:ctor()
     local layerColor = CCLayerColor:create(ccc4(0,0,0, 150),display.width,display.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    self:addChild(layerColor)
    layerColor:setOpacity(200)

    if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded(plistName) then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistName)
    end

    local btn_close = ccui.Button:create("majia/images/game/Button_close.png", "majia/images/game/Button_close.png", "", 0)
    btn_close:addTo(layerColor)
    btn_close:setPosition(cc.p(85, 560))
    btn_close:addTouchEventListener(function(sender , event)    
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            self:removeFromParent()
        end
    end)

    local txt = cc.Label:createWithTTF(ShopLayer.txt, "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(510, 40))
    txt:addTo(layerColor)

    local userCard = cc.UserDefault:getInstance():getStringForKey("userCard")  
    local cardCount = cc.UserDefault:getInstance():getIntegerForKey("cardCount")
    if cardCount < 1 then
        cardCount = 5
        userCard = self:toTableM('01.02.03.04.05')
        cc.UserDefault:getInstance():setIntegerForKey("cardCount", 5)
        cc.UserDefault:getInstance():setStringForKey("userCard", self:toStringM(userCard))
    else
        userCard = self:toTableM(userCard)
    end
    
    local money = cc.UserDefault:getInstance():getIntegerForKey("myMoney")

    Tab = {}
    for i = 1, 3 do
        for j = 1, 6 do
            local idx = (i - 1) * 6 + j
            local card = CardSprite:createShopCard(idx)
            card.frame:setVisible(false)
            card.sp:setPosition(cc.p(ShopLayer.pos.x + (j - 1) * 130, ShopLayer.pos.y - (i - 1) * 183 ))
            card.sp:addTo(layerColor)     
                   
            card.checkbox = ccui.CheckBox:create("majia/images/game/btn_cz.png","majia/images/game/btn_xx.png")
            card.checkbox:addTouchEventListener(function(sender , event)                                
                if event == ccui.CheckBoxEventType.selected then
                    if card.checkbox:isSelected() then
                        if #userCard <= 4 then
                            self:createTips("最小出战卡组为4张", 2)
                            card.checkbox:setSelected(false)
                        else
                            for k = 1, #userCard do
                                if userCard[k] == idx then
                                    table.remove(userCard, k)
                                    card.frame:setVisible(false)
                                    cc.UserDefault:getInstance():setStringForKey("userCard", self:toStringM(userCard)) 
                                end
                            end
                       
                        end
                    else
                        if #userCard >= 6 then
                            self:createTips("最大出战卡组为6张", 2)
                            card.checkbox:setSelected(true)
                        else
                            userCard[#userCard + 1] = idx
                            card.frame:setVisible(true)
                            cc.UserDefault:getInstance():setStringForKey("userCard", self:toStringM(userCard))  
                        end
                            
                    end                                          
              
                end 

            end)
            card.checkbox:setAnchorPoint(ccp(0.5,0.5))
            card.checkbox:setPosition(cc.p(60, 25))
            card.checkbox:addTo(card.sp)
                                                   
            card.btn_js = ccui.Button:create("majia/images/game/btn_js.png", "majia/images/game/btn_js.png", "", 0)
            card.btn_js:addTouchEventListener(function(sender , event)    
                if event == 2 then
                    if MainScene.isOpenEffect then
                        AudioEngine.playEffect("majia/sound/click.mp3")
                    end
                        
                    if money < card.coin then
                        self:createTips("对不起，钱不够", 2)
                    elseif card.idx ~= cardCount + 1 then
                        self:createTips("你必须解锁前一张", 2)
                    else
                        money = money - card.coin
                        cc.UserDefault:getInstance():setIntegerForKey("myMoney", money)
                        cardCount = cardCount + 1
                        cc.UserDefault:getInstance():setIntegerForKey("cardCount", cardCount)       
                        card.maks:setVisible(false)
                        card.btn_js:setVisible(false)
                    end

                end
            end)
            card.btn_js:setAnchorPoint(ccp(0.5,0.5))
            card.btn_js:setPosition(cc.p(60, 25))
            card.btn_js:addTo(card.sp)

            if idx <= cardCount then
                card.maks:setVisible(false)
                card.btn_js:setVisible(false)
            end


            table.insert(Tab, card)

        end
    end

    for k = 1, #userCard do
        print(userCard[k])
        Tab[userCard[k]].frame:setVisible(true)         
        Tab[userCard[k]].checkbox:setSelected(true)       
  
    end
     
end

-- 读取
function ShopLayer:toTableM(str)
    print(str)
    local temp = {}
    for w in string.gmatch(str, "%d+") do
        temp[#temp + 1] = tonumber(w)   
    end

    return temp
end


-- 提示
function ShopLayer:createTips(txt, time)
    local message = MessageLayer:create()
    self:addChild(message)
    message:setMseeage(txt, time)
end


-- 存储
function ShopLayer:toStringM(table)

    local str = ""
    for i = 1, #table do
        str = str .. tostring(table[i]) .. "."
    end

    return str
end

return ShopLayer



--endregion
