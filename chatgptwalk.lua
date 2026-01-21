-- AUTO WALK TRACK SYSTEM - FINAL FIX v7 (HP FRIENDLY)

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

-- MAIN PANEL
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,280,0,260) -- pendek
main.Position = UDim2.new(0.05,0,0.2,0)
main.BackgroundColor3 = Color3.fromRGB(18,22,38)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- HEADER
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(25,30,55)
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Text = "AUTO WALK PRO"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE
local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(170,60,60)
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- MINIMIZE (BENERAN HILANG SEMUA)
local minimized = false
local mini = Instance.new("TextButton", header)
mini.Size = UDim2.new(0,30,0,30)
mini.Position = UDim2.new(1,-70,0,5)
mini.Text = "—"
mini.Font = Enum.Font.GothamBold
mini.TextSize = 18
mini.TextColor3 = Color3.new(1,1,1)
mini.BackgroundColor3 = Color3.fromRGB(70,90,160)
Instance.new("UICorner", mini)

-- ICON MODE
local iconBtn
mini.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		main.Visible = false
		iconBtn = Instance.new("TextButton", gui)
		iconBtn.Size = UDim2.new(0,120,0,32)
		iconBtn.Position = UDim2.new(0.05,0,0.2,0)
		iconBtn.Text = "AutoWalk"
		iconBtn.Font = Enum.Font.GothamBold
		iconBtn.TextSize = 13
		iconBtn.TextColor3 = Color3.new(1,1,1)
		iconBtn.BackgroundColor3 = Color3.fromRGB(25,30,55)
		iconBtn.Active = true
		iconBtn.Draggable = true
		Instance.new("UICorner", iconBtn)

		iconBtn.MouseButton1Click:Connect(function()
			main.Visible = true
			iconBtn:Destroy()
			minimized = false
		end)
	end
end)

-- ================= SCROLL BODY =================
local body = Instance.new("ScrollingFrame", main)
body.Size = UDim2.new(1,-20,1,-60)
body.Position = UDim2.new(0,10,0,50)
body.CanvasSize = UDim2.new(0,0,0,0)
body.ScrollBarThickness = 6
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", body)
layout.Padding = UDim.new(0,8)

-- BUTTON MAKER
local function makeBtn(text)
	local b = Instance.new("TextButton", body)
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
local track = {}

-- ================= BUTTONS =================
local recBtn   = makeBtn("● Record Track")
local stopBtn  = makeBtn("⏹ Stop Record")
local playBtn  = makeBtn("▶ Play Track")
local clearBtn = makeBtn("🗑 Clear Track")
local flyBtn   = makeBtn("🕊 Fly OFF")
local flySet   = makeBtn("⚙ Fly Speed")

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
		task.wait(0.03)
	end
	playing = false
end)

clearBtn.MouseButton1Click:Connect(function()
	track = {}
end)

-- ================= FLY =================
local flying = false
local flySpeed = 50
local bv, bg, flyConn

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
flySet.MouseButton1Click:Connect(function()
	local fg = Instance.new("Frame", gui)
	fg.Size = UDim2.new(0,200,0,120)
	fg.Position = UDim2.new(0.4,0,0.35,0)
	fg.BackgroundColor3 = Color3.fromRGB(25,30,55)
	fg.Active = true
	fg.Draggable = true
	Instance.new("UICorner", fg)

	local t = Instance.new("TextLabel", fg)
	t.Size = UDim2.new(1,0,0,30)
	t.Text = "Fly Speed"
	t.Font = Enum.Font.GothamBold
	t.TextSize = 13
	t.TextColor3 = Color3.new(1,1,1)
	t.BackgroundTransparency = 1

	local plus = Instance.new("TextButton", fg)
	plus.Size = UDim2.new(0.4,0,0,36)
	plus.Position = UDim2.new(0.05,0,0.5,0)
	plus.Text = "+"
	plus.Font = Enum.Font.GothamBold
	plus.TextSize = 18
	plus.BackgroundColor3 = Color3.fromRGB(60,100,200)
	Instance.new("UICorner", plus)

	local minus = Instance.new("TextButton", fg)
	minus.Size = UDim2.new(0.4,0,0,36)
	minus.Position = UDim2.new(0.55,0,0.5,0)
	minus.Text = "-"
	minus.Font = Enum.Font.GothamBold
	minus.TextSize = 18
	minus.BackgroundColor3 = Color3.fromRGB(60,100,200)
	Instance.new("UICorner", minus)

	plus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed + 10,10,200)
	end)
	minus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed - 10,10,200)
	end)
end)

print("AUTO WALK PRO v7 FIXED LOADED")
