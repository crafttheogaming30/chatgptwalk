--[[ 
 AUTO WALK TRACK SYSTEM - HP FIXED SCROLL + MINIMIZE
 Theme : Dark Blue
 UI     : Scrollable, Smooth, HP Friendly
 Author : ChatGPT + Teyoo Fix
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

if not isfolder("tracks") then
    makefolder("tracks")
end

-- STATE
local recording, paused, playing, loopTrack = false, false, false, false
local speed = 40
local recordData, playData, playIndex, recordConn, playConn = {}, {}, 1

-- THEME
local THEME = {
    bg      = Color3.fromRGB(14,22,35),
    panel   = Color3.fromRGB(20,32,52),
    header  = Color3.fromRGB(24,40,70),
    accent  = Color3.fromRGB(80,140,255),
    text    = Color3.fromRGB(230,235,255),
    muted   = Color3.fromRGB(150,160,190)
}

-- TOAST
local function toast(text)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "Toast"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.3,0.07)
    frame.Position = UDim2.fromScale(0.35,0.9)
    frame.BackgroundColor3 = THEME.panel
    frame.BackgroundTransparency = 0.1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.fromScale(1,1)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14

    TweenService:Create(frame,TweenInfo.new(0.3), {Position = UDim2.fromScale(0.35,0.82)}):Play()
    task.delay(2,function()
        TweenService:Create(frame,TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        gui:Destroy()
    end)
end

-- CREATE PANEL
local function createPanel(title)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoWalkPro_"..math.random(1000,9999)

    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.fromOffset(360,400)
    panel.Position = UDim2.fromScale(0.05,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)

    -- header
    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1,0,0,36)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,18)

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(0.6,0,1,0)
    titleLbl.Position = UDim2.fromScale(0.05,0)
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 15
    titleLbl.TextColor3 = THEME.text
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local minimize = Instance.new("TextButton", header)
    minimize.Size = UDim2.new(0,32,1,0)
    minimize.Position = UDim2.new(0.85,0,0,0)
    minimize.Text = "—"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextColor3 = THEME.text
    minimize.BackgroundTransparency = 1

    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0,32,1,0)
    close.Position = UDim2.new(1,-32,0,0)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextColor3 = THEME.text
    close.BackgroundTransparency = 1
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        toast("Panel ditutup")
    end)

    -- scrollable body
    local body = Instance.new("ScrollingFrame", panel)
    body.Size = UDim2.new(1,-10,1,-36)
    body.Position = UDim2.fromOffset(5,36)
    body.CanvasSize = UDim2.new(0,0,0,0)
    body.ScrollBarThickness = 10
    body.BackgroundTransparency = 1

    minimize.MouseButton1Click:Connect(function()
        body.Visible = not body.Visible
    end)

    return gui, body
end

local mainGui, body = createPanel("Auto Walk Track Pro HP")

-- BUTTON HELPER
local function addButton(parent,text)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.fromOffset(300,38)
    btn.Position = UDim2.fromOffset(30,0)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = THEME.text
    btn.BackgroundColor3 = THEME.header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)
    return btn
end

-- ADD BUTTONS WITH AUTO POSITION
local function createButtons(parent, texts)
    local buttons = {}
    local y = 10
    for _,t in ipairs(texts) do
        local b = addButton(parent,t)
        b.Position = UDim2.fromOffset(30,y)
        table.insert(buttons,b)
        y += 50
    end
    parent.CanvasSize = UDim2.new(0,0,0,y)
    return buttons
end

local buttonNames = {
    "● Record",
    "⏸ Pause",
    "■ Stop Record",
    "💾 Save Track",
    "📂 History",
    "▶ Play Selected",
    "🔁 Loop Track",
    "⏹ Stop Play"
}

local buttons = createButtons(body, buttonNames)

-- text box for track name
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(300,36)
nameBox.Position = UDim2.fromOffset(30,#buttonNames*50 + 10)
nameBox.PlaceholderText = "Nama Track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,12)
body.CanvasSize = UDim2.new(0,0,0,#buttonNames*50 + 60)

-- SLIDER
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(300,10)
sliderBg.Position = UDim2.fromOffset(30,body.CanvasSize.Y.Offset-40)
sliderBg.BackgroundColor3 = THEME.header
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,6)

local knob = Instance.new("Frame", sliderBg)
knob.Size = UDim2.fromOffset(18,18)
knob.Position = UDim2.new(speed/100,-9,-0.4,0)
knob.BackgroundColor3 = THEME.accent
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

knob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        local moveConn
        moveConn = RunService.RenderStepped:Connect(function()
            local x = math.clamp((UserInputService:GetMouseLocation().X - sliderBg.AbsolutePosition.X)/sliderBg.AbsoluteSize.X,0,1)
            knob.Position = UDim2.new(x,-9,-0.4,0)
            speed = math.floor(x*100)
        end)
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                moveConn:Disconnect()
                toast("Speed : "..speed)
            end
        end)
    end
end)

-- LOGIC RECORD / PLAY / STOP
local recordBtn, pauseBtn, stopBtn, saveBtn, historyBtn, playBtn, loopBtn, stopPlayBtn = unpack(buttons)
local recordConn, playConn = nil, nil
local recordData, selectedTrack = {}, nil
local playing, loopTrack = false, false
local paused = false

recordBtn.MouseButton1Click:Connect(function()
    if recording then return end
    recording, paused, recordData = true, false, {}
    recordConn = RunService.RenderStepped:Connect(function()
        if recording and not paused then
            table.insert(recordData, hrp.Position)
        end
    end)
    toast("Recording dimulai")
end)

pauseBtn.MouseButton1Click:Connect(function()
    if not recording then return end
    paused = not paused
    toast(paused and "Recording pause" or "Recording lanjut")
end)

stopBtn.MouseButton1Click:Connect(function()
    recording = false
    if recordConn then recordConn:Disconnect() end
    toast("Recording stop")
end)

saveBtn.MouseButton1Click:Connect(function()
    if #recordData == 0 then return end
    local data = "return {\n"
    for _,p in ipairs(recordData) do
        data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
    end
    data ..= "}"
    writefile("tracks/"..(nameBox.Text~="" and nameBox.Text or "Track")..".lua", data)
    toast("Track disimpan")
end)

-- HISTORY
local historyList = Instance.new("ScrollingFrame", body)
historyList.Size = UDim2.fromOffset(300,150)
historyList.Position = UDim2.fromOffset(30,sliderBg.Position.Y.Offset+50)
historyList.BackgroundColor3 = THEME.bg
Instance.new("UICorner", historyList).CornerRadius = UDim.new(0,10)
historyList.Visible = false
historyList.CanvasSize = UDim2.new(0,0,0,0)

historyBtn.MouseButton1Click:Connect(function()
    historyList:ClearAllChildren()
    local files = listfiles("tracks")
    local y = 0
    for _,file in ipairs(files) do
        local name = file:match("tracks/(.+)%.lua")
        local btn = Instance.new("TextButton", historyList)
        btn.Size = UDim2.fromOffset(280,30)
        btn.Position = UDim2.fromOffset(10,y)
        btn.Text = name
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = THEME.text
        btn.BackgroundColor3 = THEME.header
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        btn.MouseButton1Click:Connect(function()
            selectedTrack = file
            toast("Track dipilih: "..name)
        end)
        y += 35
    end
    historyList.CanvasSize = UDim2.new(0,0,0,y)
    historyList.Visible = not historyList.Visible
end)

-- LOOP
loopBtn.MouseButton1Click:Connect(function()
    loopTrack = not loopTrack
    toast(loopTrack and "Loop: ON" or "Loop: OFF")
end)

-- STOP PLAY
stopPlayBtn.MouseButton1Click:Connect(function()
    if playing and playConn then
        playing = false
        playConn:Disconnect()
        toast("Play track dihentikan")
    end
end)

-- PLAY
playBtn.MouseButton1Click:Connect(function()
    if not selectedTrack then return toast("Pilih track dulu") end
    local success, data = pcall(function() return loadfile(selectedTrack)() end)
    if not success then return toast("Gagal load track") end

    if playing and playConn then playConn:Disconnect() end
    playing = true
    playIndex = 1

    playConn = RunService.RenderStepped:Connect(function(dt)
        local pos = data[playIndex]
        if pos then
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos), dt*(speed/10))
            playIndex += 1
        else
            if loopTrack then
                playIndex = 1
            else
                playing = false
                playConn:Disconnect()
                toast("Track selesai")
            end
        end
    end)
end)
