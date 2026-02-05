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
    data ..= string.format(
        "{pos=Vector3.new(%f,%f,%f), dir=Vector3.new(%f,%f,%f)},\n",
        p.pos.X, p.pos.Y, p.pos.Z,
        p.dir.X, p.dir.Y, p.dir.Z
    )
                end
        data ..= "}"
        writefile("tracks/"..box.Text..".lua", data)
        panelNotify("Track disimpan: "..box.Text)
        p:Destroy()
    end)
end)

RunService.RenderStepped:Connect(function()
    if recording and not paused then
        table.insert(track, {
            pos = root.Position,
            dir = hum.MoveDirection
        })
    end
end)

-- =========================
-- AUTOWALK FIX (REAL WALK)
-- =========================

local function stopAutoWalk()
    playing = false

    hum.PlatformStand = false
    hum.AutoRotate = true
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)

    root.Anchored = false
end

local function playAutoWalk()
    if #track < 2 or playing then return end

    playing = true
    playIndex = 1
    panelNotify("AutoWalk jalan")

    -- 🔥 MATIIN PHYSICS & MAP
    hum.PlatformStand = false
hum.AutoRotate = true
hum:ChangeState(Enum.HumanoidStateType.Running)
root.Anchored = false

    task.spawn(function()
        while playing do
    local target = track[playIndex]

    if not target then
        if loopPlay then
            playIndex = 1
        else
            stopAutoWalk()
            panelNotify("AutoWalk selesai")
            break
        end
    else
        hum:Move(target.dir, true)

        root.CFrame = root.CFrame:Lerp(
            CFrame.new(target.pos),
            0.35
        )

        local step = math.clamp(
            math.floor(AutoWalkMultiplier),
            1, 100
        )
        playIndex += step

        RunService.RenderStepped:Wait()
    end
            end
    end)
end

playBtn.MouseButton1Click:Connect(function()
    playAutoWalk()
end)

stopBtn.MouseButton1Click:Connect(function()
    stopAutoWalk()
    panelNotify("AutoWalk stop")
end)


-- LOOP
loopBtn.MouseButton1Click:Connect(function()
    loopPlay = not loopPlay
    loopBtn.Text = "🔁 Loop : "..(loopPlay and "ON" or "OFF")
    panelNotify("Loop "..(loopPlay and "ON" or "OFF"))
end)

-- SPEED CONTROL PANEL (FINAL - SLIDER + BUTTON, HP SAFE)
speedBtn.MouseButton1Click:Connect(function()
    local p,b = createPanel(
        UDim2.new(0,280,0,260),
        UDim2.new(0,35,0,0.25,0),
        "SPEED CONTROL"
    )

    local function makeSpeedControl(title, minV, maxV, step, getVal, setVal)
        local label = Instance.new("TextLabel", b)
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = Color3.new(1,1,1)

        local bar = Instance.new("Frame", b)
        bar.Size = UDim2.new(1,-20,0,18)
        bar.BackgroundColor3 = Color3.fromRGB(40,55,85)
        Instance.new("UICorner", bar)

        local fill = Instance.new("Frame", bar)
        fill.BackgroundColor3 = Color3.fromRGB(180,200,255)
        fill.Size = UDim2.new(0,0,1,0)
        Instance.new("UICorner", fill)

        local function refresh()
            local v = getVal()
            local pct = (v-minV)/(maxV-minV)
            fill.Size = UDim2.new(pct,0,1,0)
            label.Text = title.." : "..string.format("%.2f", v)
        end

        local dragging = false
        local function setFromX(x)
            local pct = math.clamp(
                (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                0,1
            )
            local v = math.floor((minV + (maxV-minV)*pct)*100)/100
            setVal(v)
            refresh()
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                setFromX(i.Position.X)
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if dragging and
               (i.UserInputType == Enum.UserInputType.Touch
               or i.UserInputType == Enum.UserInputType.MouseMovement) then
                setFromX(i.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function()
            dragging = false
        end)

        local plus = makeBtn(b,"+")
        plus.Size = UDim2.new(0.48,0,0,28)

        local minus = makeBtn(b,"-")
        minus.Size = UDim2.new(0.48,0,0,28)

        plus.MouseButton1Click:Connect(function()
            setVal(math.min(getVal()+step, maxV))
            refresh()
        end)

        minus.MouseButton1Click:Connect(function()
            setVal(math.max(getVal()-step, minV))
            refresh()
        end)

        refresh()
        return plus, minus
    end

    -- AUTOWALK SPEED
    local awPlus, awMin = makeSpeedControl(
        "AutoWalk Speed",
        0.5, 3,
        0.1,
        function() return AutoWalkMultiplier end,
        function(v) AutoWalkMultiplier = v end
    )

    awPlus.Position = UDim2.fromOffset(10,70)
    awMin.Position  = UDim2.fromOffset(150,70)

    -- FLY SPEED
    local flyPlus, flyMin = makeSpeedControl(
        "Fly Speed",
        0.5, 5,
        0.2,
        function() return FlyMultiplier end,
        function(v) FlyMultiplier = v end
    )

    flyPlus.Position = UDim2.fromOffset(10,160)
    flyMin.Position  = UDim2.fromOffset(150,160)
end)

-- HISTORY PANEL
histBtn.MouseButton1Click:Connect(function()
    local p,b = createPanel(UDim2.new(0,260,0,260), UDim2.new(0.4,0,0.25,0), "HISTORY")
    for _,file in ipairs(listfiles("tracks")) do
        local play = makeBtn(b, file:match("([^/]+)$"))
        play.MouseButton1Click:Connect(function()
            track = loadfile(file)()
            panelNotify("Track loaded")
            playAutoWalk()
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


panelNotify("AUTO WALK + FLY PRO READY")
