--[[
AUTO WALK TRACK SYSTEM - FINAL V10
Theme : Dark Blue
UI     : HP Ready, Scrollable, Draggable, History, Speed +/-, Animasi Fix
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
local humanoid = char:WaitForChild("Humanoid")

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
    gui.Name = "Toast_"..math.random(1,9999)
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
local function createPanel(title)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoWalkPro_"..math.random(1000,9999)

    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.fromOffset(320,360)
    panel.Position = UDim2.fromScale(0.1,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,14)

    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1,0,0,36)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

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
    close.MouseButton1Click:Connect(function() gui:Destroy() toast("Panel ditutup") end)

    local body = Instance.new("ScrollingFrame", panel)
    body.Size = UDim2.new(1,-10,1,-36)
    body.Position = UDim2.fromOffset(5,36)
    body.BackgroundTransparency = 1
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.ScrollBarThickness = 10

    -- Minimize Logic
    local iconBtn
    minimize.MouseButton1Click:Connect(function()
        if body.Visible then
            body.Visible = false
            iconBtn = Instance.new("TextButton", game.CoreGui)
            iconBtn.Size = UDim2.fromOffset(150,30)
            iconBtn.Position = UDim2.fromScale(0.5,0.5)
            iconBtn.AnchorPoint = Vector2.new(0.5,0.5)
            iconBtn.Text = "THEO GANTENG"
            iconBtn.Font = Enum.Font.GothamBold
            iconBtn.TextColor3 = THEME.text
            iconBtn.BackgroundColor3 = THEME.panel
            Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0,12)
            -- draggable logo
            local dragging = false
            local offset = Vector2.new()
            iconBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    offset = input.Position - iconBtn.AbsolutePosition
                end
            end)
            iconBtn.InputChanged:Connect(function(input)
                if dragging then
                    iconBtn.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
                end
            end)
            iconBtn.InputEnded:Connect(function(input)
                dragging = false
            end)
            iconBtn.MouseButton1Click:Connect(function()
                body.Visible = true
                iconBtn:Destroy()
            end)
        else
            body.Visible = true
            if iconBtn then iconBtn:Destroy() end
        end
    end)

    return gui, body
end

-- MAIN PANEL
local mainGui, body = createPanel("Auto Walk Track Pro HP")

-- BUTTON HELPER
local function addButton(parent,text,y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.fromOffset(280,36)
    btn.Position = UDim2.fromOffset(20,y)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = THEME.text
    btn.BackgroundColor3 = THEME.header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

-- BUTTONS
local buttons, y = {},10
local btnNames = {"Record","Pause","Save Track","History","Play Selected","Loop Track","Stop Play"}
for _,name in ipairs(btnNames) do
    local b = addButton(body,name,y)
    table.insert(buttons,b)
    y += 50
end
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- NAME BOX
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(280,32)
nameBox.Position = UDim2.fromOffset(20,y)
nameBox.PlaceholderText = "Nama Track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,10)
y += 50
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- SPEED CONTROL
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(280,10)
sliderBg.Position = UDim2.fromOffset(20,y)
sliderBg.BackgroundColor3 = THEME.header
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,5)

local knob = Instance.new("Frame", sliderBg)
knob.Size = UDim2.fromOffset(18,18)
knob.Position = UDim2.new(speed/50, -9, -0.4,0)
knob.BackgroundColor3 = THEME.accent
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- SPEED + / -
local plusBtn = addButton(body,"+",y+20)
plusBtn.Size = UDim2.fromOffset(40,30)
plusBtn.Position = UDim2.fromOffset(80,y+20)
local minusBtn = addButton(body,"-",y+20)
minusBtn.Size = UDim2.fromOffset(40,30)
minusBtn.Position = UDim2.fromOffset(140,y+20)
y += 70
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- SPEED LOGIC
local function updateKnob(x)
    knob.Position = UDim2.new(x, -9, -0.4,0)
    speed = math.floor(1 + x*49)
    toast("Speed : "..speed.."x")
end
knob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        local moveConn
        moveConn = RunService.RenderStepped:Connect(function()
            local x = math.clamp((UserInputService:GetMouseLocation().X - sliderBg.AbsolutePosition.X)/sliderBg.AbsoluteSize.X,0,1)
            updateKnob(x)
        end)
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then moveConn:Disconnect() end
        end)
    end
end)
plusBtn.MouseButton1Click:Connect(function()
    local x = knob.Position.X.Scale
    x = math.clamp(x + 0.02,0,1)
    updateKnob(x)
end)
minusBtn.MouseButton1Click:Connect(function()
    local x = knob.Position.X.Scale
    x = math.clamp(x - 0.02,0,1)
    updateKnob(x)
end)

-- RECORD LOGIC
local recordBtn, pauseBtn, saveBtn, historyBtn, playBtn, loopBtn, stopPlayBtn = unpack(buttons)
local recordConn, playConn = nil,nil
local recordData, playing, loopTrack, paused = {}, false,false,false

recordBtn.MouseButton1Click:Connect(function()
    if recording then
        recording = false
        if recordConn then recordConn:Disconnect() end
        toast("Record Stopped")
        saveBtn.Visible = true
        return
    end
    recording = true
    paused = false
    recordData = {}
    saveBtn.Visible = false
    recordConn = RunService.RenderStepped:Connect(function()
        if recording and not paused then
            table.insert(recordData, {pos = hrp.Position, anim = humanoid:GetState()})
        end
    end)
    toast("Recording Started")
end)

pauseBtn.MouseButton1Click:Connect(function()
    if not recording then return end
    paused = not paused
    toast(paused and "Recording Paused" or "Recording Resumed")
end)

saveBtn.MouseButton1Click:Connect(function()
    if #recordData==0 then return end
    local fname = (nameBox.Text~="" and nameBox.Text or "Track")..".lua"
    local data = "return {\n"
    for _,p in ipairs(recordData) do
        data ..= string.format("{Vector3.new(%f,%f,%f),'%s'},\n",p.pos.X,p.pos.Y,p.pos.Z,tostring(p.anim))
    end
    data ..= "}"
    writefile("tracks/"..fname,data)
    toast("Track saved")
end)

-- STOP PLAY
stopPlayBtn.MouseButton1Click:Connect(function()
    if playing and playConn then
        playing = false
        playConn:Disconnect()
        toast("Play track stopped")
    end
end)

-- PLAY SELECTED
playBtn.MouseButton1Click:Connect(function()
    local fname = nameBox.Text
    if fname=="" then return toast("Select track first") end
    local path = "tracks/"..fname..".lua"
    if not pcall(function() return readfile(path) end) then return toast("Track not found") end
    local success,data = pcall(function() return loadfile(path)() end)
    if not success then return toast("Failed load track") end
    if playing and playConn then playConn:Disconnect() end
    playing = true
    local index = 1
    playConn = RunService.RenderStepped:Connect(function(dt)
        if not playing then playConn:Disconnect() return end
        local step = math.max(1, speed/10)
        local recordStep = data[index]
        if recordStep then
            hrp.CFrame = CFrame.new(recordStep[1])
            humanoid:ChangeState(Enum.HumanoidStateType[recordStep[2]] or Enum.HumanoidStateType.Running)
            index += 1
        else
            if loopTrack then index = 1 else playing=false;playConn:Disconnect();toast("Track finished") end
        end
    end)
end)

-- LOOP TOGGLE
loopBtn.MouseButton1Click:Connect(function()
    loopTrack = not loopTrack
    toast(loopTrack and "Loop ON" or "Loop OFF")
end)

-- HISTORY PANEL
historyBtn.MouseButton1Click:Connect(function()
    local histGui = Instance.new("ScreenGui",game.CoreGui)
    histGui.Name = "AutoWalkHistory_"..math.random(1000,9999)
    local panel = Instance.new("Frame",histGui)
    panel.Size = UDim2.fromOffset(320,360)
    panel.Position = UDim2.fromScale(0.1,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner",panel).CornerRadius = UDim.new(0,14)
    local header = Instance.new("Frame",panel)
    header.Size = UDim2.new(1,0,0,36)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner",header).CornerRadius = UDim.new(0,14)
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
        del.Size = UDim2.fromOffset(50,36)
        del.Position = UDim2.fromOffset(260,y)
        del.MouseButton1Click:Connect(function()
            delfile(file)
            b:Destroy()
            del:Destroy()
            toast("Track "..name.." deleted")
        end)
        b.MouseButton1Click:Connect(function() nameBox.Text = name; toast("Track "..name.." selected") end)
        y += 50
    end
    body.CanvasSize = UDim2.new(0,0,0,y+50)
end)
