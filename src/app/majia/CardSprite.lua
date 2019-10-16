--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CardSprite = class("CardSprite", cc.Sprite)

local CardData = {

    --枪兵
    { name = "qiangbing", blood = 25,damage =  9, recovery = 0 , range = {1}, coin = 0},

    --盾兵
    { name = "dunbing", blood = 35,damage =  7, recovery = 0 , range = {1}, coin = 0 },

    --骑兵
    { name = "qibing", blood = 25,damage =  12, recovery = 0 , range = {1}, coin = 0 },

    --重甲兵
    { name = "zhongjiabing", blood = 40,damage =  5, recovery = 0 , range = {1}, coin = 0 },

    --剑士
    { name = "jianshi", blood = 20,damage =  15, recovery = 0, range = {1}, coin = 0 },

    --祭司
    { name = "jisi", blood = 18,damage =  0, recovery = 8 , range = {1}, coin = 500 },

    --刺客
    { name = "cike", blood = 12,damage =  18, recovery = 0 , range = {1}, coin = 500 },

    --斧兵
    { name = "fubing", blood = 30,damage =  10, recovery = 0, range = {1}, coin = 500 },

    --弓箭手
    { name = "gongjianshou", blood = 22,damage =  14, recovery = 0, range = {2}, coin = 500 },

    --投枪手
    { name = "touqiangshou", blood = 15,damage =  16, recovery = 0, range = {1, 2}, coin = 800 },

    --盗贼
    { name = "daozei", blood = 25,damage =  10, recovery = 0 , range = {1}, coin = 800 },

    --海盗
    { name = "haidao", blood = 28,damage =  12, recovery = 0 , range = {1}, coin = 800 },

    --巫师
    { name = "wushi", blood = 18,damage =  15, recovery = 0, range = {1, 2}, coin = 1000 },

    --魔法师
    { name = "mofashi",blood = 25,damage =  14, recovery = 0, range = {1, 2}, coin = 500 },

    --魔导士
    { name = "modaoshi", blood = 35,damage =  200, recovery = 0, range = {1, 2}, coin = 1000 },

    --神官骑士
    { name = "shenguanqishi", blood = 30,damage =  0, recovery = 12 , range = {1}, coin = 1500 },

    --天马骑士
    { name = "tianmaqishi", blood = 35,damage =  20, recovery = 0 , range = {1}, coin = 1500 },

    --翼龙骑士
    { name = "yilongqishi", blood = 38,damage =  25, recovery = 0 , range = {1}, coin = 1500 },


}

local fromFrame = {"Friendship.png", "enemy.png"}
function CardSprite:ctor()

local plistName = "majia/images/game/card.plist"

end

function CardSprite:createCard(idx, state, user)

    local card = {}
    -- 卡牌
    card.sp = cc.Sprite:createWithSpriteFrameName(state..CardData[idx].name..".png")      
    -- 攻击力
    card.damage = CardData[idx].damage
    -- 当前血量
    card.blood = CardData[idx].blood
    -- 初始血量
    card.startHP = CardData[idx].blood
    -- 生命恢复值
    card.recovery = CardData[idx].recovery
    -- 名字
    card.name = CardData[idx].name
    -- 攻击范围
    card.range = {}
    card.range = CardData[idx].range
    -- 精灵血条
    card.blood_txt = cc.Label:createWithTTF(card.blood , "majia/font/font.ttf", 16)
    card.blood_txt:setAnchorPoint(ccp(0.5,0.5))
    card.blood_txt:setPosition(cc.p(34, 17))
    card.blood_txt:addTo(card.sp)
    card.blood_txt:setVisible(false)
    -- 外框
    card.from = user
    card.frame = cc.Sprite:createWithSpriteFrameName(fromFrame[user])
    card.frame:setVisible(false)
    card.frame:setPosition(cc.p(52, 54))
    card.frame:setAnchorPoint(cc.p(0.5, 0.5))
    card.frame:setScale(1.05)
    card.frame:addTo(card.sp)
    -- 是否阵亡 (以后加复活技能)
    card.death = false
    return card
end

-- 放置棋盘上
function CardSprite:setSprite(card)
    card.sp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("X" .. card.name..".png"))
    card.blood_txt:setVisible(true)
    card.frame:setVisible(true)
end

-- 返回手牌
function CardSprite:setSpriteD(card)   
    card.sp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("D" .. card.name..".png"))
    card.blood_txt:setVisible(false)
    card.frame:setVisible(false)
end

-- 商店卡牌预制体
function CardSprite:createShopCard(idx)

    local card = {}
    card.sp = cc.Sprite:createWithSpriteFrameName("C".. CardData[idx].name ..".png")
    card.frame = cc.Sprite:createWithSpriteFrameName("chios.png")
    card.frame:setPosition(cc.p(61, 82))
    card.frame:setAnchorPoint(cc.p(0.5, 0.5))
    card.frame:addTo(card.sp)
    card.maks = cc.Sprite:createWithSpriteFrameName("shopMaks.png")
   -- card.maks:setScale(1.1)
    card.maks:setAnchorPoint(ccp(0.5,0.5))
    card.maks:setPosition(cc.p(60, 78))
    card.maks:addTo(card.sp)
    local money = cc.Sprite:createWithSpriteFrameName("money.png")
    money:setAnchorPoint(ccp(0.5,0.5))
    money:setPosition(cc.p(40, 78))
    money:addTo(card.maks)
    local txt = cc.Label:createWithTTF(CardData[idx].coin, "majia/font/font.ttf", 20)
    txt:setAnchorPoint(ccp(0.5,0.5))
    txt:setPosition(cc.p(72, 78))
    txt:addTo(card.maks)
    card.coin = CardData[idx].coin
    card.idx = idx
    return card

end

return CardSprite;
--endregion
