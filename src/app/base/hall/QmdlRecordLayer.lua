local C = class("QmdlRecordLayer",BaseLayer)
QmdlRecordLayer = C

C.RESOURCE_FILENAME = "base/QmdlRecordLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
    recordItem = {path="box_img.item"},
    recordList = {path="box_img.listview_0"},
}

function C:onCreate()
	C.super.onCreate(self)
    self.recordItem:setVisible(false)
end

function C:show()
	C.super.show(self)

    if dataManager.qmdlrecord ~= nil then
        self:refreshRecordList(dataManager.qmdlrecord.data)
    end
    self.onLoadRecordHandler = handler(self,self.onLoadRecord)
    eventManager:on("RepQmdlRecode",self.onLoadRecordHandler)
end

function C:onExit()
    eventManager:off("RepQmdlRecode",self.onLoadRecordHandler)
	C.super.onExit(self)
end

function C:onLoadRecord(  )
    if dataManager.qmdlrecord == nil then
        return
    end
    self:refreshRecordList(dataManager.qmdlrecord.data)
end

function C:refreshRecordList( list )
	if list == nil or #list == 0 then
		return
	end

    self.recordList:removeAllItems()
	for i,v in ipairs(list) do
		local item = self.recordItem:clone()
		item:setVisible(true)
		item:getChildByName("recharge_label"):setString(v.profit)
        item:getChildByName("time_label"):setString(v.date)
		self.recordList:pushBackCustomItem(item)
	end
end

return QmdlRecordLayer