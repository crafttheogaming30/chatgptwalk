--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v6 FULL
 Theme : Dark Blue
 UI     : Scrollable, Draggable, Modular, History, Speed Control +/-, Minimize Logo Theo Ganteng
 Author : ChatGPT + Teyoo Fix
]]--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
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
    panel.Size = UDim2.fromOffset(300,350)
    panel.Position = UDim2.fromScale(0.05,0.2)
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1,0,0,30)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(0.7,0,1,0)
    titleLbl.Position = UDim2.fromScale(0.05,0)
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = THEME.text
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local minimize = Instance.new("TextButton", header)
    minimize.Size = UDim2.new(0,28,1,0)
    minimize.Position = UDim2.new(0.8,0,0,0)
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
    body.CanvasSize = UDim2.new(0,0,0,0)
    body.ScrollBarThickness = 10
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- MINIMIZE FUNCTION
    local iconBtn
    local dragging = false
    local dragOffset = Vector2.new()
    minimize.MouseButton1Click:Connect(function()
        if panel.Visible then
            panel.Visible = false
            iconBtn = Instance.new("TextButton", game.CoreGui)
            iconBtn.Size = UDim2.fromOffset(150,30)
            iconBtn.Position = UDim2.fromScale(0.05,0.1)
            iconBtn.Text = "THEO GANTENG"
            iconBtn.Font = Enum.Font.GothamBold
            iconBtn.TextColor3 = Color3.fromRGB(255,255,255)
            iconBtn.BackgroundColor3 = THEME.panel
            Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0,12)
            -- Dragging icon
            iconBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragOffset = input.Position - iconBtn.AbsolutePosition
                end
            end)
            iconBtn.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                    iconBtn.Position = UDim2.fromOffset(input.Position.X - dragOffset.X,input.Position.Y - dragOffset.Y)
                end
            end)
            iconBtn.InputEnded:Connect(function(input)
                dragging = false
            end)
            iconBtn.MouseButton1Click:Connect(function()
                panel.Visible = true
                iconBtn:Destroy()
            end)
        end
    end)

    return gui, body
end

local mainGui, body = createPanel("Auto Walk Track Pro HP")

-- FUNCTION TO ADD BUTTON
local function addButton(parent,text,y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.fromOffset(250,30)
    btn.Position = UDim2.fromOffset(20,y)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = THEME.text
    btn.BackgroundColor3 = THEME.header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

-- CREATE MAIN BUTTONS
local buttons, y = {},10
local buttonNames = {"● Record","⏸ Pause","💾 Save Track","📂 History","▶ Play Selected","🔁 Loop Track","⏹ Stop Play"}
for _,name in ipairs(buttonNames) do
    local b = addButton(body,name,y)
    table.insert(buttons,b)
    y += 45
end
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- TRACK NAME BOX
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(250,30)
nameBox.Position = UDim2.fromOffset(20,y)
nameBox.PlaceholderText = "Nama Track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,10)
y += 45
body.CanvasSize = UDim2.new(0,0,0,y+50)

-- SPEED SLIDER
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(250,10)
sliderBg.Position = UDim2.fromOffset(20,y)
sliderBg.BackgroundColor3 = THEME.header
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,5)
local knob = Instance.new("Frame", sliderBg)
knob.Size = UDim2.fromOffset(16,16)
knob.Position = UDim2.new(speed/50, -8, -0.3, 0)
knob.BackgroundColor3 = THEME.accent
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- SPEED +/- BUTTONS
local plusBtn = addButton(body,"+",y+15)
local minusBtn = addButton(body,"-",y+15)
plusBtn.Size = UDim2.fromOffset(40,25)
plusBtn.Position = UDim2.fromOffset(200,y+15)
minusBtn.Size = UDim2.fromOffset(40,25)
minusBtn.Position = UDim2.fromOffset(150,y+15)

plusBtn.MouseButton1Click:Connect(function()
    speed = math.min(speed+1,50)
    knob.Position = UDim2.new(speed/50, -8, -0.3, 0)
end)
minusBtn.MouseButton1Click:Connect(function()
    speed = math.max(speed-1,1)
    knob.Position = UDim2.new(speed/50, -8, -0.3, 0)
end)

-- SLIDER INPUT
knob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        local moveConn
        moveConn = RunService.RenderStepped:Connect(function()
            local x = math.clamp((UserInputService:GetMouseLocation().X - sliderBg.AbsolutePosition.X)/sliderBg.AbsoluteSize.X,0,1)
            knob.Position = UDim2.new(x,-8,-0.3,0)
            speed = math.floor(1 + x*49)
        end)
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                moveConn:Disconnect()
                toast("Speed : "..speed.."x")
            end
        end)
    end
end)

--[CUSTOM FEATURES] <- Tambah kode fitur baru di bawah sini
-- Contoh: 
-- local myBtn = addButton(body,\"Fitur Baru\")
-- myBtn.MouseButton1Click:Connect(function()
--     print(\"Fitur baru jalan!\")
-- end)
