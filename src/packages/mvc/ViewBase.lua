local C = class("ViewBase", cc.Node)
ViewBase = C

C.resourceNode = nil
C.RESOURCE_FILENAME = nil
C.RESOURCE_BINDING = nil

function C:ctor()
    self:enableNodeEvents()
    -- check CSB resource file
    local filename = rawget(self.class, "RESOURCE_FILENAME")
    if filename then
        self:createResoueceNode(filename)
    end
    local binding = rawget(self.class, "RESOURCE_BINDING")
    if filename and binding then
        self:createResoueceBinding(binding)
    end
    if self.onCreate then self:onCreate() end
end

function C:createResoueceNode(resourceFilename)
    if self.resourceNode then
        self.resourceNode:removeSelf()
        self.resourceNode = nil
    end
    if string.find(resourceFilename, ".json") then
        self.resourceNode = ccs.GUIReader:getInstance():widgetFromJsonFile(resourceFilename)
    else
        self.resourceNode = cc.CSLoader:createNode(resourceFilename)
    end
    assert(self.resourceNode, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode)
end

function C:createResoueceBinding(binding)
    assert(self.resourceNode, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node =  self:findNestedChildByName(self.resourceNode, nodeBinding.path)
        if node then
            self[nodeName] = node
            for _, event in ipairs(nodeBinding.events or {}) do
                if event.event == "click" and node["onClick"] ~= nil then
                    node:onClick(handler(self, self[event.method]))
                end
                if event.event == "touch" and node["onTouch"] ~= nil then
                    node:onTouch(handler(self, self[event.method]))
                end
                if event.event == "event" and node["onEvent"] ~= nil then
                    node:onEvent(handler(self, self[event.method]))
                end
                if event.event == "scroll" and node["onScroll"] ~= nil then
                    node:onScroll(handler(self, self[event.method]))
                end
            end
        end
    end
end

function C:findNestedChildByName( node, name )
    local array = self:stringSplit(name,".")
    if #array == 0 then
        return nil
    end
    if #array == 1 then
        return node:getChildByName(array[1])
    end
    local parent = node
    local count = #array
    for i=1,count do
        if parent == nil then
            return nil
        end
        parent = parent:getChildByName(array[i])
        if parent == nil then
            return nil
        end
        if i == count - 1 then
            return parent:getChildByName(array[count])
        end
    end
end

function SEEK_CHILD(root, name)
    local child = root:getChildByName(name)
    if child then
        return child
    end

    local children = root:getChildren()
    for i, child in ipairs(children) do
        local rightone = SEEK_CHILD(child, name)
        if rightone then
            return rightone
        end
    end
    return nil
end

function C:seekChild(name)
    return SEEK_CHILD(self, name)
end

--分割字符串
function C:stringSplit( theString, theSeparator )
    if theString == nil then
        return {}
    end

    local pos, arr = 0, {}

    if theSeparator == nil then
        table.insert(arr,theString)
        return arr
    end

    theString = tostring(theString)
    theSeparator = tostring(theSeparator)

    if theSeparator == '' then
        table.insert(arr,theString)
        return arr
    end

    for st, sp in function()
        return string.find(theString, theSeparator, pos, true)
    end do
        table.insert(arr, string.sub(theString, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(theString, pos))
    return arr
end

return ViewBase
