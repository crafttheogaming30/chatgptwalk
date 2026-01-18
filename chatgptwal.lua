--[[ 
 AUTO WALK TRACK SYSTEM - PRO v1
 Theme : Dark Blue
 UI     : Premium (Rounded, Gotham, Slider)
 Author : Custom Build
]]--

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

---------------- PLAYER ----------------
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

---------------- FILE SYSTEM ----------------
if not isfolder("tracks") then
    makefolder("tracks")
end

---------------- STATE ----------------
local recording = false
local paused = false
local playing = false
local loopTrack = false
local speed = 40

local recordData = {}
local playData = {}
local playIndex = 1
local recordConn, playConn

------------------------------------------------
-- 🎨 THEME
------------------------------------------------
local THEME = {
    bg      = Color3.fromRGB(14,22,35),
    panel   = Color3.fromRGB(20,32,52),
    header  = Color3.fromRGB(24,40,70),
    accent  = Color3.fromRGB(80,140,255),
    text    = Color3.fromRGB(230,235,255),
    muted   = Color3.fromRGB(150,160,190)
}

------------------------------------------------
-- 🔔 CUSTOM TOAST NOTIFICATION
------------------------------------------------
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

    TweenService:Create(frame,TweenInfo.new(0.3),
        {Position = UDim2.fromScale(0.35,0.82)}
    ):Play()

    task.delay(2,function()
        TweenService:Create(frame,TweenInfo.new(0.3),
            {BackgroundTransparency = 1}
        ):Play()
        task.wait(0.3)
        gui:Destroy()
    end)
end

------------------------------------------------
-- 🧱 PANEL BUILDER
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoWalkPro"

local function createPanel(title, size, pos)
    local panel = Instance.new("Frame", gui)
    panel.Size = size
    panel.Position = pos
    panel.BackgroundColor3 = THEME.panel
    panel.Active = true
    panel.Draggable = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)

    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1,0,0,36)
    header.BackgroundColor3 = THEME.header
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,18)

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(0.7,0,1,0)
    titleLbl.Position = UDim2.fromScale(0.05,0)
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 15
    titleLbl.TextColor3 = THEME.text
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Left

    local min = Instance.new("TextButton", header)
    min.Size = UDim2.new(0,32,1,0)
    min.Position = UDim2.new(1,-64,0,0)
    min.Text = "—"
    min.Font = Enum.Font.GothamBold
    min.TextColor3 = THEME.text
    min.BackgroundTransparency = 1

    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0,32,1,0)
    close.Position = UDim2.new(1,-32,0,0)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextColor3 = THEME.text
    close.BackgroundTransparency = 1

    local body = Instance.new("Frame", panel)
    body.Position = UDim2.new(0,0,0,36)
    body.Size = UDim2.new(1,0,1,-36)
    body.BackgroundTransparency = 1

    min.MouseButton1Click:Connect(function()
        body.Visible = not body.Visible
    end)

    close.MouseButton1Click:Connect(function()
        panel.Visible = false
        toast("Panel ditutup")
    end)

    return panel, body
end

------------------------------------------------
-- 🎮 MAIN PANEL
------------------------------------------------
local main, body = createPanel(
    "Auto Walk Track Pro",
    UDim2.fromOffset(360,420),
    UDim2.fromScale(0.05,0.2)
)

------------------------------------------------
-- 🔘 BUTTON HELPER
------------------------------------------------
local function button(text, y)
    local b = Instance.new("TextButton", body)
    b.Size = UDim2.fromOffset(300,38)
    b.Position = UDim2.fromOffset(30,y)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 14
    b.TextColor3 = THEME.text
    b.BackgroundColor3 = THEME.header
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
    return b
end

------------------------------------------------
-- ⏺ RECORD CONTROLS
------------------------------------------------
local recordBtn = button("● Record",20)
local pauseBtn  = button("⏸ Pause",70)
local stopBtn   = button("■ Stop",120)

local nameBox = Instance.new("TextBox", body)
nameBox.Size = UDim2.fromOffset(300,36)
nameBox.Position = UDim2.fromOffset(30,175)
nameBox.PlaceholderText = "Nama track"
nameBox.Font = Enum.Font.Gotham
nameBox.TextColor3 = THEME.text
nameBox.BackgroundColor3 = THEME.header
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,12)

local saveBtn = button("💾 Save Track",225)
local historyBtn = button("📂 History",275)

------------------------------------------------
-- 🎚 SPEED SLIDER
------------------------------------------------
local sliderBg = Instance.new("Frame", body)
sliderBg.Size = UDim2.fromOffset(300,10)
sliderBg.Position = UDim2.fromOffset(30,340)
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
            local x = math.clamp(
                (game:GetService("UserInputService"):GetMouseLocation().X - sliderBg.AbsolutePosition.X)
                / sliderBg.AbsoluteSize.X, 0,1
            )
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

------------------------------------------------
-- 🧠 LOGIC (RECORD / PLAY)
------------------------------------------------
recordBtn.MouseButton1Click:Connect(function()
    if recording then return end
    recording = true
    paused = false
    recordData = {}

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
    if #recordData == 0 or nameBox.Text == "" then return end
    local data = "return {\n"
    for _,p in ipairs(recordData) do
        data ..= string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
    end
    data ..= "}"
    writefile("tracks/"..nameBox.Text..".lua", data)
    toast("Track "..nameBox.Text.." disimpan")
end)

------------------------------------------------
-- ▶ PLAY ENGINE (SMOOTH)
------------------------------------------------
local function playTrack(data)
    if playing then return end
    playing = true
    playIndex = 1
    toast("Track dimainkan")

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
end
