--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v9
 Theme : Dark Blue
 UI     : Scrollable, Draggable, Modular, History, Speed Control, Full Animations
 Author : ChatGPT + Teyoo Final Fix
]]--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- PLAYER
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local anims = {} -- simpan animasi Humanoid

-- FILE SYSTEM
if not isfolder("tracks") then makefolder("tracks") end

-- STATE
local recording, playing, paused, loopTrack = false,false,false,false
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

-- TOAST FUNCTION
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

    -- HEADER
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

    -- MINIMIZE & CLOSE
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
    close.MouseButton1Click:Connect(function() gui:Destroy(); toast("Panel ditutup") end)

    -- BODY
    local body = Instance.new("ScrollingFrame", panel)
    body.Size = UDim2.new(1,-10,1,-36)
    body.Position = UDim2.fromOffset(5,36)
    body.BackgroundTransparency = 1
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.ScrollBarThickness = 10

    -- MINIMIZE LOGO
    local iconBtn
    minimize.MouseButton1Click:Connect(function()
        panel.Visible = false
        if iconBtn then iconBtn:Destroy() end
        iconBtn = Instance.new("TextButton", game.CoreGui)
        iconBtn.Size = UDim2.fromOffset(140,36)
        iconBtn.Position = UDim2.fromScale(0.05,0.1)
        iconBtn.Text = "THEO GANTENG"
        iconBtn.Font = Enum.Font.GothamBold
        iconBtn.TextColor3 = THEME.text
        iconBtn.BackgroundColor3 = THEME.panel
        Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0,12)
        -- Drag
        local dragging = false
        local dragOffset = Vector2.new()
        iconBtn.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging = true
                dragOffset = Vector2.new(input.Position.X,input.Position.Y) - Vector2.new(iconBtn.AbsolutePosition.X,iconBtn.AbsolutePosition.Y)
            end
        end)
        iconBtn.InputChanged:Connect(function(input)
            if dragging and input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement then
                iconBtn.Position = UDim2.new(0,input.Position.X - dragOffset.X,0,input.Position.Y - dragOffset.Y)
            end
        end)
        iconBtn.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        iconBtn.MouseButton1Click:Connect(function()
            panel.Visible = true
            iconBtn:Destroy()
        end)
    end)

    return gui, body
end

-- CREATE MAIN PANEL
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

-- TRACK NAME BOX
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(300,36)
nameBox.Position = UDim2.fromOffset(30,10)
nameBox.PlaceholderText = "Nama Track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,12)

-- SPEED SLIDER
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(300,10)
sliderBg.Position = UDim2.fromOffset(30,60)
sliderBg.BackgroundColor3 = THEME.header
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,6)
local knob = Instance.new("Frame", sliderBg)
knob.Size = UDim2.fromOffset(18,18)
knob.Position = UDim2.new(speed/100,-9,-0.4,0)
knob.BackgroundColor3 = THEME.accent
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- SPEED +/- BUTTONS
local plusBtn = addButton(body,"+",100)
local minusBtn = addButton(body,"-",150)
plusBtn.MouseButton1Click:Connect(function() speed = math.min(50,speed+0.1); knob.Position = UDim2.new(speed/50,-9,-0.4,0); toast("Speed: "..string.format("%.1f",speed).."x") end)
minusBtn.MouseButton1Click:Connect(function() speed = math.max(0.1,speed-0.1); knob.Position = UDim2.new(speed/50,-9,-0.4,0); toast("Speed: "..string.format("%.1f",speed).."x") end)

-- RECORD LOGIC WITH ANIMATION
local recordBtn = addButton(body,"● Record",200)
local stopBtn   = addButton(body,"■ Stop Record",250)
recordBtn.MouseButton1Click:Connect(function()
    if recording then return end
    recording, recordData = true, {}
    toast("Record ON")
    local currentAnim = "Idle"
    local animTrack = nil
    recordConn = RunService.RenderStepped:Connect(function(dt)
        if recording then
            -- save position + anim
            table.insert(recordData,{pos=hrp.Position,anim=currentAnim})
        end
    end)
end)
stopBtn.MouseButton1Click:Connect(function()
    if recording then
        recording = false
        if recordConn then recordConn:Disconnect() end
        toast("Record Stopped")
        -- save auto
        local fname = (nameBox.Text~="" and nameBox.Text or "Track")..".lua"
        local data = "return {\n"
        for _,v in ipairs(recordData) do
            data ..= string.format("{Vector3.new(%f,%f,%f),'%s'},\n",v.pos.X,v.pos.Y,v.pos.Z,v.anim)
        end
        data ..= "}"
        writefile("tracks/"..fname,data)
        toast("Track "..fname.." disimpan")
    end
end)

-- PLAY SELECTED
local playBtn = addButton(body,"▶ Play Selected",300)
local stopPlayBtn = addButton(body,"⏹ Stop Play",350)
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
        local step = math.max(1,speed) -- speed multiplier
        local entry = data[index]
        if entry then
            hrp.CFrame = CFrame.new(entry.pos)
            -- anim logic placeholder, bisa diganti load anim sesuai entry.anim
            index += step
        else
            if loopTrack then index = 1
            else playing = false; playConn:Disconnect(); toast("Track selesai") end
        end
    end)
end)
stopPlayBtn.MouseButton1Click:Connect(function()
    if playing and playConn then
        playing = false
        playConn:Disconnect()
        toast("Play Stopped")
    end
end)

-- LOOP TRACK
local loopBtn = addButton(body,"🔁 Loop Track",400)
loopBtn.MouseButton1Click:Connect(function()
    loopTrack = not loopTrack
    toast(loopTrack and "Loop: ON" or "Loop: OFF")
end)

-- HISTORY PANEL
local historyBtn = addButton(body,"📂 History",450)
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
