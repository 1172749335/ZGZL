--region *.lua
--Date 2019/9/25
--此文件由[BabeLua]插件自动生成
local CardSprite = require "app.majia.CardSprite"
local MessageLayer = require "app.majia.MessageLayer"
local GameLayer = class("GameLayer", function()
    return cc.Scene:create() end)

local USERSELF = 1
local USERCOMPUTER = 2

local DUIZHAN = "D"
local ZHANCHANG = "X"

local ZHENG = 1
local FAN = 2

function GameLayer:ctor()    

    math.randomseed( os.time())
    self:loadResource()
   
    if MainScene.isOpenMusic then
        CHANGE_BACKGROUND_MUSIC("majia/sound/game_bg.mp3")
    end
end

-- 初始化数据
function GameLayer:reSetData()
    
    -- 棋盘
    self.Maps = {}

    -- 玩家卡牌
    self.userCards = {{},{}}

    -- 棋盘上的牌
    self.battCards = {{},{}}

    -- 当前操作玩家
    self.currentPlayer = USERSELF

    -- 当前玩家剩余步数
    self.surplusCount = 4

    -- 是否猜正反
    self.firsPlayer = false

end

-- 读取
function GameLayer:toTableM(str)

    if str == "" then
        str = "1.2.3.4.5."
    end
    local temp = {}
    for w in string.gmatch(str, "%d+") do
        temp[#temp + 1] = tonumber(w)   
    end

    return temp
end

-- 加载资源
function GameLayer:loadResource()
    
    -- 初始化数据
    self:reSetData()

    -- 加载卡牌纹理
    cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/card.plist")

    -- 加载纹理
    cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/dice.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/gold.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/attck.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/recovery.plist")

    -- 加载游戏
    self.loadNode = cc.CSLoader:createNode("majia/PlayScene.csb")
    --self.loadNode:setContentSize(cc.size(display.size.height, display.size.width))
    ccui.Helper:doLayout(self.loadNode)
    self:addChild(self.loadNode, 0)

    self.layer = self.loadNode:getChildByName("Panel_ui")
    local scX = display.width/self.loadNode:getContentSize().width
    local scY = display.height/self.loadNode:getContentSize().height
    self.loadNode:setScaleX(scX)
    self.loadNode:setScaleY(scY)
   
     -- 关闭
    local btn_close = self.layer:getChildByName("Button_close")
    btn_close:addTouchEventListener(function(sender , event)
        if event == 2 then
            print("关闭")
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            self:onExit()
            local GameScene = require "app.majia.MainScene"
            local miniGameScene = GameScene:create()
            local ts = cc.TransitionFlipY:create(0.5, miniGameScene)

            cc.Director:getInstance():replaceScene(ts) 
        end
    end)

     -- 剩余步数
     self.surplustxt = cc.Label:createWithTTF("0", "majia/font/font.ttf", 40)
     self.surplustxt:setPosition(cc.p(btn_close:getPositionX(), btn_close:getPositionY() + 80))
     self.surplustxt:addTo(self.layer)
     self.surplustxt:setColor(cc.c3b(0xFF, 0xFF,0xFF))
 
    -- 回合结束
    self.btn_end = self.layer:getChildByName("Button_end")
    self.btn_end:setEnabled(false)
    self.btn_end:addTouchEventListener(function(sender , event)
        if event == 2 then
           self:reSetGameState()         
        end
    end)


   -- 摇骰子
    self.btn_dice = self.layer:getChildByName("Button_dice")
    self.btn_dice:setEnabled(false)
    self.btn_dice:addTouchEventListener(function(sender , event)
        if event == 2 then
            local num = math.random(1, 6)
            self.surplusCount = num
            print(" 步数为" .. num)
            self:diceAnimation(num)
            self.btn_dice:setEnabled(false)
        end      
    end)

    self.guessLayer = self.loadNode:getChildByName("Panel_guess")
    self.guessLayer:setVisible(false)
    
    -- 正面
    Button_obcerse = self.guessLayer:getChildByName("Button_obcerse")
    Button_obcerse:addTouchEventListener(function(sender , event)
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            self:guessFirstAnimation(ZHENG)
            Button_bcak:setVisible(false)
            Button_obcerse:setVisible(false)
        end
    end)
 
    -- 反面
    Button_bcak = self.guessLayer:getChildByName("Button_bcak")
    Button_bcak:addTouchEventListener(function(sender , event)
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            self:guessFirstAnimation(FAN)
            Button_bcak:setVisible(false)
            Button_obcerse:setVisible(false)
        end
    end)

    self.spr = self.guessLayer:getChildByName("Coinback_90")
    self.spr:setVisible(true)
------------------------------------------------------------------------------------------------------------------

    -- 加载棋盘
    self.Maps = self:createMapTexture()

    -- 玩家
    self.userCards[USERSELF] = {}
    local cardTemp = {}
    cardTemp[USERSELF] = self:toTableM(cc.UserDefault:getInstance():getStringForKey("userCard"))
    for i = 1, #cardTemp[USERSELF] do
        local card = CardSprite:createCard(cardTemp[USERSELF][i], DUIZHAN, USERSELF)  
        card.sp:setPosition(cc.p(-120, 320))
        card.sp:addTo(self.layer)
        card.id = cardTemp[USERSELF][i]
        card.idx = 0
        card.isAttack = false
        card.placeRange = {}
        card.sp:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(205 + (i - 1) * 140, 100)),
        cc.CallFunc:create(function() 

        end)))
       
        table.insert(self.userCards[USERSELF], card)
    end
    

    --机器人
    self.userCards[USERCOMPUTER] = {}
    cardTemp[USERCOMPUTER] = self:createRobot()
    for i = 1, #cardTemp[USERCOMPUTER] do
        local card = CardSprite:createCard(cardTemp[USERCOMPUTER][i], DUIZHAN, USERCOMPUTER)  
        card.sp:setPosition(cc.p(-1200, 500))
        card.sp:addTo(self.layer)
        card.id = cardTemp[USERCOMPUTER][i]
        -- 放置在那块地方
        card.idx = 0
        -- 攻击范围
        card.placeRange = {}
        -- 是否已经攻击
        card.isAttack = false
        card.sp:runAction(cc.Sequence:create(cc.MoveTo:create(0.01, cc.p(1200 + (i - 1) * 140, 500)),
        cc.CallFunc:create(function() 

        end)))
       
        table.insert(self.userCards[USERCOMPUTER], card)
    end 

    self:addEventListener()
    --self:GameEndLayer()
end

-- 创建地图
function GameLayer:createMapTexture()

    local pos = { x = 72, y = 245 }
    
    local Tmp = {}
    for i = 1, 4 do
        for j = 1, 10 do
            local sp = {}
            local posX = pos.x + (j - 1) * 110
            local posY = pos.y + (i - 1) * 110
            local spr_mps = cc.Sprite:create( string.format("majia/images/game/image%d.png", (j+i)%2))
            spr_mps:setPosition(cc.p(posX, posY))
            spr_mps:setAnchorPoint(ccp(0.5,0.5))
            spr_mps:addTo(self.layer)
            sp.bg = spr_mps
            local spr_mask =  cc.Sprite:create("majia/images/game/mapMask.png")
            spr_mask:setPosition(ccp(55,55))
            spr_mask:setAnchorPoint(ccp(0.5,0.5))
            spr_mask:setVisible(true)
            spr_mask:addTo(spr_mps)
            sp.mask = spr_mask
            local spr_damage =  cc.Sprite:create("majia/images/game/redMask.png")
            spr_damage:setPosition(ccp(55,55))
            spr_damage:setAnchorPoint(ccp(0.5,0.5))
            spr_damage:setVisible(false)
            spr_damage:addTo(spr_mps)
            sp.damage = spr_damage
            -- 是否可以放置
            sp.can_place = true
            sp.idx = (i - 1) * 10 + j
            if j == 1 then
                spr_mask:setVisible(false)                   
            end 
            table.insert(Tmp, sp)
        end
    end
    return Tmp
end

-- 开启监听
function GameLayer:addEventListener()
    local layerColor = CCLayerColor:create(ccc4(0,0,0, 0),display.width, display.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    self.loadNode:addChild(layerColor)
    self:createTips("请选择4张牌放置在最左列", 2)
    local currentCard = {}

    local function onTouchBegan( touch, event )
        if self.currentPlayer ~= USERSELF then return false end
        if self.surplusCount < 1 then return false end
        currentCard = {}
        
        -- 放置到棋盘
        for i = 1, #self.userCards[USERSELF] do
            local pos = touch:getLocation()
            local sender = self.userCards[USERSELF][i].sp
            pos = sender:convertToNodeSpace(pos)
            local rec = cc.rect(0, 0, sender:getContentSize().width, sender:getContentSize().height)
            if cc.rectContainsPoint(rec, pos) then
                currentCard.ID = i   
                currentCard.lZO = self.userCards[USERSELF][i].sp:getLocalZOrder()
                currentCard.Pos = cc.p(self.userCards[USERSELF][i].sp:getPositionX(),self.userCards[USERSELF][i].sp:getPositionY()) 
                currentCard.isNew = true 
                currentCard.idx = self.userCards[USERSELF][i].idx
                currentCard.card = self.userCards[USERSELF][i]
                return true     
            end
        end 
        
        if self.firsPlayer then
            -- 移动棋盘上的卡牌
            for i = 1, #self.battCards[USERSELF] do
                local pos = touch:getLocation()
                local sender = self.battCards[USERSELF][i].sp
                pos = sender:convertToNodeSpace(pos)
                local rec = cc.rect(0, 0, sender:getContentSize().width, sender:getContentSize().height)
                if cc.rectContainsPoint(rec, pos) then  
                    currentCard.ID = i   
                    currentCard.lZO = self.battCards[USERSELF][i].sp:getLocalZOrder()
                    currentCard.Pos = cc.p(self.battCards[USERSELF][i].sp:getPositionX(),self.battCards[USERSELF][i].sp:getPositionY()) 
                    currentCard.isNew = false 
                    currentCard.idx = self.battCards[USERSELF][i].idx
                    currentCard.card = self.battCards[USERSELF][i]               
                    self:setPlaceRange(self.battCards[USERSELF][i].idx, currentCard.card)
                    return true
                end
            end 
        end

        return false
    end 

    local function onTouchMoved(touch, event)  
        
        local pos = self.loadNode:convertToNodeSpace(touch:getLocation())
        currentCard.card.sp:setPosition(pos)
        currentCard.card.sp:setLocalZOrder(100)
        if touch:getLocation().y > 200 then
            if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("majia/images/game/card.plist") then
                cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/card.plist")
            end
            CardSprite:setSprite(currentCard.card)
            self:setDamageRange(touch:getLocation(), currentCard.card)
        else      
            if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("majia/images/game/card.plist") then
                cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/card.plist")
            end     
            CardSprite:setSpriteD(currentCard.card)
        end       
    end

    local function onTouchEnded( touch, event )   
        currentCard.card.sp:setLocalZOrder(currentCard.lZO) 
        for i = 1, #self.Maps do
            local pos = touch:getLocation()
            local sender = self.Maps[i].bg
            pos = sender:convertToNodeSpace(pos)
            local rec = cc.rect(0, 0, sender:getContentSize().width, sender:getContentSize().height)
            if cc.rectContainsPoint(rec, pos) and self.Maps[i].can_place then   
                if self.Maps[i].mask:isVisible() then break end
                self.Maps[i].can_place = false                     
                -- 来自棋盘移动
                if currentCard.isNew == false then
                    
                    self:setPlaceRange()
                    self.surplusCount =  self.surplusCount - self:calculateRemainin(i, self.battCards[USERSELF][currentCard.ID].idx)
                    self.surplustxt:setString(self.surplusCount)
                    self.Maps[currentCard.idx].can_place = true
                    self.battCards[USERSELF][currentCard.ID].idx = i
                    self:setPlaceMapUI(currentCard.card,self.Maps[i])    
                    self:isDamage(i, currentCard.card)
                    
                else
   
                    if i % 10 == 1 then
                        if #self.battCards[USERSELF] < 4 then
                            self:setPlaceMapUI(currentCard.card,self.Maps[i])  
                            self.userCards[USERSELF][currentCard.ID].idx = i
                            table.insert(self.battCards[USERSELF], self.userCards[USERSELF][currentCard.ID]) 
                            table.remove(self.userCards[USERSELF], currentCard.ID)
                            self.surplusCount = self.surplusCount - 1
                        else
                            self:createTips("你场上的卡牌没有小于\r\n4张，不能补牌", 2)
                        end
                    else
                        self:createTips("需放置在最左列的空格内", 2)
                        break
                    end
                end
                                
                if self.surplusCount < 1 then
                    if not self.firsPlayer and #self.battCards[USERSELF] >= 4 then
                        self.surplusCount = 0
                        -- 猜先手                 
                        self:setPlaceRange()
                        self:robotReady()                                
                     
                    else
                        -- 对家
                       self:reSetGameState()                       
                    end
                    self.firsPlayer = true
                end   
                return                 
            end
                              
        end 
        if currentCard.isNew then
             CardSprite:setSpriteD(currentCard.card)  
        else
            CardSprite:setSprite(currentCard.card)
        end
        currentCard.card.sp:setPosition(currentCard.Pos)
        self:setDamageRange()     
 
        currentCard = {}                                  
    end 
    
    local listener1 = cc.EventListenerTouchOneByOne:create()  --创建一个单点事件监听
    listener1:setSwallowTouches(false)  --是否向下传递
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layerColor:getEventDispatcher() 
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layerColor) --分发监听事件
    
end

-- 提示
function GameLayer:createTips(txt, time)
    local message = MessageLayer:create()
    self.loadNode:addChild(message)
    message:setMseeage(txt, time)
end
-- 计算行走步数
function GameLayer:calculateRemainin(star, des)

    local number = 0
    number = math.floor( math.max(star, des) / 10) -  math.floor( math.min(star, des) / 10)
    number = number + math.max(star % 10, des % 10) -  math.min(star % 10, des % 10)
    return number
end
-- 猜先手
function GameLayer:guessFirstAnimation(num)

    self.spr:setVisible(false)
    if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("majia/images/game/gold.plist") then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/gold.plist")
    end
    local number = math.random(1, 2)
    if num == number then
        self.currentPlayer = USERSELF
        self.btn_dice:setEnabled(true)
        print("玩家")
    else
        self.currentPlayer = USERCOMPUTER
        print("电脑")
    end

    local filename = {"obcerse.png", "Coinback.png"}    
    local spriteFrame = cc.SpriteFrameCache:getInstance()  
    spriteFrame:addSpriteFrames("majia/images/game/gold.plist" )  
  
    local spriteTest = cc.Sprite:createWithSpriteFrameName("00000.png") 
    spriteTest:setAnchorPoint( 0.5, 0.5 )  
    spriteTest:setPosition( cc.p( display.cx , display.cy ) )  
    self.loadNode:addChild( spriteTest )  
  
    local animation = cc.Animation:create()  
    for i=1, 24 do  
        local blinkFrame = spriteFrame:getSpriteFrame( string.format( "000%02d.png", i ) )  
        animation:addSpriteFrame( blinkFrame )  
    end  
    animation:addSpriteFrame(spriteFrame:getSpriteFrame(filename[number])) 
    animation:setDelayPerUnit( 0.05 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( false )--设置播放完成后是否回归最初状态  
    animation:setLoops(1)
    local action = cc.Animate:create(animation)  
    -- spriteTest:runAction( cc.RepeatForever:create( action ) )  无限循环播放
    spriteTest:runAction(cc.Sequence:create( cc.Repeat:create( action, 1 ), cc.DelayTime:create(2),cc.CallFunc:create(function()
        spriteTest:removeFromParent()
        self.guessLayer:setVisible(false)

        if self.currentPlayer == USERCOMPUTER then
            self:createTips("对方回合", 1)
            self:runAction(cc.Sequence:create(
                            cc.DelayTime:create( 1 ),
                            cc.CallFunc:create(function()
                                local num = math.random(1, 2)
                                self.surplusCount = num                             
                                self:diceAnimation(num)
                            end),
                        cc.DelayTime:create( 2 ),
                            cc.CallFunc:create(function()
                                self:GameLayerrobotPlay()
                            end)
                        ))
        else
            self.btn_end:setEnabled(true)
            self:createTips("你的回合，请点击【掷骰\r\n子】获得移动步数", 1)
        end
    end)) )
end
--回血动画
function GameLayer:recoveryAnimation(scend)

    if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("majia/images/game/recovery.plist") then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/recovery.plist")
    end
    local Pos = cc.p(self.Maps[scend.idx].bg:getPositionX(), self.Maps[scend.idx].bg:getPositionY())
    local spriteFrame = cc.SpriteFrameCache:getInstance()  
  
    local spriteTest = cc.Sprite:createWithSpriteFrameName("img_0.png")  
    spriteTest:setAnchorPoint( 0.5, 0.5 )  
    spriteTest:setPosition( Pos )  
    self.loadNode:addChild( spriteTest )  
  
    local animation = cc.Animation:create()  
    for i=1, 4 do  
        -- local frameName = string.format( "shuohua%02d.png", i )  
        local blinkFrame = spriteFrame:getSpriteFrame( string.format( "img_%d.png", i ) )  
        animation:addSpriteFrame( blinkFrame )  
    end  

    animation:setDelayPerUnit( 0.2 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( false )--设置播放完成后是否回归最初状态  
    animation:setLoops(1)
    local action = cc.Animate:create(animation)  
    -- spriteTest:runAction( cc.RepeatForever:create( action ) )  无限循环播放
    spriteTest:setScale(0.7)
    
    if self.currentPlayer == USERCOMPUTER then
        spriteTest:setFlipX(true)
    end
    spriteTest:runAction(cc.Sequence:create(
    cc.Repeat:create( action, 1 ), cc.DelayTime:create(0.3),cc.CallFunc:create(function()
        spriteTest:removeFromParent()
    end)) )

end

--攻击动画
function GameLayer:attackAnimation(scend)
    if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("majia/images/game/attck.plist") then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/attck.plist")
    end
    local Pos = cc.p(self.Maps[scend.idx].bg:getPositionX(), self.Maps[scend.idx].bg:getPositionY())
    local spriteFrame = cc.SpriteFrameCache:getInstance()  
  
    local spriteTest = cc.Sprite:createWithSpriteFrameName("1.png")  
    spriteTest:setAnchorPoint( 0.5, 0.5 )  
    spriteTest:setPosition( Pos )  
    self.loadNode:addChild( spriteTest )  
  
    local animation = cc.Animation:create()  
    for i=1, 4 do  
        -- local frameName = string.format( "shuohua%02d.png", i )  
        local blinkFrame = spriteFrame:getSpriteFrame( string.format( "%d.png", i ) )  
        animation:addSpriteFrame( blinkFrame )  
    end  

    animation:setDelayPerUnit( 0.1 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( false )--设置播放完成后是否回归最初状态  
    animation:setLoops(1)
    local action = cc.Animate:create(animation)  
    -- spriteTest:runAction( cc.RepeatForever:create( action ) )  无限循环播放
    spriteTest:setScale(0.7)
    
    if self.currentPlayer == USERCOMPUTER then
        spriteTest:setFlipX(true)
    end
    spriteTest:runAction(cc.Sequence:create(
    cc.Repeat:create( action, 1 ), cc.DelayTime:create(0.3),cc.CallFunc:create(function()
        spriteTest:removeFromParent()
    end)) )


end

-- 摇骰子
function GameLayer:diceAnimation(filename)

    if not cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("majia/images/game/dice.plist") then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("majia/images/game/dice.plist")
    end
    local spriteFrame = cc.SpriteFrameCache:getInstance()  
    local spriteTest = cc.Sprite:createWithSpriteFrameName("1_00000.png")  
    spriteTest:setAnchorPoint( 0.5, 0.5 )  
    spriteTest:setPosition( cc.p( 600, display.cy ) )  
    self.loadNode:addChild( spriteTest )  
  
    local animation = cc.Animation:create()  
    for i=1, 23 do  
        -- local frameName = string.format( "shuohua%02d.png", i )  
        local blinkFrame = spriteFrame:getSpriteFrame( string.format( "1_000%02d.png", i ) )  
        animation:addSpriteFrame( blinkFrame )  
    end  
    animation:addSpriteFrame(spriteFrame:getSpriteFrame("t_" .. filename .. ".png")) 
    animation:setDelayPerUnit( 0.08 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( false )--设置播放完成后是否回归最初状态  
    animation:setLoops(1)
    local action = cc.Animate:create(animation)  
    -- spriteTest:runAction( cc.RepeatForever:create( action ) )  无限循环播放
    spriteTest:runAction(cc.Sequence:create( cc.Repeat:create( action, 1 ), cc.DelayTime:create(2),cc.CallFunc:create(function()
        
        spriteTest:removeFromParent()
        if self.currentPlayer == USERSELF then
            self.btn_end:setEnabled(true)
            self.surplustxt:setString(self.surplusCount)
        end

    end)) )
end

-- 放置置棋盘
function GameLayer:setPlaceMapUI(scend, map)
  
    if self.currentPlayer == USERSELF then
        scend.sp:setPosition(cc.p(map.bg:getPositionX(), map.bg:getPositionY()))  
        if MainScene.isOpenEffect then
            AudioEngine.playEffect("majia/sound/card_play.mp3")
        end
    else
        scend.sp:runAction(cc.MoveTo:create(0.2, cc.p(map.bg:getPositionX(), map.bg:getPositionY())))
    end
   
    map.can_place = false
    return true

end

-- 攻击检测
function GameLayer:isDamage(idx, val, ispect)
    
    local i = idx

    -- 攻击范围内
    local m_range = {}
  
    local range = 1

    local damageType = 1
    if #val.range > 1 then
        damageType = 3
        range = 2
    else
        if val.range[1] > 1 then
            damageType = 2
            range = 2
        end
    end

    local numTop = i + range * 10
    local count = 0
    for j = 1, range * 2 + 1, 2 do       
        for k = 1, j do   
            local int = math.floor((numTop + count) / 10) * 10 + 1
            if (numTop + count) % 10 == 0 then
                int = int - 10
            end    
                
            if (numTop + k - 1) >= int and (numTop + k - 1) <= (int + 9) then              
                -- 正尖头
                if int <= 40 and int > 0 then     
                    for c = 1, #m_range do
                        if m_range[c] == numTop + k - 1 then
                            table.remove(m_range, c)
                        end
                    end
                    table.insert(m_range, numTop + k - 1)                                      
                end
                -- 反尖头
                if (numTop + k - 1) - (range - count) * 20 > 0 then
                   for c = 1, #m_range do
                        if m_range[c] == (numTop + k - 1) - (range - count) * 2 then
                            table.remove(m_range, c)
                        end
                    end  
                    table.insert(m_range, (numTop + k - 1) - (range - count) * 20)  
                end                 
            end                
        end               
        count = count + 1         
        numTop = numTop - 11               
    end   

    if damageType == 2 then
        local temp = {10, -10, 1, -1}
        for p = 1, 4 do
            if i + temp[p] > 0 and i + temp[p] <= 40 then
                for s = 1, #m_range do
                    if m_range[s] == i + temp[p] then
                        table.remove(m_range, s)
                    end
                end
            end
        end

    end                                
 
    -- 过滤
    local m_rangeNew = {}
    -- 被攻击卡牌表
    local m_damage = {}
    -- 回血卡牌表
    local m_recovery = {}
    local current = USERSELF
    if self.currentPlayer == USERSELF then
        current = USERCOMPUTER
    end

    for y = 1, #self.battCards[current] do
        for o = 1, #m_range do
            if self.battCards[current][y].idx == m_range[o] then
                table.insert(m_rangeNew, self.battCards[current][y])                
            end
            if y <= #self.battCards[self.currentPlayer] then
                if self.battCards[self.currentPlayer][y].idx == m_range[o] then
                    table.insert(m_recovery, self.battCards[self.currentPlayer][y])   
                end
            end
        end
    end

    if next(m_rangeNew) ~= nil then
        local minHR = m_rangeNew[1]
    
        for i = 1, #m_rangeNew do
            if m_rangeNew[i].blood < minHR.blood and val.isAttack == false then
                minHR = m_rangeNew[i]
            end    
        end

        if not val.isAttack then
            -- 扣血
            self:upDataBloodSub(minHR, val)
        end

    end
    
    if next(m_recovery) ~= nil then
        local minHR = m_recovery[1]
        for i = 1, #m_recovery do
            if m_recovery[i].blood < minHR.blood and val.isAttack == false then
                minHR = m_recovery[i]
            end          
        end

        if not val.isAttack then
            -- 回血
            self:upDataBloodAdd(minHR, val)
        end

    end

end

-- 扣血
function GameLayer:upDataBloodSub(scend, val)
    if val.damage < 1 then return end
    local current = USERSELF 
    if self.currentPlayer == USERSELF then
        current = USERCOMPUTER
    end
    scend.blood = scend.blood - val.damage
    val.isAttack = true
    if MainScene.isOpenEffect then
        AudioEngine.playEffect("majia/sound/attack.mp3")
    end
    local txt = cc.Label:createWithTTF("-"..val.damage, "majia/font/font.ttf", 30)
    txt:setPosition(cc.p(50, 43))
    txt:addTo(scend.sp)
    txt:setColor(cc.c3b(0xFF, 0x00,0x00))
    self:attackAnimation(scend)
    txt:runAction(cc.Sequence:create(
        cc.MoveTo:create(1, cc.p(txt:getPositionX(), 88)),
        cc.CallFunc:create(function() 
        txt:removeFromParent() 
        scend.blood_txt:setString(scend.blood)
            if scend.blood < 1 then
                scend.sp:runAction(cc.Sequence:create(  
                cc.MoveTo:create(0.5,cc.p(display.width, display.height)),               
                cc.CallFunc:create(function()
                        scend.sp:removeFromParent()
                        for i = 1, #self.battCards[current] do
                            if self.battCards[current][i].name == scend.name then                                    
                                self.Maps[self.battCards[current][i].idx].can_place = true
                                table.remove(self.battCards[current], i)
                                break                                                    
                            end                             
                        end
                        if #self.battCards[current] < 1 then
                            self:GameEndLayer()
                        end 
                        end)
                    )    
                               
                )
            end
        end)
         
    ))


end

-- 游戏结束
function GameLayer:GameEndLayer()
    local layerColor = CCLayerColor:create(ccc4(0,0,0, 200),display.width, display.height)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    local scX = display.width/self.loadNode:getContentSize().width
    local scY = display.height/self.loadNode:getContentSize().height

    self.loadNode:addChild(layerColor)
  
    local fileName = {"majia/img/victory.png", "majia/img/fail.png"}

    
    local winner = USERSELF
    if next(self.battCards[USERSELF]) == nil then
        winner = USERCOMPUTER
    end

    local bg = cc.Sprite:create(fileName[winner])
    bg:setPosition(cc.p(display.cx, display.cy))
    layerColor:addChild(bg)

    -- 获得积分
    local integral_Get = 0

    -- 当前积分
    local integral = cc.UserDefault:getInstance():getIntegerForKey("integral")  
    if integral < 0 then
        integral = 0
    end

    -- 获得金币
    local getMoney = 0

    -- 当前身份
    local identityTb = {"士兵", "统帅", "团长", "城主", "领主"}
    local identity = cc.UserDefault:getInstance():getIntegerForKey("identity")  
    if identity < 1 then
        identity = 1
    elseif identity > 5 then
        identity = 5
    end
   

    if winner == 1 then
        integral_Get = #self.userCards[USERSELF] * 5 + #self.battCards[USERSELF] * 5
        integral = integral + integral_Get
        cc.UserDefault:getInstance():setIntegerForKey("integral", integral)

        for i = 1, #self.userCards[USERSELF] do
            getMoney = getMoney + self.userCards[USERSELF][i].blood
        end
        for i = 1, #self.battCards[USERSELF] do
            getMoney = getMoney + self.battCards[USERSELF][i].blood
        end

        local mymoney =  cc.UserDefault:getInstance():getIntegerForKey("myMoney")
        if mymoney < 1 then
            mymoney = 0
        end
        mymoney = mymoney + getMoney
        cc.UserDefault:getInstance():setIntegerForKey("myMoney", mymoney)

        local grade = { 149, 319, 569, 869, 99999999}
        if identity < 5 then
            if integral > grade[identity] then
                identity = identity + 1
                cc.UserDefault:getInstance():setIntegerForKey("identity", identity)  
            else
                cc.UserDefault:getInstance():setIntegerForKey("identity", identity) 
            end
        end

        -- 胜利场次
        local victoryField = cc.UserDefault:getInstance():getIntegerForKey("victoryField")
        victoryField = victoryField + 1
        cc.UserDefault:getInstance():setIntegerForKey("victoryField", victoryField)

        local victory = cc.UserDefault:getInstance():getIntegerForKey("victory")
        victory = victory + 1
        cc.UserDefault:getInstance():setIntegerForKey("victory", victory)

        -- 最高连胜
        local victoryAlways = cc.UserDefault:getInstance():getIntegerForKey("victoryAlways")
        if victory < victoryAlways then
            cc.UserDefault:getInstance():setIntegerForKey("victoryAlways", victory)
        end

    else
        cc.UserDefault:getInstance():setIntegerForKey("victory", 0)
    end

    -- 总场次
    local totalField = cc.UserDefault:getInstance():getIntegerForKey("totalField")
    totalField = totalField + 1
    cc.UserDefault:getInstance():setIntegerForKey("totalField", totalField)

    identity = identityTb[identity]
    local txt = cc.Label:createWithTTF("积分", "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx - 120, 320))
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF))   

    txt = cc.Label:createWithTTF("当前积分", "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx - 120, 280))
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF))  

    txt = cc.Label:createWithTTF("金币", "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx + 80, 320))
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF))  

    txt = cc.Label:createWithTTF("当前身份", "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx + 80, 280))
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF))  

    -- 获得积分
    txt = cc.Label:createWithTTF(integral_Get, "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx - 60, 320))
    txt:setAnchorPoint(0, 0.5)
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF)) 

    -- 当前积分
    txt = cc.Label:createWithTTF(integral, "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx - 60, 280))
    txt:setAnchorPoint(0, 0.5)
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF)) 

    -- 金币
    txt = cc.Label:createWithTTF(getMoney, "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx + 130, 320))
    txt:setAnchorPoint(0, 0.5)
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF)) 

    --当前身份
    txt = cc.Label:createWithTTF(identity, "majia/font/font.ttf", 20)
    txt:setPosition(cc.p(display.cx + 130, 280))
    txt:setAnchorPoint(0, 0.5)
    txt:addTo(layerColor)
    txt:setColor(cc.c3b(0xFF, 0xFF,0xFF)) 

    local btn_reture = ccui.Button:create("majia/img/btn_return.png","","")
    btn_reture:setPosition(cc.p(display.cx - 100, 200))
    btn_reture:addTouchEventListener(function(sender, event) 
        if event == 2 then
            if MainScene.isOpenEffect then
                AudioEngine.playEffect("majia/sound/click.mp3")
            end
            self:onExit()
            local GameScene = require "app.majia.MainScene"
            local miniGameScene = GameScene:create()
            local ts = cc.TransitionFlipY:create(0.5, miniGameScene)

            cc.Director:getInstance():replaceScene(ts)           
        end
    end)
    btn_reture:addTo(layerColor)

    local btn_play = ccui.Button:create("majia/img/btn_play.png","","")
    btn_play:setPosition(cc.p(display.cx + 120, 200))
    btn_play:addTouchEventListener(function(sender, event) 
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
    btn_play:addTo(layerColor)

end

-- 回血
function GameLayer:upDataBloodAdd(scend, val)
    if val.recovery < 1 then return end

    local recovery = val.recovery
    if scend.blood >= scend.startHP then

        return
    else
        if scend.startHP - scend.blood < recovery then
            recovery = scend.startHP - scend.blood
        end        
    end
    if scend.blood < scend.startHP then
        if MainScene.isOpenEffect then
            AudioEngine.playEffect("majia/sound/life_recovery.mp3")
        end
     
        val.isAttack = true
        scend.blood = scend.blood + recovery
        local txt = cc.Label:createWithTTF("+"..recovery, "majia/font/font.ttf", 30)
        txt:setPosition(cc.p(50, 43))
        txt:addTo(scend.sp)
        txt:setColor(cc.c3b(0x00, 0xF0,0x00))
        self:recoveryAnimation(scend)
        txt:runAction(cc.Sequence:create(
            cc.MoveTo:create(1, cc.p(txt:getPositionX(), 88)),
            cc.CallFunc:create(function() 
            txt:removeFromParent() 
            scend.blood_txt:setString(scend.blood) 
            end)
        ))
    end
end

-- 回合结束攻击回血
function GameLayer:gameEndPlay()

    local current = USERSELF 
    if self.currentPlayer == USERSELF then
        current = USERCOMPUTER 
    end
    for i = 1, #self.battCards[self.currentPlayer] do
        if not self.battCards[self.currentPlayer][i].isAttack then  
            local m_damage = {}  
            local m_recovery = {} 
            for j = 1, #self.battCards[self.currentPlayer][i].placeRange do  
              -- 攻击范围内是否有卡牌               
                for k = 1, #self.battCards[current] do  
                    -- 查找对方卡牌  (攻击)             
                    if self.battCards[current][k].idx == self.battCards[self.currentPlayer][i].placeRange[j] then 
                        table.insert(m_damage, self.battCards[current][k])
                    end                     
                end      
                
                for k = 1, #self.battCards[self.currentPlayer] do
                    -- 查找自己卡牌 (回血)
                    if self.battCards[self.currentPlayer][k].idx == self.battCards[self.currentPlayer][i].placeRange[j] then         
                        table.insert(m_recovery, self.battCards[self.currentPlayer][k])
                    end
                end       
            end

             -- 查找血量最

             -- 查找血量最低的卡 
            if next(m_damage) ~= nil then                  
                local minBlood = m_damage[1]
                for min = 1, #m_damage do
                    if m_damage[min].blood < minBlood.blood then
                        minBlood =  m_damage[min]
                    end
                end
                -- 扣血
                self:upDataBloodSub(minBlood, self.battCards[self.currentPlayer][i])
            end

            if next(m_recovery) ~= nil then  
                local minBlood = m_recovery[1]
                for min = 1, #m_recovery do

                    if (m_recovery[min].startHP - m_recovery[min].blood) > (minBlood.startHP - minBlood.blood) then
                        minBlood = m_recovery[min]
                    end
                end   
                -- 回血
                self:upDataBloodAdd(minBlood, self.battCards[self.currentPlayer][i])       
            end

        end
    end
    self.surplusCount = 0
end

-- 计算攻击范围
function GameLayer:setDamageRange(pos, val)
    for i = 1, #self.Maps do
        self.Maps[i].damage:setVisible(false)
    end

    if pos == nil then return end

    local placeRange = {}
    for i = 1, #self.Maps do
        local pos = pos
        local sender = self.Maps[i].bg
        pos = sender:convertToNodeSpace(pos)
        local rec = cc.rect(0, 0, sender:getContentSize().width, sender:getContentSize().height)
        if cc.rectContainsPoint(rec, pos) then             
            local range = 1
            -- 1为近战 2为远程 3为中远程
            local damageType = 1
            if #val.range > 1 then
                damageType = 3
                range = 2
            else
                if val.range[1] > 1 then
                    damageType = 2
                    range = 2
                end
            end

            local numTop = i + range * 10
            local count = 0
            for j = 1, range * 2 + 1, 2 do       
                for k = 1, j do   
                    local int = math.floor((numTop + count) / 10) * 10 + 1
                    if (numTop + count) % 10 == 0 then
                        int = int - 10
                    end                   
                    if (numTop + k - 1) >= int and (numTop + k - 1) <= (int + 9) then
                        -- 正尖头
                        if int <= 40 and int > 0 then
                            if self.currentPlayer == USERSELF then
                                self.Maps[numTop + k - 1].damage:setVisible(true)   
                            end
                            table.insert(placeRange, numTop + k - 1)                                             
                        end
                        -- 反尖头
                        if (numTop + k - 1) - (range - count) * 20 > 0 then
                            if self.currentPlayer == USERSELF then
                                self.Maps[(numTop + k - 1) - (range - count) * 20].damage:setVisible(true)
                            end
                            table.insert(placeRange, (numTop + k - 1) - (range - count) * 20) 
                        end
                    end                  
                end               
                count = count + 1         
                numTop = numTop - 11               
            end   
            if damageType == 2 then
                local temp = {10, -10, 1, -1}
                for idx = 1, 4 do
                    if i + temp[idx] > 0 and i + temp[idx] <= 40 then
                        if self.currentPlayer == USERSELF then
                            self.Maps[i + temp[idx]].damage:setVisible(false)
                        end
                        for o = 1, #placeRange do
                            if i + temp[idx] == placeRange[o] then
                                table.remove(placeRange, i + temp[idx])
                            end
                        end
                        
                    end
                end
            end                                
        end                           
    end

    val.placeRange = {}
    table.insert(val.placeRange, placeRange[1])
    for i = 1, #placeRange do
        local haveTemp = true
        for j = 1, #val.placeRange do
            if val.placeRange[j] == placeRange[i] then
                haveTemp = false
            end
        end

        if haveTemp then
            if placeRange[i] > 0 and placeRange[i] <= 40 then
                table.insert(val.placeRange, placeRange[i])
            end
        end
    end
end

-- 计算可放置范围
function GameLayer:setPlaceRange(idx, val)

    local rangeTb = {}
    if val == nil then
        for i = 1, #self.Maps do
            self.Maps[i].mask:setVisible(false)
        end
        return
    end

    if self.currentPlayer == USERSELF then
        for i = 1, #self.Maps do
            self.Maps[i].mask:setVisible(true)
        end
    end  

    local numTop = idx + self.surplusCount * 10
    -- 最右方块偏移量
    local count = 0
    for j = 1,  self.surplusCount * 2 + 1, 2 do       
        for k = 1, j do   
            -- 右边界
            local int = math.floor((numTop + count) / 10) * 10 + 1
            if (numTop + count) % 10 == 0 then
                int = int - 10
            end  
            -- (int + 9)左边界                 
            if (numTop + k - 1) >= int and (numTop + k - 1) <= (int + 9) then
                -- 正尖头
                if int <= 40 and int > 0 then
                    if self.currentPlayer == USERSELF then
                        self.Maps[numTop + k - 1].mask:setVisible(false)   
                    end
                    table.insert(rangeTb, numTop + k - 1)                                              
                end
                -- 反尖头
                if (numTop + k - 1) - (self.surplusCount - count) * 20 > 0 then
                    if self.currentPlayer == USERSELF then
                        self.Maps[(numTop + k - 1) - (self.surplusCount - count) * 20].mask:setVisible(false)
                    end
                    table.insert(rangeTb, (numTop + k - 1) - (self.surplusCount - count) * 20)   
                end
            end                  
        end     

        count = count + 1         
        numTop = numTop - 11               
    end  
  
    return rangeTb
end

-- 回合结束重置游戏状态
function GameLayer:reSetGameState()

    if next(self.battCards[USERCOMPUTER]) == nil or next(self.battCards[USERSELF]) == nil then
        return
    end 
    self:gameEndPlay()

    -- 重置攻击状态
    for i = 1, #self.battCards[self.currentPlayer] do
        self.battCards[self.currentPlayer][i].isAttack = false
    end

    -- 设置当前出牌方
    if self.currentPlayer == USERSELF then
        print("电脑出牌")
        self:createTips("对方的回合", 1)
        self.currentPlayer = USERCOMPUTER
        self.btn_end:setEnabled(false)
        self.btn_dice:setEnabled(false)
        self.surplusCount = 0    
        self.surplustxt:setString(self.surplusCount)
        self:runAction(cc.Sequence:create(
                            cc.DelayTime:create( 1 ),
                            cc.CallFunc:create(function()
                                local num = math.random(1, 2)
                                self.surplusCount = num
                                print(" 电脑步数为" .. num)
                                self:diceAnimation(num)
                            end),
                        cc.DelayTime:create( 2 ),
                            cc.CallFunc:create(function()
                                self:GameLayerrobotPlay()
                            end)
                        ))
            
    else
        print("玩家出牌")
        self:createTips("你的回合", 1)
        self.currentPlayer = USERSELF
        self.btn_end:setEnabled(true)
        self.btn_dice:setEnabled(true)
    end
end
--------------------------------------------------------------机器人操作---------------------------------------------
-- 创建机器人卡牌
function GameLayer:createRobot()

    local cardCount = tonumber(cc.UserDefault:getInstance():getStringForKey("cardCount"))
    if cardCount == nil then
        cardCount = 4
    end
    if cardCount <= 16 then
        cardCount = cardCount + 2
    end
    local idxTable = {}
    math.randomseed(os.time())  
    local randomT = math.random(1, cardCount)
    table.insert(idxTable, randomT)    
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

-- 电脑准备阶段
function GameLayer:robotReady()

    for i = 1, 4 do 
        table.insert(self.battCards[USERCOMPUTER], self.userCards[USERCOMPUTER][#self.userCards[USERCOMPUTER]])    
        table.remove(self.userCards[USERCOMPUTER])   
        self.Maps[i * 10].can_place = false
        self.battCards[USERCOMPUTER][#self.battCards[USERCOMPUTER]].idx = i * 10
        CardSprite:setSprite(self.battCards[USERCOMPUTER][#self.battCards[USERCOMPUTER]])  
        self.battCards[USERCOMPUTER][#self.battCards[USERCOMPUTER]].sp:runAction(cc.Sequence:create(
        cc.DelayTime:create(i / 10),
        cc.MoveTo:create(0.5, cc.p(self.Maps[i * 10].bg:getPositionX(), self.Maps[i * 10].bg:getPositionY())),
        cc.DelayTime:create(1),
        cc.CallFunc:create(function()
                                if i == #self.battCards[USERCOMPUTER] then 
                                    self.guessLayer:setVisible(true) 
      
                                end
                            end)
        ))
                  
    end

      
end

-- 获得机器人攻击表
function GameLayer:setDamageRangeOfRobot(idx, val)
  
    local placeRange = {}  
    local range = 1
    local damageType = 1
    if #val.range > 1 then
        damageType = 3
        range = 2
    else
        if val.range[1] > 1 then
            damageType = 2
            range = 2
        end
    end

    local numTop = idx + range * 10
    local count = 0
    for j = 1, range * 2 + 1, 2 do       
        for k = 1, j do   
            local int = math.floor((numTop + count) / 10) * 10 + 1
            if (numTop + count) % 10 == 0 then
                int = int - 10
            end                   
            if (numTop + k - 1) >= int and (numTop + k - 1) <= (int + 9) then
                -- 正尖头
                if int <= 40 and int > 0 then
  
                    table.insert(placeRange, numTop + k - 1)                                             
                end
                -- 反尖头
                if (numTop + k - 1) - (range - count) * 20 > 0 then
                    table.insert(placeRange, (numTop + k - 1) - (range - count) * 20) 
                end
            end                  
        end               
        count = count + 1         
        numTop = numTop - 11               
    end   
    if damageType == 2 then
        local temp = {10, -10, 1, -1}
        for idx = 1, 4 do
            if idx + temp[idx] > 0 and idx + temp[idx] <= 40 then
                for o = 1, #placeRange do
                    if idx + temp[idx] == placeRange[o] then
                        table.remove(placeRange, idx + temp[idx])
                    end
                end              
            end
        end
    end                                
   

    val.placeRange = {}
    table.insert(val.placeRange, placeRange[1])
    for i = 1, #placeRange do
        local haveTemp = true
        for j = 1, #val.placeRange do
            if val.placeRange[j] == placeRange[i] then
                haveTemp = false
            end
        end

        if haveTemp then
            if placeRange[i] > 0 and placeRange[i] <= 40 then
                table.insert(val.placeRange, placeRange[i])
            end
        end
    end 
end

-- 电脑出牌
function GameLayer:GameLayerrobotPlay()

    self.currentPlayer = USERCOMPUTER
   -- 检查棋盘上是否需要补拍
    if #self.battCards[USERCOMPUTER] < 4 and next(self.userCards[USERCOMPUTER]) ~= nil then
         print("补拍")
        if next(self.userCards[USERCOMPUTER]) ~= nil then
            table.insert(self.battCards[USERCOMPUTER], self.userCards[USERCOMPUTER][#self.userCards[USERCOMPUTER]])    
            table.remove(self.userCards[USERCOMPUTER]) 

            --dump(self.Maps)
            local iTemp = 1
            while true do
                iTemp = math.random(1, 4)
                if self.Maps[iTemp * 10].can_place then                     
                    break
                end
            end
            print("iTemp = " .. iTemp)
            self.Maps[iTemp * 10].can_place = false
            self.battCards[USERCOMPUTER][#self.battCards[USERCOMPUTER]].idx = iTemp * 10
            CardSprite:setSprite(self.battCards[USERCOMPUTER][#self.battCards[USERCOMPUTER]]) 
            self.battCards[USERCOMPUTER][#self.battCards[USERCOMPUTER]].sp:setPosition(self.Maps[iTemp * 10].bg:getPosition())
--            self.battCards[USERCOMPUTER][#self.battCards[USERCOMPUTER]].sp:runAction(
--            cc.MoveTo:create(0.5, self.Maps[iTemp * 10].bg:getPosition())         
--            )                 
        end           
    end

    if next(self.battCards[USERCOMPUTER]) == nil then return end
   
    -- 获得人机行走路线
    local random = math.random(1, #self.battCards[USERCOMPUTER])
    local pos = self.Maps[self.battCards[USERCOMPUTER][random].idx].bg:getPosition()
    local rander = self:setPlaceRange(self.battCards[USERCOMPUTER][random].idx, self.battCards[USERCOMPUTER][random]) 
    local star = 0
    local uu = 0

    while true do
        star = rander[math.random(1, #rander)]
        if self.Maps[star].can_place then
            break
        end
        uu = uu + 1
        local tv = {}
        if uu > 500 then
            for i = 1, #self.Maps do
                if self.Maps[i].can_place == false then
                    table.insert(tv, i)
                end
            end
            dump(tv)
            random = math.random(1, #self.battCards[USERCOMPUTER])
            pos = self.Maps[self.battCards[USERCOMPUTER][random].idx].bg:getPosition()
            rander = self:setPlaceRange(self.battCards[USERCOMPUTER][random].idx, self.battCards[USERCOMPUTER][random]) 
        end
    end

    self.battCards[USERCOMPUTER][random].sp:runAction(cc.Sequence:create(
    cc.DelayTime:create(1),
    cc.CallFunc:create(function()
            self.Maps[self.battCards[USERCOMPUTER][random].idx].can_place = true
            self.Maps[star].can_place = false
            self.battCards[USERCOMPUTER][random].idx = star
            self:setPlaceMapUI(self.battCards[USERCOMPUTER][random], self.Maps[star])   
            self:setDamageRangeOfRobot(self.battCards[USERCOMPUTER][random].idx, self.battCards[USERCOMPUTER][random])                                
            self:isDamage(self.battCards[USERCOMPUTER][random].idx, self.battCards[USERCOMPUTER][random])               
        end),
    cc.DelayTime:create(1),
    cc.CallFunc:create(function()
        self:reSetGameState()
         end)
    ))
    
end

function GameLayer:onExit()

end

return GameLayer
--endregion
