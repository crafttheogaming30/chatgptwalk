--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v5
 Theme : Dark Blue
 UI     : Scrollable, Draggable, Modular, History, Speed Control Fixed, Minimize Icon, Animasi Presisi
 Author : ChatGPT + Teyoo Fix
]]--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- FILE SYSTEM
if not isfolder("tracks") then makefolder("tracks") end

-- STATE
local recording, paused, playing, loopTrack = false,false,false,false
local speed = 1
local recordData, playConn = {}, nil

-- THEME
local THEME = {
    bg      = Color3.fromRGB(14,22,35),
    panel   = Color3.fromRGB(20,32,52),
    header  = Color3.fromRGB(24,40,70),
    accent  = Color3.fromRGB(80,140,255),
    text    = Color3.fromRGB(230,235,255)
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

-- CREATE PANEL FUNCTION
local function createPanel(title, width, height, fontSize)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoWalkPro_"..math.random(1000,9999)

    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.fromOffset(width,height)
    panel.Position = UDim2.fromScale(0.05,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,14)

    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1,0,0,28)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(0.6,0,1,0)
    titleLbl.Position = UDim2.fromScale(0.05,0)
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = fontSize
    titleLbl.TextColor3 = THEME.text
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local minimize = Instance.new("TextButton", header)
    minimize.Size = UDim2.new(0,28,1,0)
    minimize.Position = UDim2.new(0.85,0,0,0)
    minimize.Text = "—"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextColor3 = THEME.text
    minimize.TextSize = fontSize
    minimize.BackgroundTransparency = 1

    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0,28,1,0)
    close.Position = UDim2.new(1,-28,0,0)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextSize = fontSize
    close.TextColor3 = THEME.text
    close.BackgroundTransparency = 1
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        toast("Panel ditutup")
    end)

    local body = Instance.new("ScrollingFrame", panel)
    body.Size = UDim2.new(1,-8,1,-28)
    body.Position = UDim2.fromOffset(4,28)
    body.BackgroundTransparency = 1
    body.CanvasSize = UDim2.new(0,0,0,0)
    body.ScrollBarThickness = 8
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local iconBtn
    minimize.MouseButton1Click:Connect(function()
        if body.Visible then
            body.Visible = false
            panel.Visible = false
            iconBtn = Instance.new("TextButton", game.CoreGui)
            iconBtn.Size = UDim2.fromOffset(120,30)
            iconBtn.Position = UDim2.fromScale(0.05,0.1)
            iconBtn.Text = "Theo Ganteng"
            iconBtn.Font = Enum.Font.GothamBold
            iconBtn.TextSize = fontSize
            iconBtn.TextColor3 = THEME.text
            iconBtn.BackgroundColor3 = THEME.header
            Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0,12)
            iconBtn.MouseButton1Click:Connect(function()
                panel.Visible = true
                body.Visible = true
                iconBtn:Destroy()
            end)
        else
            body.Visible = true
            panel.Visible = true
            if iconBtn then iconBtn:Destroy() end
        end
    end)

    return gui, body
end

local panelWidth, panelHeight, fontSize = 300,360,12
local mainGui, body = createPanel("Auto Walk Track Pro HP", panelWidth, panelHeight, fontSize)

-- BUTTON HELPER
local function addButton(parent,text,y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.fromOffset(260,32)
    btn.Position = UDim2.fromOffset(20,y)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = fontSize
    btn.TextColor3 = THEME.text
    btn.BackgroundColor3 = THEME.header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

-- CREATE BUTTONS
local buttons, y = {},10
local buttonNames = {
    "● Record","⏸ Pause","💾 Save Track","📂 History","▶ Play Selected","🔁 Loop Track","⏹ Stop Play"
}
for _,name in ipairs(buttonNames) do
    local b = addButton(body,name,y)
    table.insert(buttons,b)
    y += 40
end
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- TRACK BOX
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(260,32)
nameBox.Position = UDim2.fromOffset(20,y)
nameBox.PlaceholderText = "Nama Track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,10)
y += 40
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- SPEED SLIDER DETAIL
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(260,8)
sliderBg.Position = UDim2.fromOffset(20,y)
sliderBg.BackgroundColor3 = THEME.header
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,4)
local knob = Instance.new("Frame", sliderBg)
knob.Size = UDim2.fromOffset(16,16)
knob.Position = UDim2.new((speed-1)/49, -8, -0.4,0)
knob.BackgroundColor3 = THEME.accent
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

knob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        local moveConn
        moveConn = RunService.RenderStepped:Connect(function()
            local x = math.clamp((UserInputService:GetMouseLocation().X - sliderBg.AbsolutePosition.X)/sliderBg.AbsoluteSize.X,0,1)
            knob.Position = UDim2.new(x,-8,-0.4,0)
            speed = 1 + x*49 -- detail x1 > x1.1 > ... x50
        end)
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                moveConn:Disconnect()
                toast("Speed : "..string.format("%.1f",speed).."x")
            end
        end)
    end
end)

-- BUTTON LOGIC
local recordBtn, pauseBtn, saveBtn, historyBtn, playBtn, loopBtn, stopPlayBtn = unpack(buttons)
local recordConn, playConn = nil,nil
local recordData, playing, loopTrack, paused = {}, false,false,false

-- RECORD ON/OFF
local recordStateLbl = Instance.new("TextLabel", recordBtn)
recordStateLbl.Size = UDim2.new(0.3,0,1,0)
recordStateLbl.Position = UDim2.new(0.7,0,0,0)
recordStateLbl.Text = "Off"
recordStateLbl.Font = Enum.Font.GothamBold
recordStateLbl.TextSize = fontSize
recordStateLbl.TextColor3 = THEME.accent
recordStateLbl.BackgroundTransparency = 1

recordBtn.MouseButton1Click:Connect(function()
    if recording then
        recording = false
        if recordConn then recordConn:Disconnect() end
        recordStateLbl.Text = "Off"
    else
        recording, paused, recordData = true,false,{}
        recordConn = RunService.RenderStepped:Connect(function()
            if recording and not paused then table.insert(recordData, {pos=hrp.Position,CFrame=hrp.CFrame}) end
        end)
        recordStateLbl.Text = "On"
        toast("Recording dimulai")
    end
end)

-- PLAY SELECTED WITH DETAIL SPEED & ANIMATION
playBtn.MouseButton1Click:Connect(function()
    local fname = nameBox.Text
    if fname=="" then return toast("Pilih track dulu") end
    local path = "tracks/"..fname..".lua"
    if not pcall(function() return readfile(path) end) then return toast("Track tidak ada") end
    local success,data = pcall(function() return loadfile(path)() end)
    if not success then return toast("Gagal load track") end
    if playing and playConn then playConn:Disconnect() end
    playing = true
    local index = 1
    playConn = RunService.RenderStepped:Connect(function()
        if not playing then playConn:Disconnect() return end
        local frame = data[index]
        if frame then
            hrp.CFrame = frame.CFrame -- animasi presisi sesuai record
            index += speed/10 -- lompat kecil per frame detail
        else
            if loopTrack then index = 1
            else playing = false; playConn:Disconnect(); toast("Track selesai") end
        end
    end)
end)

-- LOOP ON/OFF LABEL
local loopStateLbl = Instance.new("TextLabel", loopBtn)
loopStateLbl.Size = UDim2.new(0.2,0,1,0)
loopStateLbl.Position = UDim2.new(0.75,0,0,0)
loopStateLbl.Text = "Off"
loopStateLbl.Font = Enum.Font.GothamBold
loopStateLbl.TextSize = fontSize
loopStateLbl.TextColor3 = THEME.accent
loopStateLbl.BackgroundTransparency = 1

loopBtn.MouseButton1Click:Connect(function()
    loopTrack = not loopTrack
    loopStateLbl.Text = loopTrack and "On" or "Off"
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

-- HISTORY PANEL SMALL & SCROLLABLE
historyBtn.MouseButton1Click:Connect(function()
    local histGui = Instance.new("ScreenGui",game.CoreGui)
    histGui.Name = "AutoWalkHistory_"..math.random(1000,9999)
    local panel = Instance.new("Frame",histGui)
    panel.Size = UDim2.fromOffset(280,300)
    panel.Position = UDim2.fromScale(0.05,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)
    local header = Instance.new("Frame",panel)
    header.Size = UDim2.new(1,0,0,24)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner",header).CornerRadius = UDim.new(0,12)
    local closeBtn = Instance.new("TextButton",header)
    closeBtn.Size = UDim2.new(0,28,1,0)
    closeBtn.Position = UDim2.new(1,-28,0,0)
    closeBtn.Text="✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = fontSize
    closeBtn.TextColor3 = THEME.text
    closeBtn.BackgroundTransparency = 1
    closeBtn.MouseButton1Click:Connect(function() histGui:Destroy() end)
    local body = Instance.new("ScrollingFrame",panel)
    body.Size = UDim2.new(1,-6,1,-24)
    body.Position = UDim2.fromOffset(3,24)
    body.BackgroundTransparency=1
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize=Enum.AutomaticSize.Y
    body.ScrollBarThickness = 8

    local y = 10
    for _,file in ipairs(listfiles("tracks")) do
        local name = file:match(".+/([^/]+)%.lua$")
        local b = addButton(body,name,y)
        local del = addButton(body,"❌",y)
        del.Size = UDim2.fromOffset(40,32)
        del.Position = UDim2.fromOffset(240,y)
        del.MouseButton1Click:Connect(function()
            delfile(file)
            b:Destroy()
            del:Destroy()
            toast("Track "..name.." dihapus")
        end)
        b.MouseButton1Click:Connect(function() nameBox.Text = name; toast("Track "..name.." dipilih") end)
        y += 36
    end
    body.CanvasSize = UDim2.new(0,0,0,y+40)
end)

--[CUSTOM FEATURES] <- Tempat tambah fitur baru
