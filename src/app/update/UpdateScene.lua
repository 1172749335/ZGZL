local C = class("UpdateScene",SceneBase)
UpdateScene = C

C.RESOURCE_FILENAME = "update/UpdateScene.csb"
C.RESOURCE_BINDING = {
	logoImg = {path="logo_img"},
	progressPanel = {path="progress_panel"},
	loading = {path="progress_panel.loading"},
	updating = {path="progress_panel.updating"},
	unziping = {path="progress_panel.unziping"},
	loging = {path="progress_panel.logining"},
	progressImg = {path="progress_panel.progress_img"},
	progressBar = {path="progress_panel.progress_img.progress_bar"}
}

function C:initialize()
	self.progressPanel:setVisible(false)
	self.loading:setVisible(false)
	self.updating:setVisible(false)
	self.unziping:setVisible(false)
	self.loging:setVisible(false)
	self.progressBar:setPercent(0)
	self:startProgressAni()
end

function C:onExit()
	self:hideTips()
	self:stopProgressAni()
	C.super.onExit(self)
end

function C:startProgressAni()
	self:stopProgressAni()
	local array = {}
	array[1] = cc.DelayTime:create(0.02)
	array[2] = cc.CallFunc:create(function()
		local percent = self.progressBar:getPercent() + 1
		if percent > 100 then
			percent = 100
			self.progressBar:setPercent(percent)
			self:stopProgressAni()
		else
			self.progressBar:setPercent(percent)
		end
		
	end)
    local act = cc.RepeatForever:create(cc.Sequence:create(array))
    act:setTag(888)
	self.progressImg:runAction(act)
end

function C:stopProgressAni()
	self.progressImg:stopAllActions()
end

--提示类型 1：加载中  2：更新中  3：解压中  4：登录中
function C:showTips( ctype )
	self.progressPanel:setVisible(true)
	self.loading:setVisible(false)
	self.loading:stopAllActions()
	self.updating:setVisible(false)
	self.updating:stopAllActions()
	self.unziping:setVisible(false)
	self.unziping:stopAllActions()
	self.loging:setVisible(false)
	self.loging:stopAllActions()
	if ctype == 1 then
		self:startDotAni(self.loading)
	elseif ctype == 2 then
		self:startDotAni(self.updating)
	elseif ctype == 3 then
		self:startDotAni(self.unziping)
	elseif ctype == 4 then
		self:startDotAni(self.loging)
	end
end

function C:hideTips()
	self:showTips(0)
	self.progressPanel:setVisible(false)
end

function C:startDotAni( node )
	node:setVisible(true)
	local dot1 = node:getChildByName("dot_1")
	local dot2 = node:getChildByName("dot_2")
	local dot3 = node:getChildByName("dot_3")
	dot1:setVisible(true)
	dot2:setVisible(true)
	dot3:setVisible(true)
	local array = {}
	array[1] = cc.DelayTime:create(0.5)
    array[2] = cc.CallFunc:create(function()
		dot1:setVisible(false)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
    array[3] = cc.DelayTime:create(0.25)
    array[4] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
    array[5] = cc.DelayTime:create(0.5)
    array[6] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(false)
	end)
	array[7] = cc.DelayTime:create(0.5)
    array[8] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(true)
	end)
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
end

--设置进度条 0~100
function C:setProgressBar( percent )
	self:stopProgressAni()
	self.progressBar:setPercent(percent)
end

return UpdateScene