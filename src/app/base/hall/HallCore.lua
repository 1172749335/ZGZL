local C = class("HallCore",CoreBase)
HallCore = C

C.MODULE_PATH = "app.base.hall"
C.SCENE_CONFIG = {scenename = "HallScene", filename = "HallScene"}

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	self.scene:initialize()
end

function C:exit()
    C.super.exit(self)
end

return HallCore