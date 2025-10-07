--// Macro Data Inspector dengan Play Frame & Edit Frame Number //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Data storage
local macroData = {}
local currentFrame = 1
local totalFrames = 0
local inspecting = false
local originalJsonData = nil
local playingFrame = false
local playingRange = false
local rangeStartFrame = 1
local rangeEndFrame = 1

-- Variabel untuk smooth playback
local rangePlaybackTime = 0
local rangePlayIndex = 1
local rangePlaySpeed = 1.0

-- Fungsi konversi CFrame
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

local function CFtoTable(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return {
        p = { x, y, z },
        r = { r00, r01, r02, r10, r11, r12, r20, r21, r22 }
    }
end

-- Fungsi untuk memformat data frame menjadi string yang readable
local function formatFrameData(frameIndex)
    if not macroData[frameIndex] then return "No data" end

    local frame = macroData[frameIndex]
    local cf = frame.cf
    local pos = cf.Position
    local look = cf.LookVector

    local info = string.format(
        "Frame: %d/%d\n" ..
        "Time: %.3fs\n" ..
        "Position: [%.2f, %.2f, %.2f]\n" ..
        "Look: [%.2f, %.2f, %.2f]\n" ..
        "Jump: %s",
        frameIndex, totalFrames,
        frame.time,
        pos.X, pos.Y, pos.Z,
        look.X, look.Y, look.Z,
        tostring(frame.jump or false)
    )

    return info
end

-- Fungsi untuk mendapatkan JSON data frame tertentu
local function getFrameJSON(frameIndex)
    if not macroData[frameIndex] then return "{}" end

    local frame = macroData[frameIndex]
    local exportFrame = {
        t = frame.time,
        j = frame.jump or false,
        c = CFtoTable(frame.cf)
    }

    local success, json = pcall(function()
        return HttpService:JSONEncode(exportFrame, true)
    end)

    return success and json or "{}"
end

-- Fungsi untuk play frame tertentu
local function playCurrentFrame()
    if totalFrames == 0 or not macroData[currentFrame] then
        showStatus("❌ No frame to play", Color3.fromRGB(255, 100, 100))
        return
    end

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        showStatus("❌ No character found", Color3.fromRGB(255, 100, 100))
        return
    end

    playingFrame = true
    updatePlayButton()

    -- Teleport karakter ke posisi frame
    local frame = macroData[currentFrame]
    player.Character.HumanoidRootPart.CFrame = frame.cf

    -- Jika frame ini ada jump, trigger jump
    if frame.jump then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    showStatus("▶️ Playing Frame " .. currentFrame .. " (t=" .. string.format("%.3f", frame.time) .. "s)",
        Color3.fromRGB(100, 255, 100))

    -- Reset playing status setelah 1 detik
    spawn(function()
        wait(1)
        playingFrame = false
        updatePlayButton()
    end)
end

-- Fungsi untuk play rentang frame dengan interpolasi smooth
local function playFrameRange(startFrame, endFrame)
    if totalFrames == 0 then
        showStatus("❌ No data to play", Color3.fromRGB(255, 100, 100))
        return
    end

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        showStatus("❌ No character found", Color3.fromRGB(255, 100, 100))
        return
    end

    -- Validasi input
    startFrame = math.clamp(startFrame, 1, totalFrames)
    endFrame = math.clamp(endFrame, 1, totalFrames)

    if startFrame > endFrame then
        startFrame, endFrame = endFrame, startFrame
    end

    local totalRangeFrames = endFrame - startFrame + 1

    if totalRangeFrames <= 0 then
        showStatus("❌ Invalid frame range", Color3.fromRGB(255, 100, 100))
        return
    end

    -- Validasi data samples
    for i = startFrame, endFrame do
        if not macroData[i] or not macroData[i].cf or not macroData[i].time then
            showStatus("❌ Invalid data in frame " .. i, Color3.fromRGB(255, 100, 100))
            return
        end
    end

    playingRange = true
    rangePlaybackTime = 0
    rangePlayIndex = startFrame

    updatePlayButton()

    showStatus(string.format("▶️ Playing frames %d-%d (%d frames, %.2fs)...",
            startFrame, endFrame, totalRangeFrames, macroData[endFrame].time - macroData[startFrame].time),
        Color3.fromRGB(100, 255, 100))
end

-- Fungsi untuk stop play rentang frame
local function stopFrameRange()
    playingRange = false
    rangePlaybackTime = 0
    rangePlayIndex = 1
    updatePlayButton()
    showStatus("⏹️ Stopped frame range playback", Color3.fromRGB(255, 150, 50))
end

-- Fungsi hapus frame dengan PENYESUAIAN WAKTU
local function deleteCurrentFrame()
    if totalFrames == 0 then
        showStatus("❌ No frames to delete", Color3.fromRGB(255, 100, 100))
        return
    end

    -- Simpan info frame yang dihapus
    local deletedTime = macroData[currentFrame].time
    local deletedIndex = currentFrame

    if totalFrames == 1 then
        macroData = {}
        totalFrames = 0
        currentFrame = 1
        showStatus("🗑️ All frames deleted", Color3.fromRGB(255, 200, 100))
        return
    end

    -- Hitung waktu frame sebelum dan sesudah
    local prevTime = currentFrame > 1 and macroData[currentFrame - 1].time or 0
    local nextTime = currentFrame < totalFrames and macroData[currentFrame + 1].time or nil

    -- Hapus frame
    table.remove(macroData, currentFrame)
    totalFrames = #macroData

    -- SESUAIKAN WAKTU: Geser frame setelah yang dihapus
    if currentFrame <= totalFrames and nextTime then
        local timeToRemove = nextTime - deletedTime
        for i = currentFrame, totalFrames do
            macroData[i].time = macroData[i].time - timeToRemove
        end
    end

    -- Adjust current frame
    if currentFrame > totalFrames then
        currentFrame = totalFrames
    end

    -- Pastikan waktu tidak negatif
    if macroData[1].time < 0 then
        local adjust = -macroData[1].time
        for i = 1, totalFrames do
            macroData[i].time = macroData[i].time + adjust
        end
    end

    showStatus(
        "🗑️ Frame " .. deletedIndex .. " (t=" .. string.format("%.3f", deletedTime) ..
        "s) deleted. Time adjusted automatically. Total: " .. totalFrames .. " frames",
        Color3.fromRGB(255, 200, 100)
    )
end

-- Fungsi apply edit dari JSON
local function applyJSONEdit()
    if totalFrames == 0 then return false, "No data" end

    local jsonText = JsonDataBox.Text
    local success, newData = pcall(function()
        return HttpService:JSONDecode(jsonText)
    end)

    if success and type(newData) == "table" then
        -- Update frame data
        if newData.t then
            macroData[currentFrame].time = newData.t
        end
        if newData.j ~= nil then
            macroData[currentFrame].jump = newData.j
        end
        if newData.c then
            macroData[currentFrame].cf = TableToCF(newData.c)
        end

        -- Sort ulang setelah edit time
        table.sort(macroData, function(a, b) return a.time < b.time end)

        -- Find new index for current frame
        for i, frame in ipairs(macroData) do
            if frame == macroData[currentFrame] then
                currentFrame = i
                break
            end
        end

        updateDisplay()
        return true
    else
        return false, "Invalid JSON format"
    end
end

-- Fungsi export seluruh data
local function exportModifiedJSON()
    if totalFrames == 0 then return "{}" end

    local exportData = {
        v = 1,
        d = {}
    }

    for i, frame in ipairs(macroData) do
        local exportFrame = {
            t = frame.time,
            j = frame.jump or false,
            c = CFtoTable(frame.cf)
        }
        table.insert(exportData.d, exportFrame)
    end

    local success, json = pcall(function()
        return HttpService:JSONEncode(exportData, true)
    end)

    return success and json or "{}"
end

-- Load data dari JSON
local function loadMacroData(jsonText)
    local success, data = pcall(function()
        return HttpService:JSONDecode(jsonText)
    end)

    if not success then
        return false, "Invalid JSON format"
    end

    originalJsonData = jsonText
    macroData = {}

    if data.v and data.v == 1 then
        if data.d and type(data.d) == "table" then
            for i, sample in ipairs(data.d) do
                local frame = {
                    time = sample.t,
                    jump = sample.j or false
                }

                if sample.c then
                    frame.cf = TableToCF(sample.c)
                end

                if frame.cf then
                    table.insert(macroData, frame)
                end
            end
        end
    else
        for i, sample in ipairs(data) do
            local frame = {
                time = sample.time,
                jump = sample.jump or false
            }

            if sample.cf then
                if type(sample.cf) == "table" then
                    frame.cf = TableToCF(sample.cf)
                else
                    frame.cf = sample.cf
                end
            end

            if frame.cf then
                table.insert(macroData, frame)
            end
        end
    end

    totalFrames = #macroData
    currentFrame = 1
    rangeStartFrame = 1
    rangeEndFrame = math.max(1, totalFrames)

    -- Sort by time
    table.sort(macroData, function(a, b) return a.time < b.time end)

    return #macroData > 0, #macroData
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MacroInspector"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame (diperbesar untuk fitur baru)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 750) -- Diperbesar untuk fitur rentang frame
MainFrame.Position = UDim2.new(0.3, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Shadow
local Shadow = Instance.new("ImageLabel", MainFrame)
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

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BackgroundTransparency = 0.1
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "🔍 Macro Data Inspector - EDIT MODE"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Close Button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content Frame
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1

-- JSON Input Area
local JsonInputLabel = Instance.new("TextLabel", ContentFrame)
JsonInputLabel.Text = "Paste Macro JSON:"
JsonInputLabel.Size = UDim2.new(1, 0, 0, 20)
JsonInputLabel.Position = UDim2.new(0, 0, 0, 0)
JsonInputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JsonInputLabel.BackgroundTransparency = 1
JsonInputLabel.Font = Enum.Font.Gotham
JsonInputLabel.TextSize = 12
JsonInputLabel.TextXAlignment = Enum.TextXAlignment.Left

local JsonTextBox = Instance.new("TextBox", ContentFrame)
JsonTextBox.Size = UDim2.new(1, 0, 0, 80)
JsonTextBox.Position = UDim2.new(0, 0, 0, 20)
JsonTextBox.Text = ""
JsonTextBox.PlaceholderText = "Paste your macro JSON data here..."
JsonTextBox.TextWrapped = true
JsonTextBox.MultiLine = true
JsonTextBox.ClearTextOnFocus = false
JsonTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
JsonTextBox.TextColor3 = Color3.new(1, 1, 1)
JsonTextBox.Font = Enum.Font.Code
JsonTextBox.TextSize = 10
JsonTextBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
local JsonBoxCorner = Instance.new("UICorner", JsonTextBox)
JsonBoxCorner.CornerRadius = UDim.new(0, 6)

-- Load Button
local LoadBtn = Instance.new("TextButton", ContentFrame)
LoadBtn.Text = "📥 LOAD DATA"
LoadBtn.Size = UDim2.new(1, 0, 0, 30)
LoadBtn.Position = UDim2.new(0, 0, 0, 105)
LoadBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
LoadBtn.TextColor3 = Color3.new(1, 1, 1)
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.TextSize = 12
local LoadCorner = Instance.new("UICorner", LoadBtn)
LoadCorner.CornerRadius = UDim.new(0, 6)

-- Frame Info Display
local FrameInfoLabel = Instance.new("TextLabel", ContentFrame)
FrameInfoLabel.Text = "Frame Information:"
FrameInfoLabel.Size = UDim2.new(1, 0, 0, 20)
FrameInfoLabel.Position = UDim2.new(0, 0, 0, 140)
FrameInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FrameInfoLabel.BackgroundTransparency = 1
FrameInfoLabel.Font = Enum.Font.Gotham
FrameInfoLabel.TextSize = 12
FrameInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

local FrameInfoBox = Instance.new("TextLabel", ContentFrame)
FrameInfoBox.Size = UDim2.new(1, 0, 0, 80)
FrameInfoBox.Position = UDim2.new(0, 0, 0, 160)
FrameInfoBox.Text = "No data loaded"
FrameInfoBox.TextWrapped = true
FrameInfoBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FrameInfoBox.TextColor3 = Color3.new(1, 1, 1)
FrameInfoBox.Font = Enum.Font.Code
FrameInfoBox.TextSize = 11
FrameInfoBox.TextXAlignment = Enum.TextXAlignment.Left
FrameInfoBox.TextYAlignment = Enum.TextYAlignment.Top
local InfoBoxCorner = Instance.new("UICorner", FrameInfoBox)
InfoBoxCorner.CornerRadius = UDim.new(0, 6)

-- JSON Data Display
local JsonDataLabel = Instance.new("TextLabel", ContentFrame)
JsonDataLabel.Text = "Edit JSON Data for Current Frame:"
JsonDataLabel.Size = UDim2.new(1, 0, 0, 20)
JsonDataLabel.Position = UDim2.new(0, 0, 0, 245)
JsonDataLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JsonDataLabel.BackgroundTransparency = 1
JsonDataLabel.Font = Enum.Font.Gotham
JsonDataLabel.TextSize = 12
JsonDataLabel.TextXAlignment = Enum.TextXAlignment.Left

local JsonDataBox = Instance.new("TextBox", ContentFrame)
JsonDataBox.Size = UDim2.new(1, 0, 0, 100)
JsonDataBox.Position = UDim2.new(0, 0, 0, 265)
JsonDataBox.Text = "{}"
JsonDataBox.TextWrapped = true
JsonDataBox.MultiLine = true
JsonDataBox.ClearTextOnFocus = false
JsonDataBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
JsonDataBox.TextColor3 = Color3.fromRGB(220, 220, 150)
JsonDataBox.Font = Enum.Font.Code
JsonDataBox.TextSize = 10
JsonDataBox.TextXAlignment = Enum.TextXAlignment.Left
JsonDataBox.TextYAlignment = Enum.TextYAlignment.Top
local JsonDataCorner = Instance.new("UICorner", JsonDataBox)
JsonDataCorner.CornerRadius = UDim.new(0, 6)

-- Edit Controls Frame
local EditControls = Instance.new("Frame", ContentFrame)
EditControls.Size = UDim2.new(1, 0, 0, 30)
EditControls.Position = UDim2.new(0, 0, 0, 370)
EditControls.BackgroundTransparency = 1

-- Apply Edit Button
local ApplyEditBtn = Instance.new("TextButton", EditControls)
ApplyEditBtn.Text = "💾 APPLY EDIT"
ApplyEditBtn.Size = UDim2.new(0.48, 0, 1, 0)
ApplyEditBtn.Position = UDim2.new(0, 0, 0, 0)
ApplyEditBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
ApplyEditBtn.TextColor3 = Color3.new(1, 1, 1)
ApplyEditBtn.Font = Enum.Font.GothamBold
ApplyEditBtn.TextSize = 11
local ApplyCorner = Instance.new("UICorner", ApplyEditBtn)
ApplyCorner.CornerRadius = UDim.new(0, 6)

-- Delete Frame Button
local DeleteFrameBtn = Instance.new("TextButton", EditControls)
DeleteFrameBtn.Text = "🗑️ DELETE FRAME"
DeleteFrameBtn.Size = UDim2.new(0.48, 0, 1, 0)
DeleteFrameBtn.Position = UDim2.new(0.52, 0, 0, 0)
DeleteFrameBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
DeleteFrameBtn.TextColor3 = Color3.new(1, 1, 1)
DeleteFrameBtn.Font = Enum.Font.GothamBold
DeleteFrameBtn.TextSize = 11
local DeleteCorner = Instance.new("UICorner", DeleteFrameBtn)
DeleteCorner.CornerRadius = UDim.new(0, 6)

-- Frame Selection Controls
local FrameSelectFrame = Instance.new("Frame", ContentFrame)
FrameSelectFrame.Size = UDim2.new(1, 0, 0, 30)
FrameSelectFrame.Position = UDim2.new(0, 0, 0, 405)
FrameSelectFrame.BackgroundTransparency = 1

-- Frame Number Label
local FrameNumberLabel = Instance.new("TextLabel", FrameSelectFrame)
FrameNumberLabel.Text = "Frame:"
FrameNumberLabel.Size = UDim2.new(0.2, 0, 1, 0)
FrameNumberLabel.Position = UDim2.new(0, 0, 0, 0)
FrameNumberLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FrameNumberLabel.BackgroundTransparency = 1
FrameNumberLabel.Font = Enum.Font.Gotham
FrameNumberLabel.TextSize = 12
FrameNumberLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Frame Number TextBox
local FrameNumberBox = Instance.new("TextBox", FrameSelectFrame)
FrameNumberBox.Text = "1"
FrameNumberBox.Size = UDim2.new(0.2, 0, 1, 0)
FrameNumberBox.Position = UDim2.new(0.2, 0, 0, 0)
FrameNumberBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FrameNumberBox.TextColor3 = Color3.new(1, 1, 1)
FrameNumberBox.Font = Enum.Font.GothamBold
FrameNumberBox.TextSize = 12
FrameNumberBox.TextXAlignment = Enum.TextXAlignment.Center
FrameNumberBox.PlaceholderText = "1"
local FrameNumberCorner = Instance.new("UICorner", FrameNumberBox)
FrameNumberCorner.CornerRadius = UDim.new(0, 6)

-- Go To Frame Button
local GoToFrameBtn = Instance.new("TextButton", FrameSelectFrame)
GoToFrameBtn.Text = "GO"
GoToFrameBtn.Size = UDim2.new(0.15, 0, 1, 0)
GoToFrameBtn.Position = UDim2.new(0.41, 0, 0, 0)
GoToFrameBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 200)
GoToFrameBtn.TextColor3 = Color3.new(1, 1, 1)
GoToFrameBtn.Font = Enum.Font.GothamBold
GoToFrameBtn.TextSize = 11
local GoToCorner = Instance.new("UICorner", GoToFrameBtn)
GoToCorner.CornerRadius = UDim.new(0, 6)

-- Play Frame Button
local PlayFrameBtn = Instance.new("TextButton", FrameSelectFrame)
PlayFrameBtn.Text = "▶ PLAY FRAME"
PlayFrameBtn.Size = UDim2.new(0.4, 0, 1, 0)
PlayFrameBtn.Position = UDim2.new(0.57, 0, 0, 0)
PlayFrameBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
PlayFrameBtn.TextColor3 = Color3.new(1, 1, 1)
PlayFrameBtn.Font = Enum.Font.GothamBold
PlayFrameBtn.TextSize = 11
local PlayFrameCorner = Instance.new("UICorner", PlayFrameBtn)
PlayFrameCorner.CornerRadius = UDim.new(0, 6)

-- Range Play Controls
local RangePlayFrame = Instance.new("Frame", ContentFrame)
RangePlayFrame.Size = UDim2.new(1, 0, 0, 40)
RangePlayFrame.Position = UDim2.new(0, 0, 0, 440)
RangePlayFrame.BackgroundTransparency = 1

-- Range Start Label
local RangeStartLabel = Instance.new("TextLabel", RangePlayFrame)
RangeStartLabel.Text = "Start:"
RangeStartLabel.Size = UDim2.new(0.15, 0, 0, 20)
RangeStartLabel.Position = UDim2.new(0, 0, 0, 0)
RangeStartLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RangeStartLabel.BackgroundTransparency = 1
RangeStartLabel.Font = Enum.Font.Gotham
RangeStartLabel.TextSize = 11
RangeStartLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Range Start TextBox
local RangeStartBox = Instance.new("TextBox", RangePlayFrame)
RangeStartBox.Text = "1"
RangeStartBox.Size = UDim2.new(0.15, 0, 0, 20)
RangeStartBox.Position = UDim2.new(0.15, 0, 0, 0)
RangeStartBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RangeStartBox.TextColor3 = Color3.new(1, 1, 1)
RangeStartBox.Font = Enum.Font.Gotham
RangeStartBox.TextSize = 11
RangeStartBox.TextXAlignment = Enum.TextXAlignment.Center
local RangeStartCorner = Instance.new("UICorner", RangeStartBox)
RangeStartCorner.CornerRadius = UDim.new(0, 4)

-- Range End Label
local RangeEndLabel = Instance.new("TextLabel", RangePlayFrame)
RangeEndLabel.Text = "End:"
RangeEndLabel.Size = UDim2.new(0.15, 0, 0, 20)
RangeEndLabel.Position = UDim2.new(0.32, 0, 0, 0)
RangeEndLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RangeEndLabel.BackgroundTransparency = 1
RangeEndLabel.Font = Enum.Font.Gotham
RangeEndLabel.TextSize = 11
RangeEndLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Range End TextBox
local RangeEndBox = Instance.new("TextBox", RangePlayFrame)
RangeEndBox.Text = "1"
RangeEndBox.Size = UDim2.new(0.15, 0, 0, 20)
RangeEndBox.Position = UDim2.new(0.47, 0, 0, 0)
RangeEndBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RangeEndBox.TextColor3 = Color3.new(1, 1, 1)
RangeEndBox.Font = Enum.Font.Gotham
RangeEndBox.TextSize = 11
RangeEndBox.TextXAlignment = Enum.TextXAlignment.Center
local RangeEndCorner = Instance.new("UICorner", RangeEndBox)
RangeEndCorner.CornerRadius = UDim.new(0, 4)

-- Play Range Button
local PlayRangeBtn = Instance.new("TextButton", RangePlayFrame)
PlayRangeBtn.Text = "▶ PLAY RANGE"
PlayRangeBtn.Size = UDim2.new(0.35, 0, 0, 20)
PlayRangeBtn.Position = UDim2.new(0.64, 0, 0, 0)
PlayRangeBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
PlayRangeBtn.TextColor3 = Color3.new(1, 1, 1)
PlayRangeBtn.Font = Enum.Font.GothamBold
PlayRangeBtn.TextSize = 11
local PlayRangeCorner = Instance.new("UICorner", PlayRangeBtn)
PlayRangeCorner.CornerRadius = UDim.new(0, 6)

-- Stop Range Button
local StopRangeBtn = Instance.new("TextButton", RangePlayFrame)
StopRangeBtn.Text = "⏹️ STOP"
StopRangeBtn.Size = UDim2.new(0.35, 0, 0, 20)
StopRangeBtn.Position = UDim2.new(0.64, 0, 0, 20)
StopRangeBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
StopRangeBtn.TextColor3 = Color3.new(1, 1, 1)
StopRangeBtn.Font = Enum.Font.GothamBold
StopRangeBtn.TextSize = 11
local StopRangeCorner = Instance.new("UICorner", StopRangeBtn)
StopRangeCorner.CornerRadius = UDim.new(0, 6)

-- Set Range Button
local SetRangeBtn = Instance.new("TextButton", RangePlayFrame)
SetRangeBtn.Text = "SET RANGE"
SetRangeBtn.Size = UDim2.new(0.35, 0, 0, 20)
SetRangeBtn.Position = UDim2.new(0.64, 0, 0, 20)
SetRangeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
SetRangeBtn.TextColor3 = Color3.new(1, 1, 1)
SetRangeBtn.Font = Enum.Font.GothamBold
SetRangeBtn.TextSize = 11
local SetRangeCorner = Instance.new("UICorner", SetRangeBtn)
SetRangeCorner.CornerRadius = UDim.new(0, 6)

-- Speed Control untuk Range Play
local SpeedControlFrame = Instance.new("Frame", ContentFrame)
SpeedControlFrame.Size = UDim2.new(1, 0, 0, 20)
SpeedControlFrame.Position = UDim2.new(0, 0, 0, 485)
SpeedControlFrame.BackgroundTransparency = 1

local SpeedLabel = Instance.new("TextLabel", SpeedControlFrame)
SpeedLabel.Text = "Speed:"
SpeedLabel.Size = UDim2.new(0.15, 0, 1, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local SpeedDisplay = Instance.new("TextLabel", SpeedControlFrame)
SpeedDisplay.Text = "1.0x"
SpeedDisplay.Size = UDim2.new(0.15, 0, 1, 0)
SpeedDisplay.Position = UDim2.new(0.15, 0, 0, 0)
SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedDisplay.BackgroundTransparency = 0.2
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.TextSize = 11
SpeedDisplay.TextXAlignment = Enum.TextXAlignment.Center
local SpeedDisplayCorner = Instance.new("UICorner", SpeedDisplay)
SpeedDisplayCorner.CornerRadius = UDim.new(0, 4)

local SpeedDownBtn = Instance.new("TextButton", SpeedControlFrame)
SpeedDownBtn.Text = "◀"
SpeedDownBtn.Size = UDim2.new(0.1, 0, 1, 0)
SpeedDownBtn.Position = UDim2.new(0.31, 0, 0, 0)
SpeedDownBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 180)
SpeedDownBtn.TextColor3 = Color3.new(1, 1, 1)
SpeedDownBtn.Font = Enum.Font.GothamBold
SpeedDownBtn.TextSize = 11
local SpeedDownCorner = Instance.new("UICorner", SpeedDownBtn)
SpeedDownCorner.CornerRadius = UDim.new(0, 4)

local SpeedUpBtn = Instance.new("TextButton", SpeedControlFrame)
SpeedUpBtn.Text = "▶"
SpeedUpBtn.Size = UDim2.new(0.1, 0, 1, 0)
SpeedUpBtn.Position = UDim2.new(0.42, 0, 0, 0)
SpeedUpBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 240)
SpeedUpBtn.TextColor3 = Color3.new(1, 1, 1)
SpeedUpBtn.Font = Enum.Font.GothamBold
SpeedUpBtn.TextSize = 11
local SpeedUpCorner = Instance.new("UICorner", SpeedUpBtn)
SpeedUpCorner.CornerRadius = UDim.new(0, 4)

-- Navigation Controls
local NavFrame = Instance.new("Frame", ContentFrame)
NavFrame.Size = UDim2.new(1, 0, 0, 40)
NavFrame.Position = UDim2.new(0, 0, 0, 510)
NavFrame.BackgroundTransparency = 1

-- Frame Navigation Buttons
local function createNavBtn(text, position, size, callback, color)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Size = size or UDim2.new(0.2, 0, 0, 30)
    btn.Position = position
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = Color3.new(1, 1, 1)

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Navigation buttons
local FirstBtn = createNavBtn("⏮ First", UDim2.new(0, 0, 0, 0), UDim2.new(0.2, 0, 0, 30), function()
    if totalFrames > 0 then
        currentFrame = 1
        updateDisplay()
    end
end, Color3.fromRGB(80, 120, 200))

local PrevBtn = createNavBtn("◀ Prev", UDim2.new(0.21, 0, 0, 0), UDim2.new(0.2, 0, 0, 30), function()
    if totalFrames > 0 then
        currentFrame = math.max(1, currentFrame - 1)
        updateDisplay()
    end
end, Color3.fromRGB(80, 160, 200))

local NextBtn = createNavBtn("Next ▶", UDim2.new(0.59, 0, 0, 0), UDim2.new(0.2, 0, 0, 30), function()
    if totalFrames > 0 then
        currentFrame = math.min(totalFrames, currentFrame + 1)
        updateDisplay()
    end
end, Color3.fromRGB(80, 160, 200))

local LastBtn = createNavBtn("Last ⏭", UDim2.new(0.8, 0, 0, 0), UDim2.new(0.2, 0, 0, 30), function()
    if totalFrames > 0 then
        currentFrame = totalFrames
        updateDisplay()
    end
end, Color3.fromRGB(80, 120, 200))

-- Frame counter
local FrameCounter = Instance.new("TextLabel", NavFrame)
FrameCounter.Size = UDim2.new(0.35, 0, 0, 30)
FrameCounter.Position = UDim2.new(0.325, 0, 0, 0)
FrameCounter.Text = "0/0"
FrameCounter.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FrameCounter.TextColor3 = Color3.new(1, 1, 1)
FrameCounter.Font = Enum.Font.GothamBold
FrameCounter.TextSize = 12
local CounterCorner = Instance.new("UICorner", FrameCounter)
CounterCorner.CornerRadius = UDim.new(0, 6)

-- Export Controls
local ExportFrame = Instance.new("Frame", ContentFrame)
ExportFrame.Size = UDim2.new(1, 0, 0, 30)
ExportFrame.Position = UDim2.new(0, 0, 0, 555)
ExportFrame.BackgroundTransparency = 1

-- Export Button
local ExportBtn = Instance.new("TextButton", ExportFrame)
ExportBtn.Text = "📤 EXPORT MODIFIED JSON"
ExportBtn.Size = UDim2.new(0.6, 0, 1, 0)
ExportBtn.Position = UDim2.new(0, 0, 0, 0)
ExportBtn.BackgroundColor3 = Color3.fromRGB(160, 120, 80)
ExportBtn.TextColor3 = Color3.new(1, 1, 1)
ExportBtn.Font = Enum.Font.GothamBold
ExportBtn.TextSize = 11
local ExportCorner = Instance.new("UICorner", ExportBtn)
ExportCorner.CornerRadius = UDim.new(0, 6)

-- Copy to Clipboard Button
local CopyBtn = Instance.new("TextButton", ExportFrame)
CopyBtn.Text = "📋 COPY"
CopyBtn.Size = UDim2.new(0.38, 0, 1, 0)
CopyBtn.Position = UDim2.new(0.62, 0, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
CopyBtn.TextColor3 = Color3.new(1, 1, 1)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 11
local CopyCorner = Instance.new("UICorner", CopyBtn)
CopyCorner.CornerRadius = UDim.new(0, 6)

-- Toggle inspection mode
local InspectBtn = Instance.new("TextButton", ContentFrame)
InspectBtn.Text = "👁️ PREVIEW MODE: OFF"
InspectBtn.Size = UDim2.new(1, 0, 0, 30)
InspectBtn.Position = UDim2.new(0, 0, 0, 590)
InspectBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 80)
InspectBtn.TextColor3 = Color3.new(1, 1, 1)
InspectBtn.Font = Enum.Font.GothamBold
InspectBtn.TextSize = 12
local InspectCorner = Instance.new("UICorner", InspectBtn)
InspectCorner.CornerRadius = UDim.new(0, 6)

-- Status Message
local StatusLabel = Instance.new("TextLabel", ContentFrame)
StatusLabel.Text = "Ready"
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 625)
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Update display function
function updateDisplay()
    if totalFrames > 0 and macroData[currentFrame] then
        -- Update frame info
        FrameInfoBox.Text = formatFrameData(currentFrame)

        -- Update JSON data
        JsonDataBox.Text = getFrameJSON(currentFrame)

        -- Update counter
        FrameCounter.Text = string.format("%d/%d", currentFrame, totalFrames)

        -- Update frame number box
        FrameNumberBox.Text = tostring(currentFrame)

        -- Update range boxes
        RangeStartBox.Text = tostring(rangeStartFrame)
        RangeEndBox.Text = tostring(rangeEndFrame)

        -- Visualize position
        if inspecting and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = macroData[currentFrame].cf
        end
    else
        FrameInfoBox.Text = "No data loaded"
        JsonDataBox.Text = "{}"
        FrameCounter.Text = "0/0"
        FrameNumberBox.Text = "1"
        RangeStartBox.Text = "1"
        RangeEndBox.Text = "1"
    end

    updatePlayButton()
end

function updatePlayButton()
    if playingFrame then
        PlayFrameBtn.Text = "⏹️ STOPPING..."
        PlayFrameBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    else
        PlayFrameBtn.Text = "▶ PLAY FRAME"
        PlayFrameBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    end

    if playingRange then
        PlayRangeBtn.Text = "▶ PLAYING..."
        PlayRangeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
        StopRangeBtn.Visible = true
        SetRangeBtn.Visible = false
    else
        PlayRangeBtn.Text = "▶ PLAY RANGE"
        PlayRangeBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
        StopRangeBtn.Visible = false
        SetRangeBtn.Visible = true
    end
end

function showStatus(message, color)
    StatusLabel.Text = message
    StatusLabel.TextColor3 = color or Color3.fromRGB(180, 180, 180)

    -- Reset status after 3 seconds
    spawn(function()
        wait(3)
        if StatusLabel.Text == message then
            StatusLabel.Text = "Ready"
            StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end)
end

-- Toggle inspection mode
InspectBtn.MouseButton1Click:Connect(function()
    inspecting = not inspecting
    if inspecting then
        InspectBtn.Text = "👁️ PREVIEW MODE: ON"
        InspectBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
        if totalFrames > 0 then
            updateDisplay()
        end
        showStatus("Preview mode ON - Character will teleport to frame position", Color3.fromRGB(100, 255, 100))
    else
        InspectBtn.Text = "👁️ PREVIEW MODE: OFF"
        InspectBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 80)
        showStatus("Preview mode OFF", Color3.fromRGB(255, 100, 100))
    end
end)

-- Load data button functionality
LoadBtn.MouseButton1Click:Connect(function()
    local jsonText = JsonTextBox.Text
    if jsonText and jsonText ~= "" then
        local success, result = loadMacroData(jsonText)
        if success then
            updateDisplay()
            showStatus("✅ Data loaded successfully! " .. result .. " frames imported", Color3.fromRGB(100, 255, 100))
        else
            showStatus("❌ Error: " .. tostring(result), Color3.fromRGB(255, 100, 100))
        end
    else
        showStatus("❌ Please paste JSON data first", Color3.fromRGB(255, 150, 50))
    end
end)

-- Apply Edit functionality
ApplyEditBtn.MouseButton1Click:Connect(function()
    if totalFrames == 0 then
        showStatus("❌ No data to edit", Color3.fromRGB(255, 100, 100))
        return
    end

    local success, errorMsg = applyJSONEdit()
    if success then
        showStatus("✅ Frame " .. currentFrame .. " updated successfully", Color3.fromRGB(100, 255, 100))
    else
        showStatus("❌ Edit failed: " .. tostring(errorMsg), Color3.fromRGB(255, 100, 100))
    end
end)

-- Delete Frame functionality
DeleteFrameBtn.MouseButton1Click:Connect(function()
    deleteCurrentFrame()
    updateDisplay()
end)

-- Go to Frame functionality
GoToFrameBtn.MouseButton1Click:Connect(function()
    local frameNum = tonumber(FrameNumberBox.Text)
    if frameNum and totalFrames > 0 then
        frameNum = math.clamp(frameNum, 1, totalFrames)
        currentFrame = frameNum
        updateDisplay()
        showStatus("📋 Jumped to frame " .. currentFrame, Color3.fromRGB(150, 200, 255))
    else
        showStatus("❌ Invalid frame number", Color3.fromRGB(255, 100, 100))
    end
end)

-- Play Frame functionality
PlayFrameBtn.MouseButton1Click:Connect(function()
    playCurrentFrame()
end)

-- Play Range functionality
PlayRangeBtn.MouseButton1Click:Connect(function()
    if playingRange then
        stopFrameRange()
    else
        local startFrame = tonumber(RangeStartBox.Text) or rangeStartFrame
        local endFrame = tonumber(RangeEndBox.Text) or rangeEndFrame
        playFrameRange(startFrame, endFrame)
    end
end)

-- Stop Range functionality
StopRangeBtn.MouseButton1Click:Connect(function()
    stopFrameRange()
end)

-- Set Range functionality
SetRangeBtn.MouseButton1Click:Connect(function()
    if totalFrames > 0 then
        rangeStartFrame = currentFrame
        RangeStartBox.Text = tostring(rangeStartFrame)
        showStatus("📌 Range start set to frame " .. currentFrame, Color3.fromRGB(150, 200, 255))
    end
end)

-- Speed control functionality
SpeedDownBtn.MouseButton1Click:Connect(function()
    rangePlaySpeed = math.max(0.1, rangePlaySpeed - 0.1)
    SpeedDisplay.Text = string.format("%.1fx", rangePlaySpeed)
    showStatus("🐢 Speed: " .. string.format("%.1fx", rangePlaySpeed), Color3.fromRGB(150, 200, 255))
end)

SpeedUpBtn.MouseButton1Click:Connect(function()
    rangePlaySpeed = math.min(3.0, rangePlaySpeed + 0.1)
    SpeedDisplay.Text = string.format("%.1fx", rangePlaySpeed)
    showStatus("🏃 Speed: " .. string.format("%.1fx", rangePlaySpeed), Color3.fromRGB(80, 160, 255))
end)

-- Range End Box functionality
RangeEndBox.FocusLost:Connect(function()
    local endFrame = tonumber(RangeEndBox.Text)
    if endFrame and totalFrames > 0 then
        rangeEndFrame = math.clamp(endFrame, 1, totalFrames)
        RangeEndBox.Text = tostring(rangeEndFrame)
    end
end)

-- Range Start Box functionality
RangeStartBox.FocusLost:Connect(function()
    local startFrame = tonumber(RangeStartBox.Text)
    if startFrame and totalFrames > 0 then
        rangeStartFrame = math.clamp(startFrame, 1, totalFrames)
        RangeStartBox.Text = tostring(rangeStartFrame)
    end
end)

-- Export functionality
ExportBtn.MouseButton1Click:Connect(function()
    if totalFrames == 0 then
        showStatus("❌ No data to export", Color3.fromRGB(255, 100, 100))
        return
    end

    local exportedJson = exportModifiedJSON()
    JsonTextBox.Text = exportedJson
    showStatus("📤 JSON exported to input box (" .. totalFrames .. " frames)", Color3.fromRGB(100, 200, 255))
end)

-- Copy to clipboard functionality
CopyBtn.MouseButton1Click:Connect(function()
    if JsonTextBox.Text ~= "" then
        showStatus("📋 JSON copied to input box - Copy manually from there", Color3.fromRGB(200, 200, 100))
    else
        showStatus("❌ No JSON to copy", Color3.fromRGB(255, 100, 100))
    end
end)

-- Frame number box enter key support
FrameNumberBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local frameNum = tonumber(FrameNumberBox.Text)
        if frameNum and totalFrames > 0 then
            frameNum = math.clamp(frameNum, 1, totalFrames)
            currentFrame = frameNum
            updateDisplay()
        else
            FrameNumberBox.Text = tostring(currentFrame)
        end
    end
end)

-- SMOOTH PLAYBACK LOOP - Menggunakan teknik interpolasi seperti macro recorder
RunService.RenderStepped:Connect(function(dt)
    if playingRange and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChild("Humanoid")

        if not hrp or not hum then
            stopFrameRange()
            return
        end

        -- Update playback time dengan speed
        rangePlaybackTime = rangePlaybackTime + dt * rangePlaySpeed

        -- Cari sample index yang tepat
        local startFrame = tonumber(RangeStartBox.Text) or rangeStartFrame
        local endFrame = tonumber(RangeEndBox.Text) or rangeEndFrame

        while rangePlayIndex < endFrame and macroData[rangePlayIndex + 1] and
            macroData[rangePlayIndex + 1].time <= (macroData[startFrame].time + rangePlaybackTime) do
            rangePlayIndex = rangePlayIndex + 1
        end

        -- Check jika sudah mencapai akhir rentang
        if rangePlayIndex >= endFrame then
            stopFrameRange()
            showStatus("✅ Finished playing frame range", Color3.fromRGB(100, 255, 100))
            return
        end

        -- Dapatkan frame saat ini dan berikutnya untuk interpolasi
        local currentSample = macroData[rangePlayIndex]
        local nextSample = macroData[rangePlayIndex + 1]

        if not currentSample or not nextSample or not currentSample.cf or not nextSample.cf then
            stopFrameRange()
            return
        end

        -- Hitung interpolasi factor (t)
        local sampleStartTime = currentSample.time - macroData[startFrame].time
        local sampleEndTime = nextSample.time - macroData[startFrame].time
        local t = (rangePlaybackTime - sampleStartTime) / (sampleEndTime - sampleStartTime)
        t = math.clamp(t, 0, 1)

        -- Interpolasi CFrame dengan smooth lerp
        local cf = currentSample.cf:Lerp(nextSample.cf, t)
        hrp.CFrame = cf

        -- Update current frame display
        currentFrame = rangePlayIndex
        updateDisplay()

        -- Movement handling seperti macro recorder
        local dist = (currentSample.cf.Position - nextSample.cf.Position).Magnitude
        if nextSample.jump then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        elseif dist > 0.09 then
            hum:Move((nextSample.cf.Position - currentSample.cf.Position).Unit, false)
        else
            hum:Move(Vector3.new(), false)
        end
    end
end)

-- Initial update
updateDisplay()

print("Macro Data Inspector with Smooth Frame Range Playback loaded!")
print("Features: Load, Edit, Delete frames, Play Frame, Smooth Play Frame Range, Export")
print("Frame Range Play: Set start/end frames and click PLAY RANGE")
print("Smooth interpolation with accurate timing and movement handling!")
