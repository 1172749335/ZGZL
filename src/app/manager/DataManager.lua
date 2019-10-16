local C = class("DataManager");
DataManager = C

---------持久化成员变量----------

C.playerId = nil;
C.account = "";
C.password = "";
C.random = "";
C.localBaseVersion = 0;
C.accounts = {}
C.passwords = {}
C.randoms = {}

---------------------------------

--------非持久化成员变量---------

C.remoteBaseVersion = 0
C.hallServers = {}
C.gameServers = {}
C.updateUrl = DEFAULT_UPDATE_URL
C.payUrl = DEFAULT_PAY_URL
C.agentUrl = DEFAULT_AGENT_URL
C.gameRuleUrl = DEFAULT_GAME_RULE_URL
C.exchangeLogUrl = DEFAULT_EXCHANGE_LOG_URL

C.cer = nil;
C.agentextips = ""
C.bankextips = ""
C.bindtips = ""
C.chargetips = ""
C.isbindaccount = 0
C.isgame = 0
C.isusa = false
C.officalwebdisplay = 1
C.promotion = 1
C.ranktips = ""
C.regsendmoney = 300
C.serverip = ""
C.serverport = 0
C.gamelist = {}
C.sitegamelist = {}
C.state = 1 -- 1：大厅状态，2：游戏状态
C.userInfo = {}
C.channel = CHANNEL_ID
C.configs = {}
C.detectVm = false
C.mails = {}
C.gameRemoteVersions = {}
--平台类型（接收跑马灯用到）
C.styleId = 2

C.goldRankSyncInterval = 300    --金币排行榜同步时间间隔（s）
C.goldRankLastSyncTime = 0      --金币排行榜上一次同步时间（戳）
C.timeRankSyncInterval = 300    --时间排行榜同步时间间隔（s）
C.timeRankLastSyncTime = 0      --时间排行榜上一次同步时间（戳）

C.myWinToday = 0            --今日赢钱

--排行榜今日金币
C.rankTodayGoldList = 
{
--    rankIndex = 0,
--    ranks = 
--    {
--        [1]={playerId = "",name = "",money = "0",vip = 0,headId = 1}
--    }
}    

--排行榜今日在线时长
C.rankTodayTimeList = 
{
--    rankIndex = 0,
--    ranks = 
--    {
--        [1]={playerId = "",name = "",time = 300000,vip = 0,headId = 1}
--    }
}  

--我与客服聊天记录
C.customServiceMsgList = 
{
    --[1] = {time = "2018-09-29T10:23:28.326Z",type = "to",content = "哈哈哈哈"}
    --[2] = {time = "2018-09-29T10:23:28.326Z",type = "from",content = "呵呵呵呵"}
}


--登录时间，用于统计在线时长
C.loginTime = os.time()

---------------------------------

local userDefault = cc.UserDefault:getInstance();

--获取今日在线时长，返回秒数
function C:getOnlineTime()
    
    return os.time() - self.loginTime + tonumber(self.userInfo["OnlineTime"])
end

--获取玩家ID
function C:getPlayerId()
    if self.playerId ~= nil and self.playerId ~= "" then
        return self.playerId;
    end
    return userDefault:getStringForKey("playerId","null");
end

--设置玩家ID
function C:setPlayerId(playerId)
    self.playerId = playerId;
    userDefault:setStringForKey("playerId",playerId);
    userDefault:flush()
end

--获取登陆账号
function C:getAccount()
    if self.account ~= "" and self.account ~= nil then
        return self.account;
    end
    self.account = userDefault:getStringForKey("account","")
    return self.account
end

--设置登陆账号
function C:setAccount(account)
    self.account = account;
    userDefault:setStringForKey("account",account)
    userDefault:flush()
end

--获取登陆密码
function C:getPassword()
    if self.password ~= "" and self.password ~= nil then
        return self.password;
    end
    self.password = userDefault:getStringForKey("password","")
    return self.password
end

--设置登陆密码
function C:setPassword(password)
    self.password = password;
    userDefault:setStringForKey("password",password);
    userDefault:flush()
end

--获取随机登陆密码
function C:getRandomCer()
    if self.random ~= "" and self.random ~= nil then
        return self.random;
    end
    self.random = userDefault:getStringForKey("random","")
    return self.random
end

--设置随机登陆密码
function C:setRandomCer(random)
    self.random = random;
    userDefault:setStringForKey("random",random);
    userDefault:flush()
end

--获取大厅版本
function C:getLocalBaseVersion()
    self.localBaseVersion = userDefault:getIntegerForKey("localBaseVersion",0)
    local origVer = VERSIONS.pt
    if origVer then
        self.localBaseVersion = math.max(self.localBaseVersion ,tonumber(origVer))
    end
    return self.localBaseVersion 
end

--设置大厅版本
function C:setLocalBaseVersion(version)
    self.localBaseVersion = version;
    userDefault:setIntegerForKey("localBaseVersion",version);
    userDefault:flush()
end

--获取账号列表
function C:getAccounts()

    if self.account == nil or self.account == "" then
        self:getAccount()
    end

    if self.accounts == nil or #self.accounts== 0 then
        local str = userDefault:getStringForKey("accounts",self.account);
        self.accounts = string.split(str,",");
    end
    
    local a = clone(self.accounts)
    for k,v in pairs(a) do
        if v == "" then
            a[k] = "游客"
        end
    end

    return a;
end

--添加账号到账号列表
function C:addAccount(acc,pwd,rand)

    if self.accounts == nil or #self.accounts == 0 then
        self:getAccounts()
    end

    for k,v in pairs(self.accounts) do
        if v == acc then table.remove(self.accounts,k) end
    end
    
    table.insert(self.accounts,1,acc)
    local str = table.concat(self.accounts,",",1,#self.accounts)
    userDefault:setStringForKey("accounts",str);
    
    self:setAccount(acc)

    if pwd ~= nil then
        self.passwords[acc] = pwd
        self:setPassword(password)
        userDefault:setStringForKey("A"..acc.."P",pwd);
    end
    if rand ~= nil then
        self.randoms[acc] = rand
        self:setRandomCer(rand)
        userDefault:setStringForKey("A"..acc.."R",rand);
    end

    userDefault:flush()
end

--从账号列表移除账号
function C:removeAccount(acc)
    if self.accounts == nil or #self.accounts == 0 then
        self:getAccounts()
    end
    table.removebyvalue(self.accounts,acc,true)
    local str = table.concat(self.accounts,",",1,#self.accounts)
    userDefault:setStringForKey("accounts",str);
    self.passwords[acc] = nil
    self.randoms[acc] = nil
    userDefault:flush()
end

--获取账号对应的密码
function C:getPasswordByAccount(acc)
    if self.passwords == nil or #self.passwords == 0 then
        self:getAccounts()
        self.passwords = {}
        for k,v in pairs(self.accounts) do
            self.passwords[v] = userDefault:getStringForKey("A"..v.."P","")
        end
    end
    return self.passwords[acc]
end

--获取账号对应的随机登陆密码
function C:getRandomCerByAccount(acc)
    if self.randoms == nil or #self.randoms == 0 then
        self:getAccounts()
        self.randoms = {}
        for k,v in pairs(self.accounts) do
            self.randoms[v] = userDefault:getStringForKey("A"..v.."R","")
            userDefault:flush()
        end
    end
    return self.randoms[acc]
end

--保存游戏版本到本地
function C:setGameLocalVersion(id,version)
    userDefault:setIntegerForKey("game"..tostring(id).."ver",tonumber(version));
    userDefault:flush()
end

--读取游戏本地版本
function C:getGameLocalVersion(id)
    local v = userDefault:getIntegerForKey("game"..tostring(id).."ver",0);
    local origVer = rawget(VERSIONS,GAME_ALIAS[id])
    if origVer then
        return math.max(v,tonumber(origVer))
    end
    return v
end

--读取游戏服务器版本号
function C:getGameRemoteVersion(id)
    local v = 1;
    for k,v in pairs(self.gameRemoteVersions) do 
        if v.gameid == id then
            if device.platform == "android" then
                return v.gamever
            elseif device.platform == "ios" then
                return v.gameverios
            else
                return v.gamever
            end
        end
    end
    return v
end

--获取游戏房间服务器信息
function C:getGameServerInfo(gameId,orderId)
    for k,v in pairs(self.gamelist) do
        if v.gameid == gameId and v.orderid == orderId then
            v.ip = GetCurrentHallServerIp()
            return v
        end
    end
    return nil
end

--通过端口获取房间信息
function C:getRoomInfoByPort(port)
    for k,v in pairs(self.gamelist) do
        if v.port == port then
            v.ip = GetCurrentHallServerIp()
            return v
        end
    end
end

function C:addGameRoom(roomInfo)
    for k,v in pairs(self.gamelist) do
        if v.gameid == roomInfo.gameid and v.orderid == roomInfo.orderid then
            self.gamelist[k] = roomInfo
            return
        end
    end
    table.insert(self.gamelist,roomInfo)
end

function C:delGameRoom(gameId,port)
    for k,v in pairs(self.gamelist) do
        if v.gameid == gameId and v.port == port then
            self.gamelist[k] = nil
            table.remove(self.gamelist,k)
            break
        end
    end
end

--读取最近一次查看客服消息的时间
function C:getLastReadMsgTime()
    return userDefault:getIntegerForKey("ReadMsgTime",0);
end

--设置最近一次查看客服消息的时间
function C:setLastReadMsgTime(time)
    return userDefault:setIntegerForKey("ReadMsgTime",time);
end

function C:updateMoney(money)
    self.userInfo.money = money
end

dataManager = DataManager.new()

return DataManager;

