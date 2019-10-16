local C = class("ZcsjLayer",BaseLayer)
ZcsjLayer = C

C.RESOURCE_FILENAME = "base/ZcsjLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="close_btn",events={{event="click",method="hide"}}},
	registerBtn = {path="register_btn",events={{event="click",method="onClickRegisterBtn"}}},
}

function C:onClickRegisterBtn( event )
	RegisterLayer.new():show()
	self:hide()
end

return ZcsjLayer