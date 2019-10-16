local C = class("RedBagLayer",BaseLayer)
RedBagLayer = C

--C.USE_ACTION = false

C.RESOURCE_FILENAME = "base/RedBagLayer.csb"
C.RESOURCE_BINDING = {
	openBtn = {path="Button_open",events={{event="click",method="onClickOpenBtn"}}},
    panelBtn = {path="Panel_1",events={{event="click",method="onClickPanel"}}},
	nodeAnim = {path="Node_animOpen"},
    nodeAnimed = {path="Node_animOpened"},
    labelNum = {path="label_num"},
    imgFront = {path="label_num.img_front"},
    imgBack = {path="label_num.img_back"},
}

function C:onCreate()
	C.super.onCreate(self)
    self:loadPaySkelentonAnimation()
end

function C:show( money )
	C.super.show(self)
    self.onGetSucc = handler(self,self.onGetSuccess)
    eventManager:on("GetRedEnvelopeSucc",self.onGetSucc)
    self.onGetFail = handler(self,self.onGetFailed)
    eventManager:on("GetRedEnvelopeFailed",self.onGetFail)
    
    self.openBtn:setVisible(true)
    self.labelNum:setVisible(false)

    self.nodeAnim:setVisible(true)
    self.redbagNode:setAnimation(0,"animation",true)

    self.nodeAnimed:setVisible(false)
end

function C:onGetSuccess(money)
    self:setMoney(money)
end

function C:onGetFailed()
    self:hide()
end

function C:setMoney(money)
    self.labelNum:setString(utils:moneyString(money,2))
    self.nodeAnim:setVisible(false)
    self.nodeAnimed:setVisible(true)
    self.redbagNodeed:setAnimation(0,"animation",false)
    self.openBtn:setVisible(false)
end

function C:loadPaySkelentonAnimation()
    local redbagAnimName = "base/animation/skeleton/redbag/red_box"
    self.redbagNode = sp.SkeletonAnimation:create(redbagAnimName .. ".json", redbagAnimName .. ".atlas", 1)
--    self.redbagNode:setAnimation(0,"animation",true)
	self.nodeAnim:addChild( self.redbagNode )

    local redbagAnimedName = "base/animation/skeleton/redbag/red_box3"
    self.redbagNodeed = sp.SkeletonAnimation:create(redbagAnimedName .. ".json", redbagAnimedName .. ".atlas", 1)
--    self.redbagNodeed:setAnimation(0,"animation",false)
	self.nodeAnimed:addChild( self.redbagNodeed )

    self.redbagNodeed:registerSpineEventHandler(function(event)
        if event.animation == "animation" then
            if event.eventData.name == "open" then
                utils:createTimer("redbag.hideRedBagLayer",2,function()
			        self:hide()
		        end)
                self.labelNum:setVisible(true)
                self.imgFront:setPositionX(0)
                self.imgBack:setPositionX(self.labelNum:getContentSize().width)
            end
        end
    end,sp.EventType.ANIMATION_EVENT)
end

function C:onClickOpenBtn( event )
	eventManager:publish("GetRedEnvelope")
--    self:hide()
end

function C:onClickPanel( event )
end

function C:onHide()
	C.super.onHide(self)
end

function C:onExit()
    utils:removeTimer("redbag.hideRedBagLayer")
    eventManager:off("GetRedEnvelopeSucc",self.onGetSucc)
    eventManager:off("GetRedEnvelopeFailed",self.onGetFail)
    C.super.onExit(self)
end

return RedBagLayer