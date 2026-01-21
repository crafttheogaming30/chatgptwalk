-- AUTO WALK + FLY PRO HP
-- Rebuild Total by ChatGPT for Teyoo

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")

-- FILE
if not isfolder("tracks") then makefolder("tracks") end

-- STATE
local recording = false
local paused = false
local playing = false
local flyEnabled = false
local speed = 25
local track = {}
local playIndex = 1
local recordConn, playConn, flyConn

-- THEME
local THEME = {
	bg = Color3.fromRGB(15,25,40),
	panel = Color3.fromRGB(20,35,60),
	header = Color3.fromRGB(30,55,90),
	accent = Color3.fromRGB(90,160,255),
	text = Color3.fromRGB(235,240,255)
}

------------------------------------------------
-- NOTIFY
------------------------------------------------
local function notify(txt)
	local gui = Instance.new("ScreenGui", game.CoreGui)
	local f = Instance.new("Frame", gui)
	f.Size = UDim2.fromScale(0.35,0.07)
	f.Position = UDim2.fromScale(0.325,0.85)
	f.BackgroundColor3 = THEME.panel
	Instance.new("UICorner", f).CornerRadius = UDim.new(0,14)

	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.fromScale(1,1)
	t.BackgroundTransparency = 1
	t.Text = txt
	t.TextColor3 = THEME.text
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 14

	task.delay(2,function()
		gui:Destroy()
	end)
end

------------------------------------------------
-- UI BASE
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoWalkPro"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(280,260)
main.Position = UDim2.fromScale(0.05,0.25)
main.BackgroundColor3 = THEME.panel
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,32)
header.BackgroundColor3 = THEME.header
Instance.new("UICorner", header).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7,0,1,0)
title.Position = UDim2.fromScale(0.05,0)
title.Text = "AUTO WALK PRO"
title.TextColor3 = THEME.text
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.fromOffset(28,28)
close.Position = UDim2.new(1,-32,0,2)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextColor3 = THEME.text
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local body = Instance.new("ScrollingFrame", main)
body.Position = UDim2.fromOffset(8,40)
body.Size = UDim2.fromOffset(264,210)
body.ScrollBarThickness = 6
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.BackgroundTransparency = 1

------------------------------------------------
-- UI HELPERS
------------------------------------------------
local function button(txt,y)
	local b = Instance.new("TextButton", body)
	b.Size = UDim2.fromOffset(240,32)
	b.Position = UDim2.fromOffset(10,y)
	b.Text = txt
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	b.TextColor3 = THEME.text
	b.BackgroundColor3 = THEME.header
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

------------------------------------------------
-- BUTTONS
------------------------------------------------
local y = 10
local recordBtn = button("● Record",y); y+=38
local stopBtn = button("⏹ Stop Record",y); y+=38
local playBtn = button("▶ Play Track",y); y+=38
local historyBtn = button("📂 History",y); y+=38
local flyBtn = button("🛫 Fly : OFF",y); y+=38

------------------------------------------------
-- RECORD LOGIC
------------------------------------------------
recordBtn.MouseButton1Click:Connect(function()
	if not recording then
		recording = true
		paused = false
		track = {}
		recordBtn.Text = "⏸ Pause"
		notify("Record started")
	else
		paused = not paused
		recordBtn.Text = paused and "▶ Resume" or "⏸ Pause"
		notify(paused and "Paused" or "Resumed")
	end
end)

stopBtn.MouseButton1Click:Connect(function()
	if recording then
		recording = false
		paused = false
		recordBtn.Text = "● Record"
		local name = "track_"..os.time()..".lua"
		local data = "return {\n"
		for _,p in ipairs(track) do
			data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
		end
		data ..= "}"
		writefile("tracks/"..name,data)
		notify("Saved "..name)
	end
end)

recordConn = RunService.RenderStepped:Connect(function()
	if recording and not paused then
		table.insert(track,HRP.Position)
	end
end)

------------------------------------------------
-- PLAY
------------------------------------------------
playBtn.MouseButton1Click:Connect(function()
	local files = listfiles("tracks")
	if #files == 0 then return notify("No track") end
	local data = loadfile(files[#files])()
	playIndex = 1
	playing = true
	if playConn then playConn:Disconnect() end
	playConn = RunService.RenderStepped:Connect(function()
		if not playing then playConn:Disconnect() return end
		local p = data[math.floor(playIndex)]
		if p then
			HRP.CFrame = CFrame.new(p)
			playIndex += speed/6
		else
			playing = false
			notify("Play done")
		end
	end)
end)

------------------------------------------------
-- FLY (MANUAL CONTROL)
------------------------------------------------
flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyBtn.Text = "🛫 Fly : "..(flyEnabled and "ON" or "OFF")
	notify("Fly "..(flyEnabled and "ON" or "OFF"))

	if flyEnabled then
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		flyConn = RunService.RenderStepped:Connect(function()
			local move = Humanoid.MoveDirection
			HRP.Velocity = Vector3.new(move.X*speed,0,move.Z*speed)
		end)
	else
		if flyConn then flyConn:Disconnect() end
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)
