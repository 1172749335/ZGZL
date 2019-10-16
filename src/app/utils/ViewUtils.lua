local luaFileVersion = "1.5.1"

function ButtonOnClick(node, callback)
	local function onClick(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			callback()
		end
	end
	node:addTouchEventListener(onClick)
end