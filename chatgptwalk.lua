--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v6
 Theme : Dark Blue
 UI     : Scrollable, Draggable, Modular, History, Speed Control +/-, Minimize Icon
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
    panel.Size = UDim2.fromOffset(300,350)
    panel.Position = UDim2.fromScale(0.05,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,16)

    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1,0,0,30)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,16)

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(0.6,0,1,0)
    titleLbl.Position = UDim2.fromScale(0.05,0)
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = THEME.text
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local minimize = Instance.new("TextButton", header)
    minimize.Size = UDim2.new(0,28,1,0)
    minimize.Position = UDim2.new(0.85,0,0,0)
    minimize.Text = "—"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextColor3 = THEME.text
    minimize.BackgroundTransparency = 1

    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0,28,1,0)
    close.Position = UDim2.new(1,-28,0,0)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextColor3 = THEME.text
    close.BackgroundTransparency = 1
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        toast("Panel ditutup")
    end)

    local body = Instance.new("ScrollingFrame", panel)
    body.Size = UDim2.new(1,-10,1,-30)
    body.Position = UDim2.fromOffset(5,30)
    body.BackgroundTransparency = 1
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.ScrollBarThickness = 10

    local iconBtn
    minimize.MouseButton1Click:Connect(function()
        if body.Visible then
            body.Visible = false
            iconBtn = Instance.new("TextButton", game.CoreGui)
            iconBtn.Size = UDim2.fromOffset(120,28)
            iconBtn.Position = UDim2.fromScale(0.05,0.1)
            iconBtn.Text = "Theo Ganteng"
            iconBtn.Font = Enum.Font.GothamBold
            iconBtn.TextColor3 = THEME.text
            iconBtn.BackgroundColor3 = THEME.panel
            Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0,12)
            -- drag icon
            local dragging = false
            local dragOffset
            iconBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragOffset = input.Position - iconBtn.AbsolutePosition
                end
            end)
            iconBtn.InputChanged:Connect(function(input)
                if dragging then
                    iconBtn.Position = UDim2.new(0, input.Position.X - dragOffset.X, 0, input.Position.Y - dragOffset.Y)
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

local mainGui, body = createPanel("Auto Walk Track Pro HP")

-- BUTTON HELPER
local function addButton(parent,text,y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.fromOffset(250,32)
    btn.Position = UDim2.fromOffset(20,y)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextColor3 = THEME.text
    btn.BackgroundColor3 = THEME.header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

-- TRACK NAME BOX
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(250,28)
nameBox.Position = UDim2.fromOffset(20,10)
nameBox.PlaceholderText = "Nama Track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,10)

local y = 50
-- SPEED SLIDER + +/-
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(250,8)
sliderBg.Position = UDim2.fromOffset(20,y)
sliderBg.BackgroundColor3 = THEME.header
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,4)
local knob = Instance.new("Frame", sliderBg)
knob.Size = UDim2.fromOffset(16,16)
knob.Position = UDim2.new(speed/50, -8, -0.4,0)
knob.BackgroundColor3 = THEME.accent
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

local function updateSpeed(x)
    speed = math.clamp(x,1,50)
    knob.Position = UDim2.new(speed/50,-8,-0.4,0)
    toast("Speed "..speed.."x")
end

-- slider drag
knob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        local moveConn
        moveConn = RunService.RenderStepped:Connect(function()
            local mouseX = UserInputService:GetMouseLocation().X
            local rel = math.clamp((mouseX - sliderBg.AbsolutePosition.X)/sliderBg.AbsoluteSize.X,0,1)
            updateSpeed(rel*50)
        end)
        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then moveConn:Disconnect() end
        end)
    end
end)

y+=20
-- + / - buttons
local plusBtn = addButton(body,"+",y)
plusBtn.Size = UDim2.fromOffset(50,28)
plusBtn.Position = UDim2.fromOffset(20,y)
plusBtn.MouseButton1Click:Connect(function()
    updateSpeed(speed+1)
end)
local minusBtn = addButton(body,"-",y)
minusBtn.Size = UDim2.fromOffset(50,28)
minusBtn.Position = UDim2.fromOffset(80,y)
minusBtn.MouseButton1Click:Connect(function()
    updateSpeed(speed-1)
end)

y+=50

-- BUTTONS
local buttons = {}
local buttonNames = {"● Record","⏸ Pause","💾 Save Track","📂 History","▶ Play Selected","🔁 Loop Track","⏹ Stop Play"}
for _,name in ipairs(buttonNames) do
    local b = addButton(body,name,y)
    buttons[name] = b
    y+=40
end
body.CanvasSize = UDim2.new(0,0,0,y+20)

-- STATES
local recordConn, playConn = nil,nil
local recordData, playing, loopTrack, paused = {}, false,false,false

-- RECORD
buttons["● Record"].MouseButton1Click:Connect(function()
    if recording then
        recording=false
        if recordConn then recordConn:Disconnect() end
        toast("Record Stopped")
        -- save otomatis
        local fname = (nameBox.Text~="" and nameBox.Text or "Track")..".lua"
        local data = "return {\n"
        for _,p in ipairs(recordData) do
            data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
        end
        data ..= "}"
        writefile("tracks/"..fname,data)
        toast("Track "..fname.." disimpan")
        recordData = {}
    else
        recording=true
        paused=false
        recordData={}
        recordConn = RunService.RenderStepped:Connect(function()
            if recording and not paused then
                table.insert(recordData,hrp.Position)
            end
        end)
        toast("Record ON")
    end
end)

-- PAUSE
buttons["⏸ Pause"].MouseButton1Click:Connect(function()
    if not recording then return end
    paused = not paused
    toast(paused and "Recording Pause" or "Recording Continue")
end)

-- LOOP
buttons["🔁 Loop Track"].MouseButton1Click:Connect(function()
    loopTrack = not loopTrack
    buttons["🔁 Loop Track"].Text = "🔁 Loop Track : "..(loopTrack and "ON" or "OFF")
    toast("Loop "..(loopTrack and "ON" or "OFF"))
end)

-- STOP PLAY
buttons["⏹ Stop Play"].MouseButton1Click:Connect(function()
    if playing and playConn then
        playing=false
        playConn:Disconnect()
        toast("Play Stopped")
    end
end)

-- PLAY SELECTED WITH SPEED AND ANIMATION
buttons["▶ Play Selected"].MouseButton1Click:Connect(function()
    local fname = nameBox.Text
    if fname=="" then return toast("Pilih track dulu") end
    local path = "tracks/"..fname
    if not path:find(".lua") then path = path..".lua" end
    if not pcall(function() return readfile(path) end) then return toast("Track tidak ada") end
    local success,data = pcall(function() return loadfile(path)() end)
    if not success then return toast("Gagal load track") end
    if playing and playConn then playConn:Disconnect() end
    playing=true
    local index=1
    playConn=RunService.RenderStepped:Connect(function(dt)
        if not playing then playConn:Disconnect() return end
        local pos = data[math.floor(index)]
        if pos then
            hrp.CFrame = CFrame.new(pos)
            index += speed/5 -- detail speed
        else
            if loopTrack then index=1
            else playing=false; playConn:Disconnect(); toast("Track selesai") end
        end
    end)
end)

-- HISTORY PANEL
buttons["📂 History"].MouseButton1Click:Connect(function()
    local histGui = Instance.new("ScreenGui",game.CoreGui)
    histGui.Name="AutoWalkHistory_"..math.random(1000,9999)
    local panel = Instance.new("Frame",histGui)
    panel.Size=UDim2.fromOffset(300,350)
    panel.Position=UDim2.fromScale(0.05,0.2)
    panel.BackgroundColor3=THEME.panel
    panel.Active=true
    panel.Draggable=true
    Instance.new("UICorner",panel).CornerRadius=UDim.new(0,16)
    local header=Instance.new("Frame",panel)
    header.Size=UDim2.new(1,0,0,28)
    header.BackgroundColor3=THEME.header
    Instance.new("UICorner",header).CornerRadius=UDim.new(0,16)
    local closeBtn=Instance.new("TextButton",header)
    closeBtn.Size=UDim2.new(0,28,1,0)
    closeBtn.Position=UDim2.new(1,-28,0,0)
    closeBtn.Text="✕"
    closeBtn.Font=Enum.Font.GothamBold
    closeBtn.TextColor3=THEME.text
    closeBtn.BackgroundTransparency=1
    closeBtn.MouseButton1Click:Connect(function() histGui:Destroy() end)
    local body=Instance.new("ScrollingFrame",panel)
    body.Size=UDim2.new(1,-10,1,-28)
    body.Position=UDim2.fromOffset(5,28)
    body.BackgroundTransparency=1
    body.ScrollingDirection=Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize=Enum.AutomaticSize.Y
    body.ScrollBarThickness=10
    local y=10
    for _,file in ipairs(listfiles("tracks")) do
        local name=file:match(".+/([^/]+)%.lua$")
        local b=addButton(body,name,y)
        local del=addButton(body,"❌",y)
        del.Size=UDim2.fromOffset(40,28)
        del.Position=UDim2.fromOffset(260,y)
        del.MouseButton1Click:Connect(function()
            delfile(file)
            b:Destroy()
            del:Destroy()
            toast("Track "..name.." dihapus")
        end)
        b.MouseButton1Click:Connect(function() nameBox.Text=name; toast("Track "..name.." dipilih") end)
        y+=35
    end
    body.CanvasSize=UDim2.new(0,0,0,y+20)
end)

--[CUSTOM FEATURES] <- Tambah kode fitur baru di bawah sini
