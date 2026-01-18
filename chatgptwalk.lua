--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v6
 Theme : Dark Blue
 UI     : Scrollable, Draggable, Modular, History, Speed Control +/-, Minimize Logo Theo Ganteng
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

    -- MINIMIZE LOGO FIX
    local iconBtn
    minimize.MouseButton1Click:Connect(function()
        if panel.Visible then
            panel.Visible = false
            iconBtn = Instance.new("TextButton", game.CoreGui)
            iconBtn.Size = UDim2.fromOffset(120,30)
            iconBtn.Position = UDim2.fromScale(0.05,0.1)
            iconBtn.Text = "THEO GANTENG"
            iconBtn.Font = Enum.Font.GothamBold
            iconBtn.TextColor3 = Color3.fromRGB(255,255,255)
            iconBtn.BackgroundColor3 = THEME.panel
            Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0,12)
            -- DRAG
            local dragging, dragInput, dragStart, startPos = false,nil, nil, nil
            iconBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = iconBtn.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end)
            iconBtn.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Position - dragStart
                    iconBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
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

-- SPEED + / -
local speedInc = Instance.new("TextButton", body)
speedInc.Size = UDim2.fromOffset(40,30)
speedInc.Position = UDim2.fromOffset(30, 360)
speedInc.Text = "+"
speedInc.Font = Enum.Font.GothamBold
speedInc.TextColor3 = THEME.text
speedInc.BackgroundColor3 = THEME.header
Instance.new("UICorner", speedInc).CornerRadius = UDim.new(0,6)

local speedDec = Instance.new("TextButton", body)
speedDec.Size = UDim2.fromOffset(40,30)
speedDec.Position = UDim2.fromOffset(80, 360)
speedDec.Text = "-"
speedDec.Font = Enum.Font.GothamBold
speedDec.TextColor3 = THEME.text
speedDec.BackgroundColor3 = THEME.header
Instance.new("UICorner", speedDec).CornerRadius = UDim.new(0,6)

speedInc.MouseButton1Click:Connect(function()
    speed += 1
    toast("Speed "..speed.."x")
end)
speedDec.MouseButton1Click:Connect(function()
    speed -= 1
    if speed<1 then speed=1 end
    toast("Speed "..speed.."x")
end)

--[CUSTOM FEATURES] <- Tambah kode fitur baru di bawah sini
-- tinggal tambahin tombol/fungsi baru, panel scrollable tetep rapi
