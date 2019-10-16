module("platform",package.seeall)
luaoc = require("cocos.cocos2d.luaoc")

OC_CLASS_NAME = "LuaObjectCBridge"


--切换横竖屏
function setOrientation( dir )
    local ocMethodName = "setOrientation"
    local args = {
        dir = dir
    }
    local ok,ret = luaoc.callStaticMethod(OC_CLASS_NAME, ocMethodName, args)
    if not ok then
    	printInfo("==== call oc setOrientation failed")
    else 
    	printInfo("==== call oc setOrientation success")
        return 1
    end
    return 0
end