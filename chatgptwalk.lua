--[[ 
 AUTO WALK TRACK SYSTEM - HP SAFE FINAL
 Author : ChatGPT x Teyoo
 Executor : Delta Android
]]--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- FILE
if not isfolder("tracks") then makefolder("tracks") end

-- STATE
local recording=false
local paused=false
local playing=false
local loopTrack=false
local fly=false
local speed=20
local recordData={}
local con=nil

-- THEME
local C_BG = Color3.fromRGB(20,30,45)
local C_HD = Color3.fromRGB(30,45,70)
local C_TX = Color3.fromRGB(230,230,230)
local C_AC = Color3.fromRGB(90,150,255)

-- GUI ROOT
local gui = Instance.new("ScreenGui")
gui.Name="AutoWalk_HP"
gui.Parent=player:WaitForChild("PlayerGui")

-- PANEL
local panel=Instance.new("Frame",gui)
panel.Size=UDim2.fromOffset(300,380)
panel.Position=UDim2.fromScale(0.05,0.2)
panel.BackgroundColor3=C_BG
panel.BorderSizePixel=0
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,14)

-- HEADER
local header=Instance.new("Frame",panel)
header.Size=UDim2.new(1,0,0,36)
header.BackgroundColor3=C_HD
Instance.new("UICorner",header).CornerRadius=UDim.new(0,14)

local title=Instance.new("TextLabel",header)
title.Size=UDim2.new(1,-80,1,0)
title.Position=UDim2.fromOffset(10,0)
title.Text="Auto Walk Track PRO"
title.TextColor3=C_TX
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.BackgroundTransparency=1
title.TextXAlignment=Left

-- CLOSE
local close=Instance.new("TextButton",header)
close.Size=UDim2.fromOffset(30,30)
close.Position=UDim2.fromOffset(260,3)
close.Text="X"
close.TextColor3=C_TX
close.Font=Enum.Font.GothamBold
close.TextSize=14
close.BackgroundTransparency=1
close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- MINIMIZE
local mini=Instance.new("TextButton",header)
mini.Size=UDim2.fromOffset(30,30)
mini.Position=UDim2.fromOffset(230,3)
mini.Text="-"
mini.TextColor3=C_TX
mini.Font=Enum.Font.GothamBold
mini.TextSize=18
mini.BackgroundTransparency=1

-- BODY
local body=Instance.new("ScrollingFrame",panel)
body.Position=UDim2.fromOffset(0,40)
body.Size=UDim2.new(1,0,1,-40)
body.CanvasSize=UDim2.new(0,0,0,520)
body.ScrollBarThickness=6
body.BackgroundTransparency=1

-- LIST
local layout=Instance.new("UIListLayout",body)
layout.Padding=UDim.new(0,8)

-- MINIMIZE LOGIC
local minimized=false
mini.MouseButton1Click:Connect(function()
	minimized=not minimized
	body.Visible=not minimized
	panel.Size=minimized and UDim2.fromOffset(300,40) or UDim2.fromOffset(300,380)
end)

-- DRAG HP SAFE
do
	local dragging=false
	local offset
	header.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch then
			dragging=true
			offset=i.Position-panel.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType==Enum.UserInputType.Touch then
			panel.Position=UDim2.fromOffset(i.Position.X-offset.X,i.Position.Y-offset.Y)
		end
	end)
	UIS.InputEnded:Connect(function()
		dragging=false
	end)
end

-- HELPER
local function button(text)
	local b=Instance.new("TextButton")
	b.Size=UDim2.fromOffset(260,32)
	b.Text=text
	b.Font=Enum.Font.GothamMedium
	b.TextSize=13
	b.TextColor3=C_TX
	b.BackgroundColor3=C_HD
	b.BorderSizePixel=0
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
	b.Parent=body
	return b
end

-- TRACK NAME
local nameBox=Instance.new("TextBox",body)
nameBox.Size=UDim2.fromOffset(260,30)
nameBox.PlaceholderText="Nama Track"
nameBox.Text=""
nameBox.TextColor3=C_TX
nameBox.Font=Enum.Font.Gotham
nameBox.TextSize=13
nameBox.BackgroundColor3=C_HD
Instance.new("UICorner",nameBox).CornerRadius=UDim.new(0,10)

-- BUTTONS
local bRecord=button("● RECORD")
local bPause=button("⏸ PAUSE")
local bPlay=button("▶ PLAY")
local bStop=button("⏹ STOP")
local bLoop=button("🔁 LOOP : OFF")
local bFly=button("🕊️ FLY : OFF")
local bSave=button("💾 SAVE TRACK")

-- RECORD
bRecord.MouseButton1Click:Connect(function()
	recording=not recording
	if recording then
		recordData={}
		con=RunService.RenderStepped:Connect(function()
			if not paused then
				table.insert(recordData,hrp.Position)
			end
		end)
	else
		if con then con:Disconnect() end
	end
end)

bPause.MouseButton1Click:Connect(function()
	paused=not paused
end)

-- SAVE
bSave.MouseButton1Click:Connect(function()
	if #recordData==0 then return end
	local fname=(nameBox.Text~="" and nameBox.Text or "track")..".lua"
	local s="return {\n"
	for _,p in ipairs(recordData) do
		s..=string.format("Vector3.new(%f,%f,%f),\n",p.X,p.Y,p.Z)
	end
	s..="}"
	writefile("tracks/"..fname,s)
end)

-- PLAY
bPlay.MouseButton1Click:Connect(function()
	local f="tracks/"..nameBox.Text..".lua"
	if not pcall(function() readfile(f) end) then return end
	local data=loadfile(f)()
	local i=1
	playing=true
	con=RunService.RenderStepped:Connect(function()
		if not playing then con:Disconnect() return end
		local p=data[i]
		if p then
			hrp.CFrame=CFrame.new(p)
			i+=1
		else
			if loopTrack then i=1 else playing=false end
		end
	end)
end)

bStop.MouseButton1Click:Connect(function()
	playing=false
end)

bLoop.MouseButton1Click:Connect(function()
	loopTrack=not loopTrack
	bLoop.Text="🔁 LOOP : "..(loopTrack and "ON" or "OFF")
end)

-- FLY
local flyConn
bFly.MouseButton1Click:Connect(function()
	fly=not fly
	bFly.Text="🕊️ FLY : "..(fly and "ON" or "OFF")
	if fly then
		flyConn=RunService.RenderStepped:Connect(function()
			hrp.Velocity=Vector3.new(0,40,0)
		end)
	else
		if flyConn then flyConn:Disconnect() end
	end
end)
