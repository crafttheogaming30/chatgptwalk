--[[ 
 AUTO WALK TRACK SYSTEM - HP READY v6 + FLY
 Theme : Dark Blue
 UI     : Scrollable, Draggable, Modular, History, Speed Control +/-, Minimize Icon
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
local humanoid = char:WaitForChild("Humanoid")

-- FILE SYSTEM
if not isfolder("tracks") then makefolder("tracks") end

-- STATE
local recording, paused, playing, loopTrack = false,false,false,false
local speed = 40
local recordData, playConn = {}, nil

-- THEME
local THEME = {
    panel  = Color3.fromRGB(20,32,52),
    header = Color3.fromRGB(24,40,70),
    accent = Color3.fromRGB(80,140,255),
    text   = Color3.fromRGB(230,235,255)
}

-- TOAST
local function toast(text)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.3,0.07)
    frame.Position = UDim2.fromScale(0.35,0.9)
    frame.BackgroundColor3 = THEME.panel
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.fromScale(1,1)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    TweenService:Create(frame,TweenInfo.new(0.3), {Position = UDim2.fromScale(0.35,0.82)}):Play()
    task.delay(2,function() gui:Destroy() end)
end

-- PANEL
local function createPanel(title)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.fromOffset(300,360)
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
    titleLbl.Size = UDim2.new(1,-60,1,0)
    titleLbl.Position = UDim2.fromOffset(10,0)
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = THEME.text
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Left

    local body = Instance.new("ScrollingFrame", panel)
    body.Size = UDim2.new(1,-10,1,-35)
    body.Position = UDim2.fromOffset(5,35)
    body.BackgroundTransparency = 1
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.ScrollBarThickness = 8

    return gui, body
end

local gui, body = createPanel("Auto Walk Track Pro HP")

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

-- TRACK NAME
local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(250,28)
nameBox.Position = UDim2.fromOffset(20,10)
nameBox.PlaceholderText = "Nama Track"
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,10)

-- BUTTONS
local y = 50
local buttons = {}
local names = {
    "● Record","⏸ Pause","💾 Save Track","📂 History",
    "▶ Play Selected","🔁 Loop Track","⏹ Stop Play",
    "🕊 Fly"
}

for _,n in ipairs(names) do
    local b = addButton(body,n,y)
    buttons[n] = b
    y += 38
end
body.CanvasSize = UDim2.new(0,0,0,y+20)

-- =====================
-- FLY SYSTEM
-- =====================
local flying = false
local flySpeed = 20
local flyConn, lv, ao

local function stopMovement()
    recording = false
    playing = false
    if playConn then playConn:Disconnect() end
end

local function startFly()
    if flying then return end
    flying = true
    stopMovement()

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local att = Instance.new("Attachment", hrp)

    lv = Instance.new("LinearVelocity", hrp)
    lv.Attachment0 = att
    lv.MaxForce = math.huge

    ao = Instance.new("AlignOrientation", hrp)
    ao.Attachment0 = att
    ao.MaxTorque = math.huge
    ao.Responsiveness = 200

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        lv.VectorVelocity = cam.CFrame.LookVector * flySpeed
        ao.CFrame = cam.CFrame
    end)

    toast("Fly ON")
end

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect() end
    if lv then lv:Destroy() end
    if ao then ao:Destroy() end
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
    toast("Fly OFF")
end

-- FLY PANEL
local function openFlyPanel()
    local g = Instance.new("ScreenGui", game.CoreGui)
    local p = Instance.new("Frame", g)
    p.Size = UDim2.fromOffset(240,150)
    p.Position = UDim2.fromScale(0.6,0.3)
    p.BackgroundColor3 = THEME.panel
    p.Active = true
    p.Draggable = true
    Instance.new("UICorner", p).CornerRadius = UDim.new(0,14)

    local h = Instance.new("TextLabel", p)
    h.Size = UDim2.new(1,0,0,30)
    h.Text = "Fly Speed"
    h.TextColor3 = THEME.text
    h.BackgroundColor3 = THEME.header
    h.Font = Enum.Font.GothamBold

    local slider = Instance.new("Frame", p)
    slider.Size = UDim2.fromOffset(200,6)
    slider.Position = UDim2.fromOffset(20,70)
    slider.BackgroundColor3 = THEME.header

    local knob = Instance.new("Frame", slider)
    knob.Size = UDim2.fromOffset(14,14)
    knob.Position = UDim2.new(flySpeed/100,-7,-0.6,0)
    knob.BackgroundColor3 = THEME.accent
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            local c
            c = RunService.RenderStepped:Connect(function()
                local x = UserInputService:GetMouseLocation().X
                local r = math.clamp((x-slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
                flySpeed = math.clamp(math.floor(r*100),1,100)
                knob.Position = UDim2.new(flySpeed/100,-7,-0.6,0)
            end)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then c:Disconnect() end
            end)
        end
    end)
end

buttons["🕊 Fly"].MouseButton1Click:Connect(function()
    if not flying then
        startFly()
        openFlyPanel()
    else
        stopFly()
    end
end)
