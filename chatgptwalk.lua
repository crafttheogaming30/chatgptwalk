-- AUTO WALK + FLY PRO HP - FULL SLIDER + BUTTON
-- UI SAFE | PANEL NOTIFY | SAVE | HISTORY | LOOP | SPEED SLIDER + BUTTON

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera

-- FILE
if not isfolder("tracks") then makefolder("tracks") end

-- STATE
local recording = false
local paused = false
local playing = false
local loopPlay = false
local flying = false

local track = {}
local playIndex = 1

local walkSpeed = 20
local flySpeed = 40
local AutoWalkMultiplier = 1
local FlyMultiplier = 1

local bv, bg, bvf, bgf, conn, flyConn

-- GUI BASE
local gui = Instance.new("ScreenGui")
gui.Name = "AutoWalkPro"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- PANEL NOTIFY
local function panelNotify(text)
    local n = Instance.new("Frame", gui)
    n.Size = UDim2.new(0, 260, 0, 40)
    n.Position = UDim2.new(0.5, -130, 0.05, 0)
    n.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    n.BorderSizePixel = 0
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 10)

    local t = Instance.new("TextLabel", n)
    t.Size = UDim2.new(1, -10, 1, 0)
    t.Position = UDim2.new(0, 5, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13

    task.delay(2, function() n:Destroy() end)
end

-- PANEL BUILDER
local function createPanel(size, pos, titleText)
    local f = Instance.new("Frame", gui)
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    f.Active = true
    f.Draggable = true
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

    local header = Instance.new("Frame", f)
    header.Size = UDim2.new(1, 0, 0, 34)
    header.BackgroundColor3 = Color3.fromRGB(30, 40, 80)
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = titleText
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left

    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0, 26, 0, 26)
    close.Position = UDim2.new(1, -30, 0, 4)
    close.Text = "✕"
    close.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    Instance.new("UICorner", close)

    local mini = Instance.new("TextButton", header)
    mini.Size = UDim2.new(0, 26, 0, 26)
    mini.Position = UDim2.new(1, -60, 0, 4)
    mini.Text = "—"
    mini.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
    mini.TextColor3 = Color3.new(1, 1, 1)
    mini.Font = Enum.Font.GothamBold
    Instance.new("UICorner", mini)

    local body = Instance.new("ScrollingFrame", f)
    body.Position = UDim2.new(0, 8, 0, 40)
    body.Size = UDim2.new(1, -16, 1, -48)
    body.ScrollBarThickness = 6
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", body)
    layout.Padding = UDim.new(0, 6)

    close.MouseButton1Click:Connect(function() f:Destroy() end)

    local minimized = false
    mini.MouseButton1Click:Connect(function()
        minimized = not minimized
        body.Visible = not minimized
        f.Size = minimized and UDim2.new(0, size.X.Offset, 0, 36) or size
    end)

    return f, body
end

local function makeBtn(parent, text)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(60, 80, 150)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b)
    return b
end

-- MAIN PANEL
local main, body = createPanel(UDim2.new(0, 300, 0, 380), UDim2.new(0.05, 0, 0.2, 0), "AUTO WALK + FLY PRO")

-- RECORD BUTTONS
local recStart = makeBtn(body, "● Start Record")
local recPause = makeBtn(body, "⏸ Pause Record")
local recStop  = makeBtn(body, "⏹ Stop & Save Record")

-- PLAY / STOP / LOOP
local playBtn = makeBtn(body, "▶ Play AutoWalk")
local stopBtn = makeBtn(body, "⏹ Stop AutoWalk")
local loopBtn = makeBtn(body, "🔁 Loop : OFF")

-- SPEED & HISTORY & FLY
local speedBtn = makeBtn(body, "⚙ Speed Control")
local histBtn  = makeBtn(body, "📂 History Track")
local flyBtn   = makeBtn(body, "🕊 Fly")

-- RECORD LOGIC
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

    local p,b = createPanel(UDim2.new(0, 240, 0, 140), UDim2.new(0.4,0,0.35,0), "SAVE TRACK")
    local box = Instance.new("TextBox", b)
    box.Size = UDim2.new(1,0,0,32)
    box.PlaceholderText = "Nama track..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.BackgroundColor3 = Color3.fromRGB(50,70,130)
    box.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", box)

    local save = makeBtn(b,"SAVE")
    save.MouseButton1Click:Connect(function()
        if box.Text == "" then return end
        local data = "return {\n"
        for _,p in ipairs(track) do
            data ..= string.format("Vector3.new(%f,%f,%f),\n", p.X,p.Y,p.Z)
        end
        data ..= "}"
        writefile("tracks/"..box.Text..".lua", data)
        panelNotify("Track disimpan: "..box.Text)
        p:Destroy()
    end)
end)

RunService.RenderStepped:Connect(function()
    if recording and not paused then
        table.insert(track, root.Position)
    end
end)

-- AUTOWALK LOGIC
playBtn.MouseButton1Click:Connect(function()
    if #track < 2 then return end
    playing = true
    playIndex = 1

    bv = Instance.new("BodyVelocity", root)
    bg = Instance.new("BodyGyro", root)
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)

    panelNotify("AutoWalk jalan")

    conn = RunService.RenderStepped:Connect(function()
        if not playing then return end
        local target = track[math.floor(playIndex)]
        if target then
            local dir = (target - root.Position)
            bv.Velocity = dir.Unit * (walkSpeed * AutoWalkMultiplier)
            bg.CFrame = CFrame.new(root.Position, root.Position + dir)
            playIndex += walkSpeed/10
        else
            if loopPlay then
                playIndex = 1
            else
                playing = false
                bv:Destroy()
                bg:Destroy()
                conn:Disconnect()
                panelNotify("AutoWalk selesai")
            end
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    playing = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    panelNotify("AutoWalk stop")
end)

-- LOOP
loopBtn.MouseButton1Click:Connect(function()
    loopPlay = not loopPlay
    loopBtn.Text = "🔁 Loop : "..(loopPlay and "ON" or "OFF")
    panelNotify("Loop "..(loopPlay and "ON" or "OFF"))
end)

-- SPEED CONTROL PANEL
speedBtn.MouseButton1Click:Connect(function()
    local p,b = createPanel(UDim2.new(0, 280, 0, 260), UDim2.new(0.35,0,0.25,0), "SPEED CONTROL")

    -- AUTO WALK SPEED
    local awLabel = Instance.new("TextLabel", b)
    awLabel.Text = "AutoWalk Speed"
    awLabel.Font = Enum.Font.GothamBold
    awLabel.TextSize = 14
    awLabel.TextColor3 = Color3.new(1,1,1)
    awLabel.BackgroundTransparency = 1
    awLabel.Position = UDim2.fromOffset(10, 10)
    awLabel.Size = UDim2.new(1,-20,0,20)

    local awSlider = Instance.new("Frame", b)
    awSlider.Size = UDim2.new(1,-20,0,20)
    awSlider.Position = UDim2.fromOffset(10,35)
    awSlider.BackgroundColor3 = Color3.fromRGB(40,55,85)
    Instance.new("UICorner", awSlider)

    local handle = Instance.new("Frame", awSlider)
    handle.Size = UDim2.new(0,20,1,0)
    handle.Position = UDim2.new(0,0,0,0)
    handle.BackgroundColor3 = Color3.fromRGB(200,200,255)
    Instance.new("UICorner", handle)

    local dragging = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UIS:GetMouseLocation().X
            local sliderPos = math.clamp(mousePos - awSlider.AbsolutePosition.X, 0, awSlider.AbsoluteSize.X)
            handle.Position = UDim2.new(sliderPos/awSlider.AbsoluteSize.X,0,0,0)
            AutoWalkMultiplier = 1 + (sliderPos/awSlider.AbsoluteSize.X)
            panelNotify("AutoWalk x"..string.format("%.2f", AutoWalkMultiplier))
        end
    end)

    local awPlus = makeBtn(b,"+")
    awPlus.Position = UDim2.fromOffset(10,70)
    local awMin = makeBtn(b,"-")
    awMin.Position = UDim2.fromOffset(140,70)
    awPlus.MouseButton1Click:Connect(function()
        AutoWalkMultiplier = math.min(AutoWalkMultiplier+0.2,5)
        panelNotify("AutoWalk x"..string.format("%.2f", AutoWalkMultiplier))
    end)
    awMin.MouseButton1Click:Connect(function()
        AutoWalkMultiplier = math.max(AutoWalkMultiplier-0.2,1)
        panelNotify("AutoWalk x"..string.format("%.2f", AutoWalkMultiplier))
    end)

    -- FLY SPEED (Slider + Button)
    local flyLabel = awLabel:Clone()
    flyLabel.Parent = b
    flyLabel.Text = "Fly Speed"
    flyLabel.Position = UDim2.fromOffset(10,110)

    local flySlider = awSlider:Clone()
    flySlider.Parent = b
    flySlider.Position = UDim2.fromOffset(10,135)
    local flyHandle = flySlider:FindFirstChildWhichIsA("Frame")
    local flyDragging = false
    flyHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then flyDragging = true end
    end)
    flyHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then flyDragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if flyDragging then
            local mousePos = UIS:GetMouseLocation().X
            local sliderPos = math.clamp(mousePos - flySlider.AbsolutePosition.X, 0, flySlider.AbsoluteSize.X)
            flyHandle.Position = UDim2.new(sliderPos/flySlider.AbsoluteSize.X,0,0,0)
            FlyMultiplier = 1 + 2*(sliderPos/flySlider.AbsoluteSize.X)
            panelNotify("Fly x"..string.format("%.2f", FlyMultiplier))
        end
    end)

    local flyPlus = awPlus:Clone()
    flyPlus.Parent = b
    flyPlus.Position = UDim2.fromOffset(10,170)
    local flyMin = awMin:Clone()
    flyMin.Parent = b
    flyMin.Position = UDim2.fromOffset(140,170)
    flyPlus.MouseButton1Click:Connect(function()
        FlyMultiplier = math.min(FlyMultiplier+0.5,10)
        panelNotify("Fly x"..string.format("%.2f", FlyMultiplier))
    end)
    flyMin.MouseButton1Click:Connect(function()
        FlyMultiplier = math.max(FlyMultiplier-0.5,1)
        panelNotify("Fly x"..string.format("%.2f", FlyMultiplier))
    end)
end)

-- HISTORY PANEL
histBtn.MouseButton1Click:Connect(function()
    local p,b = createPanel(UDim2.new(0,260,0,260), UDim2.new(0.4,0,0.25,0), "HISTORY")
    for _,file in ipairs(listfiles("tracks")) do
        local play = makeBtn(b, file:match("([^/]+)$"))
        play.MouseButton1Click:Connect(function()
            track = loadfile(file)()
            panelNotify("Track loaded")
        end)
        local del = makeBtn(b, "Delete")
        del.BackgroundColor3 = Color3.fromRGB(150,60,60)
        del.MouseButton1Click:Connect(function()
            delfile(file)
            play:Destroy()
            del:Destroy()
            panelNotify("Track deleted")
        end)
    end
end)

-- FLY PANEL
flyBtn.MouseButton1Click:Connect(function()
    local p,b = createPanel(UDim2.new(0,240,0,160), UDim2.new(0.3,0,0.25,0), "FLY")
    local toggle = makeBtn(b,"ON / OFF")
    toggle.MouseButton1Click:Connect(function()
        flying = not flying
        if flying then
            bvf = Instance.new("BodyVelocity", root)
            bgf = Instance.new("BodyGyro", root)
            bvf.MaxForce = Vector3.new(1e6,1e6,1e6)
            bgf.MaxTorque = Vector3.new(1e6,1e6,1e6)
            flyConn = RunService.RenderStepped:Connect(function()
                local move = hum.MoveDirection
                bvf.Velocity = cam.CFrame.LookVector * move.Magnitude * flySpeed * FlyMultiplier
                bgf.CFrame = cam.CFrame
            end)
            panelNotify("Fly ON")
        else
            if flyConn then flyConn:Disconnect() end
            if bvf then bvf:Destroy() end
            if bgf then bgf:Destroy() end
            panelNotify("Fly OFF")
        end
    end)
end)

-- APPLY MULTIPLIER
RunService.RenderStepped:Connect(function()
    hum.WalkSpeed = walkSpeed * AutoWalkMultiplier
end)

panelNotify("AUTO WALK + FLY PRO READY")
