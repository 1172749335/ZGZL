local C = class("Utils")
Utils = C

C.timers = {}
C.scheduler = cc.Director:getInstance():getScheduler()

--获取金币字符串 count:0无小数 1一位小数 2两位小数 3直接tostring(有几位小数就是几位) ,如果不传count,会加亿/万单位处理
function C:moneyString( money, count )
    money = tonumber(money) or 0
    money = money/MONEY_SCALE
    if count == 0 then
        return string.format("%0.0f",money)--tostring(money)
    elseif count == 1 then
        return string.format("%0.1f",money)
    elseif count == 2 then
        return string.format("%0.2f",money)
    elseif count == 3 then
        return tostring(money)
    else
        if money > 100000000 then
            return string.format("%0.2f亿",money/100000000)
        elseif money > 100000 then
            return string.format("%0.2f万",money/10000)
        else
            if money == math.floor(money) then
                return string.format("%0.0f",money)
            elseif money*10 == math.floor(money*10) then
                return string.format("%0.1f",money)
            else
                return string.format("%0.2f",money)
            end
        end
    end
end

--分割字符串
function C:stringSplit( theString, theSeparator )
	theString = tostring(theString)
    theSeparator = tostring(theSeparator)

    if theSeparator == '' then
        return theString
    end

    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(theString, theSeparator, pos, true)
    end do
        table.insert(arr, string.sub(theString, pos, st - 1))
        pos = sp + 1
    end

    table.insert(arr, string.sub(theString, pos))
    return arr
end

--将秒转为时间字符串（00:00:00）
function C:timeString( time )
    time = tonumber(time);
    local timeStr = "";
    local hour = 0;
    local minus = 0;
    local seconds = 0;
    if time > 3600 then
        hour = math.floor(time / 3600);
        local hourYu = time % 3600;
        minus = math.floor(hourYu / 60);
        minus = tonumber(string.format("%d", minus));
        local minusYu = hourYu % 60;
        seconds = minusYu;
    else
        if time >= 60 then
            minus = math.floor(time / 60);

            local minusYu = time % 60;
            seconds = minusYu;
        else
            seconds = time;
        end
    end
    return string.format("%02d:%02d:%02d",hour,minus,seconds)
end

function C:string2Time(str)
    local Y = string.sub(str , 1, 4)
    local M = string.sub(str , 6, 7)
    local D = string.sub(str , 9, 10)
    local H = string.sub(str , 12, 13)
    local m = string.sub(str , 15, 16)
    local s = string.sub(str , 18, 19)
    return os.time({year=Y, month=M, day=D, hour=H,min=m,sec=s})
end

--定时器
function C:createTimer( name, interval, callback)
    self:removeTimer(name)
    local entry = self.scheduler:scheduleScriptFunc(callback, interval, false)
    self.timers[tostring(entry)] = name
    return entry
end

function C:removeTimer( name )
    for k,v in pairs(self.timers) do
        local index = string.find(v,name)
        if index then
            self:removeTimerByEntry(tonumber(k))
        end
    end
end

function C:removeTimerByEntry( entry )
    self.scheduler:unscheduleScriptEntry(entry)
    self.timers[tostring(entry)] = nil
end

function C:delayInvoke(name, delay, callback)
    local doAction = function()
        self:removeTimer(name)
        if callback then
            callback()
        end
    end
    self:createTimer(name, delay, doAction)
end

function C:quitApp()
    cc.Director:getInstance():endToLua()
end

--http获取json
function C:httpGet(url,callback)
    local xmlHttpReq = cc.XMLHttpRequest:new()
    xmlHttpReq.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型
    xmlHttpReq.timeout = 5;
    xmlHttpReq:open("GET", url) -- 打开链接

    -- http响应回调
    local function onResponse()

        if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
            callback(xmlHttpReq.response)
        else
            callback(nil)
        end

        xmlHttpReq:unregisterScriptHandler();
        xmlHttpReq = nil;
    end

    -- 注册脚本回调方法
    xmlHttpReq:registerScriptHandler(onResponse)
    xmlHttpReq:send() -- 发送请求
end

--设置剪切板内容
function C:setCopy(content)
    platform.setClipboardText(content)
end

--获取剪切板内容
function C:getCopy()
    return platform.getClipboardText()
end

--浏览器打开链接
function C:openUrl(url)
    platform.openUrl(url)
end

--是否已经安装微信
function C:isInstallWechat()
    return platform.isInstallWechat()
end

--获取安卓设备
function C:getAndroidDeviceType()
    return platform.getDeviceType()
end

--获取当前网络类型（wifi/4G）
function C:getCurrentConnectType()
    return platform.getCurrentNetworkType()
end

--当前网络是否可用
function C:isNetworkAvailable()
    return platform.isNetworkAvailable()
end

--打开应用（qq,wx,zfb）
function C:openApp(appName)
    platform.openApp(appName)
end

--切换横竖屏
function C:setOrientation(dir)
    --if device.platform == "android" or device.platform == "ios" then
    if platform.setOrientation(dir) == 1 then
        local CC_DESIGN_RESOLUTION = {}
        if dir == 2 then
            CC_DESIGN_RESOLUTION = {
            width = 640,
            height = 1136,
            autoscale = "FIXED_WIDTH",
            callback = function(framesize)
                local ratio = framesize.width / framesize.height
                if ratio <= 1.34 then
                    -- iPad 768*1024(1536*2048) is 4:3 screen
                    return {autoscale = "FIXED_WIDTH"}
                end
            end
            }
        elseif dir == 1 then
           CC_DESIGN_RESOLUTION = {
            width = 1136,
            height = 640,
            autoscale = "FIXED_HEIGHT",
            callback = function(framesize)
                local ratio = framesize.width / framesize.height
                if ratio <= 1.34 then
                    -- iPad 768*1024(1536*2048) is 4:3 screen
                    return {autoscale = "FIXED_HEIGHT"}
                end
            end
            }
        end
        local view = cc.Director:getInstance():getOpenGLView()
        view:setFrameSize(view:getFrameSize().height, view:getFrameSize().width)
        package.loaded["cocos.framework.display"] = nil
        display = require("cocos.framework.display")
        display.setAutoScale(CC_DESIGN_RESOLUTION)
    end
    --end
end




function C:playFramesAnimation(sprite,aniName,startFrame,endFrame,speed,loops,callback)
    local array = {}
    for i=startFrame,endFrame do
        local resPng = aniName..i..".png"
        local tmpsf = cc.SpriteFrameCache:getInstance():getSpriteFrame( resPng )
        array[i] = tmpsf
    end
    local animation = CCAnimation:createWithSpriteFrames(array, speed)
    local animate = CCAnimate:create(animation)
    if callback then
        animate = cc.Sequence:create({animate,CCCallFunc:create(callback)})
    end
    sprite:setVisible(true)
    if loops < 0 then
        sprite:runAction(cc.RepeatForever:create(animate))
    else
        sprite:runAction(cc.Repeat:create( animate, loops))
    end
end

function C:createFrameAnim(params)
    local path = params.path;
    local image = params.image;
    local endFrame = params.endFrame;
    local interval = params.interval or 0.1;
    local start = params.start or 1;
    local remove = true;
    if params.remove ~= nil then 
        remove = params.remove;
    end 
    params.removeSelf = remove
    display.loadSpriteFrames(path..".plist", path..".png");
    local frames = display.newFrames(image.."%d.png", start, endFrame);
    local sprite = display.newSprite(frames[start]);
    local animation = display.newAnimation(frames, interval);
    if params.once then 
        sprite:playAnimationOnce(animation,params)
    else
        sprite:playAnimationForever(animation)
    end
    return sprite;
end

function C:newTTFLabel(params)
    assert(type(params) == "table","[framework.display] newTTFLabel() invalid params")

    local text       = tostring(params.text)
    local font       = params.font or display.DEFAULT_TTF_FONT
    local size       = params.size or display.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    local textAlign  = params.align or kCCTextAlignmentLeft
    local textValign = params.valign or kCCVerticalTextAlignmentCenter 
    local x, y       = params.x, params.y
    local dimensions = params.dimensions or cc.size(0, 0)

    local label = CCLabelTTF:create(text, font, size, dimensions, textAlign, textValign)

    if label then
        label:setColor(color)
        if x and y then label:setPosition(x, y) end
    end

    return label
end

function C:copyTable( tb )
    local table = {}
    for k, v in pairs(tb or {}) do
        if type(v) ~= "table" then
            table[k] = v
        else
            table[k] = self:copyTable(v)
        end
    end
    return table
end

-- 数字匀速变化action，能在给定时间内从A速匀变化到B
function C.numberGO(node, a, b, duration, callback)
    callback = callback or function()end
    a = math.floor(a)
    b = math.floor(b)
    duration = (duration == 0 and 0.0001 or duration)
    local length =(b - a)
    local handler = { timeAcc = 0 }
    node:scheduleUpdateWithPriorityLua( function(deltaT)
        handler.timeAcc = handler.timeAcc + deltaT
        if handler.timeAcc >= duration then
            node:unscheduleUpdate()
        end
        local now = a +(math.min(handler.timeAcc, duration) / duration) * length
        if node.setString then node:setString(math.floor(now)) end
        local terminate = callback(now, handler.timeAcc >= duration)
        if terminate then
            node:unscheduleUpdate()
        end
    end , 1)
    callback(a)
end

utils = Utils.new()

return C
