-- AUTO WALK + FLY FULL PRO (COREGUI SAFE)
-- HP / Delta / Anti UI Hilang
-- by ChatGPT for Teyoo

------------------------------------------------
-- ANTI DUPLIKAT GUI
------------------------------------------------
pcall(function()
	if game.CoreGui:FindFirstChild("AutoWalkFullGUI") then
		game.CoreGui.AutoWalkFullGUI:Destroy()
	end
end)

------------------------------------------------
-- SERVICES
------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera

------------------------------------------------
-- FILE SYSTEM
------------------------------------------------
if not isfolder("autowalk_tracks") then
	makefolder("autowalk_tracks")
end

------------------------------------------------
-- STATE
------------------------------------------------
local recording = false
local paused = false
local playing = false
local loopPlay = false

local track = {}
local recordConn, playConn

local walkSpeed = 25

------------------------------------------------
-- FLY STATE
------------------------------------------------
local flyEnabled = false
local flySpeed = 40
local bv, bg, flyConn

------------------------------------------------
-- THEME
------------------------------------------------
local THEME = {
	bg = Color3.fromRGB(18,22,38),
	panel = Color3.fromRGB(25,30,55),
	btn = Color3.fromRGB(45,65,130),
	accent = Color3.fromRGB(90,160,255),
	text = Color3.fromRGB(235,240,255),
	danger = Color3.fromRGB(170,60,60)
}

------------------------------------------------
-- GUI BASE (COREGUI)
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AutoWalkFullGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

------------------------------------------------
-- NOTIFY
------------------------------------------------
local function notify(txt)
	local n = Instance.new("TextLabel", gui)
	n.Size = UDim2.fromScale(0.4,0.06)
	n.Position = UDim2.fromScale(0.3,0.86)
	n.BackgroundColor3 = THEME.panel
	n.TextColor3 = THEME.text
	n.Text = txt
	n.Font = Enum.Font.GothamMedium
	n.TextSize = 14
	n.TextScaled = true
	n.BackgroundTransparency = 0
	Instance.new("UICorner", n).CornerRadius = UDim.new(0,14)

	TweenService:Create(n, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	task.delay(2,function()
		TweenService:Create(n, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		task.wait(0.35)
		n:Destroy()
	end)
end

------------------------------------------------
-- UI HELPERS
------------------------------------------------
local function makeCorner(obj,r)
	local c = Instance.new("UICorner",obj)
	c.CornerRadius = UDim.new(0,r or 10)
end

local function makePanel(titleText, size, pos)
	local f = Instance.new("Frame", gui)
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = THEME.panel
	f.Active = true
	f.Draggable = true
	makeCorner(f,14)

	local header = Instance.new("Frame", f)
	header.Size = UDim2.new(1,0,0,36)
	header.BackgroundColor3 = THEME.bg
	makeCorner(header,14)

	local title = Instance.new("TextLabel", header)
	title.Size = UDim2.new(1,-80,1,0)
	title.Position = UDim2.fromOffset(10,0)
	title.Text = titleText
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextColor3 = THEME.text
	title.BackgroundTransparency = 1
	title.TextXAlignment = Left

	local close = Instance.new("TextButton", header)
	close.Size = UDim2.fromOffset(28,28)
	close.Position = UDim2.new(1,-32,0,4)
	close.Text = "X"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.TextColor3 = Color3.new(1,1,1)
	close.BackgroundColor3 = THEME.danger
	makeCorner(close,8)

	local mini = Instance.new("TextButton", header)
	mini.Size = UDim2.fromOffset(28,28)
	mini.Position = UDim2.new(1,-64,0,4)
	mini.Text = "—"
	mini.Font = Enum.Font.GothamBold
	mini.TextSize = 16
	mini.TextColor3 = Color3.new(1,1,1)
	mini.BackgroundColor3 = THEME.btn
	makeCorner(mini,8)

	return f, header, close, mini
end

local function makeScroll(parent)
	local s = Instance.new("ScrollingFrame", parent)
	s.Position = UDim2.fromOffset(10,44)
	s.Size = UDim2.new(1,-20,1,-54)
	s.ScrollBarThickness = 6
	s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.CanvasSize = UDim2.new(0,0,0,0)
	s.BackgroundTransparency = 1

	local lay = Instance.new("UIListLayout", s)
	lay.Padding = UDim.new(0,8)

	return s
end

local function makeBtn(parent, txt)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,0,0,36)
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = THEME.text
	b.BackgroundColor3 = THEME.btn
	b.BorderSizePixel = 0
	makeCorner(b,10)
	return b
end

------------------------------------------------
-- MAIN PANEL (PENDEK + SCROLL)
------------------------------------------------
local main, mainHeader, mainClose, mainMini =
	makePanel("AUTO WALK PRO",
		UDim2.fromOffset(280,260),
		UDim2.fromScale(0.05,0.25)
	)

local mainBody = makeScroll(main)

-- minimize main
local mainMinimized = false
local mainIcon
mainMini.MouseButton1Click:Connect(function()
	mainMinimized = not mainMinimized
	if mainMinimized then
		main.Visible = false
		mainIcon = Instance.new("TextButton", gui)
		mainIcon.Size = UDim2.fromOffset(120,32)
		mainIcon.Position = UDim2.fromScale(0.05,0.25)
		mainIcon.Text = "AutoWalk"
		mainIcon.Font = Enum.Font.GothamBold
		mainIcon.TextSize = 13
		mainIcon.TextColor3 = THEME.text
		mainIcon.BackgroundColor3 = THEME.panel
		makeCorner(mainIcon,12)
		mainIcon.Active = true
		mainIcon.Draggable = true
		mainIcon.MouseButton1Click:Connect(function()
			main.Visible = true
			mainIcon:Destroy()
			mainMinimized = false
		end)
	end
end)

mainClose.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

------------------------------------------------
-- BUTTONS (4 AWAL TERLIHAT)
------------------------------------------------
local recordBtn = makeBtn(mainBody,"● Record (Double Tap Stop)")
local pauseBtn  = makeBtn(mainBody,"⏸ Pause Record")
local playBtn   = makeBtn(mainBody,"▶ Play AutoWalk")
local stopPlayBtn = makeBtn(mainBody,"⏹ Stop AutoWalk")

-- SCROLL KE BAWAH
local speedBtn  = makeBtn(mainBody,"⚙ Speed AutoWalk")
local loopBtn   = makeBtn(mainBody,"🔁 Loop OFF (Double Tap)")
local historyBtn= makeBtn(mainBody,"📂 History Track")
local flyBtn    = makeBtn(mainBody,"🛫 Fly Panel")

------------------------------------------------
-- RECORD LOGIC (DOUBLE TAP STOP)
------------------------------------------------
local lastRecordTap = 0

recordBtn.MouseButton1Click:Connect(function()
	local now = tick()
	if recording and now-lastRecordTap < 0.35 then
		-- STOP
		recording = false
		paused = false
		recordBtn.Text = "● Record (Double Tap Stop)"
		pauseBtn.Text = "⏸ Pause Record"

		local name = "track_"..os.time()..".lua"
		local data = "return {\n"
		for _,p in ipairs(track) do
			data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
		end
		data ..= "}"
		writefile("autowalk_tracks/"..name,data)
		notify("Record saved: "..name)
	else
		-- START
		recording = true
		paused = false
		track = {}
		recordBtn.Text = "● Recording..."
		notify("Record started")
	end
	lastRecordTap = now
end)

pauseBtn.MouseButton1Click:Connect(function()
	if not recording then return end
	paused = not paused
	pauseBtn.Text = paused and "▶ Resume Record" or "⏸ Pause Record"
	notify(paused and "Record paused" or "Record resumed")
end)

recordConn = RunService.RenderStepped:Connect(function()
	if recording and not paused then
		table.insert(track, root.Position)
	end
end)

------------------------------------------------
-- PLAY / STOP AUTOWALK
------------------------------------------------
local function stopPlay()
	playing = false
	if playConn then playConn:Disconnect() end
	notify("Play stopped")
end

playBtn.MouseButton1Click:Connect(function()
	if playing then return end

	local files = listfiles("autowalk_tracks")
	if #files == 0 then
		return notify("No track found")
	end

	local data = loadfile(files[#files])()
	if not data or #data < 2 then
		return notify("Track invalid")
	end

	playing = true
	notify("Play started")

	local i = 1
	playConn = RunService.RenderStepped:Connect(function()
		if not playing then return end
		if data[i] then
			root.CFrame = CFrame.new(data[i])
			i += math.clamp(walkSpeed/10,1,5)
		else
			if loopPlay then
				i = 1
			else
				stopPlay()
			end
		end
	end)
end)

stopPlayBtn.MouseButton1Click:Connect(stopPlay)

------------------------------------------------
-- LOOP (DOUBLE TAP)
------------------------------------------------
local lastLoopTap = 0
loopBtn.MouseButton1Click:Connect(function()
	local now = tick()
	if now-lastLoopTap < 0.35 then
		loopPlay = not loopPlay
		loopBtn.Text = loopPlay and "🔁 Loop ON (Double Tap)" or "🔁 Loop OFF (Double Tap)"
		notify(loopPlay and "Loop ON" or "Loop OFF")
	end
	lastLoopTap = now
end)

------------------------------------------------
-- SPEED AUTOWALK PANEL
------------------------------------------------
speedBtn.MouseButton1Click:Connect(function()
	local p,_,c,m = makePanel(
		"AutoWalk Speed",
		UDim2.fromOffset(220,140),
		UDim2.fromScale(0.4,0.35)
	)

	local body = makeScroll(p)

	local label = makeBtn(body,"Speed : "..walkSpeed)
	label.Active = false

	local plus = makeBtn(body,"+")
	local minus = makeBtn(body,"-")

	plus.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed+5,5,100)
		label.Text = "Speed : "..walkSpeed
		notify("Speed "..walkSpeed)
	end)
	minus.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed-5,5,100)
		label.Text = "Speed : "..walkSpeed
		notify("Speed "..walkSpeed)
	end)

	c.MouseButton1Click:Connect(function() p:Destroy() end)
	m.MouseButton1Click:Connect(function() p.Visible = false end)
end)

------------------------------------------------
-- HISTORY PANEL
------------------------------------------------
historyBtn.MouseButton1Click:Connect(function()
	local p,_,c,m = makePanel(
		"History Track",
		UDim2.fromOffset(260,260),
		UDim2.fromScale(0.38,0.25)
	)
	local body = makeScroll(p)

	for _,file in ipairs(listfiles("autowalk_tracks")) do
		local b = makeBtn(body, file:match("[^/]+$"))

		b.MouseButton1Click:Connect(function()
			delfile(file)
			notify("Deleted "..file)
			b:Destroy()
		end)
	end

	c.MouseButton1Click:Connect(function() p:Destroy() end)
	m.MouseButton1Click:Connect(function() p.Visible = false end)
end)

------------------------------------------------
-- FLY PANEL (MANUAL HP)
------------------------------------------------
flyBtn.MouseButton1Click:Connect(function()
	local p,_,c,m = makePanel(
		"Fly Control",
		UDim2.fromOffset(220,180),
		UDim2.fromScale(0.45,0.32)
	)
	local body = makeScroll(p)

	local onBtn = makeBtn(body,"FLY ON")
	local offBtn = makeBtn(body,"FLY OFF")
	local spdLbl = makeBtn(body,"Speed : "..flySpeed)
	spdLbl.Active = false
	local plus = makeBtn(body,"+ Speed")
	local minus = makeBtn(body,"- Speed")

	onBtn.MouseButton1Click:Connect(function()
		if flyEnabled then return end
		flyEnabled = true
		hum:ChangeState(Enum.HumanoidStateType.Physics)

		bv = Instance.new("BodyVelocity", root)
		bg = Instance.new("BodyGyro", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)

		flyConn = RunService.RenderStepped:Connect(function()
			local dir = hum.MoveDirection
			bv.Velocity = (cam.CFrame.LookVector * dir.Z + cam.CFrame.RightVector * dir.X) * flySpeed
			bg.CFrame = cam.CFrame
		end)

		notify("Fly ON")
	end)

	offBtn.MouseButton1Click:Connect(function()
		flyEnabled = false
		if flyConn then flyConn:Disconnect() end
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		notify("Fly OFF")
	end)

	plus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed+5,10,200)
		spdLbl.Text = "Speed : "..flySpeed
		notify("Fly speed "..flySpeed)
	end)
	minus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed-5,10,200)
		spdLbl.Text = "Speed : "..flySpeed
		notify("Fly speed "..flySpeed)
	end)

	c.MouseButton1Click:Connect(function() p:Destroy() end)
	m.MouseButton1Click:Connect(function() p.Visible = false end)
end)

------------------------------------------------
notify("AutoWalk Full Loaded")
print("AUTO WALK FULL PRO LOADED (CoreGui Safe)")
