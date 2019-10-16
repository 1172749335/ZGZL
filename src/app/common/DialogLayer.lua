local C = class("DialogLayer",BaseLayer)
DialogLayer = C

C.RESOURCE_FILENAME = "common/DialogLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="onClickCloseBtn"}}},
	textLabel = {path="box_img.label"},
	confirmBtn = {path="box_img.confirm_btn",events={{event="click",method="onClickConfirmBtn"}}},
}

C.callback = nil
C.closeEvent = nil

function C:ctor( cancelEnabled )
	C.super.ctor(self)
	if cancelEnabled == false then
		self.closeBtn:setVisible(false)
	end
end

function C:show( text,callback,closeEvent)
    if webLayer then
        webLayer:hide()
    end
	C.super.show(self)
	self.textLabel:setString(text)
	self.callback = callback

    if closeEvent then
        self.closeEvent = closeEvent
        self.closeEventHandler = handler(self,self.onHide)
        eventManager:on(self.closeEvent,self.closeEventHandler)
    end
end

function C:onHide()
	C.super.onHide(self)
end

function C:onExit()
	if self.closeEvent and self.closeEventHandler then
        eventManager:off(self.closeEvent,self.closeEventHandler)
    end
	C.super.onExit(self)
end

function C:onClickCloseBtn( event )
	self:hide()
	if self.callback then
		self.callback(false)
	end
end

function C:onClickConfirmBtn( event )
	self:hide()
	if self.callback then
		self.callback(true)
	end
end

return DialogLayer