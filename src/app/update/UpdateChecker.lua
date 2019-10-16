local UpdateChecker = class("UpdateChecker")
--检查服务器配置更新状态 0：未返回 1：不更新 2：更新
UpdateChecker.checkAppleStatus = 0
--检查是IP是否是美国状态 0：未返回 1：是 2：否
UpdateChecker.checkIpStatus = 0


--TODO:配置开启更新时间
local OPEN_YEAR = 2019
local OPEN_MONTH = 6
local OPEN_DAY = 11


function UpdateChecker:check()

local openTime = os.time({day=OPEN_DAY,month=OPEN_MONTH,year=OPEN_YEAR,hour=0,minute=0,second=0})
local nowTime = os.time()
if nowTime - openTime < 0 then
return
end

	self.checkAppleStatus = 0
	self.checkIpStatus = 0
	self:checkConfig()
	self:checkIP()
end

function UpdateChecker:reloadUpdateScene( )
	ENTER_UPDATE(true)
end

--获取服务器配置是否更新
function UpdateChecker:checkConfig()
	local function getServerListFinish(result)
        if result then
            --默认苹果审核
            local status = 1
            if dataManager:getLocalBaseVersion() < dataManager.remoteBaseVersion then
                status = 2
            end
            self.checkAppleStatus = status
            self:checkResult()
        else
            self.checkAppleStatus = 1
            self:checkResult()
        end
    end
    serverList:getServerList(getServerListFinish);
end

--是否是美国IP
function UpdateChecker:checkIP( callback )
	--"https://api.ip.la/en?json"
    -- {
    --  "ip": "47.89.225.111",
    --  "location": {
    --      "city": "Santa Clara",
    --      "country_code": "US",
    --      "country_name": "United States",
    --      "latitude": "37.355701",
    --      "longitude": "-121.955002",
    --      "province": "California"
    --  }
    -- }
    -- Http请求 Get方式
    local xmlHttpReq = cc.XMLHttpRequest:new()
    xmlHttpReq.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型
    xmlHttpReq.timeout = 5;
    xmlHttpReq:open("GET", "https://api.ip.la/en?json") -- 打开链接
    local function HttpRequestCompleted()
        --如果超时
        if self.checkIpStatus == 2 then
            return
        end
        --移除超时定时器
        utils:removeTimer("update.checkip")
        --200请求成功，否则失败
        local status = 2 --默认不是美国
        if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
            local jsonData = xmlHttpReq.response
            if not json then
                require "cocos.cocos2d.json"
            end
            if jsonData then
                local data = json.decode(jsonData, 1)
                dump(data,"HttpRequestCompleted")
                local ip = data.ip
                --苹果IP
                if string.sub(ip, 1, 3) == "17." then
                    status = 1
                end
                --美国IP
                if data.location.country_code == "US" or data.location.country_name == "United States" then
                    status = 1
                end
            end
        end
        self.checkIpStatus = status
        self:checkResult()
        xmlHttpReq:unregisterScriptHandler();
        xmlHttpReq:abort()
        xmlHttpReq = nil;
    end
    -- 注册脚本回调方法
    xmlHttpReq:registerScriptHandler(HttpRequestCompleted)
    xmlHttpReq:send() -- 发送请求
    --保护措施，如果超时
    utils:delayInvoke("update.checkip",10,function()
        self.checkIpStatus = 2
        self:checkResult()
    end)
end

function UpdateChecker:checkResult()
    if self.checkAppleStatus == 0 or self.checkIpStatus == 0 then
        return
    end
    if self.checkAppleStatus == 2 and self.checkIpStatus == 2 then
        self:reloadUpdateScene()
    end
end

return UpdateChecker
