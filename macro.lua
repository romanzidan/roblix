--// Macro Recorder Presisi dengan Export/Import //--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
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
local SAMPLE_MIN_INTERVAL = 0.06 -- Throttling untuk mencegah sample berlebih
local lastSampleTime = 0

-- Fungsi untuk konversi CFrame ke table
local function CFtoTable(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return {
        x = x,
        y = y,
        z = z,
        r00 = r00,
        r01 = r01,
        r02 = r02,
        r10 = r10,
        r11 = r11,
        r12 = r12,
        r20 = r20,
        r21 = r21,
        r22 = r22
    }
end

-- Fungsi untuk konversi table ke CFrame
local function TableToCF(t)
    return CFrame.new(
        t.x, t.y, t.z,
        t.r00, t.r01, t.r02,
        t.r10, t.r11, t.r12,
        t.r20, t.r21, t.r22
    )
end

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
    lastSampleTime = 0
    recording = true
    updateStatus("🔴 RECORDING", Color3.fromRGB(255, 50, 50))
end

local function stopRecord()
    recording = false
    updateStatus("⏹️ READY", Color3.fromRGB(100, 200, 100))
end

-- Playback
local function startPlayback()
    if #samples < 2 then
        updateStatus("❌ NO DATA", Color3.fromRGB(255, 150, 50))
        return
    end
    playing = true
    playbackTime = 0
    playIndex = 1
    updateStatus("▶️ PLAYING", Color3.fromRGB(50, 150, 255))
end

local function stopPlayback()
    playing = false
    updateStatus("⏹️ READY", Color3.fromRGB(100, 200, 100))
end

-- Fix playback function dengan error handling
local function safePlayback()
    if not hrp or not hum then
        updateStatus("❌ NO CHARACTER", Color3.fromRGB(255, 100, 100))
        return
    end

    if #samples < 2 then
        updateStatus("❌ NO DATA", Color3.fromRGB(255, 150, 50))
        return
    end

    -- Validasi samples data
    for i, sample in ipairs(samples) do
        if not sample.cf or not sample.time then
            updateStatus("❌ INVALID DATA", Color3.fromRGB(255, 100, 100))
            return
        end
    end

    playing = true
    playbackTime = 0
    playIndex = 1
    updateStatus("▶️ PLAYING", Color3.fromRGB(50, 150, 255))
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

-- Record loop dengan throttling
RunService.Heartbeat:Connect(function()
    if recording and hrp then
        local currentTime = tick() - startTime
        if currentTime - lastSampleTime >= SAMPLE_MIN_INTERVAL then
            table.insert(samples, {
                time = currentTime,
                cf = hrp.CFrame
            })
            lastSampleTime = currentTime
        end
    end
end)

-- Playback loop dengan error handling
RunService.RenderStepped:Connect(function(dt)
    if playing and hrp and hum and #samples > 1 then
        playbackTime += dt * playSpeed

        -- Cari sample index yang tepat
        while playIndex < #samples and samples[playIndex + 1].time <= playbackTime do
            playIndex += 1
        end

        if playIndex >= #samples then
            stopPlayback()
            return
        end

        local s1 = samples[playIndex]
        local s2 = samples[playIndex + 1]

        if not s1 or not s2 or not s1.cf or not s2.cf then
            stopPlayback()
            return
        end

        -- Interpolasi CFrame
        local t = (playbackTime - s1.time) / (s2.time - s1.time)
        t = math.clamp(t, 0, 1)

        local cf = s1.cf:Lerp(s2.cf, t)
        hrp.CFrame = cf

        -- Movement handling
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

-- Main Frame (lebih kecil untuk mobile)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 220)
Frame.Position = UDim2.new(0.02, 0, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Shadow effect
local Shadow = Instance.new("ImageLabel", Frame)
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- Title bar
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BackgroundTransparency = 0.1
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "🎯 Macro Recorder"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

-- Status Indicator
local StatusLabel = Instance.new("TextLabel", TitleBar)
StatusLabel.Text = "⏹️ READY"
StatusLabel.Size = UDim2.new(0, 80, 0, 20)
StatusLabel.Position = UDim2.new(1, -85, 0, 4)
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusLabel.BackgroundTransparency = 0.3
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
local StatusCorner = Instance.new("UICorner", StatusLabel)
StatusCorner.CornerRadius = UDim.new(0, 6)

function updateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color

    -- Animasi fade
    local tween = TweenService:Create(
        StatusLabel,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { TextColor3 = color }
    )
    tween:Play()
end

-- Minimize Button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "−"
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -25, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 6)

-- Container untuk konten (akan dihide saat minimize)
local ContentFrame = Instance.new("Frame", Frame)
ContentFrame.Size = UDim2.new(1, 0, 1, -28)
ContentFrame.Position = UDim2.new(0, 0, 0, 28)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Name = "ContentFrame"

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        -- Tutup frame jadi kecil
        Frame:TweenSize(UDim2.new(0, 250, 0, 28), "Out", "Quad", 0.3, true)
        -- Sembunyikan content frame dengan animasi
        ContentFrame.Visible = false
    else
        -- Kembalikan ukuran penuh
        Frame:TweenSize(UDim2.new(0, 250, 0, 220), "Out", "Quad", 0.3, true)
        -- Tampilkan content frame
        ContentFrame.Visible = true
    end
end)

-- Button factory dengan style modern
local function createBtn(name, position, size, callback, color)
    local btn = Instance.new("TextButton", ContentFrame)
    btn.Size = size or UDim2.new(0.4, 0, 0, 26)
    btn.Position = position
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    btn.BackgroundTransparency = 0.1
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.AutoButtonColor = true

    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 8)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        local tween = TweenService:Create(
            btn,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0 }
        )
        tween:Play()
    end)

    btn.MouseLeave:Connect(function()
        local tween = TweenService:Create(
            btn,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0.1 }
        )
        tween:Play()
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Buttons dalam layout 2 kolom
-- Baris 1: Start Record (kiri) | Stop Record (kanan)
createBtn("● Record", UDim2.new(0.05, 0, 0, 5), UDim2.new(0.4, 0, 0, 26), startRecord, Color3.fromRGB(200, 50, 50))
createBtn("■ Stop", UDim2.new(0.55, 0, 0, 5), UDim2.new(0.4, 0, 0, 26), stopRecord, Color3.fromRGB(100, 100, 100))

-- Baris 2: Play (kiri) | Stop Play (kanan)
createBtn("▶ Play", UDim2.new(0.05, 0, 0, 35), UDim2.new(0.4, 0, 0, 26), safePlayback, Color3.fromRGB(50, 150, 50))
createBtn("■ Stop", UDim2.new(0.55, 0, 0, 35), UDim2.new(0.4, 0, 0, 26), stopPlayback, Color3.fromRGB(100, 100, 100))

-- Baris 3: Speed Buttons
local speedLabel = Instance.new("TextLabel", ContentFrame)
speedLabel.Text = "Playback Speed:"
speedLabel.Size = UDim2.new(0.9, 0, 0, 15)
speedLabel.Position = UDim2.new(0.05, 0, 0, 65)
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Speed buttons dalam 3 kolom
createBtn("0.5x", UDim2.new(0.05, 0, 0, 80), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = 0.5
    updateStatus("🐢 SPEED 0.5x", Color3.fromRGB(150, 200, 255))
end, Color3.fromRGB(80, 100, 180))

createBtn("1.0x", UDim2.new(0.375, 0, 0, 80), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = 1.0
    updateStatus("🚶 SPEED 1.0x", Color3.fromRGB(100, 180, 255))
end, Color3.fromRGB(60, 120, 220))

createBtn("2.0x", UDim2.new(0.7, 0, 0, 80), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = 2.0
    updateStatus("🏃 SPEED 2.0x", Color3.fromRGB(80, 160, 255))
end, Color3.fromRGB(40, 140, 240))

-- Export/Import Box
local ExportBox = Instance.new("TextBox", ContentFrame)
ExportBox.Size = UDim2.new(0.9, 0, 0, 35)
ExportBox.Position = UDim2.new(0.05, 0, 0, 105)
ExportBox.Text = ""
ExportBox.PlaceholderText = "Paste JSON here or Copy from here"
ExportBox.TextWrapped = true
ExportBox.ClearTextOnFocus = false
ExportBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ExportBox.TextColor3 = Color3.new(1, 1, 1)
ExportBox.Font = Enum.Font.Code
ExportBox.TextSize = 10
ExportBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
local bc = Instance.new("UICorner", ExportBox)
bc.CornerRadius = UDim.new(0, 6)

-- Export/Import Buttons (2 kolom)
createBtn("📤 Export", UDim2.new(0.05, 0, 0, 145), UDim2.new(0.4, 0, 0, 26), function()
    if #samples > 0 then
        -- Konversi samples untuk export (CFrame -> Table)
        local exportData = {}
        for i, sample in ipairs(samples) do
            local exportSample = {
                time = sample.time,
                jump = sample.jump or false
            }
            -- Konversi CFrame ke table
            if sample.cf then
                exportSample.cf = CFtoTable(sample.cf)
            end
            table.insert(exportData, exportSample)
        end

        local success, json = pcall(function()
            return HttpService:JSONEncode(exportData)
        end)
        if success then
            ExportBox.Text = json
            updateStatus("📤 EXPORTED", Color3.fromRGB(150, 200, 255))
        else
            ExportBox.Text = "Export failed!"
            updateStatus("❌ EXPORT FAIL", Color3.fromRGB(255, 100, 100))
        end
    else
        ExportBox.Text = "No data to export"
        updateStatus("❌ NO DATA", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(80, 120, 200))

createBtn("📥 Import", UDim2.new(0.55, 0, 0, 145), UDim2.new(0.4, 0, 0, 26), function()
    local text = ExportBox.Text
    if text and text ~= "" and text ~= "No data to export" and text ~= "Invalid JSON!" and text ~= "Export failed!" then
        local success, data = pcall(function()
            return HttpService:JSONDecode(text)
        end)
        if success and type(data) == "table" and #data > 0 then
            -- Konversi data import (Table -> CFrame)
            local importData = {}
            for i, sample in ipairs(data) do
                local importSample = {
                    time = sample.time,
                    jump = sample.jump or false
                }
                -- Konversi table ke CFrame
                if sample.cf and type(sample.cf) == "table" then
                    importSample.cf = TableToCF(sample.cf)
                else
                    updateStatus("❌ INVALID CF", Color3.fromRGB(255, 100, 100))
                    return
                end
                table.insert(importData, importSample)
            end

            samples = importData
            updateStatus("📥 IMPORTED", Color3.fromRGB(150, 255, 150))
        else
            ExportBox.Text = "Invalid JSON!"
            updateStatus("❌ IMPORT FAIL", Color3.fromRGB(255, 100, 100))
        end
    else
        updateStatus("❌ NO JSON", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(80, 200, 120))

-- Info label
local infoLabel = Instance.new("TextLabel", ContentFrame)
infoLabel.Text = "Samples: 0 | Time: 0s"
infoLabel.Size = UDim2.new(0.9, 0, 0, 15)
infoLabel.Position = UDim2.new(0.05, 0, 1, -20)
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 9
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Update info label
spawn(function()
    while true do
        wait(0.5)
        if ContentFrame.Visible then
            local totalTime = 0
            if #samples > 0 then
                totalTime = samples[#samples].time
            end
            infoLabel.Text = string.format("Samples: %d | Time: %.1fs", #samples, totalTime)
        end
    end
end)
