local C = class("QmdlSelectLayer",BaseLayer)
QmdlSelectLayer = C

C.RESOURCE_FILENAME = "base/QmdlSelectLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="close_btn",events={{event="click",method="hide"}}},
    imgSel1 = {path="Img_sel1",events={{event="click",method="onClickImg1"}}},
    imgQrcode1 = {path="Img_sel1.Image"},
    imgSel2 = {path="Img_sel2",events={{event="click",method="onClickImg2"}}},
    imgQrcode2 = {path="Img_sel2.Image"},
    imgSel3 = {path="Img_sel3",events={{event="click",method="onClickImg3"}}},
    imgQrcode3 = {path="Img_sel3.Image"},
    imgSelect = {path="Img_sel"},
    saveBtn = {path="Button_save",events={{event="click",method="onClickSave"}}},
    shareCircleBtn = {path="Button_share",events={{event="click",method="onClickShareCircle"}}},
    shareQunBtn = {path="Button_sharequn",events={{event="click",method="onClickShareQun"}}},
}

C.selIndex = 1
C.qrcodeUrl = nil

function C:onCreate()
	C.super.onCreate(self)
    self.selIndex = 1

    self.imgQrcode1:setVisible(false)
    self.imgQrcode2:setVisible(false)
    self.imgQrcode3:setVisible(false)
end

function C:show(url)
	C.super.show(self)
    self.qrcodeUrl = url

    local storagePath = DOWNLOAD_PATH.."res/"..Md5.sumhexa(tostring(self.qrcodeUrl))..".png"
    if cc.FileUtils:getInstance():isFileExist(storagePath) then
        self.imgQrcode1:setVisible(true)
        self.imgQrcode2:setVisible(true)
        self.imgQrcode3:setVisible(true)

        self.imgQrcode1:loadTexture(storagePath)
        self.imgQrcode2:loadTexture(storagePath)
        self.imgQrcode3:loadTexture(storagePath)
    else
        self.imgQrcode1:setVisible(false)
        self.imgQrcode2:setVisible(false)
        self.imgQrcode3:setVisible(false)
        if CHANNEL_ID ~= 18 and CHANNEL_ID ~= 22 and CHANNEL_ID ~= 36 then
            local qr = QrNode:createQrNode(self.qrcodeUrl, 120, 5, 1)
            qr:setPosition(133, 99)
            self.imgSel1:addChild(qr)
    
            local qr2 = QrNode:createQrNode(self.qrcodeUrl, 120, 5, 1)
            qr2:setPosition(133, 99)
            self.imgSel2:addChild(qr2)

            local qr3 = QrNode:createQrNode(self.qrcodeUrl, 120, 5, 1)
            qr3:setPosition(133, 99)
            self.imgSel3:addChild(qr3)
        end
    end
end

function C:onExit()
    C.super.onExit(self)
end

function C:onClickSave()
    self:saveToPhoto()
end

function C:onClickShareCircle()
    self:shareToWx("","",2,1)
end

function C:onClickShareQun()
    self:shareToWx("","",2,0)
end

function C:onClickImg1()
    if self.selIndex ~= 1 then
        self.selIndex = 1
        self.imgSelect:setPosition(self.imgSel1:getPosition())
    end
end

function C:onClickImg2()
    if self.selIndex ~= 2 then
        self.selIndex = 2
        self.imgSelect:setPosition(self.imgSel2:getPosition())
    end
end

function C:onClickImg3()
    if self.selIndex ~= 3 then
        self.selIndex = 3
        self.imgSelect:setPosition(self.imgSel3:getPosition())
    end
end

function C:saveToPhoto()
    if self.qrcodeUrl == nil then
        return
    end

    if CHANNEL_ID == 18 or CHANNEL_ID == 22 or CHANNEL_ID == 36 then
        local storagePath = DOWNLOAD_PATH.."res/"..Md5.sumhexa(tostring(self.qrcodeUrl))..".png"
        if cc.FileUtils:getInstance():isFileExist(storagePath) then
            utils:saveImage(storagePath,function( success )
    	        if success == true or tonumber(success) == 1 then
    		        toastLayer:show("保存成功")
    	        else
    		        toastLayer:show("保存失败，请检查相册权限是否开启",3)
    	        end
    	    end)
        end
        return
    end

    local selectedImg = self.imgSel1
    if self.selIndex == 2 then
        selectedImg = self.imgSel2
    elseif self.selIndex == 3 then
        selectedImg = self.imgSel3
    end

    local m_qrFrameRect = nil
    if device.platform == "ios" then
        local bgsize = selectedImg:getContentSize()
        local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        local xRate = framesize.width / display.width 
        local yRate = framesize.height / display.height
        local screenPos = selectedImg:convertToWorldSpace(cc.p(bgsize.width * 0.5, bgsize.height * 0.5))
        local framePosX = (screenPos.x -  bgsize.width/2) * xRate
        local framePosY = (screenPos.y -  bgsize.height/2) * yRate
        local frameWidth = bgsize.width * xRate
        local frameHeight = bgsize.height * yRate
        m_qrFrameRect=cc.rect(framePosX, framePosY, frameWidth, frameHeight)
     else
        local bgsize = selectedImg:getContentSize()
        local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        local xRate = framesize.width / display.width 
        local yRate = framesize.height / display.height
        local screenPos = selectedImg:convertToWorldSpace(cc.p(bgsize.width * 0.5, bgsize.height * 0.5))
        local framePosX = (screenPos.x -  bgsize.width/2) * xRate
        local framePosY = (screenPos.y -  bgsize.height/2) * yRate
        local frameWidth = bgsize.width * xRate
        local frameHeight = bgsize.height * yRate
        m_qrFrameRect=cc.rect(framePosX, framePosY, frameWidth, frameHeight)
    end
    captureScreenWithArea(m_qrFrameRect, "qmdl_share.jpg", function(ok, savepath)
        release_print(ok,savepath)
        if ok then
            utils:saveImage(savepath,function( success )
    	        if success == true or tonumber(success) == 1 then
    		        toastLayer:show("保存成功")
    	        else
    		        toastLayer:show("保存失败，请检查相册权限是否开启",3)
    	        end
    	    end)
        end
    end )
end

function C:shareToWx(title, desc, wxtype, wxscene)
    if self.qrcodeUrl == nil then
        return
    end

    if CHANNEL_ID == 18 or CHANNEL_ID == 22 or CHANNEL_ID == 36 then
        local storagePath = DOWNLOAD_PATH.."res/"..Md5.sumhexa(tostring(self.qrcodeUrl))..".png"
        if cc.FileUtils:getInstance():isFileExist(storagePath) then
            local info = {}
	        info.title = title
	        info.description = desc
	        info.imagePath = storagePath
            utils:shareToWechat(wxtype,wxscene,info)
        end
        return
    end

    local selectedImg = self.imgSel1
    if self.selIndex == 2 then
        selectedImg = self.imgSel2
    elseif self.selIndex == 3 then
        selectedImg = self.imgSel3
    end

    local m_qrFrameRect = nil
    if device.platform == "ios" then
        local bgsize = selectedImg:getContentSize()
        local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        local xRate = framesize.width / display.width 
        local yRate = framesize.height / display.height
        local screenPos = selectedImg:convertToWorldSpace(cc.p(bgsize.width * 0.5, bgsize.height * 0.5))
        local framePosX = (screenPos.x -  bgsize.width/2) * xRate
        local framePosY = (screenPos.y -  bgsize.height/2) * yRate
        local frameWidth = bgsize.width * xRate
        local frameHeight = bgsize.height * yRate
        m_qrFrameRect=cc.rect(framePosX, framePosY, frameWidth, frameHeight)
     else
        local bgsize = selectedImg:getContentSize()
        local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        local xRate = framesize.width / display.width 
        local yRate = framesize.height / display.height
        local screenPos = selectedImg:convertToWorldSpace(cc.p(bgsize.width * 0.5, bgsize.height * 0.5))
        local framePosX = (screenPos.x -  bgsize.width/2) * xRate
        local framePosY = (screenPos.y -  bgsize.height/2) * yRate
        local frameWidth = bgsize.width * xRate
        local frameHeight = bgsize.height * yRate
        m_qrFrameRect=cc.rect(framePosX, framePosY, frameWidth, frameHeight)
    end
    
    captureScreenWithArea(m_qrFrameRect, "qmdl_share.jpg", function(ok, savepath)
        release_print(ok,savepath)
        if ok then
            local info = {}
	        info.title = title
	        info.description = desc
	        info.imagePath = savepath
            utils:shareToWechat(wxtype,wxscene,info)
        end
    end )
end

return QmdlSelectLayer