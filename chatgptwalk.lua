-- AUTO WALK TRACK RECORDER
-- Theme: Dark Blue | Smooth Movement
-- By: ChatGPT (custom for you)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ===================== DATA =====================
local Recording = false
local Paused = false
local CurrentTrack = {}
local SavedTracks = {}
local LoopPlay = false
local Speed = 50

-- ===================== NOTIF =====================
local function notify(txt)
	game.StarterGui:SetCore("SendNotification", {
		Title = "AutoWalk",
		Text = txt,
		Duration = 2
	})
end

-- ===================== UI BASE =====================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoWalkUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(420, 320)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Name = "Main"

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- ===================== HEADER =====================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(15, 30, 70)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "AutoWalk Recorder"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local minimize = Instance.new("TextButton", header)
minimize.Text = "—"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.Size = UDim2.fromOffset(30, 30)
minimize.Position = UDim2.new(1, -70, 0, 5)
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.fromRGB(200,200,255)

local close = Instance.new("TextButton", header)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundTransparency = 1
close.TextColor3 = Color3.fromRGB(255,120,120)

-- ===================== CONTENT =====================
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0, 0, 0, 45)
content.Size = UDim2.new(1, 0, 1, -50)
content.BackgroundTransparency = 1

local function button(txt, y)
	local b = Instance.new("TextButton", content)
	b.Size = UDim2.new(1, -30, 0, 36)
	b.Position = UDim2.new(0, 15, 0, y)
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(220,230,255)
	b.BackgroundColor3 = Color3.fromRGB(20,40,90)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	return b
end

local recordBtn = button("● Record Track", 0)
local pauseBtn = button("⏸ Pause", 45)
local stopBtn = button("■ Stop & Save", 90)
local historyBtn = button("📁 Track History", 135)

-- ===================== SPEED SLIDER =====================
local sliderBg = Instance.new("Frame", content)
sliderBg.Size = UDim2.new(1, -30, 0, 20)
sliderBg.Position = UDim2.new(0, 15, 0, 185)
sliderBg.BackgroundColor3 = Color3.fromRGB(30,50,100)
sliderBg.BorderSizePixel = 0
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)

local slider = Instance.new("Frame", sliderBg)
slider.Size = UDim2.new(0.5,0,1,0)
slider.BackgroundColor3 = Color3.fromRGB(80,140,255)
Instance.new("UICorner", slider).CornerRadius = UDim.new(1,0)

local speedTxt = Instance.new("TextLabel", content)
speedTxt.Position = UDim2.new(0,15,0,210)
speedTxt.Size = UDim2.new(1,-30,0,20)
speedTxt.Text = "Speed: 50"
speedTxt.Font = Enum.Font.Gotham
speedTxt.TextSize = 13
speedTxt.TextColor3 = Color3.fromRGB(200,220,255)
speedTxt.BackgroundTransparency = 1

-- ===================== LOGIC =====================
recordBtn.MouseButton1Click:Connect(function()
	Recording = true
	Paused = false
	CurrentTrack = {}
	notify("Recording started")
end)

pauseBtn.MouseButton1Click:Connect(function()
	Paused = not Paused
	notify(Paused and "Recording paused" or "Recording resumed")
end)

stopBtn.MouseButton1Click:Connect(function()
	Recording = false
	local name = "Track"..tostring(#SavedTracks+1)
	SavedTracks[name] = CurrentTrack
	notify("Saved as "..name)
end)

task.spawn(function()
	while true do
		if Recording and not Paused then
			table.insert(CurrentTrack, hrp.CFrame)
		end
		task.wait(0.15)
	end
end)

local function playTrack(track)
	repeat
		for _,cf in ipairs(track) do
			local t = TweenService:Create(
				hrp,
				TweenInfo.new((101-Speed)/60, Enum.EasingStyle.Linear),
				{CFrame = cf}
			)
			t:Play()
			t.Completed:Wait()
		end
	until not LoopPlay
end

historyBtn.MouseButton1Click:Connect(function()
	for name,track in pairs(SavedTracks) do
		notify("Playing "..name)
		playTrack(track)
	end
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

minimize.MouseButton1Click:Connect(function()
	content.Visible = not content.Visible
end)

-- SPEED SLIDER
local dragging = false
sliderBg.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local x = math.clamp((i.Position.X - sliderBg.AbsolutePosition.X)/sliderBg.AbsoluteSize.X,0,1)
		slider.Size = UDim2.new(x,0,1,0)
		Speed = math.floor(x*100)
		speedTxt.Text = "Speed: "..Speed
	end
end)
