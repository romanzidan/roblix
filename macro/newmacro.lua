--// Macro Recorder dengan Dropdown System //--
-- Cegah execute berulang
if _G.MacroLoaderExecuted then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Macro Player",
        Text = "Script sudah berjalan!",
        Duration = 3
    })
    return
end
_G.MacroLoaderExecuted = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local hrp, hum

-- Vars
local playing = false
local playSpeed = 1
local samples = {}
local playbackTime = 0
local playIndex = 1

-- Macro Library System - LOCAL STORAGE
local macroLibrary = {}
local currentMacros = {}
local selectedMacro = nil
local playingAll = false
local currentPlayIndex = 1

-- Local Storage untuk macros yang sudah diload
local loadedMacrosCache = {} -- Format: { ["yahayuk"] = {macros}, ["atin"] = {macros} }

-- Cache untuk dropdown yang sudah dibuka
local mapDropdownOpen = false
local mapDropdownFrame = nil

-- Fungsi untuk konversi CFrame ke table yang compact tapi presisi penuh
local function CFtoTable(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return {
        p = { x, y, z },
        r = { r00, r01, r02, r10, r11, r12, r20, r21, r22 }
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

-- Setup character
local function setupChar(char)
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end
player.CharacterAdded:Connect(setupChar)
if player.Character then setupChar(player.Character) end

-- Playback functions - FIXED ANIMATION
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
    hum:Move(Vector3.new(), false) -- Stop movement
    updateStatus("⏹️ READY", Color3.fromRGB(100, 200, 100))
end

local function resetPlayback()
    playbackTime = 0
    playIndex = 1
    playing = false
    hum:Move(Vector3.new(), false) -- Stop movement
    updateStatus("⏪ RESET", Color3.fromRGB(200, 200, 100))
end

local function togglePlayback()
    if playing then
        stopPlayback()
    else
        startPlayback()
    end
end

-- Playback loop - FIXED ANIMATION
local function checkPlaybackCompletion()
    if playing and #samples > 0 and playIndex >= #samples then
        stopPlayback()

        if playingAll and #currentMacros > 0 then
            spawn(function()
                wait(0.5) -- Jeda sebelum lanjut
                currentPlayIndex = currentPlayIndex + 1
                if currentPlayIndex <= #currentMacros then
                    local nextMacro = currentMacros[currentPlayIndex]
                    if nextMacro then
                        samples = nextMacro.samples
                        selectedMacro = nextMacro
                        playbackTime = 0
                        playIndex = 1
                        updateStatus(
                            "🎯 PLAYING " ..
                            nextMacro.displayName .. " (" .. currentPlayIndex .. "/" .. #currentMacros .. ")",
                            Color3.fromRGB(50, 200, 255))
                        startPlayback()
                    end
                else
                    playingAll = false
                    currentPlayIndex = 1
                    updateStatus("✅ ALL DONE", Color3.fromRGB(100, 255, 100))
                end
            end)
        else
            resetPlayback()
        end
    end
end

-- Playback loop dengan RenderStepped - FIXED
RunService.RenderStepped:Connect(function(dt)
    if playing and hrp and hum and #samples > 1 then
        playbackTime = playbackTime + dt * playSpeed

        -- Cari sample index yang tepat
        while playIndex < #samples and samples[playIndex + 1].time <= playbackTime do
            playIndex = playIndex + 1
        end

        checkPlaybackCompletion()

        if playing and playIndex < #samples then
            local s1 = samples[playIndex]
            local s2 = samples[playIndex + 1]

            if s1 and s2 and s1.cf and s2.cf then
                -- Interpolasi CFrame
                local t = (playbackTime - s1.time) / (s2.time - s1.time)
                t = math.clamp(t, 0, 1)

                local cf = s1.cf:Lerp(s2.cf, t)
                hrp.CFrame = cf

                -- Movement handling
                local dist = (s1.cf.Position - s2.cf.Position).Magnitude
                if s2.jump then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                elseif dist > 0.085 then
                    hum:Move((s2.cf.Position - s1.cf.Position).Unit, false)
                else
                    hum:Move(Vector3.new(), false)
                end
            end
        end
    end
end)

-------------------------------------------------------
-- Macro Library System - WITH LOCAL CACHE
-------------------------------------------------------

-- Fungsi untuk load dropdown data
local function loadDropdownData()
    if #macroLibrary > 0 then
        return true -- Data sudah diload
    end

    updateStatus("📥 LOADING MAPS...", Color3.fromRGB(150, 200, 255))

    local success, dropdownJson = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/dropdown.json",
            true)
    end)

    if success and dropdownJson then
        local success2, dropdownData = pcall(function()
            return HttpService:JSONDecode(dropdownJson)
        end)

        if success2 and dropdownData and type(dropdownData) == "table" then
            macroLibrary = dropdownData
            updateStatus("🗺️ LOADED " .. #dropdownData .. " maps", Color3.fromRGB(100, 200, 255))
            return true
        end
    end

    updateStatus("❌ FAILED LOAD MAPS", Color3.fromRGB(255, 100, 100))
    return false
end

-- Fungsi untuk load macro data dengan CACHE SYSTEM
local function loadMacroData(params, cpCount)
    -- Cek cache dulu
    if loadedMacrosCache[params] then
        updateStatus("📂 LOADED FROM CACHE: " .. params, Color3.fromRGB(100, 200, 255))
        return loadedMacrosCache[params]
    end

    local loadedMacros = {}

    updateStatus("🔄 LOADING " .. params .. " (" .. cpCount .. " CP)...", Color3.fromRGB(150, 200, 255))

    for i = 1, cpCount do
        local url = string.format("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/%s/%d.json",
            params, i)

        local success, macroData = pcall(function()
            local jsonData = game:HttpGet(url, true)
            return HttpService:JSONDecode(jsonData)
        end)

        if success and macroData then
            local convertedSamples = {}

            -- Process macro data
            if macroData.v and macroData.v == 1 then
                -- Format baru
                for _, sample in ipairs(macroData.d) do
                    local convertedSample = {
                        time = sample.t,
                        jump = sample.j or false
                    }

                    if sample.c then
                        convertedSample.cf = TableToCF(sample.c)
                    end

                    table.insert(convertedSamples, convertedSample)
                end
            else
                -- Format lama
                for _, sample in ipairs(macroData) do
                    local convertedSample = {
                        time = sample.time,
                        jump = sample.jump or false
                    }

                    if sample.cf then
                        if type(sample.cf) == "table" then
                            convertedSample.cf = TableToCF(sample.cf)
                        else
                            convertedSample.cf = sample.cf
                        end
                    end

                    table.insert(convertedSamples, convertedSample)
                end
            end

            -- Create macro object
            local macro = {
                name = params .. "_CP" .. i,
                displayName = "CP " .. i,
                samples = convertedSamples,
                params = params,
                cpIndex = i,
                sampleCount = #convertedSamples
            }

            table.insert(loadedMacros, macro)

            -- Update status progress
            updateStatus("📥 " .. params .. " CP" .. i .. " (" .. #loadedMacros .. "/" .. cpCount .. ")",
                Color3.fromRGB(150, 255, 150))
        else
            updateStatus("❌ FAILED " .. params .. " CP" .. i, Color3.fromRGB(255, 150, 100))
        end

        -- Small delay to prevent rate limiting
        wait(0.05)
    end

    -- Sort by CP index untuk memastikan urutan benar
    table.sort(loadedMacros, function(a, b)
        return a.cpIndex < b.cpIndex
    end)

    -- Simpan ke cache
    loadedMacrosCache[params] = loadedMacros
    updateStatus("💾 CACHED: " .. params .. " (" .. #loadedMacros .. " macros)", Color3.fromRGB(100, 255, 200))

    return loadedMacros
end

-- Fungsi untuk load dari cache atau load baru
local function loadOrGetMacros(params, cpCount)
    if loadedMacrosCache[params] then
        return loadedMacrosCache[params]
    else
        return loadMacroData(params, cpCount)
    end
end

-- Fungsi untuk play semua macro yang sudah diload
local function playAllMacros()
    if #currentMacros == 0 then
        updateStatus("❌ NO MACROS LOADED", Color3.fromRGB(255, 150, 50))
        return
    end

    playingAll = true
    currentPlayIndex = 1

    local firstMacro = currentMacros[1]
    if firstMacro then
        samples = firstMacro.samples
        selectedMacro = firstMacro
        playbackTime = 0
        playIndex = 1
        updateStatus("🔄 PLAYING ALL (" .. currentPlayIndex .. "/" .. #currentMacros .. ")", Color3.fromRGB(100, 200, 255))
        startPlayback()
    end
end

-------------------------------------------------------
-- GUI Modern - WITH VISIBLE MACRO LIST (MOBILE FRIENDLY)
-------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MacroGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame - DIKECILKAN untuk mobile
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 350)
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
Title.Text = "🎯 Macro Player"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

-- Status Indicator - DIKECILKAN
local StatusLabel = Instance.new("TextLabel", TitleBar)
StatusLabel.Text = "⏹️ READY"
StatusLabel.Size = UDim2.new(0, 60, 0, 20)
StatusLabel.Position = UDim2.new(1, -85, 0, 4)
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusLabel.BackgroundTransparency = 0.3
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 9
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
local StatusCorner = Instance.new("UICorner", StatusLabel)
StatusCorner.CornerRadius = UDim.new(0, 6)

function updateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color
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

-- Container untuk konten
local ContentFrame = Instance.new("Frame", Frame)
ContentFrame.Size = UDim2.new(1, 0, 1, -28)
ContentFrame.Position = UDim2.new(0, 0, 0, 28)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Name = "ContentFrame"

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Frame:TweenSize(UDim2.new(0, 260, 0, 28), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = false
        closeDropdowns()
    else
        Frame:TweenSize(UDim2.new(0, 260, 0, 350), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = true
    end
end)

-- Button factory
local function createBtn(name, position, size, callback, color)
    local btn = Instance.new("TextButton", ContentFrame)
    btn.Size = size or UDim2.new(0.45, 0, 0, 26)
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

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Variables untuk toggle buttons
local playToggleBtn

-- Update tampilan tombol play
local function updatePlayButton()
    if playing then
        playToggleBtn.Text = "⏸️ STOP"
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    else
        playToggleBtn.Text = "▶ PLAY"
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    end
end

local MapDropdown = Instance.new("TextButton", ContentFrame)
MapDropdown.Size = UDim2.new(0.9, 0, 0, 26)
MapDropdown.Position = UDim2.new(0.05, 0, 0, 20)
MapDropdown.Text = "Data MAP masih loading"
MapDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MapDropdown.TextColor3 = Color3.new(1, 1, 1)
MapDropdown.Font = Enum.Font.Gotham
MapDropdown.TextSize = 11
local MapCorner = Instance.new("UICorner", MapDropdown)
MapCorner.CornerRadius = UDim.new(0, 6)

-- Macro List Frame - DIKECILKAN untuk mobile
local macroListFrame = Instance.new("Frame", ContentFrame)
macroListFrame.Size = UDim2.new(0.9, 0, 0, 120)
macroListFrame.Position = UDim2.new(0.05, 0, 0, 80)
macroListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
macroListFrame.BackgroundTransparency = 0.1
macroListFrame.BorderSizePixel = 0
local macroListCorner = Instance.new("UICorner", macroListFrame)
macroListCorner.CornerRadius = UDim.new(0, 8)

-- Border untuk visibility
local macroListBorder = Instance.new("UIStroke", macroListFrame)
macroListBorder.Color = Color3.fromRGB(80, 80, 80)
macroListBorder.Thickness = 2

local macroListLabel = Instance.new("TextLabel", macroListFrame)
macroListLabel.Text = "Daftar Checkpoint: (0)"
macroListLabel.Size = UDim2.new(1, -10, 0, 20)
macroListLabel.Position = UDim2.new(0, 8, 0, 5)
macroListLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
macroListLabel.BackgroundTransparency = 1
macroListLabel.Font = Enum.Font.GothamBold
macroListLabel.TextSize = 11
macroListLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Scroll frame untuk macro list - DIKECILKAN
local macroScrollFrame = Instance.new("ScrollingFrame", macroListFrame)
macroScrollFrame.Size = UDim2.new(1, -10, 1, -30)
macroScrollFrame.Position = UDim2.new(0, 5, 0, 25)
macroScrollFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
macroScrollFrame.BackgroundTransparency = 0
macroScrollFrame.BorderSizePixel = 0
macroScrollFrame.ScrollBarThickness = 6
macroScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
macroScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local macroScrollCorner = Instance.new("UICorner", macroScrollFrame)
macroScrollCorner.CornerRadius = UDim.new(0, 6)

local macroListLayout = Instance.new("UIListLayout", macroScrollFrame)
macroListLayout.Padding = UDim.new(0, 3)
macroListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Function untuk update macro list - FIXED VERSION
local function updateMacroList()
    -- Update label
    macroListLabel.Text = "Loaded Macros: (" .. #currentMacros .. ")"

    -- Clear existing list
    for _, child in ipairs(macroScrollFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if #currentMacros == 0 then
        local noDataLabel = Instance.new("TextLabel", macroScrollFrame)
        noDataLabel.Size = UDim2.new(1, 0, 0, 30)
        noDataLabel.Text = "No macros loaded\nClick 'Load Macros' to load"
        noDataLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        noDataLabel.BackgroundTransparency = 1
        noDataLabel.Font = Enum.Font.Gotham
        noDataLabel.TextSize = 10
        noDataLabel.TextWrapped = true
        noDataLabel.TextYAlignment = Enum.TextYAlignment.Center
        noDataLabel.LayoutOrder = 0
        return
    end

    -- Add macros to list
    for i, macro in ipairs(currentMacros) do
        local macroBtn = Instance.new("TextButton")
        macroBtn.Size = UDim2.new(0.98, 0, 0, 26)
        macroBtn.LayoutOrder = i
        macroBtn.Text = "  " .. macro.displayName .. " • " .. macro.sampleCount .. " samples"
        macroBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        macroBtn.TextColor3 = Color3.new(1, 1, 1)
        macroBtn.Font = Enum.Font.Gotham
        macroBtn.TextSize = 10
        macroBtn.TextXAlignment = Enum.TextXAlignment.Left
        macroBtn.AutoButtonColor = true
        macroBtn.Parent = macroScrollFrame

        local macroBtnCorner = Instance.new("UICorner", macroBtn)
        macroBtnCorner.CornerRadius = UDim.new(0, 6)

        -- Hover effect
        macroBtn.MouseEnter:Connect(function()
            if macroBtn.BackgroundColor3 ~= Color3.fromRGB(80, 120, 200) then
                macroBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
            end
        end)

        macroBtn.MouseLeave:Connect(function()
            if macroBtn.BackgroundColor3 ~= Color3.fromRGB(80, 120, 200) then
                macroBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            end
        end)

        macroBtn.MouseButton1Click:Connect(function()
            selectedMacro = macro
            samples = macro.samples
            -- Hanya reset playback jika tidak sedang bermain
            if not playing then
                resetPlayback()
            end
            updateStatus("🎯 SELECTED " .. macro.displayName, Color3.fromRGB(150, 200, 255))

            -- Highlight selected
            for _, btn in ipairs(macroScrollFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    if btn == macroBtn then
                        btn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
                    else
                        btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
                    end
                end
            end
        end)
    end

    -- Force update canvas size
    macroScrollFrame.CanvasSize = UDim2.new(0, 0, 0, macroListLayout.AbsoluteContentSize.Y)
end

-- Load button dengan CACHE SYSTEM - FIXED VERSION
createBtn("📥 LOAD MAP", UDim2.new(0.05, 0, 0, 50), UDim2.new(0.9, 0, 0, 26), function()
    if MapDropdown.Text ~= "Data MAP masih loading" and MapDropdown.Text ~= "Pilih MAP..." then
        local selectedParams = nil
        local selectedCP = 6

        for _, map in ipairs(macroLibrary) do
            if MapDropdown.Text == map.nama then
                selectedParams = map.params
                selectedCP = map.cp or 6
                break
            end
        end

        if selectedParams then
            updateStatus("📚 LOADING MACROS...", Color3.fromRGB(150, 200, 255))

            -- Load macros di background thread
            spawn(function()
                local loadedMacros = loadOrGetMacros(selectedParams, selectedCP)

                -- Update di main thread dengan data yang sudah diload
                spawn(function()
                    currentMacros = loadedMacros
                    updateMacroList()

                    if #currentMacros > 0 then
                        updateStatus("✅ LOADED " .. #currentMacros .. " MACROS", Color3.fromRGB(100, 255, 100))

                        -- Auto-select first macro
                        if currentMacros[1] then
                            selectedMacro = currentMacros[1]
                            samples = currentMacros[1].samples
                            if not playing then
                                resetPlayback()
                            end
                        end
                    else
                        updateStatus("❌ NO MACROS LOADED", Color3.fromRGB(255, 150, 50))
                    end
                end)
            end)
        else
            updateStatus("❌ INVALID MAP", Color3.fromRGB(255, 150, 50))
        end
    else
        updateStatus("❌ SELECT MAP FIRST", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(80, 120, 200))

-- Control buttons - TOMBOL LEBIH KECIL
playToggleBtn = createBtn("▶ PLAY", UDim2.new(0.05, 0, 0, 205), UDim2.new(0.45, 0, 0, 26), function()
    if selectedMacro then
        togglePlayback()
        updatePlayButton()
    else
        updateStatus("❌ SELECT MACRO FIRST", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(60, 180, 60))

createBtn("⏪ RESET", UDim2.new(0.5, 0, 0, 205), UDim2.new(0.45, 0, 0, 26), function()
    resetPlayback()
    updatePlayButton()
    playingAll = false
    currentPlayIndex = 1
end, Color3.fromRGB(150, 150, 100))

createBtn("🔄 PLAY ALL", UDim2.new(0.05, 0, 0, 235), UDim2.new(0.45, 0, 0, 26), function()
    if #currentMacros > 0 then
        playAllMacros()
    else
        updateStatus("❌ NO MACROS LOADED", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(100, 150, 255))

-- Show Cache button - TEXT LEBIH PENDEK
createBtn("💾 CACHE", UDim2.new(0.5, 0, 0, 235), UDim2.new(0.45, 0, 0, 26), function()
    local cachedCount = 0
    for _ in pairs(loadedMacrosCache) do
        cachedCount = cachedCount + 1
    end
    updateStatus("💾 CACHED: " .. cachedCount .. " maps", Color3.fromRGB(100, 255, 200))

    -- Show cached maps
    local cachedList = ""
    for mapName, macros in pairs(loadedMacrosCache) do
        cachedList = cachedList .. mapName .. "(" .. #macros .. "), "
    end
    print("Cached Macros: " .. cachedList)
end, Color3.fromRGB(100, 200, 100))

-- Speed Control - DIKECILKAN
local speedLabel = Instance.new("TextLabel", ContentFrame)
speedLabel.Text = "Playback Speed:"
speedLabel.Size = UDim2.new(0.4, 0, 0, 15)
speedLabel.Position = UDim2.new(0.05, 0, 0, 265)
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedDisplay = Instance.new("TextLabel", ContentFrame)
speedDisplay.Text = "1.0x"
speedDisplay.Size = UDim2.new(0.3, 0, 0, 22)
speedDisplay.Position = UDim2.new(0.35, 0, 0, 285)
speedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedDisplay.BackgroundTransparency = 0.2
speedDisplay.Font = Enum.Font.GothamBold
speedDisplay.TextSize = 11
speedDisplay.TextXAlignment = Enum.TextXAlignment.Center
local speedDisplayCorner = Instance.new("UICorner", speedDisplay)
speedDisplayCorner.CornerRadius = UDim.new(0, 6)

createBtn("◀", UDim2.new(0.05, 0, 0, 285), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = math.max(0.1, playSpeed - 0.1)
    speedDisplay.Text = string.format("%.1fx", playSpeed)
    updateStatus("🐢 SPEED " .. string.format("%.1fx", playSpeed), Color3.fromRGB(150, 200, 255))
end, Color3.fromRGB(80, 100, 180))

createBtn("▶", UDim2.new(0.7, 0, 0, 285), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = math.min(3.0, playSpeed + 0.1)
    speedDisplay.Text = string.format("%.1fx", playSpeed)
    updateStatus("🏃 SPEED " .. string.format("%.1fx", playSpeed), Color3.fromRGB(80, 160, 255))
end, Color3.fromRGB(40, 140, 240))

-- Info label - TEXT LEBIH KECIL
local infoLabel = Instance.new("TextLabel", ContentFrame)
infoLabel.Text = "Macros: 0 | Selected: None | Progress: 0/0"
infoLabel.Size = UDim2.new(0.9, 0, 0, 15)
infoLabel.Position = UDim2.new(0.05, 0, 0, 5)
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Update info label
spawn(function()
    while true do
        wait(0.3)
        if ContentFrame.Visible then
            local progressPercent = 0
            if #samples > 0 and playbackTime > 0 then
                local totalTime = samples[#samples].time
                if totalTime > 0 then
                    progressPercent = (playbackTime / totalTime) * 100
                end
            end

            local selectedName = selectedMacro and selectedMacro.displayName or "None"
            local currentPlay = playingAll and currentPlayIndex or 1
            local totalPlay = playingAll and #currentMacros or 1

            infoLabel.Text = string.format("Macros: %d | Selected: %s | Progress: %d/%d (%d%%)",
                #currentMacros, selectedName, currentPlay, totalPlay, math.floor(progressPercent))
        end
    end
end)

-------------------------------------------------------
-- DROPDOWN SYSTEM - DIKECILKAN
-------------------------------------------------------

-- Fungsi untuk close dropdown
local function closeDropdowns()
    if mapDropdownOpen and mapDropdownFrame then
        mapDropdownFrame:Destroy()
        mapDropdownFrame = nil
        mapDropdownOpen = false
    end
end

-- Fungsi untuk toggle dropdown
local function toggleMapDropdown()
    if mapDropdownOpen then
        closeDropdowns()
        return
    end

    if #macroLibrary == 0 then
        if not loadDropdownData() then
            return
        end
    end

    -- Update dropdown text jika data berhasil diload
    if #macroLibrary > 0 then
        MapDropdown.Text = "Pilih MAP..."
    end

    -- Create dropdown frame - DIKECILKAN
    mapDropdownFrame = Instance.new("Frame", Frame)
    mapDropdownFrame.Size = UDim2.new(0.9, 0, 0, math.min(120, #macroLibrary * 26 + 10))
    mapDropdownFrame.Position = UDim2.new(0.05, 0, 0, 46)
    mapDropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mapDropdownFrame.BorderSizePixel = 0
    mapDropdownFrame.ZIndex = 10

    local dropdownCorner = Instance.new("UICorner", mapDropdownFrame)
    dropdownCorner.CornerRadius = UDim.new(0, 6)

    local dropdownBorder = Instance.new("UIStroke", mapDropdownFrame)
    dropdownBorder.Color = Color3.fromRGB(80, 80, 80)
    dropdownBorder.Thickness = 2

    local dropdownScroll = Instance.new("ScrollingFrame", mapDropdownFrame)
    dropdownScroll.Size = UDim2.new(1, 0, 1, 0)
    dropdownScroll.BackgroundTransparency = 1
    dropdownScroll.BorderSizePixel = 0
    dropdownScroll.ScrollBarThickness = 6
    dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #macroLibrary * 26)
    dropdownScroll.ZIndex = 11

    local dropdownLayout = Instance.new("UIListLayout", dropdownScroll)
    dropdownLayout.Padding = UDim.new(0, 2)

    -- Add maps - BUTTON LEBIH KECIL
    for i, map in ipairs(macroLibrary) do
        local mapBtn = Instance.new("TextButton", dropdownScroll)
        mapBtn.Size = UDim2.new(1, -10, 0, 24)
        mapBtn.Position = UDim2.new(0, 5, 0, (i - 1) * 26)
        mapBtn.Text = map.nama
        mapBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        mapBtn.TextColor3 = Color3.new(1, 1, 1)
        mapBtn.Font = Enum.Font.Gotham
        mapBtn.TextSize = 10
        mapBtn.AutoButtonColor = true
        mapBtn.ZIndex = 12

        local btnCorner = Instance.new("UICorner", mapBtn)
        btnCorner.CornerRadius = UDim.new(0, 4)

        mapBtn.MouseButton1Click:Connect(function()
            MapDropdown.Text = map.nama
            closeDropdowns()
        end)
    end

    mapDropdownOpen = true
end

-- Event handlers untuk dropdown
MapDropdown.MouseButton1Click:Connect(function()
    if #macroLibrary > 0 then
        toggleMapDropdown()
    else
        updateStatus("❌ MAP DATA NOT LOADED", Color3.fromRGB(255, 150, 50))
    end
end)

-- Input handling untuk close dropdown
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if mapDropdownOpen and mapDropdownFrame then
            local mousePos = input.Position
            local dropdownAbsPos = mapDropdownFrame.AbsolutePosition
            local dropdownSize = mapDropdownFrame.AbsoluteSize

            if not (mousePos.X >= dropdownAbsPos.X and mousePos.X <= dropdownAbsPos.X + dropdownSize.X and
                    mousePos.Y >= dropdownAbsPos.Y and mousePos.Y <= dropdownAbsPos.Y + dropdownSize.Y) then
                closeDropdowns()
            end
        end
    end
end)

-- Preload data saat startup
spawn(function()
    wait(2)
    if loadDropdownData() and #macroLibrary > 0 then
        MapDropdown.Text = "Pilih MAP..."
    end
end)

-- Update button status
RunService.Heartbeat:Connect(updatePlayButton)
