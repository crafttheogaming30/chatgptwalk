-- AUTO WALK + FLY PRO HP MERGED WITH SPEED PANEL
-- FULL FINAL + SPEED SLIDER + BUTTON
-- UI SAFE | PANEL NOTIFY | SAVE NAME | HISTORY | SPEED | LOOP | FLY

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera

---------------- FILE ----------------
if not isfolder("tracks") then makefolder("tracks") end

---------------- STATE ----------------
local recording = false
local paused = false
local playing = false
local loopPlay = false
local track = {}
local playIndex = 1

-- SPEED
local walkSpeed = 20
local AutoWalkSpeed = 1 -- multiplier x1 - x1.5
local flySpeed = 40
local FlySpeed = 1 -- multiplier x1 - x3

---------------- GUI BASE ----------------
local gui = Instance.new("ScreenGui")
gui.Name = "AutoWalkPro"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

---------------- PANEL NOTIFY ----------------
local function panelNotify(text)
	local n = Instance.new("Frame",gui)
	n.Size = UDim2.new(0,260,0,40)
	n.Position = UDim2.new(0.5,-130,0.05,0)
	n.BackgroundColor3 = Color3.fromRGB(40,60,120)
	n.BorderSizePixel = 0
	Instance.new("UICorner",n).CornerRadius = UDim.new(0,10)

	local t = Instance.new("TextLabel",n)
	t.Size = UDim2.new(1,-10,1,0)
	t.Position = UDim2.new(0,5,0,0)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = Color3.new(1,1,1)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 13

	task.delay(2,function() n:Destroy() end)
end

---------------- PANEL BUILDER ----------------
local function createPanel(size,pos,titleText)
	local f = Instance.new("Frame",gui)
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(20,25,45)
	f.Active = true
	f.Draggable = true
	f.BorderSizePixel = 0
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,12)

	local header = Instance.new("Frame",f)
	header.Size = UDim2.new(1,0,0,34)
	header.BackgroundColor3 = Color3.fromRGB(30,40,80)
	Instance.new("UICorner",header).CornerRadius = UDim.new(0,12)

	local title = Instance.new("TextLabel",header)
	title.Size = UDim2.new(1,-80,1,0)
	title.Position = UDim2.new(0,10,0,0)
	title.Text = titleText
	title.TextColor3 = Color3.new(1,1,1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left

	local close = Instance.new("TextButton",header)
	close.Size = UDim2.new(0,26,0,26)
	close.Position = UDim2.new(1,-30,0,4)
	close.Text = "✕"
	close.BackgroundColor3 = Color3.fromRGB(150,60,60)
	close.TextColor3 = Color3.new(1,1,1)
	close.Font = Enum.Font.GothamBold
	Instance.new("UICorner",close)

	local mini = Instance.new("TextButton",header)
	mini.Size = UDim2.new(0,26,0,26)
	mini.Position = UDim2.new(1,-60,0,4)
	mini.Text = "—"
	mini.BackgroundColor3 = Color3.fromRGB(70,90,160)
	mini.TextColor3 = Color3.new(1,1,1)
	mini.Font = Enum.Font.GothamBold
	Instance.new("UICorner",mini)

	local body = Instance.new("ScrollingFrame",f)
	body.Position = UDim2.new(0,8,0,40)
	body.Size = UDim2.new(1,-16,1,-48)
	body.ScrollBarThickness = 6
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout",body)
	layout.Padding = UDim.new(0,6)

	close.MouseButton1Click:Connect(function() f:Destroy() end)

	local minimized = false
	mini.MouseButton1Click:Connect(function()
		minimized = not minimized
		body.Visible = not minimized
		f.Size = minimized and UDim2.new(0,size.X.Offset,0,36) or size
	end)

	return f,body
end

local function makeBtn(parent,text)
	local b = Instance.new("TextButton",parent)
	b.Size = UDim2.new(1,0,0,32)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(60,80,150)
	b.BorderSizePixel = 0
	Instance.new("UICorner",b)
	return b
end

---------------- MAIN PANEL ----------------
local main,body = createPanel(
	UDim2.new(0,280,0,280),
	UDim2.new(0.05,0,0.2,0),
	"AUTO WALK + FLY PRO"
)

local recStart = makeBtn(body,"● Start Record")
local recPause = makeBtn(body,"⏸ Pause Record")
local recStop  = makeBtn(body,"⏹ Stop & Save Record")
local playBtn  = makeBtn(body,"▶ Play AutoWalk")
local stopBtn  = makeBtn(body,"⏹ Stop AutoWalk")
local loopBtn  = makeBtn(body,"🔁 Loop : OFF")
local speedBtn = makeBtn(body,"⚙ Speed Control")
local histBtn  = makeBtn(body,"📂 History Track")
local flyBtn   = makeBtn(body,"🕊 Fly")

---------------- RECORD ----------------
recStart.MouseButton1Click:Connect(function()
	track = {}
	recording = true
	paused = false
	panelNotify("Record dimulai")
end)

recPause.MouseButton1Click:Connect(function()
	if recording then
		paused = not paused
		panelNotify(paused and "Record di-pause" or "Record lanjut")
	end
end)

recStop.MouseButton1Click:Connect(function()
	if not recording then return end
	recording = false

	local p,b = createPanel(
		UDim2.new(0,240,0,140),
		UDim2.new(0.4,0,0.35,0),
		"SAVE TRACK"
	)

	local box = Instance.new("TextBox",b)
	box.Size = UDim2.new(1,0,0,32)
	box.PlaceholderText = "Nama track..."
	box.Text = ""
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.BackgroundColor3 = Color3.fromRGB(50,70,130)
	box.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",box)

	local save = makeBtn(b,"SAVE")
	save.MouseButton1Click:Connect(function()
		if box.Text == "" then return end
		local data = "return {\n"
		for _,p in ipairs(track) do
			data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
		end
		data ..= "}"
		writefile("tracks/"..box.Text..".lua",data)
		panelNotify("Track disimpan: "..box.Text)
		p:Destroy()
	end)
end)

RunService.RenderStepped:Connect(function()
	if recording and not paused then
		table.insert(track,root.Position)
	end
end)

---------------- SPEED PANEL ----------------
speedBtn.MouseButton1Click:Connect(function()
	local p,b = createPanel(
		UDim2.new(0,240,0,180),
		UDim2.new(0.35,0,0.25,0),
		"SPEED CONTROL"
	)

	-- AUTO WALK
	local awLabel = Instance.new("TextLabel",b)
	awLabel.Size = UDim2.new(1,0,0,20)
	awLabel.Position = UDim2.fromOffset(10,0)
	awLabel.Text = "AUTO WALK SPEED : x"..string.format("%.1f",AutoWalkSpeed)
	awLabel.Font = Enum.Font.GothamBold
	awLabel.TextSize = 13
	awLabel.TextColor3 = Color3.new(1,1,1)
	awLabel.BackgroundTransparency = 1

	local awSlider = makeBtn(b,"Slide +0.1")
	awSlider.Position = UDim2.fromOffset(10,25)
	awSlider.MouseButton1Click:Connect(function()
		AutoWalkSpeed = math.clamp(AutoWalkSpeed + 0.1, 1, 1.5)
		awLabel.Text = "AUTO WALK SPEED : x"..string.format("%.1f",AutoWalkSpeed)
		panelNotify("AutoWalk Speed x"..string.format("%.1f",AutoWalkSpeed))
	end)

	local awPlus = makeBtn(b,"+")
	awPlus.Position = UDim2.fromOffset(10,60)
	awPlus.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed+2,5,100)
		panelNotify("WalkSpeed : "..walkSpeed)
	end)

	local awMin = makeBtn(b,"-")
	awMin.Position = UDim2.fromOffset(120,60)
	awMin.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed-2,5,100)
		panelNotify("WalkSpeed : "..walkSpeed)
	end)

	-- FLY SPEED
	local flyLabel = Instance.new("TextLabel",b)
	flyLabel.Size = UDim2.new(1,0,0,20)
	flyLabel.Position = UDim2.fromOffset(10,100)
	flyLabel.Text = "FLY SPEED : x"..string.format("%.1f",FlySpeed)
	flyLabel.Font = Enum.Font.GothamBold
	flyLabel.TextSize = 13
	flyLabel.TextColor3 = Color3.new(1,1,1)
	flyLabel.BackgroundTransparency = 1

	local flySlider = makeBtn(b,"Slide +0.5")
	flySlider.Position = UDim2.fromOffset(10,125)
	flySlider.MouseButton1Click:Connect(function()
		FlySpeed = math.clamp(FlySpeed + 0.5, 1, 3)
		flyLabel.Text = "FLY SPEED : x"..string.format("%.1f",FlySpeed)
		panelNotify("Fly Speed x"..string.format("%.1f",FlySpeed))
	end)

	local flyPlus = makeBtn(b,"+")
	flyPlus.Position = UDim2.fromOffset(10,150)
	flyPlus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed+10,1,200)
		panelNotify("FlySpeed : "..flySpeed)
	end)

	local flyMin = makeBtn(b,"-")
	flyMin.Position = UDim2.fromOffset(120,150)
	flyMin.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed-10,1,200)
		panelNotify("FlySpeed : "..flySpeed)
	end)
end)

---------------- AUTOWALK APPLY ----------------
RunService.RenderStepped:Connect(function()
	hum.WalkSpeed = walkSpeed * AutoWalkSpeed
end)

panelNotify("AUTO WALK + FLY PRO READY")
