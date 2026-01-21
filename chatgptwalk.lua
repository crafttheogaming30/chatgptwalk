-- AUTO WALK + FLY PRO HP
-- UI SAFE VERSION (DELTA FIX)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")

if not isfolder("tracks") then makefolder("tracks") end

local recording = false
local paused = false
local playing = false
local flyEnabled = false
local speed = 25
local track = {}
local playIndex = 1
local recordConn, playConn, flyConn

local THEME = {
	panel = Color3.fromRGB(20,35,60),
	header = Color3.fromRGB(30,55,90),
	text = Color3.fromRGB(235,240,255)
}

------------------------------------------------
-- NOTIFY
------------------------------------------------
local function notify(txt)
	pcall(function()
		game.StarterGui:SetCore("SendNotification",{
			Title="AutoWalk",
			Text=txt,
			Duration=2
		})
	end)
end

------------------------------------------------
-- UI
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

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
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.fromOffset(10,0)
title.Text = "AUTO WALK PRO"
title.TextColor3 = THEME.text
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.fromOffset(28,28)
close.Position = UDim2.fromOffset(245,2)
close.Text = "✕"
close.TextColor3 = THEME.text
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

------------------------------------------------
-- BUTTON MAKER (MANUAL POS)
------------------------------------------------
local function button(txt,y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.fromOffset(240,32)
	b.Position = UDim2.fromOffset(20,y)
	b.Text = txt
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	b.TextColor3 = THEME.text
	b.BackgroundColor3 = THEME.header
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

------------------------------------------------
-- BUTTONS (FIXED Y)
------------------------------------------------
local y = 50
local recordBtn = button("● Record",y); y+=36
local stopBtn = button("⏹ Stop Record",y); y+=36
local playBtn = button("▶ Play Track",y); y+=36
local historyBtn = button("📂 History",y); y+=36
local flyBtn = button("🛫 Fly : OFF",y)

------------------------------------------------
-- RECORD
------------------------------------------------
recordBtn.MouseButton1Click:Connect(function()
	if not recording then
		recording = true
		paused = false
		track = {}
		recordBtn.Text = "⏸ Pause"
		notify("Record start")
	else
		paused = not paused
		recordBtn.Text = paused and "▶ Resume" or "⏸ Pause"
	end
end)

stopBtn.MouseButton1Click:Connect(function()
	if recording then
		recording = false
		recordBtn.Text = "● Record"
		local name = "track_"..os.time()..".lua"
		local data = "return {\n"
		for _,p in ipairs(track) do
			data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
		end
		data ..= "}"
		writefile("tracks/"..name,data)
		notify("Saved")
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
		local p = data[math.floor(playIndex)]
		if p then
			HRP.CFrame = CFrame.new(p)
			playIndex += speed/6
		else
			playing = false
			notify("Done")
			playConn:Disconnect()
		end
	end)
end)

------------------------------------------------
-- FLY (MANUAL)
------------------------------------------------
flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyBtn.Text = "🛫 Fly : "..(flyEnabled and "ON" or "OFF")

	if flyEnabled then
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		flyConn = RunService.RenderStepped:Connect(function()
			local m = Humanoid.MoveDirection
			HRP.Velocity = Vector3.new(m.X*speed,0,m.Z*speed)
		end)
	else
		if flyConn then flyConn:Disconnect() end
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)
