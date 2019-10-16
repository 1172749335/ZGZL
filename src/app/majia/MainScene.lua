require "app.majia.SetLayer"
require "app.majia.WebLayer"
require "app.majia.GameRule"
require "app.majia.ShopLayer"
require "app.majia.AchievementLayer"
MainScene = class("MainScene", function()
    return cc.Scene:create()
end)

MainScene.isOpenMusic = false
MainScene.isOpenEffect = false

function MainScene:ctor()
   
   -- 入场卡组
   self.userCard = {"qiangbing", "dunbing", "qibing", "zhongjiabing"}
end

function MainScene:onExit( )

end

function MainScene:create()
    local layer = MainScene.new()
    layer:init()
    return layer
end

--返回该类名称
function MainScene:getClassName()
    return "MainScene"
end

function MainScene:init()

    -- 是否是第一次登陆
    if not cc.UserDefault:getInstance():getBoolForKey("noviceguidance", false) then
        cc.UserDefault:getInstance():setIntegerForKey("myMoney", 100)
        cc.UserDefault:getInstance():setBoolForKey("noviceguidance", true)
    end

    self.loadNode = cc.CSLoader:createNode("majia/MainScene.csb")
    self.loadNode:setContentSize(cc.size(display.size.height, display.size.width))
    ccui.Helper:doLayout(self.loadNode)
    self:addChild(self.loadNode, 0)
    
    PLAY_BACKGROUND_MUSIC()--播放音乐
    local isMusic = cc.UserDefault:getInstance():getBoolForKey("isOpenMusic" , true)
    MainScene.isOpenMusic = isMusic
    MainScene.isOpenEffect = cc.UserDefault:getInstance():getBoolForKey("isOpenEffect" , true)
    if not isMusic then
        cc.SimpleAudioEngine:getInstance():pauseMusic()
    else
        cc.SimpleAudioEngine:getInstance():resumeMusic()
    end

    local layer =  self.loadNode:getChildByName("Panel_main")
    local scX = display.width/layer:getContentSize().width
    local scY = display.height/layer:getContentSize().height
    layer:setScaleX(scX)
    layer:setScaleY(scY)

    local CheckBox_music = layer:getChildByName("CheckBox_music")
    CheckBox_music:addEventListenerCheckBox(function(sender,eventType) 
        if eventType == ccui.CheckBoxEventType.selected then
            MainScene.isOpenMusic = true
            cc.UserDefault:getInstance():setBoolForKey("isOpenMusic" , MainScene.isOpenMusic)
            cc.SimpleAudioEngine:getInstance():resumeMusic()  
        elseif eventType == ccui.CheckBoxEventType.unselected then
            MainScene.isOpenMusic = false
            cc.UserDefault:getInstance():setBoolForKey("isOpenMusic" , MainScene.isOpenMusic)
            cc.SimpleAudioEngine:getInstance():pauseMusic()
        end
 
    end)

    CheckBox_music:setSelectedState(MainScene.isOpenMusic)
   
    local CheckBox_effects = layer:getChildByName("CheckBox_effects")
    CheckBox_effects:addEventListenerCheckBox(function(sender,eventType) 
        if eventType == ccui.CheckBoxEventType.selected then
            MainScene.isOpenEffect = true
            cc.UserDefault:getInstance():setBoolForKey("isOpenEffect" , MainScene.isOpenEffect)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            MainScene.isOpenEffect = false
            cc.UserDefault:getInstance():setBoolForKey("isOpenEffect" , MainScene.isOpenEffect)
        end
 
    end)

    CheckBox_effects:setSelectedState(MainScene.isOpenEffect)
 
    -- 玩家金钱
    local money = cc.UserDefault:getInstance():getIntegerForKey("myMoney")
    if money <= 0 then 
        money = 500 
        cc.UserDefault:getInstance():setIntegerForKey("myMoney", 500)
    end
    local txt = layer:getChildByName("Text_money")
    txt:setString(money)

    --WebButton
    local btn_website = layer:getChildByName("Button_website")
    btn_website:addTouchEventListener(function(sender , event)
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            WebLayer.titleId = 2
            self.loadNode:addChild(WebLayer:create())

        end
    end)

    --technaical
    local btn_technaical = layer:getChildByName("Button_technaical")
    btn_technaical:addTouchEventListener(function(sender , event)
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            WebLayer.titleId = 1
            self.loadNode:addChild(WebLayer:create())

        end
    end)

    -- 规则
    local btn_rule = layer:getChildByName("Button_rule")
    btn_rule:addTouchEventListener(function(sender , event)
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            self.loadNode:addChild(GameRule:create())
        end
    end)

    -- 荣誉
    local Button_glory = layer:getChildByName("Button_glory")
    Button_glory:addTouchEventListener(function(sender , event)
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            self.loadNode:addChild(AchievementLayer:create())
            
        end
    end)


    -- 开始游戏
    local btn_play = layer:getChildByName("Button_play")
    btn_play:addTouchEventListener(function(sender , event)
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            local gamePlayScene = require("app.majia.GameLayer")
            local scene = gamePlayScene.create()
            local ts = cc.TransitionFlipX:create(0.5, scene)

            cc.Director:getInstance():replaceScene(ts)        
        end
    end)


    --商店
    local btn_shop = layer:getChildByName("Button_Shop")
    btn_shop:addTouchEventListener(function(sender , event)
    if event == 2 then
        if MainScene.isOpenEffect then
            AudioEngine.playEffect("majia/sound/click.mp3")
        end
        self.loadNode:addChild(ShopLayer:create(), 99)
       -- self.loadNode:addChild(WebLayer:create())
    end
    end)

end


return MainScene
