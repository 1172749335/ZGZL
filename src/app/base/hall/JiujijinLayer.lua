local C = class("JiujijinLayer",BaseLayer)
JiujijinLayer = C

C.RESOURCE_FILENAME = "base/JiujijinLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
    sureBtn = {path="box_img.btn_sure",events={{event="click",method="onClickSure"}}},
    getBtn = {path="box_img.btn_get",events={{event="click",method="onClickGet"}}},
	descLabel = {path="box_img.text_content"},
    nodeAnimed = {path="box_img.node_anim"},
}

function C:onCreate()
	C.super.onCreate(self)
end

function C:show(s)
	C.super.show(self)
    if s == nil then
        self.sureBtn:setVisible(true)
        self.getBtn:setVisible(false)
        self.descLabel:setString("救济金领取已达上限，请明天再来找我吧")

        self.onGetSucc = handler(self,self.onGetSuccess)
        eventManager:on("ReceiveALMSSucc",self.onGetSucc)
        self.onGetFail = handler(self,self.onGetFailed)
        eventManager:on("ReceiveALMSFailed",self.onGetFail)
        return
    end
--    self:loadSkelentonAnimation()
    if s.TodayReceiveCount >= s.LimitCount  then
        self.sureBtn:setVisible(true)
        self.getBtn:setVisible(false)
        self.descLabel:setString("救济金领取已达上限，请明天再来找我吧")
    elseif dataManager.userInfo.money+dataManager.userInfo.walletmoney >= s.LimitMoney  then
        self.sureBtn:setVisible(true)
        self.getBtn:setVisible(false)
        self.descLabel:setString("余额小于1金币才能领取救济金，保险箱的金币也计入哦")
    else
        self.sureBtn:setVisible(false)
        self.getBtn:setVisible(true)
        self.descLabel:setString("恭喜您获得"..s.Money/MONEY_SCALE .."金币")
    end
--    self.onGetSucc = handler(self,self.onGetSuccess)
--    eventManager:on("ReceiveALMSSucc",self.onGetSucc)
--    self.onGetFail = handler(self,self.onGetFailed)
--    eventManager:on("ReceiveALMSFailed",self.onGetFail)
end

function C:onGetSuccess(money)
--    self:loadSkelentonAnimation()
    self:playGoldAni()
end

function C:onGetFailed()    
    toastLayer:show("领取失败")
    self:hide()
end

function C:onClickGet( event )
    eventManager:publish("ReceiveALMS")
    self:hide()
end

--function C:loadSkelentonAnimation()
--    local redbagAnimedName = "base/animation/skeleton/jiujijin/jinbi_baozha"
--    self.redbagNodeed = sp.SkeletonAnimation:create(redbagAnimedName .. ".json", redbagAnimedName .. ".atlas", 1)
--    self.redbagNodeed:setAnimation(0,"animation",false)
--	self.nodeAnimed:addChild( self.redbagNodeed )
--    utils:delayInvoke("jiujijin.hideJiujijinLayer",1.2,function()
--    	self.redbagNodeed:removeFromParent(true)
--        self:hide()
--    end)
--end

--function C:playGoldAni()
--    PLAY_SOUND(BASE_SOUND_RES.."ui_kaiboxiang.mp3")
--	local particle = cc.ParticleSystemQuad:create("base/animation/particle/gold.plist")
--    particle:setAutoRemoveOnFinish(true)
--    particle:setPosition(display.cx,display.bottom+100)
--    utils:delayInvoke("jiujijin.hideJiujijinLayer",1.6,function()
--        self:hide()
--    end)
--    self:addChild(particle)
--end

function C:onClickSure( event )
    self:hide()
end

function C:onExit()
--    utils:removeTimer("jiujijin.hideJiujijinLayer")
--    eventManager:off("ReceiveALMSSucc",self.onGetSucc)
--    eventManager:off("ReceiveALMSFailed",self.onGetFail)
    C.super.onExit(self)
end

return JiujijinLayer