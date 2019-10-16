local C = class("QmdlHelpLayer",BaseLayer)
QmdlHelpLayer = C

C.RESOURCE_FILENAME = "base/QmdlHelpLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
}

return QmdlHelpLayer