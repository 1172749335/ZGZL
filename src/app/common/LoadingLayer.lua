local C = class("LoadingLayer",BaseLayer)
LoadingLayer = C

C.RESOURCE_FILENAME = "common/LoadingLayer.csb"
C.RESOURCE_BINDING = {
	bg = {path="bg"},
	icon = {path="bg.icon"},
	label = {path="bg.label"}
}

--是否使用显示隐藏动画
C.USE_ACTION = false
-- 模态颜色
C.MODAL_COLOR = cc.c3b(0,0,0)

function C:show( text, parent, timeout )
	if type(parent) == "number" then
		C.super.show(self)
	else
		C.super.show(self,parent)
	end
	self:setLocalZOrder(1000)
	text = text or "请稍后..."
	self.label:setString(text)
	local width = self.label:getContentSize().width + 110
	local height = self.bg:getContentSize().height
	self.bg:setContentSize(cc.size(width,height))
	self.icon:stopAllActions()
	local action = cc.RotateBy:create(1,360)
	self.icon:runAction(cc.RepeatForever:create(action))
	if timeout == nil and parent ~= nil and type(parent) == "number" then
		timeout = parent
	end
	timeout = timeout or 10
	self:startTimer(timeout)
end

function C:startTimer( timeout )
	self:stopTimer()
	utils:createTimer("LoadingLayer",timeout,function()
		self:hide()
	end)
end

function C:stopTimer()
	utils:removeTimer("LoadingLayer")
end

function C:hide()
	self:stopTimer()
	self.icon:stopAllActions()
	C.super.hide(self)
end

return LoadingLayer