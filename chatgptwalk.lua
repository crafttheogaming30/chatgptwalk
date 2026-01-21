-- AUTO WALK + FLY PRO HP
-- FINAL REAL BUILD (STABLE + FULL FEATURE)

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

---------------- PLAYER ----------------
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
local walkSpeed = 20

---------------- NOTIFY ----------------
local function notify(txt)
	local g = Instance.new("ScreenGui",player.PlayerGui)
	g.ResetOnSpawn = false
	local f = Instance.new("Frame",g)
	f.Size = UDim2.new(0,260,0,40)
	f.Position = UDim2.new(0.5,-130,0.85,0)
	f.BackgroundColor3 = Color3.fromRGB(30,40,80)
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)

	local t = Instance.new("TextLabel",f)
	t.Size = UDim2.new(1,0,1,0)
	t.BackgroundTransparency = 1
	t.Text = txt
	t.TextColor3 = Color3.new(1,1,1)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 13

	task.delay(2,function()
		g:Destroy()
	end)
end

---------------- PANEL MAKER ----------------
local function createPanel(size,pos,titleText)
	local f = Instance.new("Frame",player.PlayerGui)
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(20,25,45)
	f.BorderSizePixel = 0
	f.Active = true
	f.Draggable = true
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,12)

	local header = Instance.new("Frame",f)
	header.Size = UDim2.new(1,0,0,34)
	header.BackgroundColor3 = Color3.fromRGB(35,45,90)
	Instance.new("UICorner",header).CornerRadius = UDim.new(0,12)

	local title = Instance.new("TextLabel",header)
	title.Size = UDim2.new(1,-80,1,0)
	title.Position = UDim2.new(0,10,0,0)
	title.Text = titleText
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextColor3 = Color3.new(1,1,1)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left

	local close = Instance.new("TextButton",header)
	close.Size = UDim2.new(0,26,0,26)
	close.Position = UDim2.new(1,-30,0,4)
	close.Text = "✕"
	close.Font = Enum.Font.GothamBold
	close.TextColor3 = Color3.new(1,1,1)
	close.BackgroundColor3 = Color3.fromRGB(160,60,60)
	Instance.new("UICorner",close)

	local mini = Instance.new("TextButton",header)
	mini.Size = UDim2.new(0,26,0,26)
	mini.Position = UDim2.new(1,-60,0,4)
	mini.Text = "—"
	mini.Font = Enum.Font.GothamBold
	mini.TextColor3 = Color3.new(1,1,1)
	mini.BackgroundColor3 = Color3.fromRGB(70,90,160)
	Instance.new("UICorner",mini)

	local body = Instance.new("ScrollingFrame",f)
	body.Position = UDim2.new(0,8,0,40)
	body.Size = UDim2.new(1,-16,1,-48)
	body.ScrollBarThickness = 6
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout",body)
	layout.Padding = UDim.new(0,6)

	close.MouseButton1Click:Connect(function()
		f:Destroy()
	end)

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

---------------- MAIN PANEL (PENDEK) ----------------
local main,body = createPanel(
	UDim2.new(0,280,0,240),
	UDim2.new(0.05,0,0.2,0),
	"AUTO WALK PRO"
)

-- 4 FITUR AWAL KELIHATAN
local recBtn   = makeBtn(body,"● Record / Stop (Double)")
local pauseBtn = makeBtn(body,"⏸ Pause Record")
local playBtn  = makeBtn(body,"▶ Play AutoWalk")
local stopBtn  = makeBtn(body,"⏹ Stop Play")

-- FITUR LAIN (SCROLL)
local loopBtn  = makeBtn(body,"🔁 Loop : OFF")
local speedBtn = makeBtn(body,"⚙ Speed AutoWalk")
local histBtn  = makeBtn(body,"📂 History")
local flyBtn   = makeBtn(body,"🕊 Fly")

---------------- RECORD ----------------
local lastRec = 0
recBtn.MouseButton1Click:Connect(function()
	if tick()-lastRec < 0.4 then
		recording = false
		recBtn.Text = "● Record / Stop (Double)"
		local name = "track_"..os.time()..".lua"
		local data = "return {\n"
		for _,p in ipairs(track) do
			data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
		end
		data ..= "}"
		writefile("tracks/"..name,data)
		notify("Track disimpan")
	else
		track = {}
		recording = true
		paused = false
		recBtn.Text = "● Recording..."
		notify("Record ON")
	end
	lastRec = tick()
end)

pauseBtn.MouseButton1Click:Connect(function()
	if recording then
		paused = not paused
		notify(paused and "Record Pause" or "Record Lanjut")
	end
end)

RunService.RenderStepped:Connect(function()
	if recording and not paused then
		table.insert(track,root.Position)
	end
end)

---------------- PLAY ----------------
playBtn.MouseButton1Click:Connect(function()
	if #track < 2 then return notify("Track kosong") end
	playing = true
	playIndex = 1
	notify("Play AutoWalk")
end)

stopBtn.MouseButton1Click:Connect(function()
	playing = false
	notify("Play Stop")
end)

RunService.RenderStepped:Connect(function()
	if playing then
		local p = track[math.floor(playIndex)]
		if p then
			root.CFrame = CFrame.new(p)
			playIndex += walkSpeed/10
		else
			if loopPlay then
				playIndex = 1
			else
				playing = false
				notify("Play selesai")
			end
		end
	end
end)

---------------- LOOP ----------------
local lastLoop = 0
loopBtn.MouseButton1Click:Connect(function()
	if tick()-lastLoop < 0.4 then
		loopPlay = not loopPlay
		loopBtn.Text = "🔁 Loop : "..(loopPlay and "ON" or "OFF")
		notify("Loop "..(loopPlay and "ON" or "OFF"))
	end
	lastLoop = tick()
end)

---------------- SPEED PANEL ----------------
speedBtn.MouseButton1Click:Connect(function()
	local p,b = createPanel(
		UDim2.new(0,240,0,180),
		UDim2.new(0.35,0,0.3,0),
		"SPEED"
	)

	local label = Instance.new("TextLabel",b)
	label.Size = UDim2.new(1,0,0,28)
	label.Text = "Speed : "..walkSpeed
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold

	local plus = makeBtn(b,"+")
	local minus = makeBtn(b,"-")

	plus.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed+2,5,100)
		label.Text = "Speed : "..walkSpeed
	end)
	minus.MouseButton1Click:Connect(function()
		walkSpeed = math.clamp(walkSpeed-2,5,100)
		label.Text = "Speed : "..walkSpeed
	end)
end)

---------------- HISTORY PANEL ----------------
histBtn.MouseButton1Click:Connect(function()
	local p,b = createPanel(
		UDim2.new(0,260,0,260),
		UDim2.new(0.4,0,0.2,0),
		"HISTORY"
	)

	for _,file in ipairs(listfiles("tracks")) do
		local play = makeBtn(b,file:match("([^/]+)$"))
		play.MouseButton1Click:Connect(function()
			track = loadfile(file)()
			notify("Track dipilih")
		end)

		local del = makeBtn(b,"Delete")
		del.BackgroundColor3 = Color3.fromRGB(160,60,60)
		del.MouseButton1Click:Connect(function()
			delfile(file)
			play:Destroy()
			del:Destroy()
			notify("Track dihapus")
		end)
	end
end)

---------------- FLY PANEL ----------------
flyBtn.MouseButton1Click:Connect(function()
	local flying = false
	local flySpeed = 40
	local bv,bg,conn

	local p,b = createPanel(
		UDim2.new(0,240,0,200),
		UDim2.new(0.3,0,0.25,0),
		"FLY"
	)

	local toggle = makeBtn(b,"ON / OFF")
	local plus = makeBtn(b,"Speed +")
	local minus = makeBtn(b,"Speed -")

	toggle.MouseButton1Click:Connect(function()
		flying = not flying
		notify("Fly "..(flying and "ON" or "OFF"))
		if flying then
			bv = Instance.new("BodyVelocity",root)
			bg = Instance.new("BodyGyro",root)
			bv.MaxForce = Vector3.new(1e5,1e5,1e5)
			bg.MaxTorque = Vector3.new(1e5,1e5,1e5)

			conn = RunService.RenderStepped:Connect(function()
				local move = hum.MoveDirection
				bv.Velocity = cam.CFrame.LookVector * move.Magnitude * flySpeed
				bg.CFrame = cam.CFrame
			end)
		else
			if conn then conn:Disconnect() end
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		end
	end)

	plus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed+5,10,200)
	end)
	minus.MouseButton1Click:Connect(function()
		flySpeed = math.clamp(flySpeed-5,10,200)
	end)
end)

print("AUTO WALK + FLY PRO FINAL LOADED")
