local C = class("GameScene",SceneBase)
-- 资源名
C.RESOURCE_FILENAME = "minigame/GameScene.csb"
-- 资源绑定
C.RESOURCE_BINDING = {
	--loading
	loadingPanel = {path="loading"},

	-- main
	mainPanel = {path="main"},
	mainbookBtn = {path="main.illustration",events={{event="click",method="onClickMainBookBtn"}}},
	mainHelpBtn = {path="main.help",events={{event="click",method="onClickMainHelpBtn"}}},
	room1= {path="main.room1",events={{event="click",method="onClickRoom1Btn"}}},
	room2= {path="main.room2",events={{event="click",method="onClickRoom2Btn"}}},
	room3= {path="main.room3",events={{event="click",method="onClickRoom3Btn"}}},

	-- help
	helpPanel = {path="help"},
	helpCloseBtn = {path="help.close_btn",events={{event="click",method="onClickHelpCloseBtn"}}},

	-- Illustration
	bookPanel = {path="illustration"},
	bookCloseBtn = {path="illustration.close_btn",events={{event="click",method="onClickBookCloseBtn"}}},

	-- game
	gamePanel = {path="game"},
	backBtn = {path="game.back_btn",events={{event="click",method="onClickResultBackBtn"}}},

	-- result
	resultPanel = {path="result"},
	resultImg = {path="result.title"},
	girlImg={path="result.girl_img"},
	resultBackBtn = {path="result.back_btn",events={{event="click",method="onClickResultBackBtn"}}},
	resultBack1Btn = {path="result.back_btn1",events={{event="click",method="onClickResultBackBtn"}}},
	resultPlayBtn = {path="result.play_btn",events={{event="click",method="onClickResultPlayBtn"}}},
	rank1={path="result.1"},
	rank2={path="result.2"},
	rank3={path="result.3"},
	rank4={path="result.4"},
	resultSelectImg={path="result.select_img"},
}


local cardPath = "minigame/images/card/"
local player1 = nil
local player2 = nil
local player3 = nil
local player4 = nil

local head1 = nil
local head2 = nil
local head3 = nil
local head4 = nil

local role1ID = nil
local role2ID = nil
local role3ID = nil
local role4ID = nil

local allScore = nil
local score1 = nil
local score2 = nil
local score3 = nil
local score4 = nil
local win1 = nil
local win2 = nil
local win3 = nil
local win4 = nil
local lose1 = nil
local lose2 = nil
local lose3 = nil
local lose4 = nil

local prefab1 = nil
local prefab2 = nil
local prefab3 = nil
local prefab4 = nil
local prefab = nil

local cardList1 = {}
local cardList2 = {}
local cardList3 = {}
local cardList4 = {}

local pos0 = cc.p(0,0)
local pos1 = cc.p(0,-218)
local pos2 = cc.p(390,0)
local pos3 = cc.p(0,230)
local pos4 = cc.p(-390,0)

local interval = 0.1
local curOrder = 100
local curCard = {}
local curTurn = 0
local turns = 0
local outCards = {}
local right = 1
local isFirst = true
local canSend = true


local resultNum=12
local maxCard = 1
local cardNum=6

local specialType = 6
local turnType = 7
local outCardTime=0.5
local incardTime=1

local cardScale=0.8

local curRoom=1

function C:ctor(core)
	--抢庄按钮
	for i=1,5 do
		local key = string.format("bookBtn%d",i)
		local path = string.format("illustration.btn%d",i)
		self.RESOURCE_BINDING[key] = {path=path,events={{event="click",method="onClickBookSelectBtn"}}}
	end
	C.super.ctor(self,core)
end

function C:onEnter()
	C.super.onEnter(self)
	PLAY_BACKGROUND_MUSIC()
end

function C:onExit()
	C.super.onExit(self)
	STOP_BACKGROUND_MUSIC()
	self:stopTimer()
end

function C:onCreate()
	self.helpPanel:setVisible(false)
	self.gamePanel:setVisible(false)
	self.mainPanel:setVisible(true)
	self.bookPanel:setVisible(false)
	self.resultPanel:setVisible(false)
	self.loadingPanel:setVisible(false)

	for i = 1, 5 do
		local key = string.format("bookBtn%d",i)
		local button = self[key]
		button:setTag(i)
	end

	player1=self.gamePanel:getChildByName("player1")
	prefab1=player1:getChildByName("card")
	prefab1:setVisible(false)
	win1=player1:getChildByName("win")
	lose1=player1:getChildByName("lose")
	head1=player1:getChildByName("role")

	player2=self.gamePanel:getChildByName("player2")
	prefab2=player2:getChildByName("card")
	prefab2:setVisible(false)
	win2=player2:getChildByName("win")
	lose2=player2:getChildByName("lose")
	head2=player2:getChildByName("role")

	player3=self.gamePanel:getChildByName("player3")
	prefab3=player3:getChildByName("card")
	prefab3:setVisible(false)
	local diImg3=player3:getChildByName("di")
	diImg3:setLocalZOrder(5000)
	win3=player3:getChildByName("win")
	win3:setLocalZOrder(6000)
	lose3=player3:getChildByName("lose")
	lose3:setLocalZOrder(6000)
	head3=player3:getChildByName("role")
	win3:setLocalZOrder(6000)

	player4=self.gamePanel:getChildByName("player4")
	prefab4=player4:getChildByName("card")
	prefab4:setVisible(false)
	win4=player4:getChildByName("win")
	lose4=player4:getChildByName("lose")
	head4=player4:getChildByName("role")

	self.scoreLabel=self.gamePanel:getChildByName("score")
	self.notice=self.gamePanel:getChildByName("tip")
	self.notice:setOpacity(0)
	self.notice:setGlobalZOrder(10000)
	self.notice:getChildByName("label"):setGlobalZOrder(11000)

	--发牌器
	self.sendCardPanel=self.gamePanel:getChildByName("sendPanel")
	prefab=self.sendCardPanel:getChildByName("card")

	score1=0
	self:updateScore1()
	score2=0
	self:updateScore2()
	score3=0
	self:updateScore3()
	score4=0
	self:updateScore4()
	turns=0

	utils:delayInvoke("minigame.loading",2,function()
		self.mainPanel:setVisible(true)
	end)
end

function C:onClickMainPlayBtn(event)
	self:StartGame()
end

function C:onClickMainHelpBtn(event)
	self.helpPanel:setVisible(true)
end

function C:onClickHelpCloseBtn(event)
	self.helpPanel:setVisible(false)
end

function C:onClickMainBookBtn(event)
	self.bookPanel:setVisible(true)
	local index = 1
	for i = 1, 5 do
		local key = string.format("bookBtn%d",i)
		local button = self[key]
		button:loadTexture("minigame/images/an2.png")
	end
	local key = string.format("bookBtn%d",index)
	local button = self[key]
	button:loadTexture("minigame/images/an1.png")
	for i = 1, 6 do
		local img=self.bookPanel:getChildByName(tostring(i))
		img:loadTexture(cardPath..index.."_"..i..".png")
		img:stopAllActions()
		img:setOpacity(0)
		local arr = {}
		arr[#arr+1]=cc.DelayTime:create(0.07*(i-1))
		arr[#arr+1]=cc.FadeIn:create(0.2)
		img:runAction(cc.Sequence:create(arr))
	end
end

function C:onClickBookCloseBtn(event)
	self.bookPanel:setVisible(false)
end

function C:onClickBookSelectBtn(event)
	local index = event.target:getTag()
	for i = 1, 5 do
		local key = string.format("bookBtn%d",i)
		local button = self[key]
		button:loadTexture("minigame/images/an2.png")
	end
	local key = string.format("bookBtn%d",index)
	local button = self[key]
	button:loadTexture("minigame/images/an1.png")
	
	for i = 1, 6 do
		local img=self.bookPanel:getChildByName(tostring(i))
		img:loadTexture(cardPath..index.."_"..i..".png")
		img:stopAllActions()
		img:setOpacity(0)
		local arr = {}
		arr[#arr+1]=cc.DelayTime:create(0.07*(i-1))
		arr[#arr+1]=cc.FadeIn:create(0.2)
		img:runAction(cc.Sequence:create(arr))
	end
end

function C:onClickRoom1Btn(event)
	curRoom=1
	maxCard = 1
    cardNum=3
	prefab:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab2:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab3:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab4:loadTexture(cardPath.."card_bg"..curRoom..".png")
	self:StartGame()
end

function C:onClickRoom2Btn(event)
	curRoom=2
	maxCard = 12
    cardNum=4
	prefab:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab2:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab3:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab4:loadTexture(cardPath.."card_bg"..curRoom..".png")
	self:StartGame()
end

function C:onClickRoom3Btn(event)
	curRoom=3
	maxCard = 24
    cardNum=6
	prefab:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab2:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab3:loadTexture(cardPath.."card_bg"..curRoom..".png")
	prefab4:loadTexture(cardPath.."card_bg"..curRoom..".png")
	self:StartGame()
end

function C:onClickResultBackBtn(event)
	self.helpPanel:setVisible(false)
	self.gamePanel:setVisible(false)
	self.mainPanel:setVisible(true)
	self.bookPanel:setVisible(false)
	self.resultPanel:setVisible(false)
	self.loadingPanel:setVisible(false)
end

function C:onClickResultPlayBtn(event)
	self:StartGame()
end

--出的牌
function C:refreshCard0()
	local count = #outCards
	local center = count/2
	local _X = 280/count
	_X=math.min(_X,50)
	local sx = pos0.x-_X/2
	for i = 1, count do
		local card = outCards[i]
		--card:setVisible(true)		
		--card:setLocalZOrder(i)
		local x = sx+(i-center)*_X
		--card:runAction(cc.MoveTo:create(0.1,cc.p(x,pos1.y)))
		card:setPosition(cc.p(x,pos0.y))
	end
end

--刷新总分数
function C:updateScore()
	self.scoreLabel:setString(tostring(allScore))
end

--显示提示
function C:showNotice(str)
	self.notice:stopAllActions()
	self.notice:getChildByName("label"):setString(str)
	self.notice:setPosition(cc.p(display.cx,380))
	local arr = {}
	arr[1]=cc.MoveTo:create(0.2,cc.p(display.cx,430))
	arr[2]=cc.DelayTime:create(1.5)
	arr[3]=cc.FadeOut:create(0.2)
	self.notice:runAction(cc.Sequence:create(arr))

	local arr1 = {}
	arr1[1]=cc.FadeIn:create(0.1)
	arr1[2]=cc.DelayTime:create(1.5)
	arr1[3]=cc.MoveTo:create(0.2,cc.p(display.cx,460))
	self.notice:runAction(cc.Sequence:create(arr1))
end

--自己的牌
function C:refreshCard1()
	local count = #cardList1
	local center = count/2
	-- local _X = 740/count
	-- _X=math.min(_X,75)
	--local sx = pos1.x-_X/2
	local _X=130
	local sx = pos1.x-_X/2
	for i = 1, count do
		local card = cardList1[i].card
		card:setVisible(true)		
		card:setLocalZOrder(i)
		local x = sx+(i-center)*_X
		--card:runAction(cc.MoveTo:create(0.1,cc.p(x,pos1.y)))
		card:setPosition(cc.p(x,pos1.y))
	end
end

--创建牌
function C:createCard1()
	math.newrandomseed()
	local color =0
	local number = 0
	local type = math.random(1,10)
	if type==specialType then
		color=specialType
		number=1
	elseif type==turnType then
		color=turnType
		number=1
	else
		color = math.random(1,5)
		number = math.random(1,6)
	end
	local card1 = prefab1:clone()
	card1:addTo(player1)
	card1:setPosition(pos1)
	card1:loadTexture(cardPath..color.."_"..number..".png")
	card1:onClick(function( ... )
		self:outCard1(card1)
	end)

	table.insert(cardList1,{card=card1,color=color,number=number})
end

--出牌
function C:outCard1(card)
	if self.moving then
		return
	end
	self.moving=true
	-- for i = 1, #cardList1 do
	-- 	if cardList1[i].card==card then
	-- 		if cardList1[i].color==specialType then
	-- 			self.selectCard=card
	-- 			self.selectPanel:setVisible(true)
	-- 			self.selectBg:setScaleX(0.1)
	-- 			self.selectBg:runAction(cc.ScaleTo:create(0.4,1))
	-- 			for i = 2, 6 do
	-- 				local color = self.selectPanel:getChildByName(tostring(i))
	-- 				color:setOpacity(0)
	-- 				local arr = {}
	-- 				arr[1]=cc.DelayTime:create((i-3)*0.2+0.4)
	-- 				arr[2]=cc.FadeIn:create(0.2)
	-- 				color:runAction(cc.Sequence:create(arr))
	-- 				local arr1 = {}
	-- 				arr1[1]=cc.DelayTime:create((i-3)*0.2+0.5)
	-- 				arr1[2]=cc.ScaleTo:create(0.1,1.1)
	-- 				arr1[3]=cc.ScaleTo:create(0.2,0.9)
	-- 				arr1[4]=cc.ScaleTo:create(0.1,1.05)
	-- 				arr1[5]=cc.ScaleTo:create(0.1,1)
	-- 				color:runAction(cc.Sequence:create(arr1))
	-- 			end
	-- 			return
	-- 		end
	-- 	end
	-- end

	PLAY_SOUND("majia/sendcard.mp3")
	local arr = {}
	arr[1]=cc.EaseBackInOut:create(cc.MoveTo:create(outCardTime,pos0))
	arr[2]=cc.CallFunc:create(function()
		for i = 1, #cardList1 do
			if cardList1[i].card==card then
				if cardList1[i].color~=turnType then
					curCard={color=cardList1[i].color,number=cardList1[i].number}
					allScore=allScore+cardList1[i].number
					self:updateScore()
				else
					right=-right
					self:showNotice("Reverse!")
				end
				
				table.remove(cardList1,i)
				break
			end
		end
		self.moving=false
		self:refreshCard0()
		self:refreshCard1()
		if self:canEnd() then
			self:gameReset(1)
			return
		end

		self:control()
	end)
	card:runAction(cc.Sequence:create(arr))
	card:runAction(cc.ScaleTo:create(0.4,cardScale))
	--card:runAction(cc.RotateTo:create(0.2,math.random(-30,30)))
	card:setGlobalZOrder(curOrder)
	table.insert(outCards,card)
	curOrder=curOrder+1
end

--出特殊牌
function C:outSpecial(color)
	PLAY_SOUND("majia/sendcard.mp3")
	self.selectPanel:setVisible(false)
	local arr = {}
	arr[1]=cc.EaseBackInOut:create(cc.MoveTo:create(outCardTime,pos0))
	arr[2]=cc.CallFunc:create(function()
		for i = 1, #cardList1 do
			if cardList1[i].card==self.selectCard then
				curCard={color=color,number=16}
				allScore=allScore+curCard.number
				self:updateScore()
				table.remove(cardList1,i)
				break
			end
		end

		self.moving=false
		self:refreshCard0()
		self:refreshCard1()

		if self:canEnd() then
			self:gameReset(1)
			return
		end	

		self:control()
	end)
	self.selectCard:runAction(cc.Sequence:create(arr))
	self.selectCard:runAction(cc.ScaleTo:create(0.3,0.7,0.7))
	--self.selectCard:runAction(cc.RotateTo:create(0.2,math.random(-30,30)))
	self.selectCard:setGlobalZOrder(curOrder)
	self.selectCard:loadTexture(cardPath..color..".png")
	table.insert(outCards,self.selectCard)
	curOrder=curOrder+1
end

--加牌
function C:inCard1()
	local card = prefab:clone()
	self.sendCardPanel:addChild(card)
	card:setPosition(cc.p(0,0))
	card:setRotation(30)
	local arr = {}
	arr[1]=cc.RotateTo:create(0.2,34)
	arr[2]=cc.RotateTo:create(0.2,0)
	arr[3]=cc.EaseBackIn:create(cc.MoveBy:create(incardTime,cc.p(-240,-326)))
	card:runAction(cc.Sequence:create(arr))
	local array = {}
	array[1]=cc.DelayTime:create(incardTime+0.3)
	array[2]=cc.FadeOut:create(0.1)
	array[3]=cc.CallFunc:create(function()
		self:createCard1()
		self:refreshCard1()
		card:removeFromParent()
	end)
	card:runAction(cc.Sequence:create(array))
end

--设置明暗
function C:setLight1(light)
	for i = 1, #cardList1 do
		if light==true then
			cardList1[i].card:setOpacity(255)	
			cardList1[i].card:setEnabled(true)		
		else
			cardList1[i].card:setOpacity(200)
			cardList1[i].card:setEnabled(false)	
		end
	end
end

--是否可出牌
function C:hasOut1()
	local has = false

	for i = 1, #cardList1 do
		if cardList1[i].color==curCard.color or cardList1[i].number==curCard.number then
			has=true
			break
		elseif cardList1[i].color==specialType then
			has=true
			break
		elseif cardList1[i].color==turnType then
			has=true
			break
		end
	end

	return has
end

--设置分数
function C:updateScore1()
	if score1>=0 then
		win1:setString("+"..score1)
		win1:setVisible(true)
		lose1:setVisible(false)
		--effect1:start()
	else
		lose1:setString(score1)
		win1:setVisible(false)
		lose1:setVisible(true)
	end
end


--card2
function C:refreshCard2()
	local count =  #cardList2
	local center = count/2
	local _X = 280/count
	_X=math.min(_X,50)
	local sx = pos2.x-_X/2
	for i = 1, count do
		local card = cardList2[i].card
		card:setVisible(true)
		card:setLocalZOrder(i)
		local x = sx+(i-center)*_X
		card:setPosition(cc.p(x,pos2.y))
	end
end

--创建牌
function C:createCard2()
	math.newrandomseed()
	local color =0
	local number = 0
	local type = math.random(1,10)
	if type==specialType then
		color=specialType
		number=1
	elseif type==turnType then
		color=turnType
		number=1
	else
		color = math.random(1,5)
		number = math.random(1,6)
	end
	local card1 = prefab2:clone()
	card1:addTo(player2)
	--card1:loadTexture(cardPath..color.."_"..number..".png")
	table.insert(cardList2,{card=card1,color=color,number=number})
end

--出牌
function C:outCard2(card)
	if card==nil then
		self:control()
	end
	PLAY_SOUND("majia/sendcard.mp3")
	local arr = {}
	arr[1]=cc.EaseSineInOut:create(cc.MoveTo:create(outCardTime,pos0))
	arr[2]=cc.CallFunc:create(function()
		for i = 1, #cardList2 do
			if cardList2[i].card==card then
				table.remove(cardList2,i)
				break
			end
		end
		self:updateScore()
		self:refreshCard2()
		self:refreshCard0()
		if self:canEnd() then
			self:gameReset(2)
			return
		end		

		self:control()
	end)
	card:runAction(cc.Sequence:create(arr))
	--card:runAction(cc.RotateTo:create(0.2,math.random(-30,30)))
	card:setGlobalZOrder(curOrder)
	table.insert(outCards,card)
	curOrder=curOrder+1

	local arr1 = {}
	arr1[1]=cc.DelayTime:create(0.3)
	arr1[2]=cc.CallFunc:create(function()
		for i = 1, #cardList2 do
			if cardList2[i].card==card then
				local color = cardList2[i].color
				-- if color==specialType then
				-- 	color=math.random(2,6)
				-- 	card:loadTexture(cardPath..color..".png")
				-- elseif color==turnType then
				-- 	right=-right
				-- 	card:loadTexture(cardPath.."7_15.png")
				-- 	self:showNotice("Reverse!")
				-- end
				if color~=turnType then
					curCard={color=color,number=cardList2[i].number}
					allScore=allScore+curCard.number
				else
					right=-right
					self:showNotice("Reverse!")
				end
				card:loadTexture(cardPath..color.."_"..cardList2[i].number..".png")
			end
		end
	end)
	card:runAction(cc.Sequence:create(arr1))
end

--加牌
function C:inCard2()
	local card = prefab:clone()
	self.sendCardPanel:addChild(card)
	card:setPosition(cc.p(0,0))
	card:setRotation(30)
	local arr = {}
	arr[1]=cc.RotateTo:create(0.2,34)
	arr[2]=cc.RotateTo:create(0.2,0)
	arr[3]=cc.EaseBackIn:create(cc.MoveBy:create(incardTime,cc.p(0,-200)))
	card:runAction(cc.Sequence:create(arr))
	local array = {}
	array[1]=cc.DelayTime:create(incardTime+0.3)
	array[2]=cc.FadeOut:create(0.1)
	array[3]=cc.CallFunc:create(function()
		self:createCard2()
		self:refreshCard2()
		card:removeFromParent()

		local arr1 = {}
		arr1[1]=cc.DelayTime:create(2)
		arr1[2]=cc.CallFunc:create(function()
			local card = self:getBestCard2()
			self:outCard2(card)	
		end)
		self.sendCardPanel:runAction(cc.Sequence:create(arr1))
	end)
	card:runAction(cc.Sequence:create(array))
end

--获取最佳牌
function C:getBestCard2()
	for i = 1, #cardList2 do
		if cardList2[i].color+allScore==resultNum then
			return cardList2[i].card
		end
	end
	if #cardList2==0 then
		return nil
	end
	local index = math.random(1,#cardList2)
	return cardList2[index].card
end

--设置明暗
function C:setLight2(light)
	for i = 1, #cardList2 do
		if light==true then
			cardList2[i].card:setOpacity(255)		
		else
			cardList2[i].card:setOpacity(200)
		end
	end
end

--设置分数
function C:updateScore2()
	if score2>=0 then
		win2:setString("+"..score2)
		win2:setVisible(true)
		lose2:setVisible(false)
		--effect2:start()
	else
		lose2:setString(score2)
		win2:setVisible(false)
		lose2:setVisible(true)
	end
end


--card3
function C:refreshCard3()
	local count = #cardList3
	local center = count/2
	local _X = 280/count
	_X=math.min(_X,50)
	local sx = pos3.x-_X/2
	for i = 1, count do
		local card = cardList3[i].card
		card:setVisible(true)
		card:setLocalZOrder(i)
		local x = sx+(i-center)*_X
		card:setPosition(cc.p(x,pos3.y))
	end
end

--创建牌
function C:createCard3()
	math.newrandomseed()
	local color =0
	local number = 0
	local type = math.random(1,10)
	if type==specialType then
		color=specialType
		number=1
	elseif type==turnType then
		color=turnType
		number=1
	else
		color = math.random(1,5)
		number = math.random(1,6)
	end
	local card1 = prefab3:clone()
	card1:addTo(player3)
	--card1:loadTexture(cardPath..color.."_"..number..".png")
	table.insert(cardList3,{card=card1,color=color,number=number})
end

--出牌
function C:outCard3(card)
	if card==nil then
		self:control()
	end
	PLAY_SOUND("majia/sendcard.mp3")
	local arr = {}
	arr[1]=cc.EaseSineInOut:create(cc.MoveTo:create(outCardTime,pos0))
	arr[2]=cc.CallFunc:create(function()
		for i = 1, #cardList3 do
			if cardList3[i].card==card then
				table.remove(cardList3,i)
				break
			end
		end
		self:updateScore()
		self:refreshCard3()
		self:refreshCard0()
		if self:canEnd() then
			self:gameReset(3)
			return
		end
		
		self:control()
	end)
	card:runAction(cc.Sequence:create(arr))
	--card:runAction(cc.RotateTo:create(0.2,math.random(-30,30)))
	card:setGlobalZOrder(curOrder)
	table.insert(outCards,card)
	curOrder=curOrder+1

	local arr1 = {}
	arr1[1]=cc.DelayTime:create(0.3)
	arr1[2]=cc.CallFunc:create(function()
		for i = 1, #cardList3 do
			if cardList3[i].card==card then
				local color = cardList3[i].color
				if color~=turnType then
					curCard={color=color,number=cardList3[i].number}
					allScore=allScore+curCard.number
				else
					right=-right
					self:showNotice("Reverse!")
				end
				card:loadTexture(cardPath..color.."_"..cardList3[i].number..".png")
			end
		end
	end)
	card:runAction(cc.Sequence:create(arr1))
end

--加牌
function C:inCard3()
	local card = prefab:clone()
	self.sendCardPanel:addChild(card)
	card:setPosition(cc.p(0,0))
	card:setRotation(30)
	local arr = {}
	arr[1]=cc.RotateTo:create(0.2,34)
	arr[2]=cc.RotateTo:create(0.2,0)
	arr[3]=cc.EaseBackIn:create(cc.MoveBy:create(incardTime,cc.p(-230,15)))
	card:runAction(cc.Sequence:create(arr))
	local array = {}
	array[1]=cc.DelayTime:create(incardTime+0.3)
	array[2]=cc.FadeOut:create(0.1)
	array[3]=cc.CallFunc:create(function()
		self:createCard3()
		self:refreshCard3()
		card:removeFromParent()

		local arr1 = {}
		arr1[1]=cc.DelayTime:create(2)
		arr1[2]=cc.CallFunc:create(function()
			local card = self:getBestCard3()
			self:outCard3(card)
		end)
		self.sendCardPanel:runAction(cc.Sequence:create(arr1))
	end)
	card:runAction(cc.Sequence:create(array))
end

--获取最佳牌
function C:getBestCard3()
	for i = 1, #cardList3 do
		if cardList3[i].number+allScore==resultNum then
			return cardList3[i].card
		end
	end
	if #cardList3==0 then
		return nil
	end
	local index = math.random(1,#cardList3)
	return cardList3[index].card
end

--设置明暗
function C:setLight3(light)
	for i = 1, #cardList3 do
		if light==true then
			cardList3[i].card:setOpacity(255)		
		else
			cardList3[i].card:setOpacity(200)
		end
	end
end

--设置分数
function C:updateScore3()
	if score3>=0 then
		win3:setString("+"..score3)
		win3:setVisible(true)
		lose3:setVisible(false)
		--effect3:start()
	else
		lose3:setString(score3)
		win3:setVisible(false)
		lose3:setVisible(true)
	end
end


--card4
function C:refreshCard4()
	local count = #cardList4
	local center = count/2
	local _X = 280/count
	_X=math.min(_X,50)
	local sx = pos4.x-_X/2
	for i = 1, count do
		local card = cardList4[i].card
		card:setVisible(true)
		card:setLocalZOrder(i)
		local x = sx+(i-center)*_X
		card:setPosition(cc.p(x,pos4.y))
	end
end

--创建牌
function C:createCard4()
	math.newrandomseed()
	local color =0
	local number = 0
	local type = math.random(1,10)
	if type==specialType then
		color=specialType
		number=1
	elseif type==turnType then
		color=turnType
		number=1
	else
		color = math.random(1,5)
		number = math.random(1,6)
	end
	local card1 = prefab4:clone()
	card1:addTo(player4)
	--card1:loadTexture(cardPath..color.."_"..number..".png")
	table.insert(cardList4,{card=card1,color=color,number=number})
end

--出牌
function C:outCard4(card)
	if card==nil then
		self:control()
	end
	PLAY_SOUND("majia/sendcard.mp3")
	local arr = {}
	arr[1]=cc.EaseSineInOut:create(cc.MoveTo:create(outCardTime,pos0))
	arr[2]=cc.CallFunc:create(function()
		for i = 1, #cardList4 do
			if cardList4[i].card==card then
				table.remove(cardList4,i)
				break
			end
		end
		self:updateScore()
		self:refreshCard4()
		self:refreshCard0()
		if self:canEnd() then
			self:gameReset(4)
			return
		end
		
		self:control()
	end)
	card:runAction(cc.Sequence:create(arr))
	--card:runAction(cc.RotateTo:create(0.2,math.random(-30,30)))
	card:setGlobalZOrder(curOrder)
	table.insert(outCards,card)
	curOrder=curOrder+1

	local arr1 = {}
	arr1[1]=cc.DelayTime:create(0.3)
	arr1[2]=cc.CallFunc:create(function()
		for i = 1, #cardList4 do
			if cardList4[i].card==card then
				local color = cardList4[i].color
				if color~=turnType then
					curCard={color=color,number=cardList4[i].number}
					allScore=allScore+curCard.number
				else
					right=-right
					self:showNotice("Reverse!")
				end
				card:loadTexture(cardPath..color.."_"..cardList4[i].number..".png")
			end
		end
	end)
	card:runAction(cc.Sequence:create(arr1))
end

--加牌
function C:inCard4()
	local card = prefab:clone()
	self.sendCardPanel:addChild(card)
	card:setPosition(cc.p(0,0))
	card:setRotation(30)
	local arr = {}
	arr[1]=cc.RotateTo:create(0.2,34)
	arr[2]=cc.RotateTo:create(0.2,0)
	arr[3]=cc.EaseBackIn:create(cc.MoveBy:create(incardTime+0.3,cc.p(-620,-205)))
	card:runAction(cc.Sequence:create(arr))
	local array = {}
	array[1]=cc.DelayTime:create(incardTime+0.3+0.3)
	array[2]=cc.FadeOut:create(0.1)
	array[3]=cc.CallFunc:create(function()
		self:createCard4()
		self:refreshCard4()
		card:removeFromParent()

		local arr1 = {}
		arr1[1]=cc.DelayTime:create(2)
		arr1[2]=cc.CallFunc:create(function()
			local card = self:getBestCard4()
			self:outCard4(card)
		end)
		self.sendCardPanel:runAction(cc.Sequence:create(arr1))
	end)
	card:runAction(cc.Sequence:create(array))
end

--获取最佳牌
function C:getBestCard4()
	for i = 1, #cardList4 do
		if cardList4[i].number+allScore==resultNum then
			return cardList4[i].card
		end
	end
	if #cardList4==0 then
		return nil
	end
	local index = math.random(1,#cardList4)
	return cardList4[index].card
end

--设置明暗
function C:setLight4(light)
	for i = 1, #cardList4 do
		if light==true then
			cardList4[i].card:setOpacity(255)			
		else
			cardList4[i].card:setOpacity(200)
		end
	end
end

--设置分数
function C:updateScore4()
	if score4>=0 then
		win4:setString("+"..score4)
		win4:setVisible(true)
		lose4:setVisible(false)
		--effect4:start()
	else
		lose4:setString(score4)
		win4:setVisible(false)
		lose4:setVisible(true)
	end
end

--清理
function C:clear()
	for i = 1, #cardList1 do
		cardList1[i].card:removeFromParent()
	end
	cardList1={}

	for i = 1, #cardList2 do
		cardList2[i].card:removeFromParent()
	end
	cardList2={}

	for i = 1, #cardList3 do
		cardList3[i].card:removeFromParent()
	end
	cardList3={}

	for i = 1, #cardList4 do
		cardList4[i].card:removeFromParent()
	end
	cardList4={}

	for i = 1, #outCards do
		outCards[i]:removeFromParent()
	end
	outCards={}
end

--开始游戏
function C:StartGame()
	self:clear()
	self.helpPanel:setVisible(false)
	self.gamePanel:setVisible(true)
	self.resultPanel:setVisible(false)
	self.sendCardPanel:setVisible(true)
	score1=0
	self:updateScore1()
	score2=0
	self:updateScore2()
	score3=0
	self:updateScore3()
	score4=0
	self:updateScore4()

	curTurn=5001
	turns=0
	curCard={color=math.random(3,6)}
	outCards={}
	curOrder=100
	right=1
	isFirst = true
	canSend=true
	allScore=0
	self:updateScore()
	self.moving=false
	
	local array = {}
	array[1]=cc.CallFunc:create(function()
		self:createCard1()
		self:refreshCard1()

		self:createCard2()
		self:refreshCard2()

		self:createCard3()
		self:refreshCard3()

		self:createCard4()
		self:refreshCard4()
	end)
	array[2]=cc.DelayTime:create(interval)
	local repeatAni=CCRepeat:create(cc.Sequence:create(array),cardNum)
	local funAni=cc.CallFunc:create(function()
		self:createCard1()
		self:refreshCard1()

		self:setLight1(true)
		self:setLight2(false)
		self:setLight3(false)
		self:setLight4(false)
	end)

	self.gamePanel:runAction(cc.Sequence:create({repeatAni,funAni}))
end

--控制
function C:control()
	curTurn=curTurn+right
	--判断是否继续发牌
	turns=turns+1
	if turns>=maxCard then
		canSend=false
		self.sendCardPanel:setVisible(false)
	else
		canSend=true
	end
	--判断是否结算
	if self:canOver() then
		self:gameOver()
		return
	end
	
	if curTurn%4==1 then
		self.gamePanel:stopAllActions()
		self:setLight1(true)
		self:setLight2(false)
		self:setLight3(false)
		self:setLight4(false)

		if canSend then
			self:inCard1()			
		end
		if #cardList1==0 then
			self:control()
		end
		return
	elseif curTurn%4==2 then
		self:setLight2(true)
		self:setLight3(false)
		self:setLight4(false)
		if #cardList2==0 then
			self:control()
			return
		end	
	elseif curTurn%4==3 then
		self:setLight2(false)
		self:setLight3(true)
		self:setLight4(false)
		if #cardList3==0 then
			self:control()
			return
		end	
	elseif curTurn%4==0 then
		self:setLight2(false)
		self:setLight3(false)
		self:setLight4(true)
		if #cardList4==0 then
			self:control()
			return
		end	
	end

	self:setLight1(false)

	local arr = {}
	arr[1]=cc.DelayTime:create(1)
	arr[2]=cc.CallFunc:create(function()
		if curTurn%4==2 then
			if canSend then
				self:inCard2()
			else
				local card = self:getBestCard2()
				self:outCard2(card)
			end
		elseif curTurn%4==3 then
			if canSend then
				self:inCard3()
			else
				local card = self:getBestCard3()
				self:outCard3(card)
			end
		elseif curTurn%4==0 then
			if canSend then
				self:inCard4()
			else
				local card = self:getBestCard4()
				self:outCard4(card)
			end
		end
	end)	

	self.gamePanel:stopAllActions()
	self.gamePanel:runAction(cc.Sequence:create(arr))
end

--游戏结束条件
function C:canEnd()
	if allScore>=resultNum then
		return true
	end
	return false
end

--游戏结束
function C:gameReset(seat)
	local count = #outCards
	if allScore>resultNum then
		count=-count
	end

	local array = {}
	array[1]=cc.DelayTime:create(2)
	array[2]=cc.CallFunc:create(function()
		for i = 1, math.abs(count) do
			local arr = {}
			arr[1]=cc.DelayTime:create(0.15*(i-1))
			if seat==1 then
				arr[2]=cc.MoveBy:create(0.4,cc.p(0,-150))
			elseif seat==2 then
				arr[2]=cc.MoveBy:create(0.4,cc.p(150,0))
			elseif seat==3 then
				arr[2]=cc.MoveBy:create(0.4,cc.p(0,150))
			elseif seat==4 then
				arr[2]=cc.MoveBy:create(0.4,cc.p(-150,0))
			end
			arr[3]=cc.CallFunc:create(function()
				outCards[i]:removeFromParent()			
				
				if i==math.abs(count) then
					if seat==1 then
						local factor = 1
						if role1ID==curCard.number then
							factor=2
							self:showNotice("Double!")
						end
						score1=score1+count*factor
						self:updateScore1()
					elseif seat==2 then 
						local factor = 1
						if role2ID==curCard.number then
							factor=2
							self:showNotice("Double!")
						end
						score2=score2+count*factor
						self:updateScore2()
					elseif seat==3 then 
						local factor = 1
						if role3ID==curCard.number then
							factor=2
							self:showNotice("Double!")
						end
						score3=score3+count*factor
						self:updateScore3()
					elseif seat==4 then 
						local factor = 1
						if role4ID==curCard.number then
							factor=2
							self:showNotice("Double!")
						end
						score4=score4+count*factor
						self:updateScore4()
					end
					outCards={}
					allScore=0
					self:updateScore()

					self:control()
				end
			end)
			outCards[i]:runAction(cc.Sequence:create(arr))

			local arr1 = {}
			arr1[1]=cc.DelayTime:create(0.15*i)
			arr1[2]=cc.FadeOut:create(0.3)
			outCards[i]:runAction(cc.Sequence:create(arr1))
		end
		
	end)
	self.gamePanel:runAction(cc.Sequence:create(array))
end

--是否结算
function C:canOver()
	if #cardList1+#cardList2+#cardList3+#cardList4==0 then
		return true
	end
	return false
end

--游戏结算
function C:gameOver()
	printInfo(">>>>>>>>>>>>游戏结算>>>>>>>>>>>")
	self:clear()
	self.resultPanel:setVisible(true)
	local total = score1
	if total>=0 then
		self.girlImg:loadTexture("minigame/images/q"..curRoom..".png")
		self.resultImg:loadTexture("minigame/images/b1.png")
	else
		self.girlImg:loadTexture("minigame/images/q"..curRoom.."_hui.png")
		self.resultImg:loadTexture("minigame/images/b2.png")
	end
	local scoreTable={
		[1]=score1,
		[2]=score2,
		[3]=score3,
		[4]=score4
	}
	table.sort(scoreTable,function(a,b)
		return a>b
	end)
	self:showResultScore(self.rank1,scoreTable[1])
	self:showResultScore(self.rank2,scoreTable[2])
	self:showResultScore(self.rank3,scoreTable[3])
	self:showResultScore(self.rank4,scoreTable[4])

	self.rank1:setPosition(cc.p(840,410))
	self.rank1:runAction(cc.MoveTo:create(0.2,cc.p(640,410)))

	self.rank2:setOpacity(0)
	self.rank2:setPosition(cc.p(860,327))
	local arr1 = {}
	arr1[1]=cc.DelayTime:create(0.1)
	arr1[2]=cc.CallFunc:create(function()
		self.rank2:runAction(cc.MoveTo:create(0.2,cc.p(660,327)))
		self.rank2:runAction(cc.FadeIn:create(0.1))
	end)
	self.rank2:runAction(cc.Sequence:create(arr1))
	

	self.rank3:setOpacity(0)
	self.rank3:setPosition(cc.p(880,244))
	local arr2 = {}
	arr2[1]=cc.DelayTime:create(0.3)
	arr2[2]=cc.CallFunc:create(function()
		self.rank3:runAction(cc.FadeIn:create(0.1))
		self.rank3:runAction(cc.MoveTo:create(0.2,cc.p(680,244)))
	end)
	self.rank3:runAction(cc.Sequence:create(arr2))
	

	self.rank4:setOpacity(0)
	self.rank4:setPosition(cc.p(900,161))
	local arr3 = {}
	arr3[1]=cc.DelayTime:create(0.5)
	arr3[2]=cc.CallFunc:create(function()
		self.rank4:runAction(cc.FadeIn:create(0.1))
		self.rank4:runAction(cc.MoveTo:create(0.2,cc.p(700,161)))
	end)
	self.rank4:runAction(cc.Sequence:create(arr3))
	

	self.resultSelectImg:setOpacity(0)
	utils:delayInvoke("minigame.gameover",1,function()
		for i = 1, 4 do
			if scoreTable[i]==score1 then
				local item=nil
				if i==1 then
					item=self.rank1
				elseif i==2 then
					item=self.rank2
				elseif i==3 then
					item=self.rank3
				elseif i==4 then
					item=self.rank4
				end
				self.resultSelectImg:setPosition(cc.p(item:getPositionX()+60,item:getPositionY()))
				self.resultSelectImg:runAction(cc.FadeIn:create(0.2))
				break
			end
		end
	end)
end

function C:showResultScore(_node,_score)
	local win=_node:getChildByName("win")
	local lose=_node:getChildByName("lose")
	if _score>=0 then
		win:setString("+".._score)
		win:setVisible(true)
		lose:setVisible(false)
	else
		lose:setString(_score)
		win:setVisible(false)
		lose:setVisible(true)
	end
end

return C