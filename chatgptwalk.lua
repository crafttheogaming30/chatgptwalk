-- AUTO WALK TRACK SYSTEM - FULL FINAL HP v1
-- FIXED UI • RECORD • PAUSE • PLAY • STOP • HISTORY • SPEED • LOOP • FLY
-- Made for Mobile / Delta

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera
local PlayerGui = player:WaitForChild("PlayerGui")

---------------- GUI ROOT ----------------
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "AutoWalkFullGUI"
gui.ResetOnSpawn = false

---------------- NOTIF ----------------
local function notify(txt)
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {
			Title = "AutoWalk",
			Text = txt,
			Duration = 2
		})
	end)
end

---------------- PANEL MAKER ----------------
local function makePanel(titleText, size, pos)
	local f = Instance.new("Frame", gui)
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(18,22,38)
	f.Active = true
	f.Draggable = true
	f.BorderSizePixel = 0
	Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)

	local header = Instance.new("Frame", f)
	header.Size = UDim2.new(1,0,0,36)
	header.BackgroundColor3 = Color3.fromRGB(25,30,55)
	Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

	local title = Instance.new("TextLabel", header)
	title.Size = UDim2.new(1,-80,1,0)
	title.Position = UDim2.new(0,10,0,0)
	title.Text = titleText
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextColor3 = Color3.new(1,1,1)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Left

	local close = Instance.new("TextButton", header)
	close.Size = UDim2.new(0,28,0,28)
	close.Position = UDim2.new(1,-32,0,4)
	close.Text = "X"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 13
	close.TextColor3 = Color3.new(1,1,1)
	close.BackgroundColor3 = Color3.fromRGB(170,60,60)
	Instance.new("UICorner", close)

	local mini = Instance.new("TextButton", header)
	mini.Size = UDim2.new(0,28,0,28)
	mini.Position = UDim2.new(1,-64,0,4)
	mini.Text = "-"
	mini.Font = Enum.Font.GothamBold
	mini.TextSize = 16
	mini.TextColor3 = Color3.new(1,1,1)
	mini.BackgroundColor3 = Color3.fromRGB(70,90,160)
	Instance.new("UICorner", mini)

	return f, close, mini
end

local function makeBtn(parent, txt)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,0,0,36)
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(45,65,130)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

---------------- MAIN PANEL ----------------
local main, mainClose, mainMini =
	makePanel("AUTO WALK PRO", UDim2.new(0,280,0,240), UDim2.new(0.05,0,0.2,0))

local body = Instance.new("ScrollingFrame", main)
body.Position = UDim2.new(0,10,0,46)
body.Size = UDim2.new(1,-20,1,-56)
body.ScrollBarThickness = 6
body.AutomaticCanvasSize = Y
body.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", body)
layout.Padding = UDim.new(0,8)

---------------- STATE ----------------
local track = {}
local recording = false
local paused = false
local playing = false
local loop = false
local autoSpeed = 0.03

---------------- DOUBLE TAP ----------------
local lastTap = 0
local function doubleTap()
	local t = tick()
	if t - lastTap < 0.35 then
		lastTap = 0
		return true
	end
	lastTap = t
	return false
end

---------------- BUTTONS ----------------
local recBtn = makeBtn(body, "● Record (Double Stop)")
local pauseBtn = makeBtn(body, "⏸ Pause Record")
local playBtn = makeBtn(body, "▶ Play AutoWalk")
local stopPlayBtn = makeBtn(body, "⏹ Stop Play")
local speedBtn = makeBtn(body, "⚙ Speed AutoWalk")
local loopBtn = makeBtn(body, "🔁 Loop OFF")
local histBtn = makeBtn(body, "📁 History Track")
local flyBtn = makeBtn(body, "🕊 Fly Panel")

---------------- RECORD ----------------
recBtn.MouseButton1Click:Connect(function()
	if recording and doubleTap() then
		recording = false
		paused = false
		notify("Record Stop")
		return
	end
	if not recording then
		track = {}
		recording = true
		paused = false
		notify("Record Start")
	end
end)

pauseBtn.MouseButton1Click:Connect(function()
	if recording then
		paused = not paused
		notify(paused and "Record Paused" or "Record Resume")
	end
end)

RunService.Heartbeat:Connect(function()
	if recording and not paused then
		table.insert(track, root.CFrame)
	end
end)

---------------- PLAY ----------------
playBtn.MouseButton1Click:Connect(function()
	if #track < 2 or playing then return end
	playing = true
	notify("Play AutoWalk")
	task.spawn(function()
		repeat
			for _,cf in ipairs(track) do
				if not playing then break end
				root.CFrame = cf
				task.wait(autoSpeed)
			end
		until not loop or not playing
		playing = false
	end)
end)

stopPlayBtn.MouseButton1Click:Connect(function()
	playing = false
	notify("Play Stop")
end)

---------------- LOOP ----------------
loopBtn.MouseButton1Click:Connect(function()
	if doubleTap() then
		loop = not loop
		loopBtn.Text = loop and "🔁 Loop ON" or "🔁 Loop OFF"
		notify(loop and "Loop ON" or "Loop OFF")
	end
end)

---------------- SPEED PANEL ----------------
speedBtn.MouseButton1Click:Connect(function()
	local p, c, m = makePanel("AutoWalk Speed", UDim2.new(0,200,0,140), UDim2.new(0.4,0,0.35,0))
	local plus = makeBtn(p, "+ Speed")
	local minus = makeBtn(p, "- Speed")
	plus.Position = UDim2.new(0.1,0,0.4,0)
	minus.Position = UDim2.new(0.1,0,0.65,0)

	plus.MouseButton1Click:Connect(function()
		autoSpeed = math.clamp(autoSpeed - 0.005, 0.01, 0.1)
		notify("Speed : "..autoSpeed)
	end)
	minus.MouseButton1Click:Connect(function()
		autoSpeed = math.clamp(autoSpeed + 0.005, 0.01, 0.1)
		notify("Speed : "..autoSpeed)
	end)

	c.MouseButton1Click:Connect(function() p:Destroy() end)
	m.MouseButton1Click:Connect(function() p.Visible = not p.Visible end)
end)

---------------- HISTORY ----------------
histBtn.MouseButton1Click:Connect(function()
	local p, c, m = makePanel("History Track", UDim2.new(0,240,0,200), UDim2.new(0.35,0,0.3,0))
	local list = Instance.new("UIListLayout", p)
	list.Padding = UDim.new(0,6)

	local del = makeBtn(p, "🗑 Delete Track")
	del.MouseButton1Click:Connect(function()
		track = {}
		notify("Track Deleted")
	end)

	c.MouseButton1Click:Connect(function() p:Destroy() end)
	m.MouseButton1Click:Connect(function() p.Visible = not p.Visible end)
end)

---------------- FLY PANEL ----------------
local flying = false
local flySpeed = 50
local bv, bg, flyConn

flyBtn.MouseButton1Click:Connect(function()
	local p, c, m = makePanel("Fly Control", UDim2.new(0,220,0,200), UDim2.new(0.4,0,0.3,0))
	local on = makeBtn(p, "FLY ON")
	local off = makeBtn(p, "FLY OFF")
	local plus = makeBtn(p, "+ Speed")
	local minus = makeBtn(p, "- Speed")

	on.MouseButton1Click:Connect(function()
		if flying then return end
		flying = true
		bv = Instance.new("BodyVelocity", root)
		bg = Instance.new("BodyGyro", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)

		flyConn = RunService.RenderStepped:Connect(function()
			bv.Velocity = hum.MoveDirection * flySpeed
			bg.CFrame = cam.CFrame
		end)
		notify("Fly ON")
	end)

	off.MouseButton1Click:Connect(function()
		flying = false
		if flyConn then flyConn:Disconnect() end
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
		notify("Fly OFF")
	end)

	plus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed + 10,10,200)
		notify("Fly Speed "..flySpeed)
	end)
	minus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed - 10,10,200)
		notify("Fly Speed "..flySpeed)
	end)

	c.MouseButton1Click:Connect(function() p:Destroy() end)
	m.MouseButton1Click:Connect(function() p.Visible = not p.Visible end)
end)

---------------- MAIN CLOSE / MINIMIZE ----------------
mainClose.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

mainMini.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

notify("AutoWalk FULL Loaded")
