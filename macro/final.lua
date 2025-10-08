--// Macro Recorder dengan Dropdown System //--
-- Cegah execute berulang
if _G.MacroLoaderExecuted then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "@LILDANZVERT",
        Text = "Script sudah berjalan!",
        Duration = 5
    })
    return
end
_G.MacroLoaderExecuted = true
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Created by LILDANZVERT",
    Duration = 5
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer
local hrp, hum

-- Vars
local playing = false
local playSpeed = 1
local samples = {}
local playbackTime = 0
local playIndex = 1
local isPathfinding = false
local macroLocked = false
local pathfindingTimeout = 0
local needsPathfinding = true  -- Flag untuk cek apakah perlu pathfinding
local startFromNearest = false -- Flag untuk mulai dari posisi terdekat

-- Macro Library System - LOCAL STORAGE
local macroLibrary = {}
local currentMacros = {}
local selectedMacro = nil
local playingAll = false
local currentPlayIndex = 1

-- Local Storage untuk macros yang sudah diload
local loadedMacrosCache = {} -- Format: { ["yahayuk"] = {macros}, ["atin"] = {macros} }

-- Variables untuk status loading
local isLoadingMaps = false
local mapsLoaded = false

-- Fungsi untuk cek game ID yang sedang dimainkan
local function getCurrentGameId()
    return tostring(game.PlaceId)
end

-- Fungsi untuk filter maps berdasarkan game ID yang sedang dimainkan
local function filterMapsByGameId(mapsData)
    local currentGameId = getCurrentGameId()
    local filteredMaps = {}

    for _, map in ipairs(mapsData) do
        if tostring(map.gameId) == currentGameId then
            table.insert(filteredMaps, map)
        end
    end

    return filteredMaps
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

-- Pathfinding System yang lebih reliable
local function moveToPosition(targetPosition, callback)
    if not hrp or not hum or isPathfinding then
        if callback then callback(false) end
        return false
    end

    isPathfinding = true
    macroLocked = true
    pathfindingTimeout = tick() + 100 -- Timeout 4 detik
    updateStatus("🗺️ PATHFINDING...", Color3.fromRGB(255, 200, 50))

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4,
        Costs = {}
    })

    -- Compute path
    local success, result = pcall(function()
        path:ComputeAsync(hrp.Position, targetPosition)
    end)

    if not success then
        isPathfinding = false
        macroLocked = false
        updateStatus("❌ PATHFINDING ERROR", Color3.fromRGB(255, 100, 100))
        if callback then callback(false) end
        return false
    end

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()

        if #waypoints == 0 then
            isPathfinding = false
            macroLocked = false
            updateStatus("✅ ALREADY AT TARGET", Color3.fromRGB(100, 255, 100))
            if callback then callback(true) end
            return true
        end

        -- Skip first waypoint jika terlalu dekat
        local startIndex = 1
        if #waypoints > 1 and (waypoints[1].Position - hrp.Position).Magnitude < 3 then
            startIndex = 2
        end

        -- Follow waypoints
        for i = startIndex, #waypoints do
            -- Check timeout
            if tick() > pathfindingTimeout then
                isPathfinding = false
                macroLocked = false
                hum:MoveTo(hrp.Position) -- Cancel movement
                updateStatus("⏰ PATHFINDING TIMEOUT", Color3.fromRGB(255, 150, 50))
                if callback then callback(false) end
                return false
            end

            if not isPathfinding then break end

            local waypoint = waypoints[i]
            local distance = (waypoint.Position - hrp.Position).Magnitude

            -- Move to waypoint dengan timeout per waypoint
            local waypointStartTime = tick()
            hum:MoveTo(waypoint.Position)

            -- Wait until reached or timeout
            while distance > 3.5 and isPathfinding do
                -- Check overall timeout
                if tick() > pathfindingTimeout then
                    isPathfinding = false
                    macroLocked = false
                    hum:MoveTo(hrp.Position) -- Cancel movement
                    updateStatus("⏰ PATHFINDING TIMEOUT", Color3.fromRGB(255, 150, 50))
                    if callback then callback(false) end
                    return false
                end

                -- Check waypoint timeout (1.5 detik per waypoint)
                if tick() > waypointStartTime + 1.5 then
                    break -- Skip to next waypoint
                end

                distance = (waypoint.Position - hrp.Position).Magnitude
                RunService.Heartbeat:Wait()
            end

            -- Handle jumping
            if waypoint.Action == Enum.PathWaypointAction.Jump and isPathfinding then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                wait(0.3)
            end

            -- Small delay between waypoints
            if i < #waypoints then
                wait(0.1)
            end
        end

        -- Check final distance
        local finalDistance = (targetPosition - hrp.Position).Magnitude
        isPathfinding = false
        macroLocked = false

        if finalDistance <= 10 then
            updateStatus("✅ READY TO PLAY", Color3.fromRGB(100, 255, 100))
            if callback then callback(true) end
            return true
        else
            updateStatus("❌ FAILED TO REACH TARGET", Color3.fromRGB(255, 100, 100))
            if callback then callback(false) end
            return false
        end
    else
        isPathfinding = false
        macroLocked = false
        updateStatus("❌ NO PATH FOUND", Color3.fromRGB(255, 100, 100))
        if callback then callback(false) end
        return false
    end
end

-- Fungsi untuk mencari sample terdekat dari posisi karakter
local function findNearestSample()
    if not hrp or #samples == 0 then
        return 1 -- Return index pertama jika tidak ada data
    end

    local currentPos = hrp.Position
    local nearestIndex = 1
    local minDistance = math.huge

    for i, sample in ipairs(samples) do
        if sample.cf then
            local distance = (currentPos - sample.cf.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestIndex = i
            end
        end
    end

    -- Jika ada sample dalam jarak 20 stud, mulai dari sana
    if minDistance <= 20 then
        updateStatus("🎯 START FROM NEAREST POSITION", Color3.fromRGB(100, 200, 255))
        return nearestIndex
    else
        -- Jika tidak ada yang dekat, mulai dari awal
        return 1
    end
end

-- Fungsi untuk move ke posisi sample terdekat
local function moveToNearestSample(callback)
    local nearestIndex = findNearestSample()

    -- Jika sudah di posisi terdekat (index 1 atau jarak < 3 stud)
    if nearestIndex == 1 then
        if callback then callback(true, nearestIndex) end
        return true
    end

    local targetPosition = samples[nearestIndex].cf.Position
    local distance = (hrp.Position - targetPosition).Magnitude

    if distance <= 3 then
        -- Sudah dekat, tidak perlu pathfinding
        if callback then callback(true, nearestIndex) end
        return true
    else
        -- Perlu pathfinding ke posisi terdekat
        updateStatus("🗺️ MOVING TO NEAREST POSITION...", Color3.fromRGB(255, 200, 50))
        return moveToPosition(targetPosition, function(success)
            if success then
                if callback then callback(true, nearestIndex) end
            else
                if callback then callback(false, 1) end
            end
        end)
    end
end

-- Playback functions - MODIFIED untuk mulai dari posisi terdekat
local function startPlayback()
    if #samples < 2 then
        updateStatus("❌ NO DATA", Color3.fromRGB(255, 150, 50))
        return
    end

    -- Check jika sedang pathfinding
    if isPathfinding then
        updateStatus("⏳ WAITING PATHFINDING...", Color3.fromRGB(255, 200, 50))
        return
    end

    playing = true
    macroLocked = true

    -- Cek apakah perlu pathfinding (hanya jika baru mulai atau reset)
    if needsPathfinding then
        updateStatus("🔍 FINDING NEAREST POSITION...", Color3.fromRGB(150, 200, 255))

        -- Cari posisi terdekat dan pathfinding jika diperlukan
        moveToNearestSample(function(success, startIndex)
            if success then
                -- Set playback mulai dari index terdekat
                playIndex = startIndex
                playbackTime = samples[startIndex].time

                -- Pathfinding berhasil, set flag ke false
                needsPathfinding = false
                startFromNearest = (startIndex > 1) -- Flag jika mulai dari tengah

                -- Tunggu sebentar sebelum mulai
                wait(0.3)
                if playing then
                    if startFromNearest then
                        updateStatus("▶️ PLAYING FROM NEAREST", Color3.fromRGB(50, 200, 150))
                    else
                        updateStatus("▶️ PLAYING", Color3.fromRGB(50, 150, 255))
                    end
                end
            else
                -- Jika pathfinding gagal, stop playback
                playing = false
                macroLocked = false
                updateStatus("❌ CANNOT REACH POSITION", Color3.fromRGB(255, 100, 100))
            end
        end)
    else
        -- Tidak perlu pathfinding, langsung play dari posisi saat ini
        updateStatus("▶️ PLAYING", Color3.fromRGB(50, 150, 255))
    end
end

local function stopPlayback()
    playing = false
    macroLocked = false
    isPathfinding = false
    if hum then
        hum:Move(Vector3.new(), false) -- Stop movement
    end
    updateStatus("⏹️ READY", Color3.fromRGB(100, 200, 100))
end

local function resetPlayback()
    playbackTime = 0
    playIndex = 1
    playing = false
    macroLocked = false
    isPathfinding = false
    needsPathfinding = true            -- Reset flag pathfinding
    startFromNearest = false           -- Reset flag start dari nearest
    if hum then
        hum:Move(Vector3.new(), false) -- Stop movement
    end
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
                        needsPathfinding = true -- Reset pathfinding untuk macro berikutnya
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

-- Playback loop dengan RenderStepped - MODIFIED untuk handle start dari tengah
RunService.RenderStepped:Connect(function(dt)
    if playing and hrp and hum and #samples > 1 and not isPathfinding then
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

-- Fungsi untuk update status button load macros
local function updateLoadButtonState()
    if isLoadingMaps then
        loadBtn.Text = "📥 LOADING MAPS..."
        loadBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        loadBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        loadBtn.AutoButtonColor = false
    elseif mapsLoaded and #macroLibrary > 0 then
        loadBtn.Text = "📥 LOAD MACROS"
        loadBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        loadBtn.TextColor3 = Color3.new(1, 1, 1)
        loadBtn.AutoButtonColor = true
    else
        loadBtn.Text = "📥 LOAD FAILED"
        loadBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        loadBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        loadBtn.AutoButtonColor = false
    end
end

-- Fungsi untuk load dropdown data dengan filter game ID
local function loadDropdownData()
    if #macroLibrary > 0 then
        mapsLoaded = true
        updateLoadButtonState()
        return true -- Data sudah diload
    end

    isLoadingMaps = true
    updateLoadButtonState()
    updateStatus("📥 LOADING MAPS...", Color3.fromRGB(150, 200, 255))

    local success, dropdownJson = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/maps.json", true)
    end)

    isLoadingMaps = false

    if success and dropdownJson then
        local success2, dropdownData = pcall(function()
            return HttpService:JSONDecode(dropdownJson)
        end)

        if success2 and dropdownData and type(dropdownData) == "table" then
            -- Filter maps berdasarkan game ID yang sedang dimainkan
            local filteredMaps = filterMapsByGameId(dropdownData)
            macroLibrary = filteredMaps

            if #filteredMaps > 0 then
                mapsLoaded = true
                updateStatus("🗺️ LOADED " .. #filteredMaps .. " maps", Color3.fromRGB(100, 200, 255))
            else
                mapsLoaded = false
                updateStatus("❌ GAME NOT SUPPORTED", Color3.fromRGB(255, 100, 100))
            end
        else
            mapsLoaded = false
            updateStatus("❌ FAILED LOAD MAPS", Color3.fromRGB(255, 100, 100))
        end
    else
        mapsLoaded = false
        updateStatus("❌ FAILED LOAD MAPS", Color3.fromRGB(255, 100, 100))
    end

    updateLoadButtonState()
    return mapsLoaded
end

-- Fungsi untuk load macro data dengan CACHE SYSTEM
local function loadMacroData(params, cpCount)
    -- Cek jika cpCount 0 atau kurang
    if cpCount <= 0 then
        updateStatus("❌ DATA BELUM TERSEDIA", Color3.fromRGB(255, 150, 50))
        return {}
    end

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
        needsPathfinding = true -- Reset pathfinding untuk play all
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
StatusLabel.Position = UDim2.new(1, -100, 0, 4)
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

-- Macro List Frame - DIKECILKAN untuk mobile - DITINGGIKAN
local macroListFrame = Instance.new("Frame", ContentFrame)
macroListFrame.Size = UDim2.new(0.9, 0, 0, 180)     -- DITINGGIKAN dari 120 ke 180
macroListFrame.Position = UDim2.new(0.05, 0, 0, 20) -- POSISI DIUBAH dari 80 ke 20
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

-- Function untuk update macro list - DENGAN LOCK SYSTEM
local function updateMacroList()
    -- Update label
    macroListLabel.Text = "Daftar Checkpoint: (" .. #currentMacros .. ")"

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

        -- Set warna berdasarkan lock status
        if macroLocked or isPathfinding then
            macroBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            macroBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            macroBtn.AutoButtonColor = false
        else
            macroBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            macroBtn.TextColor3 = Color3.new(1, 1, 1)
            macroBtn.AutoButtonColor = true
        end

        macroBtn.Font = Enum.Font.Gotham
        macroBtn.TextSize = 10
        macroBtn.TextXAlignment = Enum.TextXAlignment.Left
        macroBtn.Parent = macroScrollFrame

        local macroBtnCorner = Instance.new("UICorner", macroBtn)
        macroBtnCorner.CornerRadius = UDim.new(0, 6)

        -- Hover effect hanya jika tidak locked
        if not macroLocked and not isPathfinding then
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
        end

        macroBtn.MouseButton1Click:Connect(function()
            -- Cek jika sedang playing atau pathfinding
            if playing or isPathfinding or macroLocked then
                updateStatus("🔒 MACRO SEDANG BERJALAN", Color3.fromRGB(255, 150, 50))
                return
            end

            selectedMacro = macro
            samples = macro.samples
            resetPlayback()
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

-- Control buttons - SATU BARIS - TOMBOL LEBIH KECIL
playToggleBtn = createBtn("▶ PLAY", UDim2.new(0.05, 0, 0, 235), UDim2.new(0.3, 0, 0, 26), function()
    if selectedMacro then
        togglePlayback()
        updatePlayButton()
        updateMacroList() -- Update UI untuk lock status
    else
        updateStatus("❌ SELECT CHECKPOINT FIRST", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(60, 180, 60))

createBtn("🔄 ALL", UDim2.new(0.36, 0, 0, 235), UDim2.new(0.28, 0, 0, 26), function()
    if #currentMacros > 0 then
        playAllMacros()
        updateMacroList() -- Update UI untuk lock status
    else
        updateStatus("❌ NO CHECKPOINT LOADED", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(100, 150, 255))

createBtn("⏪ RESET", UDim2.new(0.65, 0, 0, 235), UDim2.new(0.3, 0, 0, 26), function()
    resetPlayback()
    updatePlayButton()
    playingAll = false
    currentPlayIndex = 1
    updateMacroList() -- Update UI untuk unlock status
end, Color3.fromRGB(150, 150, 100))

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
infoLabel.Text = "Checkpoint: 0 | Selected: None | Progress: 0/0"
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

            infoLabel.Text = string.format("Jumlah CP: %d | Selected: %s | Progress: %d/%d (%d%%)",
                #currentMacros, selectedName, currentPlay, totalPlay, math.floor(progressPercent))
        end
    end
end)

-- Load button dengan CACHE SYSTEM - DENGAN LOCK CHECK - POSISI DIUBAH
local loadBtn = createBtn("📥 LOADING MAPS...", UDim2.new(0.05, 0, 0, 205), UDim2.new(0.9, 0, 0, 26), function()
    -- Cek jika maps belum diload atau sedang loading
    if isLoadingMaps then
        updateStatus("⏳ STILL LOADING MAPS...", Color3.fromRGB(255, 200, 50))
        return
    end

    if not mapsLoaded or #macroLibrary == 0 then
        updateStatus("❌ MAPS NOT LOADED", Color3.fromRGB(255, 150, 50))
        return
    end

    -- Cek jika sedang playing atau pathfinding
    if playing or isPathfinding or macroLocked then
        updateStatus("🔒 TUNGGU MACRO SELESAI", Color3.fromRGB(255, 150, 50))
        return
    end

    if #macroLibrary > 0 then
        -- Ambil map pertama yang tersedia untuk game ini
        local selectedMap = macroLibrary[1]
        if selectedMap then
            -- Cek jika CP count 0 atau kurang
            if selectedMap.cp <= 0 then
                updateStatus("❌ DATA BELUM TERSEDIA", Color3.fromRGB(255, 150, 50))
                return
            end

            updateStatus("📚 LOADING CHECKPOINT...", Color3.fromRGB(150, 200, 255))

            -- Load macros di background thread
            spawn(function()
                local loadedMacros = loadOrGetMacros(selectedMap.params, selectedMap.cp)

                -- Update di main thread dengan data yang sudah diload
                spawn(function()
                    currentMacros = loadedMacros
                    updateMacroList()

                    if #currentMacros > 0 then
                        updateStatus("✅ LOADED " .. #currentMacros .. " CHECKPOINT", Color3.fromRGB(100, 255, 100))

                        -- Auto-select first macro
                        if currentMacros[1] then
                            selectedMacro = currentMacros[1]
                            samples = currentMacros[1].samples
                            resetPlayback()
                        end
                    else
                        updateStatus("❌ NO CHECKPOINT LOADED", Color3.fromRGB(255, 150, 50))
                    end
                end)
            end)
        end
    else
        updateStatus("❌ NO MAPS AVAILABLE", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(100, 100, 100)) -- Warna default abu-abu

-- Initialize button state
updateLoadButtonState()

-- Preload data saat startup dan cek game compatibility
spawn(function()
    wait(2)
    if loadDropdownData() then
        if #macroLibrary > 0 then
            updateStatus("✅ GAME SUPPORTED", Color3.fromRGB(100, 255, 100))
            -- Tampilkan info game yang sedang dimainkan
            local currentGameId = getCurrentGameId()
            local gameName = "Unknown Game"
            for _, map in ipairs(macroLibrary) do
                if tostring(map.gameId) == currentGameId then
                    gameName = map.nama
                    break
                end
            end
            infoLabel.Text = "Playing: " .. gameName .. " | Game ID: " .. currentGameId
        else
            updateStatus("❌ GAME NOT SUPPORTED", Color3.fromRGB(255, 100, 100))
        end
    else
        updateStatus("❌ FAILED TO LOAD DATA", Color3.fromRGB(255, 100, 100))
    end
end)

-- Update button status dan timeout check
RunService.Heartbeat:Connect(function()
    updatePlayButton()

    -- Check pathfinding timeout
    if isPathfinding and tick() > pathfindingTimeout then
        isPathfinding = false
        macroLocked = false
        if hum then
            hum:MoveTo(hrp.Position) -- Cancel movement
        end
        updateStatus("⏰ PATHFINDING TIMEOUT", Color3.fromRGB(255, 150, 50))
    end

    -- Update macro list jika status lock berubah
    if playing or isPathfinding or macroLocked then
        for _, btn in ipairs(macroScrollFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                btn.AutoButtonColor = false
            end
        end
    else
        for _, btn in ipairs(macroScrollFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                if btn.BackgroundColor3 ~= Color3.fromRGB(80, 120, 200) then
                    btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    btn.AutoButtonColor = true
                end
            end
        end
    end
end)
