local C = class("QmdlPopupLayer",BaseLayer)
QmdlPopupLayer = C

require("app.base.hall.QmdlHelpLayer")
require("app.base.hall.QmdlRecordLayer")

C.RESOURCE_FILENAME = "base/QmdlPopupLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},

	--tab btns
    wdtgBtn = {path="box_img.tab_listview.wdtg_btn",events={{event="click",method="onClickWdtgBtn"}}},
    smBtn = {path="box_img.tab_listview.sm_btn",events={{event="click",method="onClickSmBtn"}}},
	tgmxBtn = {path="box_img.tab_listview.tgmx_btn",events={{event="click",method="onClickTgmxBtn"}}},
	zbBtn = {path="box_img.tab_listview.zb_btn",events={{event="click",method="onClickZbBtn"}}},

    --panels
    wdtgPanel = {path="box_img.wdtg_panel"},
	smPanel = {path="box_img.sm_panel"},
	tgmxPanel = {path="box_img.tgmx_panel"},
	zbPanel = {path="box_img.zb_panel"},

    --我的推广页面
    wdtgLabel1 = {path="box_img.wdtg_panel.bg_img.Text_1"},
	wdtgLabel2_1 = {path="box_img.wdtg_panel.bg_img.Text_2.Text_1"},
    wdtgLabel2_2 = {path="box_img.wdtg_panel.bg_img.Text_2.Text_2"},
	wdtgLabel3 = {path="box_img.wdtg_panel.bg_img.Text_3"},
    wdtgLabel4_1 = {path="box_img.wdtg_panel.bg_img.Text_4.Text_1"},
    wdtgLabel4_2 = {path="box_img.wdtg_panel.bg_img.Text_4.Text_2"},
    wdtgLabel5 = {path="box_img.wdtg_panel.bg_img.Text_5"},

    wdtgLabelHistory = {path="box_img.wdtg_panel.apply_panel.Image_history.Text_num"},
    wdtgLabelTotal = {path="box_img.wdtg_panel.apply_panel.Image_total.Text_num"},

    wdtgRewardBtn = {path="box_img.wdtg_panel.apply_panel.reward_btn",events={{event="click",method="onClickRewardBtn"}}},
    wdtgRecordBtn = {path="box_img.wdtg_panel.apply_panel.record_btn",events={{event="click",method="onClickRecordBtn"}}},
    wdtgHelpBtn = {path="box_img.wdtg_panel.apply_panel.help_btn",events={{event="click",method="onClickHelpBtn"}}},
    wdtgScaleBtn = {path="box_img.wdtg_panel.share_panel.Button_scale",events={{event="click",method="onClickScaleBtn"}}},
    wdtgShareWxBtn = {path="box_img.wdtg_panel.share_panel.share_btn",events={{event="click",method="onClickShareWxBtn"}}},
    wdtgShareQunBtn = {path="box_img.wdtg_panel.share_panel.save_btn",events={{event="click",method="onClickShareQunBtn"}}},

    wdtgQrcodeBg = {path="box_img.wdtg_panel.share_panel.qrcode_bg",events={{event="click",method="onClickRefreshQr"}}},
    wdtgQrcode = {path="box_img.wdtg_panel.share_panel.qrcode_bg.img"},

    --说明页面
    smOpenQQ = {path="box_img.sm_panel.get_btn",events={{event="click",method="onClickOpenQQBtn"}}},
    smLabelQQ = {path="box_img.sm_panel.Text_qq"},
    smImgQQ = {path="box_img.sm_panel.Image_qq"},
    smImgWX = {path="box_img.sm_panel.Image_wx"},

    --推广明细页面
    tgmxList = {path="box_img.tgmx_panel.Panel_list.listview_0"},
    tgmxItem = {path="box_img.tgmx_panel.item"},
    tgmxEmpty = {path="box_img.tgmx_panel.Sprite_empty"},
    tgmxPanelList = {path="box_img.tgmx_panel.Panel_list"},

    --周榜页面
    zbList = {path="box_img.zb_panel.listview"},
    zbItem = {path="box_img.zb_panel.item"},
}

function C:onCreate()
	C.super.onCreate(self)
    self.zbItem:setVisible(false)
    self.tgmxItem:setVisible(false)
    self.tgmxPanelList:setVisible(false)
    self.tgmxEmpty:setVisible(false)
    self.wdtgQrcode:setVisible(false)
end

function C:show()
	C.super.show(self)

    self.onLoadWdtgHandler = handler(self,self.onLoadWdtg)
    eventManager:on("RepQmdlWdtg",self.onLoadWdtgHandler)
    self.onLoadTgmxHandler = handler(self,self.onLoadTgmx)
    eventManager:on("RepQmdlTgmx",self.onLoadTgmxHandler)
    self.onLoadZbHandler = handler(self,self.onLoadZb)
    eventManager:on("RepQmdlZb",self.onLoadZbHandler)
    self.onLoadQrcodeHandler = handler(self,self.onLoadQrcode)
    eventManager:on("RepQmdlQrcode",self.onLoadQrcodeHandler)
    eventManager:on("RefreshQmdlUrl",self.onLoadQrcodeHandler)

    self:showTabPanel(1)
end

function C:onExit()
    eventManager:off("RepQmdlWdtg",self.onLoadWdtgHandler)
    eventManager:off("RepQmdlTgmx",self.onLoadTgmxHandler)
    eventManager:off("RepQmdlZb",self.onLoadZbHandler)
    eventManager:off("RepQmdlQrcode",self.onLoadQrcodeHandler)
    eventManager:off("RefreshQmdlUrl",self.onLoadQrcodeHandler)

    if self.qmdlSelectLayer then
		self.qmdlSelectLayer:release()
        self.qmdlSelectLayer = nil
	end
	C.super.onExit(self)
end

function C:showTabPanel( index )
	self.wdtgPanel:setVisible(index==1)
	self.smPanel:setVisible(index==2)
	self.tgmxPanel:setVisible(index==3)
	self.zbPanel:setVisible(index==4)

	self.wdtgBtn:setEnabled(index~=1)
	self.smBtn:setEnabled(index~=2)
	self.tgmxBtn:setEnabled(index~=3)
	self.zbBtn:setEnabled(index~=4)

    if index == 1 then
        self:onLoadWdtg()
    elseif index == 2 then
        self:onLoadWdtg()
    elseif index == 3 then
        self:onLoadTgmx()
    else
        self:onLoadZb()
    end
end

function C:onClickWdtgBtn( event )
    self:showTabPanel(1)
end

function C:onClickSmBtn( event )
    self:showTabPanel(2)
end

function C:onClickTgmxBtn( event )
    if dataManager.qmdltgmx == nil then
        eventManager:publish("RequestQmdlTgmx")
    end
    
    self:showTabPanel(3)
	self.tgmxList:jumpToTop()
end

function C:onClickZbBtn( event )
    if dataManager.qmdlzb == nil then
        eventManager:publish("RequestQmdlZb")
    end

    self:showTabPanel(4)
	self.zbList:jumpToTop()
end

function C:onClickRewardBtn( event )
    if dataManager.qmdlwdtg == nil then
        toastLayer:show("代理数据加载中，请稍后")
    elseif dataManager.qmdlwdtg.curMoney < 1 then
        toastLayer:show("暂无收益可提取")
    else
        eventManager:publish("RequestQmdlTqsy")
    end
end

function C:onClickRecordBtn( event )
    QmdlRecordLayer.new():show()
    if dataManager.qmdlrecord == nil then
        eventManager:publish("RequestQmdlRecord")
    end
end

function C:onClickHelpBtn( event )
    QmdlHelpLayer.new():show()
end

function C:onClickScaleBtn( event )
    if dataManager.qmdlwdtg == nil then
        toastLayer:show("代理数据加载中，请稍后")
        return
    end
    if self.qmdlSelectLayer == nil then
		self.qmdlSelectLayer = QmdlSelectLayer.new()
		self.qmdlSelectLayer:retain()
	end

	self.qmdlSelectLayer:show(dataManager.qmdlspurl.. dataManager.qmdlwdtg.spUrl)
end

function C:onClickShareWxBtn( event )
--    local info = {}
--	info.title = "标题1"
--	info.description = "描述1"
--	info.imagePath = self:testImagePath()
--    utils.shareToWechat(2,1,info)
--    self:createShareSprite("base/images/main_layer/bg.jpg","qmdl_qrcode.png","标题1","描述1",2,1)

    if dataManager.qmdlwdtg == nil then
        toastLayer:show("代理数据加载中，请稍后")
        return
    end
    if self.qmdlSelectLayer == nil then
		self.qmdlSelectLayer = QmdlSelectLayer.new()
		self.qmdlSelectLayer:retain()
	end
	self.qmdlSelectLayer:show(dataManager.qmdlspurl.. dataManager.qmdlwdtg.spUrl)
end

function C:onClickShareQunBtn( event )
--    if dataManager.qmdlwdtg == nil then
--        toastLayer:show("代理数据加载中，请稍后")
--        return
--    end
--    if self.qmdlSelectLayer == nil then
--		self.qmdlSelectLayer = QmdlSelectLayer.new()
--		self.qmdlSelectLayer:retain()
--	end
--	self.qmdlSelectLayer:show(dataManager.qmdlwdtg.spUrl)

    if dataManager.qmdlwdtg ~= nil then
--        if dataManager.qmdlwdtg.refreshTimes > 0 then
            loadingLayer:show("二维码刷新中...")
            eventManager:publish("RequestQmdlQrcode")
--        end
    else
        toastLayer:show("代理数据加载中，请稍后")
    end
end

function C:onClickOpenQQBtn( event )
    if dataManager.qmdlwdtg then
        if dataManager.qmdlwdtg.agentQQ and dataManager.qmdlwdtg.agentQQ ~= "" then
            utils:setCopy(dataManager.qmdlwdtg.agentQQ)
            toastLayer:show("复制成功，即将打开QQ...")
	        utils:delayInvoke("hall.qmdlsm",3,function()
		        platform.openApp("qq")
		        self:hide()
	        end)
        elseif dataManager.qmdlwdtg.agentWX and dataManager.qmdlwdtg.agentWX ~= "" then
            utils:setCopy(dataManager.qmdlwdtg.agentWX)
            toastLayer:show("复制成功，即将打开微信...")
	        utils:delayInvoke("hall.qmdlsm",3,function()
		        platform.openApp("wx")
		        self:hide()
	        end)
        end
    end
end

function C:onClickRefreshQr( event )
--    if dataManager.qmdlwdtg ~= nil then
--        eventManager:publish("RequestQmdlQrcode")
--    else
--        toastLayer:show("代理数据加载中，请稍后")
--    end
end

function C:onLoadWdtg(  )
    if dataManager.qmdlwdtg == nil then
        return
    end
    self.wdtgLabel1:setString(dataManager.qmdlwdtg.yesterdayTotalProfit)
    self.wdtgLabel2_2:setString("+".. dataManager.qmdlwdtg.childs)
    self.wdtgLabel2_1:setString(dataManager.qmdlwdtg.allChilds .."(")
    self.wdtgLabel2_1:setPositionX(0-(self.wdtgLabel2_2:getContentSize().width+2))
	self.wdtgLabel3:setString(dataManager.qmdlwdtg.yesterdayProfit)
    self.wdtgLabel4_2:setString("+".. dataManager.qmdlwdtg.subChilds)
	self.wdtgLabel4_1:setString(dataManager.qmdlwdtg.allSubChilds .."(")
    self.wdtgLabel4_1:setPositionX(0-(self.wdtgLabel4_2:getContentSize().width+2))
    self.wdtgLabel5:setString(dataManager.qmdlwdtg.yesterdaySubProfit)

    self.wdtgLabelHistory:setString(dataManager.qmdlwdtg.totalMoney)
    self.wdtgLabelTotal:setString(dataManager.qmdlwdtg.curMoney)

    self:onLoadQrcode()

    if dataManager.qmdlwdtg.agentQQ and dataManager.qmdlwdtg.agentQQ ~= "" then
        self.smLabelQQ:setString(dataManager.qmdlwdtg.agentQQ)
        self.smImgQQ:setVisible(true)
        self.smImgWX:setVisible(false)
    elseif dataManager.qmdlwdtg.agentWX and dataManager.qmdlwdtg.agentWX ~= "" then
        self.smLabelQQ:setString(dataManager.qmdlwdtg.agentWX)
        self.smImgQQ:setVisible(false)
        self.smImgWX:setVisible(true)
    end
end

function C:onLoadTgmx(  )
    if dataManager.qmdltgmx == nil then
        return
    end
    self:refreshTgmxList(dataManager.qmdltgmx.data)
end

function C:onLoadZb(  )
    if dataManager.qmdlzb == nil then
        return
    end
    self:refreshZbList(dataManager.qmdlzb.data)
end

function C:onLoadQrcode()
--    local qrnode = QrNode:createQrNode(dataManager.qmdlwdtg.spUrl, self.wdtgQrcode:getContentSize().width, 5, 1)
--    qrnode:setPosition(self.wdtgQrcode:getPosition())
--    self.wdtgQrcodeBg:removeChildByTag(111)
--    qrnode:setTag(111)
--    self.wdtgQrcodeBg:addChild(qrnode)

--    loadingLayer:hide()
    local spurl = dataManager.qmdlspurl.. dataManager.qmdlwdtg.spUrl
    local storagePath = DOWNLOAD_PATH.."res/"..Md5.sumhexa(tostring(spurl))..".png"
    if cc.FileUtils:getInstance():isFileExist(storagePath) then
        cc.FileUtils:getInstance():removeFile(storagePath)
    end
    local result = utils:createQRCode(spurl,120,storagePath)
    if not result then
        if CHANNEL_ID ~= 18 and CHANNEL_ID ~= 22 and CHANNEL_ID ~= 36 then
            local qrnode = QrNode:createQrNode(spurl, self.wdtgQrcode:getContentSize().width, 5, 1)
            qrnode:setPosition(self.wdtgQrcode:getPosition())
            self.wdtgQrcodeBg:removeChildByTag(111)
            qrnode:setTag(111)
            self.wdtgQrcodeBg:addChild(qrnode)
            self.wdtgQrcode:setVisible(false)
        end
    else
        self.wdtgQrcode:loadTexture(storagePath)
        self.wdtgQrcode:setVisible(true)
    end
end

function C:refreshTgmxList( list )
	if list == nil or #list == 0 then
        self.tgmxPanelList:setVisible(false)
        self.tgmxEmpty:setVisible(true)
		return
	end

    self.tgmxPanelList:setVisible(true)
    self.tgmxEmpty:setVisible(false)
    self.tgmxList:removeAllItems()
	for i,v in ipairs(list) do
		local item = self.tgmxItem:clone()
		item:setVisible(true)
		item:getChildByName("time_label"):setString(v.date)
        item:getChildByName("player1_label"):setString(v.childs)
        item:getChildByName("reward1_label"):setString(v.profit)
        item:getChildByName("player2_label"):setString(v.subChilds)
        item:getChildByName("reward2_label"):setString(v.subProfit)
		self.tgmxList:pushBackCustomItem(item)
	end
end

function C:refreshZbList( list )
	if list == nil or #list == 0 then
		return
	end

	self.zbList:removeAllItems()
	for i,v in ipairs(list) do
		local item = self.zbItem:clone()
		if i == 1 then
            item:getChildByName("Sprite_1"):setVisible(true)
            item:getChildByName("Sprite_2"):setVisible(false)
            item:getChildByName("Sprite_3"):setVisible(false)
            item:getChildByName("font_4"):setVisible(false)
		elseif i == 2 then
            item:getChildByName("Sprite_1"):setVisible(false)
            item:getChildByName("Sprite_2"):setVisible(true)
            item:getChildByName("Sprite_3"):setVisible(false)
            item:getChildByName("font_4"):setVisible(false)
		elseif i == 3 then
            item:getChildByName("Sprite_1"):setVisible(false)
            item:getChildByName("Sprite_2"):setVisible(false)
            item:getChildByName("Sprite_3"):setVisible(true)
            item:getChildByName("font_4"):setVisible(false)
		else
            item:getChildByName("Sprite_1"):setVisible(false)
            item:getChildByName("Sprite_2"):setVisible(false)
            item:getChildByName("Sprite_3"):setVisible(false)
            item:getChildByName("font_4"):setVisible(true)
            item:getChildByName("font_4"):setString(i)
		end
		item:setVisible(true)
		item:getChildByName("id_label"):setString(v.userID)
		item:getChildByName("recharge_label"):setString(v.profit)
		local headId = tonumber(v.headId) or 1
		local headUrl = v.wxheadurl
		local headImg = item:getChildByName("head_img")
    	SET_HEAD_IMG(headImg,headId,headUrl)
		self.zbList:pushBackCustomItem(item)
	end
end


return QmdlPopupLayer