--// Macro Recorder Presisi dengan Export/Import //--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local hrp, hum

-- Vars
local recording = false
local playing = false
local playSpeed = 1
local samples = {}
local startTime
local playbackTime = 0
local playIndex = 1

-- Setup character
local function setupChar(char)
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end
player.CharacterAdded:Connect(setupChar)
if player.Character then setupChar(player.Character) end

-- Record
local function startRecord()
    samples = {}
    startTime = tick()
    recording = true
end
local function stopRecord()
    recording = false
end

-- Playback
local function startPlayback()
    if #samples < 2 then return end
    playing = true
    playbackTime = 0
    playIndex = 1
end
local function stopPlayback()
    playing = false
end

-- Record Jump
UserInputService.JumpRequest:Connect(function()
    if recording and hrp then
        table.insert(samples, {
            time = tick() - startTime,
            cf = hrp.CFrame,
            jump = true
        })
    end
end)

-- Record loop
RunService.Heartbeat:Connect(function()
    if recording and hrp then
        table.insert(samples, {
            time = tick() - startTime,
            cf = hrp.CFrame
        })
    end
end)

-- Playback loop
RunService.RenderStepped:Connect(function(dt)
    if playing and hrp and #samples > 1 then
        playbackTime += dt * playSpeed

        while playIndex < #samples and samples[playIndex + 1].time <= playbackTime do
            playIndex += 1
        end

        local s1 = samples[playIndex]
        local s2 = samples[playIndex + 1]
        if not s1 or not s2 then
            stopPlayback()
            return
        end

        local t = (playbackTime - s1.time) / (s2.time - s1.time)
        local cf = s1.cf:Lerp(s2.cf, t)
        hrp.CFrame = cf

        local dist = (s1.cf.Position - s2.cf.Position).Magnitude
        if s2.jump then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        elseif dist > 0.05 then
            hum:Move((s2.cf.Position - s1.cf.Position).Unit, false)
        else
            hum:Move(Vector3.new(), false)
        end
    end
end)

-------------------------------------------------------
-- GUI Modern
-------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MacroGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 280)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.25
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Title bar
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BackgroundTransparency = 0.15
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "Macro Recorder"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Minimize
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 1, 0)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 6)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        -- Tutup frame jadi kecil
        Frame:TweenSize(UDim2.new(0, 280, 0, 30), "Out", "Quad", 0.3, true)
        -- Sembunyikan semua child kecuali TitleBar
        for _, v in pairs(Frame:GetChildren()) do
            if v ~= TitleBar then
                v.Visible = false
            end
        end
    else
        -- Kembalikan ukuran penuh
        Frame:TweenSize(UDim2.new(0, 280, 0, 280), "Out", "Quad", 0.3, true)
        -- Tampilkan lagi semua
        for _, v in pairs(Frame:GetChildren()) do
            v.Visible = true
        end
        TitleBar.Visible = true -- pastikan titlebar tetap muncul
    end
end)

-- Button factory
local function createBtn(name, y, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.8, 0, 0, 30)
    btn.Position = UDim2.new(0.1, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BackgroundTransparency = 0.1
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

createBtn("Start Record", 40, startRecord)
createBtn("Stop Record", 80, stopRecord)
createBtn("Play", 120, startPlayback)
createBtn("Stop Play", 160, stopPlayback)

-- Export/Import Box
local ExportBox = Instance.new("TextBox", Frame)
ExportBox.Size = UDim2.new(0.8, 0, 0, 40)
ExportBox.Position = UDim2.new(0.1, 0, 0, 200)
ExportBox.Text = ""
ExportBox.PlaceholderText = "Paste JSON here or Copy from here"
ExportBox.TextWrapped = true
ExportBox.ClearTextOnFocus = false
ExportBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ExportBox.TextColor3 = Color3.new(1, 1, 1)
ExportBox.Font = Enum.Font.Code
ExportBox.TextSize = 12
local bc = Instance.new("UICorner", ExportBox)
bc.CornerRadius = UDim.new(0, 6)

createBtn("Export", 250, function()
    if #samples > 0 then
        ExportBox.Text = HttpService:JSONEncode(samples)
    else
        ExportBox.Text = "No data to export"
    end
end)

createBtn("Import", 290, function()
    local success, data = pcall(function()
        return HttpService:JSONDecode(ExportBox.Text)
    end)
    if success and type(data) == "table" then
        samples = data
    else
        ExportBox.Text = "Invalid JSON!"
    end
end)

-- Playback speed slider
local sliderFrame = Instance.new("Frame", Frame)
sliderFrame.Size = UDim2.new(0.8, 0, 0, 10)
sliderFrame.Position = UDim2.new(0.1, 0, 1, -20)
sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderFrame.BackgroundTransparency = 0.2
local sCorner = Instance.new("UICorner", sliderFrame)
sCorner.CornerRadius = UDim.new(0, 5)

local sliderBtn = Instance.new("Frame", sliderFrame)
sliderBtn.Size = UDim2.new(0.1, 0, 1, 0)
sliderBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
local sbCorner = Instance.new("UICorner", sliderBtn)
sbCorner.CornerRadius = UDim.new(0, 5)

local dragging = false
sliderBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
sliderBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((i.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        sliderBtn.Size = UDim2.new(0, math.max(10, rel * sliderFrame.AbsoluteSize.X), 1, 0)
        playSpeed = 0.5 + rel * 2.5 -- speed range 0.5x - 3x
    end
end)
