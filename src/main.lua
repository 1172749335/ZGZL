APP_VER = 4
DOWNLOAD_PATH = cc.FileUtils:getInstance():getWritablePath().."download/"
print("DOWNLOAD_PATH:"..DOWNLOAD_PATH)
local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
table.insert(searchPaths, 1, DOWNLOAD_PATH.."src/")
table.insert(searchPaths, 1, DOWNLOAD_PATH.."res/")
cc.FileUtils:getInstance():setSearchPaths(searchPaths)

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

-- cclog
cclog = function(...)
    print(string.format(...))
    end
    
local function main()
    require("app.update.UpdateCore"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
