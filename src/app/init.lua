package.loaded["app.config"] = nil
package.loaded["app.channel"] = nil
package.loaded["app.utils.init"] = nil
package.loaded["packages.openinstall"] = nil
package.loaded["app.network.ServerList"] = nil
package.loaded["app.manager.DataManager"] = nil
package.loaded["app.manager.EventManager"] = nil
package.loaded["packages.mvc.init"] = nil
package.loaded["app.common.init"] = nil
package.loaded["app.base.init"] = nil

local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
customEventDispatch:removeAllEventListeners()
customEventDispatch:addEventListenerWithFixedPriority(cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",function () eventManager:publish("OnPause") end), 1)
customEventDispatch:addEventListenerWithFixedPriority(cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",function () eventManager:publish("OnResume") end), 1)

require("cocos.cocos2d.json")
require("app.config")
require("app.channel")
require("app.version")
require("app.utils.init")
require("packages.openinstall")
require("app.network.ServerList")
require("app.manager.DataManager")
require("app.manager.EventManager")
require("packages.mvc.init")
require("app.common.init")
require("app.base.init")

function ENTER_UPDATE(isFromUpdateChecker)
	UpdateCore.new(isFromUpdateChecker):run()
    SCENE_NAME = "Update"
end