local C = class("EventManager");
EventManager = C

C.eventReceivers = {}
C.eventParams = {}
C.openInstallParam = nil

--订阅事件
function C:on(eventName,eventReceiver)

    if nil == self.eventReceivers[eventName] then
		self.eventReceivers[eventName]={}
	end

    for k,v in pairs(self.eventReceivers[eventName]) do
        if v == eventReceiver then
            return
        end
    end

    table.insert (self.eventReceivers[eventName], eventReceiver)

    if self.eventParams[eventName] ~= nil then
        local params = self.eventParams[eventName]
        local str = "local e = require(\"app.manager.EventManager\"),"
        for i = 1,#params,1 do
            str = str.."p"..tostring(i)..","
        end
        str = string.sub(str, 1, -2)
        str = str.."\nfor i=1,#(e.eventParams[...]),1 do\n"
        for i = 1,#params,1 do
            str = str.."p"..tostring(i).." = e.eventParams[...]["..tostring(i).."]\n"
        end
        str = str .. "end\n return "
        for i = 1,#params,1 do
            str = str.."p"..tostring(i)..","
        end
        str = string.sub(str, 1, -2)

        local getParams = loadstring(str)

        self:send(eventName,getParams(eventName))

        self.eventParams[eventName] = nil
    end
end

--取消订阅
function C:off(eventName,eventReceiver)
    
    if self.eventReceivers[eventName] ~= nil then
        for k,v in pairs(self.eventReceivers[eventName]) do
            if v == eventReceiver then
                self.eventReceivers[eventName][k] = nil
            end
        end
    end
end

--清除所有订阅
function C:clear(eventName)
    self.eventReceivers[eventName] = nil
end

--发布事件
function C:publish(eventName,...)

    if self.eventReceivers[eventName] == nil then
        printInfo("还没有人订阅该事件噢："..(eventName));
		return;
	end

    for k,v in pairs(self.eventReceivers[eventName]) do
        if v ~= nil then
            --printInfo("publish:"..(eventName))
            v(...);
        end
    end
end

--发送事件，要求必须有接收者，没有则等待
function C:send(eventName,...)

    if self.eventReceivers[eventName] == nil then
        --printInfo("还没有人订阅该事件噢："..(...));

        if ... ~= nil then
            self.eventParams[eventName] = {...}
        end

		return;
	end
    for k,v in pairs(self.eventReceivers[eventName]) do
        if v ~= nil then
            v(...);
        end
    end
end

--TODO:开启openUrl处理
function C:setupHandleOpenUrl()
    if utils then
        utils:registerOpenUrlHandler(handler(self,self.handleOpenUrl))
    end
end

--TODO:处理第三方应用调起本游戏
function C:handleOpenUrl( url )
    printInfo("=========handleOpenUrl:"..tostring(url))
    DialogLayer.new():show(tostring(url))
end

function C:wakeUpCallBack(result)
     release_print("拉起参数回调:"..result)
end
function C:setupOpenInstallWakeUp()
    if openInstall then
        openInstall:registerWakeUpHandler(handler(self,self.wakeUpCallBack))
    end
end
function C:getInstallCallBack(result)
     release_print("安装参数回调:"..result)
     self.openInstallParam = json.decode(result)
end
function C:setupOpenInstallgetInstall()
    if openInstall then
        openInstall:getInstall(6,handler(self,self.getInstallCallBack))
    end
end

eventManager = EventManager.new()

--TODO:
eventManager:setupOpenInstallWakeUp()
eventManager:setupOpenInstallgetInstall()
--eventManager:setupHandleOpenUrl()

return EventManager