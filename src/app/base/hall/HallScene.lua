local C = class("HallScene",SceneBase)
HallScene = C

C.RESOURCE_FILENAME = "base/HallScene.csb"
C.RESOURCE_BINDING = {
}

C.miniGameScene = nil

function C:onExit()
	--退出的时候调用小游戏的退出方法，在里面清楚定时器，停止音乐相关东西
	self.miniGameScene:onExit()
	C.super.onExit(self)
end

function C:initialize()
	--小游戏
	local GameScene = require "app.majia.MainScene"
	self.miniGameScene = GameScene:create()
	self.miniGameScene:addTo(self)
end

return HallScene
