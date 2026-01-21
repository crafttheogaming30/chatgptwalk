-- AUTO WALK TRACK SYSTEM - FULL FINAL v8 (HP STABLE)

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ================= PLAYER =================
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local guiParent = plr:WaitForChild("PlayerGui")

-- ================= FILE =================
if not isfolder("tracks") then makefolder("tracks") end

-- ================= STATE =================
local recording = false
local paused = false
local playing = false
local loopTrack = false
local trackData = {}
local playConn, recConn

local walkSpeed = 16
local flySpeed = 60

-- ================= THEME =================
local C_BG = Color3.fromRGB(18,22,38)
local C_HD = Color3.fromRGB(25,30,55)
local C_BTN = Color3.fromRGB(45,65,130)
local C_TXT = Color3.new(1,1,1)

-- ================= NOTIF =================
local function notify(txt)
	local g = Instance.new("ScreenGui", guiParent)
	local f = Instance.new("Frame", g)
	f.Size = UDim2.new(0,260,0,40)
	f.Position = UDim2.new(0.5,-130,0.9,0)
	f.BackgroundColor3 = C_HD
	Instance.new("UICorner", f)
	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.new(1,0,1,0)
	t.BackgroundTransparency = 1
	t.Text = txt
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.TextColor3 = C_TXT
	TweenService:Create(f,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-130,0.85,0)}):Play()
	task.delay(2,function()
		TweenService:Create(f,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
		task.wait(0.3)
		g:Destroy()
	end)
end

-- ================= MAIN GUI =================
local gui = Instance.new("ScreenGui", guiParent)
gui.ResetOnSpawn = false
gui.Name = "AutoWalkFull"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,280,0,260)
main.Position = UDim2.new(0.05,0,0.2,0)
main.BackgroundColor3 = C_BG
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- HEADER
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = C_HD
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Text = "AUTO WALK PRO"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = C_TXT
title.BackgroundTransparency = 1
title.TextXAlignment = Left

-- CLOSE
local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = C_TXT
close.BackgroundColor3 = Color3.fromRGB(170,60,60)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- MINIMIZE
local minimized = false
local mini = Instance.new("TextButton", header)
mini.Size = UDim2.new(0,30,0,30)
mini.Position = UDim2.new(1,-70,0,5)
mini.Text = "—"
mini.Font = Enum.Font.GothamBold
mini.TextColor3 = C_TXT
mini.BackgroundColor3 = Color3.fromRGB(70,90,160)
Instance.new("UICorner", mini)

local icon
mini.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		main.Visible = false
		icon = Instance.new("TextButton", gui)
		icon.Size = UDim2.new(0,120,0,32)
		icon.Position = UDim2.new(0.05,0,0.2,0)
		icon.Text = "AutoWalk"
		icon.Font = Enum.Font.GothamBold
		icon.TextColor3 = C_TXT
		icon.BackgroundColor3 = C_HD
		icon.Active = true
		icon.Draggable = true
		Instance.new("UICorner", icon)
		icon.MouseButton1Click:Connect(function()
			main.Visible = true
			icon:Destroy()
			minimized = false
		end)
	end
end)

-- ================= SCROLL BODY =================
local body = Instance.new("ScrollingFrame", main)
body.Size = UDim2.new(1,-20,1,-60)
body.Position = UDim2.new(0,10,0,50)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.ScrollBarThickness = 6
body.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", body)
layout.Padding = UDim.new(0,8)

local function btn(txt)
	local b = Instance.new("TextButton", body)
	b.Size = UDim2.new(1,0,0,36)
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = C_TXT
	b.BackgroundColor3 = C_BTN
	Instance.new("UICorner", b)
	return b
end

-- ================= BUTTONS =================
local recBtn   = btn("● Record Track")
local pauseBtn = btn("⏸ Pause Record")
local playBtn  = btn("▶ Play Track")
local stopBtn  = btn("⏹ Stop Play")
local loopBtn  = btn("🔁 Loop OFF")
local histBtn  = btn("📂 History")
local spdBtn   = btn("⚙ Speed")
local flyBtn   = btn("🕊 Fly OFF")
local flySpd   = btn("⚙ Fly Speed")

-- ================= RECORD =================
recBtn.MouseButton1Click:Connect(function()
	recording = not recording
	if recording then
		trackData = {}
		notify("Record ON")
		recConn = RunService.Heartbeat:Connect(function()
			if not paused then
				table.insert(trackData, root.Position)
			end
		end)
	else
		if recConn then recConn:Disconnect() end
		notify("Record OFF ("..#trackData.." point)")
	end
end)

pauseBtn.MouseButton1Click:Connect(function()
	if not recording then return end
	paused = not paused
	notify(paused and "Record Pause" or "Record Resume")
end)

-- ================= PLAY =================
playBtn.MouseButton1Click:Connect(function()
	if #trackData < 2 then return notify("Track kosong") end
	if playing then return end
	playing = true
	local i = 1
	playConn = RunService.Heartbeat:Connect(function()
		if not playing then playConn:Disconnect() return end
		if trackData[i] then
			root.CFrame = CFrame.new(trackData[i])
			i += math.clamp(walkSpeed/8,1,5)
		else
			if loopTrack then i = 1
			else playing = false notify("Play selesai") playConn:Disconnect() end
		end
	end)
end)

stopBtn.MouseButton1Click:Connect(function()
	playing = false
end)

loopBtn.MouseButton1Click:Connect(function()
	loopTrack = not loopTrack
	loopBtn.Text = loopTrack and "🔁 Loop ON" or "🔁 Loop OFF"
end)

-- ================= SPEED PANEL (MANUAL + AUTOWALK) =================
spdBtn.MouseButton1Click:Connect(function()
	local g = Instance.new("Frame", gui)
	g.Size = UDim2.new(0,220,0,120)
	g.Position = UDim2.new(0.4,0,0.35,0)
	g.BackgroundColor3 = C_HD
	g.Active = true
	g.Draggable = true
	Instance.new("UICorner", g)

	local t = Instance.new("TextLabel", g)
	t.Size = UDim2.new(1,0,0,30)
	t.Text = "Walk Speed"
	t.Font = Enum.Font.GothamBold
	t.TextColor3 = C_TXT
	t.BackgroundTransparency = 1

	local plus = Instance.new("TextButton", g)
	plus.Size = UDim2.new(0.4,0,0,36)
	plus.Position = UDim2.new(0.05,0,0.5,0)
	plus.Text = "+"
	plus.Font = Enum.Font.GothamBold
	plus.BackgroundColor3 = C_BTN
	Instance.new("UICorner", plus)

	local minus = plus:Clone()
	minus.Parent = g
	minus.Position = UDim2.new(0.55,0,0.5,0)
	minus.Text = "-"

	local c = Instance.new("TextButton", g)
	c.Size = UDim2.new(0,24,0,24)
	c.Position = UDim2.new(1,-28,0,4)
	c.Text = "X"
	c.BackgroundTransparency = 1
	c.TextColor3 = C_TXT
	c.MouseButton1Click:Connect(function() g:Destroy() end)

	plus.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed+2,8,100)
		hum.WalkSpeed = walkSpeed
		notify("Speed "..walkSpeed)
	end)
	minus.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed-2,8,100)
		hum.WalkSpeed = walkSpeed
	end)
end)

-- ================= FLY =================
local flying = false
local bv,bg,flyConn

flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	flyBtn.Text = flying and "🕊 Fly ON" or "🕊 Fly OFF"
	if flying then
		bv = Instance.new("BodyVelocity", root)
		bg = Instance.new("BodyGyro", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
		flyConn = RunService.RenderStepped:Connect(function()
			bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
			bg.CFrame = workspace.CurrentCamera.CFrame
		end)
	else
		if flyConn then flyConn:Disconnect() end
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

-- ================= FLY SPEED PANEL =================
flySpd.MouseButton1Click:Connect(function()
	local g = Instance.new("Frame", gui)
	g.Size = UDim2.new(0,200,0,120)
	g.Position = UDim2.new(0.45,0,0.35,0)
	g.BackgroundColor3 = C_HD
	g.Active = true
	g.Draggable = true
	Instance.new("UICorner", g)

	local t = Instance.new("TextLabel", g)
	t.Size = UDim2.new(1,0,0,30)
	t.Text = "Fly Speed"
	t.Font = Enum.Font.GothamBold
	t.TextColor3 = C_TXT
	t.BackgroundTransparency = 1

	local plus = Instance.new("TextButton", g)
	plus.Size = UDim2.new(0.4,0,0,36)
	plus.Position = UDim2.new(0.05,0,0.5,0)
	plus.Text = "+"
	plus.Font = Enum.Font.GothamBold
	plus.BackgroundColor3 = C_BTN
	Instance.new("UICorner", plus)

	local minus = plus:Clone()
	minus.Parent = g
	minus.Position = UDim2.new(0.55,0,0.5,0)
	minus.Text = "-"

	local c = Instance.new("TextButton", g)
	c.Size = UDim2.new(0,24,0,24)
	c.Position = UDim2.new(1,-28,0,4)
	c.Text = "X"
	c.BackgroundTransparency = 1
	c.TextColor3 = C_TXT
	c.MouseButton1Click:Connect(function() g:Destroy() end)

	plus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed+10,10,200)
	end)
	minus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed-10,10,200)
	end)
end)

-- ================= HISTORY PANEL =================
histBtn.MouseButton1Click:Connect(function()
	local g = Instance.new("Frame", gui)
	g.Size = UDim2.new(0,260,0,260)
	g.Position = UDim2.new(0.35,0,0.25,0)
	g.BackgroundColor3 = C_BG
	g.Active = true
	g.Draggable = true
	Instance.new("UICorner", g)

	local h = Instance.new("Frame", g)
	h.Size = UDim2.new(1,0,0,36)
	h.BackgroundColor3 = C_HD
	Instance.new("UICorner", h)

	local c = Instance.new("TextButton", h)
	c.Size = UDim2.new(0,28,0,28)
	c.Position = UDim2.new(1,-34,0,4)
	c.Text = "X"
	c.TextColor3 = C_TXT
	c.BackgroundTransparency = 1
	c.MouseButton1Click:Connect(function() g:Destroy() end)

	local list = Instance.new("ScrollingFrame", g)
	list.Size = UDim2.new(1,-10,1,-46)
	list.Position = UDim2.new(0,5,0,40)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 6
	list.BackgroundTransparency = 1

	local l = Instance.new("UIListLayout", list)
	l.Padding = UDim.new(0,6)

	for _,f in ipairs(listfiles("tracks")) do
		local name = f:match(".+/([^/]+)%.lua$")
		local b = Instance.new("TextButton", list)
		b.Size = UDim2.new(1,0,0,32)
		b.Text = name
		b.Font = Enum.Font.Gotham
		b.TextColor3 = C_TXT
		b.BackgroundColor3 = C_BTN
		Instance.new("UICorner", b)
		b.MouseButton1Click:Connect(function()
			trackData = loadfile(f)()
			notify("Track "..name.." loaded")
		end)
	end
end)

print("AUTO WALK FULL v8 LOADED")
