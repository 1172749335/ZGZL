
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()

	local GameScene = require "app.majia.MainScene"
	self.miniGameScene = GameScene:create()
	self.miniGameScene:addTo(self)
end

return MainScene
