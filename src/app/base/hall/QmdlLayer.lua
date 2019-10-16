local C = class("QmdlLayer",BaseLayer)
QmdlLayer = C

C.RESOURCE_FILENAME = "base/QmdlLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="close_btn",events={{event="click",method="hide"}}},
	wxLabel = {path="wx_label_1"},
	wxBtn = {path="wx_btn_1",events={{event="click",method="onClickWxBtn"}}},
	wxLabel2 = {path="wx_label_2"},
	wxBtn2 = {path="wx_btn_2",events={{event="click",method="onClickWxBtn2"}}},
}

function C:onCreate()
	C.super.onCreate(self)
	self.wxLabel:setString("")
	self.wxLabel2:setString("")
end

function C:show( wx1, wx2 )
	C.super.show(self)
	self.wxLabel:setString(wx1)
	self.wxLabel2:setString(wx2)
end

function C:onClickWxBtn( event )
	local text = self.wxLabel:getString() or ""
	platform.setClipboardText(text)
	toastLayer:show("复制成功，即将打开微信...")
	utils:delayInvoke("hall.openwx",3,function()
		platform.openApp("wx")
		self:hide()
	end)
end

function C:onClickWxBtn2( event )
	local text = self.wxLabel2:getString() or ""
	platform.setClipboardText(text)
	toastLayer:show("复制成功，即将打开微信...")
	utils:delayInvoke("hall.openwx2",3,function()
		platform.openApp("wx")
		self:hide()
	end)
end
function C:onHide()
	C.super.onHide(self)
    dataManager:stopHumanSound("qmdl")
end
return QmdlLayer