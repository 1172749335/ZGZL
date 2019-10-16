local luaFileVersion = "1.5.1"

local LuaTableView = class("LuaTableView")

LuaTableView.Config = {
	size = cc.size(500,500),
	position = cc.p(0,0),
	direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
	cellsize = cc.size(60, 60),
	numberCells = 25,
	onCreateCellFun = nil,
	onClickCellFun = nil
}

function LuaTableView:ctor()
	self.tableView = nil
end

function LuaTableView:onCreate(config)
	if config ~= nil then
		self.Config = config
	end
	local tableView = cc.TableView:create(self.Config.size)
    tableView:setDirection(self.Config.direction)
    tableView:setPosition(self.Config.position)
    tableView:setDelegate()

    local function onNumberOfCellsInTableView(table)
    	return self.Config.numberCells
    end
    local function onScrollViewDidScroll(view)
    	cclog("scrollViewDidScroll")
    end
    local function onScrollViewDidZoom(view)
    	cclog("scrollViewDidZoom")
    end
    local function onTableCellTouched(table,cell)
    	cclog("cell touched at index: " .. cell:getIdx())
    end
    local function onCellSizeForTable(table,idx) 
    	 return self.Config.cellsize.width, self.Config.cellsize.height
    end
    local function onTableCellAtIndex(table, idx)
    	return self:tableCellAtIndex(table, idx)
    end 
    tableView:registerScriptHandler(onNumberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(onScrollViewDidScroll,      cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(onScrollViewDidZoom,        cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(onTableCellTouched,         cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(onCellSizeForTable,         cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(onTableCellAtIndex,         cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    return tableView
end

function LuaTableView:numberOfCellsInTableView(table)
   return LuaTableView.Config.numberCells
end

function LuaTableView:scrollViewDidScroll(view)
    cclog("scrollViewDidScroll")
end

function LuaTableView:scrollViewDidZoom(view)
    cclog("scrollViewDidZoom")
end

function LuaTableView:tableCellTouched(table,cell)
    cclog("cell touched at index: " .. cell:getIdx())
end

function LuaTableView:cellSizeForTable(table,idx) 
    return LuaTableView.Config.cellsize.width, LuaTableView.Config.cellsize.height
end

function LuaTableView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()      
        label = cc.Label:createWithSystemFont(strValue, "Helvetica", 20.0)
        label:setPosition(cc.p(0,0))
        label:setAnchorPoint(cc.p(0,0))
        label:setTag(123)
        cell:addChild(label)
    else
        label = cell:getChildByTag(123)
        if nil ~= label then
            label:setString(strValue)
        end
    end
    return cell
end

return LuaTableView