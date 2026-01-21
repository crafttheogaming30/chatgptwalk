-- AUTO WALK TRACK SYSTEM - FULL FINAL (HP SAFE)

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- PLAYER
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local PlayerGui = player:WaitForChild("PlayerGui")

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoWalkGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,270,0,360)
main.Position = UDim2.new(0.05,0,0.2,0)
main.BackgroundColor3 = Color3.fromRGB(18,22,38)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-10,0,36)
title.Position = UDim2.new(0,5,0,5)
title.Text = "AUTO WALK PRO"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- CLOSE
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,6)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(170,60,60)
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- MINIMIZE
local mini = Instance.new("TextButton", main)
mini.Size = UDim2.new(0,30,0,30)
mini.Position = UDim2.new(1,-70,0,6)
mini.Text = "-"
mini.Font = Enum.Font.GothamBold
mini.TextSize = 18
mini.TextColor3 = Color3.new(1,1,1)
mini.BackgroundColor3 = Color3.fromRGB(60,60,120)
Instance.new("UICorner", mini)

local minimized = false
mini.MouseButton1Click:Connect(function()
	minimized = not minimized
	main.Size = minimized and UDim2.new(0,270,0,45) or UDim2.new(0,270,0,360)
end)

-- HOLDER
local holder = Instance.new("Frame", main)
holder.Size = UDim2.new(1,-20,1,-60)
holder.Position = UDim2.new(0,10,0,50)
holder.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", holder)
layout.Padding = UDim.new(0,8)

-- BUTTON MAKER
local function makeBtn(text)
	local b = Instance.new("TextButton", holder)
	b.Size = UDim2.new(1,0,0,36)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(45,65,130)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

-- ================= LOGIC =================
local recording = false
local playing = false
local speed = 1
local track = {}

-- BUTTONS
local recBtn   = makeBtn("▶ Start Record")
local stopBtn  = makeBtn("⏹ Stop Record")
local playBtn  = makeBtn("🚶 Play Track")
local speedUp  = makeBtn("➕ Speed")
local speedDn  = makeBtn("➖ Speed")
local clearBtn = makeBtn("🗑 Clear Track")
local flyBtn   = makeBtn("🕊 Fly OFF")

-- RECORD
recBtn.MouseButton1Click:Connect(function()
	track = {}
	recording = true
end)

stopBtn.MouseButton1Click:Connect(function()
	recording = false
end)

RunService.Heartbeat:Connect(function()
	if recording then
		table.insert(track, root.Position)
	end
end)

-- PLAY
playBtn.MouseButton1Click:Connect(function()
	if #track < 2 then return end
	playing = true
	for _,pos in ipairs(track) do
		if not playing then break end
		root.CFrame = CFrame.new(pos)
		task.wait(0.03 / speed)
	end
	playing = false
end)

-- SPEED
speedUp.MouseButton1Click:Connect(function()
	speed = math.clamp(speed + 0.5, 0.5, 5)
end)

speedDn.MouseButton1Click:Connect(function()
	speed = math.clamp(speed - 0.5, 0.5, 5)
end)

-- CLEAR
clearBtn.MouseButton1Click:Connect(function()
	track = {}
end)

-- ================= FLY =================
local flying = false
local bv, bg

flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	flyBtn.Text = flying and "🕊 Fly ON" or "🕊 Fly OFF"

	if flying then
		bv = Instance.new("BodyVelocity", root)
		bg = Instance.new("BodyGyro", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)

		RunService.RenderStepped:Connect(function()
			if not flying then return end
			bv.Velocity = root.CFrame.LookVector * 50
			bg.CFrame = workspace.CurrentCamera.CFrame
		end)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

print("AUTO WALK FULL FINAL LOADED")
