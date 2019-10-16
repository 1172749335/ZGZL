require("app.init")
local C = class("UpdateCore",CoreBase)
UpdateCore = C

C.MODULE_PATH = "app.update"
C.SCENE_CONFIG = {scenename = "UpdateScene", filename = "UpdateScene"}
C.currentProgress = 0

local DOWNLOAD_SUCCESS = 1      --下载成功
local DECOMPRESS_SUCCESS = 2    --解压成功

--马甲包专用
local UpdateChecker = import(".UpdateChecker")
C.updateChecker = UpdateChecker.new()
C.isFromUpdateChecker = false

function C:ctor( isFromUpdateChecker )
    self.isFromUpdateChecker = isFromUpdateChecker
end

function C:run(transition, time, more)
	C.super.run(self,transition, time, more)
	--初始化场景
    local fileUtil = cc.FileUtils:getInstance()
    if not fileUtil:isDirectoryExist(DOWNLOAD_PATH) then
        fileUtil:createDirectory(DOWNLOAD_PATH)
    end
	self.scene:initialize()
    --如果是启动进来，直接进入小游戏页面，并且启动开关检测
    if self.isFromUpdateChecker == false then
        self.updateChecker:check()
        --require("app.minigame.GameCore").new():run()
        self:enterHallScene()
        return
    end
    self:loadServerList()
end

function C:loadServerList()
    self.scene:showTips(1);
    local function connectHallServerFinish(result)
        if result then
            --连接成功，开始登陆
            printInfo("连接成功，开始登陆")
            loadingLayer:show("正在登录...",100000)
            self.scene:showTips(4)
            eventManager:publish("QuickLogin")
            eventManager:publish("EnterHall")
        else
            loadingLayer:hide()
            local dialogLayer = DialogLayer.new()
            local text = "网络连接失败，请检查您的网络状态\n点击确定重启游戏"
            dialogLayer:show(text,function( isOk )
                self:loadServerList()
            end)
        end
    end

    local function getServerListFinish(result)
        if result then

            if dataManager.detectVm then
                if device:isVm() then
                    loadingLayer:hide()
                    utils:quitApp()
                end
            end

            if self:needUpdateBase() then
                self:startUpdateBase()
            else
                ConnectHallServer(connectHallServerFinish);
            end
        else
            loadingLayer:hide()
            local dialogLayer = DialogLayer.new()
            local text = "网络连接失败，请检查您的网络状态\n点击确定重启游戏"
            dialogLayer:show(text,function( isOk )
                self:loadServerList()
            end)
        end
    end

    serverList:getServerList(getServerListFinish);
    loadingLayer:show("正在加载...",self.scene,100000)
end

--检查大厅是否需要更新
function C:needUpdateBase()
    if dataManager:getLocalBaseVersion() < dataManager.remoteBaseVersion then
        printInfo("本地版本："..dataManager:getLocalBaseVersion().." 服务器版本："..dataManager.remoteBaseVersion);
        return true;
    end
    return false;
end

function C:hallServerConnectCallback(success)
    if not success then
        loadingLayer:hide()
        toastLayer:hide()
        DialogLayer.new():show("网络连接失败，请检查您的网络状态\n点击确定重新连接",function(ok) ConnectHallServer(handler(self,self.hallServerConnectCallback)) end) 
    else
        printInfo("连接成功，开始登陆")
        loadingLayer:show("正在登录...",self.scene,100000)
        self.scene:showTips(4)
        eventManager:publish("QuickLogin")
        eventManager:publish("EnterHall")
    end
end

--开始更新基础包
function C:startUpdateBase()
    printInfo("开始更新大厅...");
    loadingLayer:show("正在更新...",self.scene,100000)
    self.scene:showTips(2);
    self.scene:setProgressBar(0)
    local localVersion = dataManager:getLocalBaseVersion();
    local remoteVersion = dataManager.remoteBaseVersion;

    local url = dataManager.updateUrl.."/pt/v"..tostring(remoteVersion).."/v"..tostring(localVersion).."/";
    local basePackageUrl = url.."package.zip";
    local baseVersionUrl = url.."version";

    local assetsManager = cc.AssetsManager:new(basePackageUrl,baseVersionUrl,DOWNLOAD_PATH)
    assetsManager:retain()

    self.currentProgress = -1

    local function onError(errorCode)
        loadingLayer:hide()
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            dataManager:setLocalBaseVersion(remoteVersion)
            assetsManager:release()
            loadingLayer:hide()
            self:reload()
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            printInfo("网络错误，下载失败:"..basePackageUrl)
            loadingLayer:hide()
            local dialogLayer = DialogLayer.new()
            local text = "网络连接失败，请检查您的网络状态\n点击确定重启游戏"
            dialogLayer:show(text,function( isOk )
                self:loadServerList()
            end)
        end
    end

    local function onProgress( percent )
        if self.currentProgress ~= percent then
            self.currentProgress = percent
            self.scene:setProgressBar(self.currentProgress)
        end
    end

    local function onSuccess(t)
        if t == DOWNLOAD_SUCCESS then
            --下载完成，开始解压
            self.scene:showTips(3)
        else
            --解压完成,重新加载
            dataManager:setLocalBaseVersion(remoteVersion)
            assetsManager:release()
            loadingLayer:hide()
            self:reload()
            return;
        end
    end

    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR) -- 注册错误回调
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS) -- 注册进度回调
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS) -- 注册更新成功回调
    assetsManager:setConnectionTimeout(3)
    assetsManager:checkUpdate() -- 自带检查版本和更新
end

function C:reload()
    package.loaded["app.init"] = nil
    require("app.init")
    self:loadServerList()
end

function C:enterLoginScene()
	require("app.init")
	LoginCore.new():run()
end

function C:enterHallScene()
	require("app.init")
	ENTER_HALL()
end

return UpdateCore