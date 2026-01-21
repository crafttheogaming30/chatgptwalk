--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v7
 FIXED UI HP + FLY MODE
 Author : ChatGPT + Teyoo
]]--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- FILE SYSTEM
if not isfolder("tracks") then makefolder("tracks") end

-- STATE
local recording, playing, paused, loopTrack = false,false,false,false
local speed = 20
local recordData = {}
local playConn, recordConn
local fly = false
local bv, bg

-- THEME
local THEME = {
	bg = Color3.fromRGB(14,22,35),
	panel = Color3.fromRGB(20,32,52),
	header = Color3.fromRGB(24,40,70),
	accent = Color3.fromRGB(80,140,255),
	text = Color3.fromRGB(230,235,255)
}

-- TOAST
local function toast(t)
	local g = Instance.new("ScreenGui",game.CoreGui)
	local f = Instance.new("Frame",g)
	f.Size = UDim2.fromScale(0.35,0.07)
	f.Position = UDim2.fromScale(0.325,0.85)
	f.BackgroundColor3 = THEME.panel
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,14)
	local l = Instance.new("TextLabel",f)
	l.Size = UDim2.fromScale(1,1)
	l.BackgroundTransparency = 1
	l.Text = t
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 14
	l.TextColor3 = THEME.text
	task.delay(2,function() g:Destroy() end)
end

-- PANEL
local gui = Instance.new("ScreenGui",game.CoreGui)
local panel = Instance.new("Frame",gui)
panel.Size = UDim2.fromOffset(300,420)
panel.Position = UDim2.fromScale(0.05,0.2)
panel.BackgroundColor3 = THEME.panel
panel.Active = true
panel.Draggable = true
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,16)

local header = Instance.new("Frame",panel)
header.Size = UDim2.new(1,0,0,32)
header.BackgroundColor3 = THEME.header
Instance.new("UICorner",header).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel",header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.fromOffset(10,0)
title.Text = "Auto Walk Track Pro HP"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = THEME.text
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local close = Instance.new("TextButton",header)
close.Size = UDim2.fromOffset(30,32)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextColor3 = THEME.text
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- BODY
local body = Instance.new("ScrollingFrame",panel)
body.Size = UDim2.new(1,-10,1,-40)
body.Position = UDim2.fromOffset(5,35)
body.CanvasSize = UDim2.new()
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.ScrollBarThickness = 6
body.BackgroundTransparency = 1
body.Visible = true

local layout = Instance.new("UIListLayout",body)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Center

-- HELPER
local function btn(txt)
	local b = Instance.new("TextButton",body)
	b.Size = UDim2.fromOffset(260,34)
	b.Text = txt
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	b.TextColor3 = THEME.text
	b.BackgroundColor3 = THEME.header
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
	return b
end

-- INPUT
local nameBox = Instance.new("TextBox",body)
nameBox.Size = UDim2.fromOffset(260,30)
nameBox.PlaceholderText = "Nama Track"
nameBox.Text = ""
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner",nameBox).CornerRadius = UDim.new(0,10)

-- SPEED
local sp = btn("Speed : "..speed)

sp.MouseButton1Click:Connect(function()
	speed = speed + 5
	if speed > 50 then speed = 5 end
	sp.Text = "Speed : "..speed
end)

-- BUTTONS
local rec = btn("● Record")
local pause = btn("⏸ Pause")
local play = btn("▶ Play")
local stop = btn("⏹ Stop")
local loop = btn("🔁 Loop : OFF")
local flyBtn = btn("🕊 Fly : OFF")

-- RECORD
rec.MouseButton1Click:Connect(function()
	if recording then
		recording = false
		recordConn:Disconnect()
		local data = "return {\n"
		for _,p in ipairs(recordData) do
			data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
		end
		data ..= "}"
		local name = (nameBox.Text ~= "" and nameBox.Text or "Track")..".lua"
		writefile("tracks/"..name,data)
		recordData = {}
		toast("Record disimpan")
	else
		recording = true
		recordData = {}
		recordConn = RunService.RenderStepped:Connect(function()
			if recording and not paused then
				table.insert(recordData,hrp.Position)
			end
		end)
		toast("Record ON")
	end
end)

pause.MouseButton1Click:Connect(function()
	paused = not paused
	toast(paused and "Pause" or "Lanjut")
end)

-- PLAY
play.MouseButton1Click:Connect(function()
	local f = "tracks/"..nameBox.Text..".lua"
	if not pcall(function() readfile(f) end) then return toast("Track ga ada") end
	local data = loadfile(f)()
	local i = 1
	playing = true
	playConn = RunService.RenderStepped:Connect(function()
		if not playing then playConn:Disconnect() end
		local p = data[math.floor(i)]
		if p then
			hrp.CFrame = CFrame.new(p)
			i += speed/5
		else
			if loopTrack then i = 1 else playing=false toast("Selesai") end
		end
	end)
end)

stop.MouseButton1Click:Connect(function()
	playing = false
end)

loop.MouseButton1Click:Connect(function()
	loopTrack = not loopTrack
	loop.Text = "🔁 Loop : "..(loopTrack and "ON" or "OFF")
end)

-- FLY
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = "🕊 Fly : "..(fly and "ON" or "OFF")
	if fly then
		bv = Instance.new("BodyVelocity",hrp)
		bg = Instance.new("BodyGyro",hrp)
		bv.MaxForce = Vector3.new(9e9,9e9,9e9)
		bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
		RunService.RenderStepped:Connect(function()
			if fly then
				bv.Velocity = hrp.CFrame.LookVector * 60
				bg.CFrame = workspace.CurrentCamera.CFrame
			end
		end)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

toast("Auto Walk Pro HP READY")
