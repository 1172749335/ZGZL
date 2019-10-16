local C = class("BaseLayer",ViewBase)
BaseLayer = C

--是否使用显示隐藏动画
C.USE_ACTION = true
--是否需要清理
C.NEED_CLEANUP = false
--是否使用模态
C.USE_MODAL = true
-- 模态颜色
C.MODAL_COLOR = cc.c3b(0,0,0)
--遮罩层
C.maskLayer = nil

function C:onCreate()
	if self.resourceNode then
		self.resourceNode:setAnchorPoint(0.5,0.5)
		self.resourceNode:setPosition(display.cx,display.cy)
	end

	if self.USE_MODAL then
		self.maskLayer = ccui.Layout:create()
		self.maskLayer:setContentSize(cc.size(display.width*2,display.height*2))
		self.maskLayer:setTouchEnabled(true)
		self.maskLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		self.maskLayer:setBackGroundColor(self.MODAL_COLOR)
		self.maskLayer:setOpacity(0)
		self:addChild(self.maskLayer,-1)
	end
end

function C:show(parent,x,y)
	parent = parent or display.getRunningScene()
	if parent == nil then
		return
	end

	if self:getParent() then
		self:removeFromParent(self.NEED_CLEANUP)
	end
	parent:addChild(self)
	
	if x and y then
		self.resourceNode:setPosition(x,y)
	end
	if not self.USE_ACTION then
        if self.maskLayer then
		    self.maskLayer:setOpacity(153)
	    end
		return
	end
	self.resourceNode:setScale(0)
	-- self.resourceNode:setOpacity(0)

    self.resourceNode:runAction( transition.sequence({
        cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)),
		cc.CallFunc:create(function()
			self:onTransFinish()
		end)
	}) )
	--transition.scaleTo(self.resourceNode,{time = 0.3,easing = {"BACKOUT",2},scale = 1})
	-- transition.fadeTo(self.resourceNode,{time = 0.2,opacity = 255})

	if self.maskLayer then
		self.maskLayer:setOpacity(50)
		self.maskLayer:runAction(cc.FadeTo:create(0.3, 153))
	end
end

function C:onTransFinish()
	printInfo("========================BaseLayer:onTransFinish")
end

function C:onEnter()
	printInfo("========================BaseLayer:onEnter")
	if self.maskLayer then
		self.maskLayer:setTouchEnabled(true)
	end
end

function C:onExit()
	printInfo("========================BaseLayer:onExit")
end

function C:hide()
	if not self.USE_ACTION then
		self:onHide()
		return
	end
	if tolua.isnull(self) then return end

	transition.scaleTo(self.resourceNode,{time = 0.3,easing = {"BACKIN",2},scale = 0,onComplete = handler(self,self.onHide)})
	-- transition.fadeTo(self.resourceNode,{time = 0.2,opacity = 0})

	if self.maskLayer then
		self.maskLayer:runAction(cc.FadeTo:create(0.3, 0))
	end
end

function C:onHide()
	if not tolua.isnull(self) and self:getParent() then
		self:removeFromParent(self.NEED_CLEANUP)
	end
end

return BaseLayer