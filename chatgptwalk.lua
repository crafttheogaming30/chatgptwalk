--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v3
 Theme : Dark Blue
 UI     : Scrollable, Draggable, Modular, History, Speed Control
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
local speed = 40
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

    local body = Instance.new("ScrollingFrame", panel)
    body.Size = UDim2.new(1,-10,1,-36)
    body.Position = UDim2.fromOffset(5,36)
    body.BackgroundTransparency = 1
    body.CanvasSize = UDim2.new(0,0,0,0)
    body.ScrollBarThickness = 10
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local iconBtn
    minimize.MouseButton1Click:Connect(function()
        body.Visible = not body.Visible
        if not body.Visible then
            iconBtn = Instance.new("TextButton", game.CoreGui)
            iconBtn.Size = UDim2.fromOffset(120,30)
            iconBtn.Position = UDim2.fromScale(0.05,0.1)
            iconBtn.Text = "Theo Ganteng"
            iconBtn.Font = Enum.Font.GothamBold
            iconBtn.TextColor3 = THEME.text
            iconBtn.BackgroundColor3 = THEME.header
            Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0,12)
            iconBtn.MouseButton1Click:Connect(function()
                body.Visible = true
                iconBtn:Destroy()
            end)
        elseif iconBtn then
            iconBtn:Destroy()
        end
    end)

    return gui, body
end

local mainGui, body = createPanel("Auto Walk Track Pro HP")

-- BUTTON HELPER
local function addButton(parent,text,y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.fromOffset(300,38)
    btn.Position = UDim2.fromOffset(30,y)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = THEME.text
    btn.BackgroundColor3 = THEME.header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)
    return btn
end

-- CREATE BUTTON LIST
local buttons, y = {},10
local buttonNames = {
    "● Record","⏸ Pause","■ Stop Record","💾 Save Track","📂 History","▶ Play Selected","🔁 Loop Track","⏹ Stop Play"
}
for _,name in ipairs(buttonNames) do
    local b = addButton(body,name,y)
    table.insert(buttons,b)
    y += 50
end
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- TRACK NAME BOX
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(300,36)
nameBox.Position = UDim2.fromOffset(30,y)
nameBox.PlaceholderText = "Nama Track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,12)
y += 50
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- SPEED SLIDER
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(300,10)
sliderBg.Position = UDim2.fromOffset(30,y)
sliderBg.BackgroundColor3 = THEME.header
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,6)
local knob = Instance.new("Frame", sliderBg)
knob.Size = UDim2.fromOffset(18,18)
knob.Position = UDim2.new(speed/100,-9,-0.4,0)
knob.BackgroundColor3 = THEME.accent
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

knob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
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

-- ASSIGN BUTTONS
local recordBtn, pauseBtn, stopBtn, saveBtn, historyBtn, playBtn, loopBtn, stopPlayBtn = unpack(buttons)
local recordConn, playConn = nil,nil
local recordData, playing, loopTrack, paused = {}, false,false,false

-- RECORD LOGIC
recordBtn.MouseButton1Click:Connect(function()
    if recording then return end
    recording, paused, recordData = true,false,{}
    recordConn = RunService.RenderStepped:Connect(function()
        if recording and not paused then table.insert(recordData, hrp.Position) end
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
    if #recordData==0 then return end
    local fname = (nameBox.Text~="" and nameBox.Text or "Track")..".lua"
    local data = "return {\n"
    for _,p in ipairs(recordData) do
        data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
    end
    data ..= "}"
    writefile("tracks/"..fname,data)
    toast("Track disimpan")
end)

-- STOP PLAY LOGIC
stopPlayBtn.MouseButton1Click:Connect(function()
    if playing and playConn then
        playing = false
        playConn:Disconnect()
        toast("Play track dihentikan")
    end
end)

-- PLAY LOGIC SESUAI TRACK DAN SPEED
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
    playConn = RunService.RenderStepped:Connect(function(dt)
        if not playing then playConn:Disconnect() return end
        local pos = data[index]
        if pos then
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos), dt*(speed/10))
            index += 1
        else
            if loopTrack then index = 1
            else playing = false; playConn:Disconnect(); toast("Track selesai") end
        end
    end)
end)

-- LOOP
loopBtn.MouseButton1Click:Connect(function()
    loopTrack = not loopTrack
    toast(loopTrack and "Loop: ON" or "Loop: OFF")
end)

-- HISTORY PANEL DRAGGABLE + SCROLLABLE + HAPUS TRACK
historyBtn.MouseButton1Click:Connect(function()
    local histGui = Instance.new("ScreenGui",game.CoreGui)
    histGui.Name = "AutoWalkHistory_"..math.random(1000,9999)
    local panel = Instance.new("Frame",histGui)
    panel.Size = UDim2.fromOffset(360,400)
    panel.Position = UDim2.fromScale(0.05,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner",panel).CornerRadius = UDim.new(0,18)
    local header = Instance.new("Frame",panel)
    header.Size = UDim2.new(1,0,0,36)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner",header).CornerRadius = UDim.new(0,18)
    local closeBtn = Instance.new("TextButton",header)
    closeBtn.Size = UDim2.new(0,32,1,0)
    closeBtn.Position = UDim2.new(1,-32,0,0)
    closeBtn.Text="✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = THEME.text
    closeBtn.BackgroundTransparency = 1
    closeBtn.MouseButton1Click:Connect(function() histGui:Destroy() end)

    local body = Instance.new("ScrollingFrame",panel)
    body.Size = UDim2.new(1,-10,1,-36)
    body.Position = UDim2.fromOffset(5,36)
    body.BackgroundTransparency=1
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize=Enum.AutomaticSize.Y
    body.ScrollBarThickness = 10

    local y = 10
    for _,file in ipairs(listfiles("tracks")) do
        local name = file:match(".+/([^/]+)%.lua$")
        local b = addButton(body,name,y)
        local del = addButton(body,"❌",y)
        del.Size = UDim2.fromOffset(50,38)
        del.Position = UDim2.fromOffset(310,y)
        del.MouseButton1Click:Connect(function()
            delfile(file)
            b:Destroy()
            del:Destroy()
            toast("Track "..name.." dihapus")
        end)
        b.MouseButton1Click:Connect(function() nameBox.Text = name; toast("Track "..name.." dipilih") end)
        y += 50
    end
    body.CanvasSize = UDim2.new(0,0,0,y+50)
end)

------------------------------------------------
-- [CUSTOM FEATURES] <- Tambah kode fitur baru di bawah sini
------------------------------------------------
-- Contoh:
-- local myBtn = addButton(body,"Fitur Baru")
-- myBtn.MouseButton1Click:Connect(function()
--     print("Fitur baru jalan!")
-- end)
