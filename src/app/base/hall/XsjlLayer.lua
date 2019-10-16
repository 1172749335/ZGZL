local C = class("XsjlLayer",BaseLayer)
XsjlLayer = C

C.RESOURCE_FILENAME = "base/XsjlLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="close_btn",events={{event="click",method="hide"}}},
	confirmBtn = {path="confirm_btn",events={{event="click",method="hide"}}}
}

return XsjlLayer