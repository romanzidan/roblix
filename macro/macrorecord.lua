--// Macro Recorder Presisi dengan Export/Import //--
if _G.MacroExecuted then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Macro",
        Text = "Script sudah berjalan!",
        Duration = 3
    })
    return
end
_G.MacroExecuted = true

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
local SAMPLE_MIN_INTERVAL = 0.06 -- 16 fps
local lastSampleTime = 0
local CHUNK_SIZE = 500

-- Fungsi untuk konversi CFrame ke table yang compact tapi presisi penuh
local function CFtoTable(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return {
        p = { x, y, z },                                    -- Position array
        r = { r00, r01, r02, r10, r11, r12, r20, r21, r22 } -- Rotation array
    }
end

-- Fungsi untuk konversi table ke CFrame
local function TableToCF(t)
    if t.p and t.r and #t.p == 3 and #t.r == 9 then
        return CFrame.new(
            t.p[1], t.p[2], t.p[3],
            t.r[1], t.r[2], t.r[3],
            t.r[4], t.r[5], t.r[6],
            t.r[7], t.r[8], t.r[9]
        )
    end
    return CFrame.new()
end

-- Fungsi untuk menghilangkan bagian diam dari rekaman
local function removeIdleParts(recordedSamples)
    if #recordedSamples < 3 then return recordedSamples end

    local filtered = {}
    local MIN_MOVEMENT = 0.1 -- Minimum movement threshold
    local lastValidIndex = 1

    -- Selalu tambah sample pertama
    table.insert(filtered, recordedSamples[1])

    for i = 2, #recordedSamples - 1 do
        local prevSample = recordedSamples[lastValidIndex]
        local currentSample = recordedSamples[i]
        local nextSample = recordedSamples[i + 1]

        -- Hitung pergerakan dari sample sebelumnya
        local movement = (currentSample.cf.Position - prevSample.cf.Position).Magnitude

        -- Jika ada pergerakan signifikan, atau ini adalah jump, atau pergerakan menuju titik berikutnya signifikan
        local nextMovement = (nextSample.cf.Position - currentSample.cf.Position).Magnitude

        if movement > MIN_MOVEMENT or nextMovement > MIN_MOVEMENT or currentSample.jump then
            table.insert(filtered, currentSample)
            lastValidIndex = i
        end
    end

    -- Selalu tambah sample terakhir
    table.insert(filtered, recordedSamples[#recordedSamples])

    return filtered
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

    -- Filter out idle parts setelah recording selesai
    if #samples > 0 then
        samples = removeIdleParts(samples)
    end

    updateStatus("⏹️ READY", Color3.fromRGB(100, 200, 100))
end

-- Toggle Record
local function toggleRecord()
    if recording then
        stopRecord()
    else
        startRecord()
    end
end

-- Playback
local function startPlayback()
    if #samples < 2 then
        updateStatus("❌ NO DATA", Color3.fromRGB(255, 150, 50))
        return
    end
    playing = true
    updateStatus("▶️ PLAYING", Color3.fromRGB(50, 150, 255))
end

local function stopPlayback()
    playing = false
    updateStatus("⏹️ READY", Color3.fromRGB(100, 200, 100))
end

-- Reset Playback ke awal
local function resetPlayback()
    playbackTime = 0
    playIndex = 1
    playing = false
    updateStatus("⏪ RESET", Color3.fromRGB(200, 200, 100))
end

-- Toggle Playback - LANJUTKAN dari posisi sebelumnya
local function togglePlayback()
    if playing then
        stopPlayback()
    else
        startPlayback() -- Lanjutkan dari posisi terakhir
    end
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

-- -- Playback loop dengan error handling
-- RunService.RenderStepped:Connect(function(dt)
--     if playing and hrp and hum and #samples > 1 then
--         playbackTime = playbackTime + dt * playSpeed

--         -- Cari sample index yang tepat
--         while playIndex < #samples and samples[playIndex + 1].time <= playbackTime do
--             playIndex = playIndex + 1
--         end

--         if playIndex >= #samples then
--             stopPlayback()
--             resetPlayback() -- Auto reset ketika selesai
--             return
--         end

--         local s1 = samples[playIndex]
--         local s2 = samples[playIndex + 1]

--         if not s1 or not s2 or not s1.cf or not s2.cf then
--             stopPlayback()
--             return
--         end

--         -- Interpolasi CFrame
--         local t = (playbackTime - s1.time) / (s2.time - s1.time)
--         t = math.clamp(t, 0, 1)

--         local cf = s1.cf:Lerp(s2.cf, t)
--         hrp.CFrame = cf

--         -- Movement handling
--         local dist = (s1.cf.Position - s2.cf.Position).Magnitude
--         if s2.jump then
--             hum:ChangeState(Enum.HumanoidStateType.Jumping)
--         elseif dist > 0.08 then
--             hum:Move((s2.cf.Position - s1.cf.Position).Unit, false)
--         else
--             hum:Move(Vector3.new(), false)
--         end
--     end
-- end)

-- MODIFIED: Pisahkan RenderStepped menjadi Heartbeat untuk pergerakan dan RenderStepped untuk animasi
RunService.Heartbeat:Connect(function(dt)
    if playing and hrp and hum and #samples > 1 then
        playbackTime = playbackTime + dt * playSpeed

        while playIndex < #samples and samples[playIndex + 1].time <= playbackTime do
            playIndex = playIndex + 1
        end

        if playing and playIndex < #samples then
            local s1 = samples[playIndex]
            local s2 = samples[playIndex + 1]

            if s1 and s2 and s1.cf and s2.cf then
                local cf = s1.cf:Lerp(s2.cf, math.clamp((playbackTime - s1.time) / (s2.time - s1.time), 0, 1))

                -- Apply CFrame ke HumanoidRootPart
                hrp.CFrame = cf
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if playing and hrp and hum and #samples > 1 and playIndex < #samples then
        local s1 = samples[playIndex]
        local s2 = samples[playIndex + 1]

        if s1 and s2 and s1.cf and s2.cf then
            local dist = (s1.cf.Position - s2.cf.Position).Magnitude

            -- Handle jumping state
            if s2.jump then
                if hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                -- Handle movement animation
            elseif dist > 0.08 then
                local moveDirection = (s2.cf.Position - s1.cf.Position).Unit
                hum:Move(moveDirection, false)
            else
                -- Stop movement animation when not moving
                hum:Move(Vector3.new(), false)
            end
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
Frame.Size = UDim2.new(0, 250, 0, 240) -- Diperbesar sedikit untuk tombol reset
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
        Frame:TweenSize(UDim2.new(0, 250, 0, 240), "Out", "Quad", 0.3, true)
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

-- Variables untuk toggle buttons
local recordToggleBtn
local playToggleBtn

-- Update tampilan tombol record berdasarkan status
local function updateRecordButton()
    if recording then
        recordToggleBtn.Text = "⏹️ STOP"
        recordToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    else
        recordToggleBtn.Text = "● RECORD"
        recordToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
end

-- Update tampilan tombol play berdasarkan status
local function updatePlayButton()
    if playing then
        playToggleBtn.Text = "⏸️ STOP"
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    else
        playToggleBtn.Text = "▶ PLAY"
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    end
end

-- Buttons dalam layout 2 kolom
-- Baris 1: Toggle Record (kiri) | Reset Playback (kanan)
recordToggleBtn = createBtn("● RECORD", UDim2.new(0.05, 0, 0, 5), UDim2.new(0.4, 0, 0, 26), function()
    toggleRecord()
    updateRecordButton()
end, Color3.fromRGB(220, 60, 60))

createBtn("⏪ RESET", UDim2.new(0.55, 0, 0, 5), UDim2.new(0.4, 0, 0, 26), function()
    resetPlayback()
    updatePlayButton()
end, Color3.fromRGB(150, 150, 100))

-- Baris 2: Toggle Play (kiri) | Clear Data (kanan)
playToggleBtn = createBtn("▶ PLAY", UDim2.new(0.05, 0, 0, 35), UDim2.new(0.4, 0, 0, 26), function()
    togglePlayback()
    updatePlayButton()
end, Color3.fromRGB(60, 180, 60))

createBtn("🗑️ CLEAR", UDim2.new(0.55, 0, 0, 35), UDim2.new(0.4, 0, 0, 26), function()
    samples = {}
    ExportBox.Text = ""
    resetPlayback()
    updateStatus("🗑️ CLEARED", Color3.fromRGB(255, 200, 50))
end, Color3.fromRGB(180, 100, 50))

-- Baris 3: Speed Control dengan tombol kiri-kanan
local speedLabel = Instance.new("TextLabel", ContentFrame)
speedLabel.Text = "Playback Speed:"
speedLabel.Size = UDim2.new(0.9, 0, 0, 15)
speedLabel.Position = UDim2.new(0.05, 0, 0, 65)
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Speed display
local speedDisplay = Instance.new("TextLabel", ContentFrame)
speedDisplay.Text = "1.0x"
speedDisplay.Size = UDim2.new(0.3, 0, 0, 22)
speedDisplay.Position = UDim2.new(0.35, 0, 0, 80)
speedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedDisplay.BackgroundTransparency = 0.2
speedDisplay.Font = Enum.Font.GothamBold
speedDisplay.TextSize = 11
speedDisplay.TextXAlignment = Enum.TextXAlignment.Center
local speedDisplayCorner = Instance.new("UICorner", speedDisplay)
speedDisplayCorner.CornerRadius = UDim.new(0, 6)

-- Tombol kurang speed
createBtn("◀", UDim2.new(0.05, 0, 0, 80), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = math.max(0.1, playSpeed - 0.1)
    hum.WalkSpeed = hum.WalkSpeed - 1
    speedDisplay.Text = string.format("%.1fx", playSpeed)
    updateStatus("🐢 SPEED " .. string.format("%.1fx", playSpeed), Color3.fromRGB(150, 200, 255))
end, Color3.fromRGB(80, 100, 180))

-- Tombol tambah speed
createBtn("▶", UDim2.new(0.7, 0, 0, 80), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = math.min(3.0, playSpeed + 0.1)
    hum.WalkSpeed = hum.WalkSpeed + 1
    speedDisplay.Text = string.format("%.1fx", playSpeed)
    updateStatus("🏃 SPEED " .. string.format("%.1fx", playSpeed), Color3.fromRGB(80, 160, 255))
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

-- Export function dengan kompresi minimal - DIPERBAIKI
-- Export function dengan sistem chunk
createBtn("📤 EXPORT", UDim2.new(0.05, 0, 0, 145), UDim2.new(0.4, 0, 0, 26), function()
    if #samples > 0 then
        -- Pastikan samples valid sebelum export
        local validSamples = {}
        for i, sample in ipairs(samples) do
            if sample and sample.cf and sample.time then
                table.insert(validSamples, sample)
            end
        end

        if #validSamples > 0 then
            -- Sistem chunk untuk data besar
            if #validSamples <= CHUNK_SIZE then
                -- Jika data kecil, export seperti biasa
                local exportData = {
                    v = 1, -- Version
                    d = {} -- Data samples
                }

                for i, sample in ipairs(validSamples) do
                    local exportSample = {
                        t = sample.time, -- Time full precision
                    }

                    -- Hanya tambah jump jika true
                    if sample.jump then
                        exportSample.j = true
                    end

                    -- Konversi CFrame ke table compact
                    if sample.cf then
                        exportSample.c = CFtoTable(sample.cf)
                    end

                    table.insert(exportData.d, exportSample)
                end

                local success, json = pcall(function()
                    return HttpService:JSONEncode(exportData)
                end)

                if success and json then
                    ExportBox.Text = json
                    updateStatus("📤 EXPORTED " .. #validSamples .. " samples", Color3.fromRGB(150, 200, 255))
                else
                    ExportBox.Text = "Export failed: JSON encoding error"
                    updateStatus("❌ EXPORT FAIL", Color3.fromRGB(255, 100, 100))
                end
            else
                -- Jika data besar, bagi menjadi chunk
                local totalChunks = math.ceil(#validSamples / CHUNK_SIZE)
                local currentChunk = 1

                -- Fungsi untuk export chunk tertentu
                local function exportChunk(chunkIndex)
                    local startIndex = (chunkIndex - 1) * CHUNK_SIZE + 1
                    local endIndex = math.min(chunkIndex * CHUNK_SIZE, #validSamples)

                    local chunkData = {
                        v = 1, -- Version
                        chunk = chunkIndex,
                        totalChunks = totalChunks,
                        totalSamples = #validSamples,
                        d = {} -- Data samples untuk chunk ini
                    }

                    for i = startIndex, endIndex do
                        local sample = validSamples[i]
                        local exportSample = {
                            t = sample.time, -- Time full precision
                        }

                        -- Hanya tambah jump jika true
                        if sample.jump then
                            exportSample.j = true
                        end

                        -- Konversi CFrame ke table compact
                        if sample.cf then
                            exportSample.c = CFtoTable(sample.cf)
                        end

                        table.insert(chunkData.d, exportSample)
                    end

                    local success, json = pcall(function()
                        return HttpService:JSONEncode(chunkData)
                    end)

                    if success and json then
                        ExportBox.Text = json
                        updateStatus(string.format("📤 CHUNK %d/%d (%d samples)", chunkIndex, totalChunks, #chunkData.d),
                            Color3.fromRGB(150, 200, 255))

                        -- Jika bukan chunk terakhir, tampilkan tombol next
                        if chunkIndex < totalChunks then
                            -- Hapus tombol next sebelumnya jika ada
                            local existingNextBtn = ContentFrame:FindFirstChild("NextChunkBtn")
                            if existingNextBtn then
                                existingNextBtn:Destroy()
                            end

                            -- Buat tombol next chunk
                            local nextChunkBtn = createBtn("➡️ NEXT CHUNK", UDim2.new(0.05, 0, 0, 175),
                                UDim2.new(0.9, 0, 0, 26), function()
                                    exportChunk(chunkIndex + 1)
                                    nextChunkBtn:Destroy()
                                end, Color3.fromRGB(100, 150, 200))
                            nextChunkBtn.Name = "NextChunkBtn"
                        else
                            -- Hapus tombol next jika ada
                            local existingNextBtn = ContentFrame:FindFirstChild("NextChunkBtn")
                            if existingNextBtn then
                                existingNextBtn:Destroy()
                            end
                            updateStatus("📤 ALL CHUNKS EXPORTED", Color3.fromRGB(100, 255, 100))
                        end
                    else
                        ExportBox.Text = "Export failed: JSON encoding error"
                        updateStatus("❌ EXPORT FAIL", Color3.fromRGB(255, 100, 100))
                    end
                end

                -- Mulai dengan chunk pertama
                exportChunk(1)
            end
        else
            ExportBox.Text = "No valid data to export"
            updateStatus("❌ NO VALID DATA", Color3.fromRGB(255, 150, 50))
        end
    else
        ExportBox.Text = "No data to export"
        updateStatus("❌ NO DATA", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(80, 120, 200))

-- Import function dengan presisi penuh
-- Import function dengan support chunk
createBtn("📥 IMPORT", UDim2.new(0.55, 0, 0, 145), UDim2.new(0.4, 0, 0, 26), function()
    local text = ExportBox.Text
    if text and text ~= "" and text ~= "No data to export" and text ~= "Invalid JSON!" and text ~= "Export failed!" and text ~= "No valid data to export" then
        local success, data = pcall(function()
            return HttpService:JSONDecode(text)
        end)

        if success and type(data) == "table" then
            local importData = {}

            -- Cek jika ini data chunked
            if data.chunk and data.totalChunks then
                -- Ini adalah chunk data
                if data.v and data.v == 1 and data.d and type(data.d) == "table" then
                    for i, sample in ipairs(data.d) do
                        local importSample = {
                            time = sample.t, -- Full precision
                            jump = sample.j or false
                        }

                        if sample.c then
                            importSample.cf = TableToCF(sample.c)
                        end

                        if importSample.cf then
                            table.insert(importData, importSample)
                        end
                    end

                    if #importData > 0 then
                        -- Simpan chunk data (untuk sekarang kita hanya menggunakan chunk yang diimport)
                        samples = importData
                        ExportBox.Text = "" -- Clear textbox setelah import sukses
                        resetPlayback()     -- Reset playback setelah import
                        updateStatus(
                            string.format("📥 IMPORTED chunk %d/%d (%d samples)", data.chunk, data.totalChunks,
                                #importData),
                            Color3.fromRGB(150, 255, 150))
                    else
                        ExportBox.Text = "No valid data found in chunk!"
                        updateStatus("❌ CHUNK IMPORT FAIL", Color3.fromRGB(255, 100, 100))
                    end
                else
                    ExportBox.Text = "Invalid chunk format!"
                    updateStatus("❌ CHUNK IMPORT FAIL", Color3.fromRGB(255, 100, 100))
                end
            else
                -- Format normal (non-chunked)
                if data.v and data.v == 1 then
                    -- Format baru
                    if data.d and type(data.d) == "table" then
                        for i, sample in ipairs(data.d) do
                            local importSample = {
                                time = sample.t, -- Full precision
                                jump = sample.j or false
                            }

                            if sample.c then
                                importSample.cf = TableToCF(sample.c)
                            end

                            if importSample.cf then
                                table.insert(importData, importSample)
                            end
                        end
                    end
                else
                    -- Format lama (backward compatibility)
                    for i, sample in ipairs(data) do
                        local importSample = {
                            time = sample.time,
                            jump = sample.jump or false
                        }

                        if sample.cf then
                            if type(sample.cf) == "table" then
                                importSample.cf = TableToCF(sample.cf)
                            else
                                -- Jika masih format CFrame langsung (shouldn't happen)
                                importSample.cf = sample.cf
                            end
                        end

                        if importSample.cf then
                            table.insert(importData, importSample)
                        end
                    end
                end

                if #importData > 0 then
                    samples = importData
                    ExportBox.Text = "" -- Clear textbox setelah import sukses
                    resetPlayback()     -- Reset playback setelah import
                    updateStatus("📥 IMPORTED " .. #importData .. " samples", Color3.fromRGB(150, 255, 150))
                else
                    ExportBox.Text = "No valid data found in JSON!"
                    updateStatus("❌ NO VALID DATA", Color3.fromRGB(255, 100, 100))
                end
            end
        else
            ExportBox.Text = "Invalid JSON format!"
            updateStatus("❌ IMPORT FAIL", Color3.fromRGB(255, 100, 100))
        end
    else
        updateStatus("❌ NO JSON", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(80, 200, 120))

-- Info label
local infoLabel = Instance.new("TextLabel", ContentFrame)
infoLabel.Text = "Samples: 0 | Time: 0s | Pos: 0%"
infoLabel.Size = UDim2.new(0.9, 0, 0, 15)
infoLabel.Position = UDim2.new(0.05, 0, 1, -20)
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 9
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Update info label dengan progress playback
spawn(function()
    while true do
        wait(0.5)
        if ContentFrame.Visible then
            local totalTime = 0
            local progress = 0
            if #samples > 0 then
                totalTime = samples[#samples].time
                if totalTime > 0 then
                    progress = (playbackTime / totalTime) * 100
                end
            end
            infoLabel.Text = string.format("Samples: %d | Time: %.1fs | Pos: %d%%", #samples, totalTime,
                math.floor(progress))
        end
    end
end)

-- Update button status secara real-time
RunService.Heartbeat:Connect(function()
    updateRecordButton()
    updatePlayButton()
end)
