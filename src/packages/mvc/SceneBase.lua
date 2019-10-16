local C = class("SceneBase",ViewBase)
SceneBase = C

C.core = nil

function C:ctor( core )
	C.super.ctor(self)
	self.core = core
end

function C:showWithScene(transition, time, more)
	self:setVisible(true)
    local scene = display.newScene()
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function C:onEnter()
	-- 随机种子
	math.randomseed(tostring(os.time()):reverse():sub(1,6))
	-- 避免内存泄漏
	collectgarbage( "setpause", 100)
    collectgarbage( "setstepmul", 5000)
	print("==================进入场景："..self.class.__cname.." at:"..os.date("%Y-%m-%d %H:%M:%S", os.time()))
	print("==================进入场景："..collectgarbage("count"))
end

function C:onExit()
	if self.core and self.core.exit then
		self.core:exit()
	end
	self.resourceNode:removeAllChildren(true)
	self:removeAllChildren(true)
	self.core = nil
	self.RESOURCE_BINDING = nil
	display.removeUnusedSpriteFrames()
	collectgarbage("collect")
	print("=============================退出场景："..self.class.__cname.." at:"..os.date("%Y-%m-%d %H:%M:%S", os.time()))
	print("=============================退出场景："..collectgarbage("count"))
end

return SceneBase