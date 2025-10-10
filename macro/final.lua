--// Macro Recorder dengan Dropdown System dan Random Checkpoint //--
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

loadstring(game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/antiafk.lua", true))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
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
local needsPathfinding = true
local startFromNearest = false
local faceBackwards = false   -- NEW: Toggle untuk hadap belakang
local isLoadingMacros = false -- NEW: Lock untuk loading macros

-- Macro Library System - LOCAL STORAGE
local macroLibrary = {}
local currentMacros = {}
local selectedMacro = nil
local playingAll = false
local currentPlayIndex = 1
local loopPlayAll = false -- NEW: Flag untuk looping play all

-- Local Storage untuk macros yang sudah diload
local loadedMacrosCache = {}

-- Random Checkpoint System
local Checkpoints = {}
local currentMapData = nil

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
    pathfindingTimeout = tick() + 100
    updateStatus("PATHFINDING", Color3.fromRGB(255, 200, 50))

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 6,
        Costs = {}
    })

    -- Compute path
    local success, result = pcall(function()
        path:ComputeAsync(hrp.Position, targetPosition)
    end)

    if not success then
        isPathfinding = false
        macroLocked = false
        updateStatus("PATH ERROR", Color3.fromRGB(255, 100, 100))
        if callback then callback(false) end
        return false
    end

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()

        if #waypoints == 0 then
            isPathfinding = false
            macroLocked = false
            updateStatus("AT TARGET", Color3.fromRGB(100, 255, 100))
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
                hum:MoveTo(hrp.Position)
                updateStatus("PATH TIMEOUT", Color3.fromRGB(255, 150, 50))
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
                    hum:MoveTo(hrp.Position)
                    updateStatus("PATH TIMEOUT", Color3.fromRGB(255, 150, 50))
                    if callback then callback(false) end
                    return false
                end

                -- Check waypoint timeout (1.5 detik per waypoint)
                if tick() > waypointStartTime + 1.5 then
                    break
                end

                distance = (waypoint.Position - hrp.Position).Magnitude
                RunService.Heartbeat:Wait()
            end

            -- Handle jumping
            if waypoint.Action == Enum.PathWaypointAction.Jump and isPathfinding then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                wait(0.2)
            end

            -- Small delay between waypoints
            if i < #waypoints then
                wait(0.05)
            end
        end

        -- Check final distance
        local finalDistance = (targetPosition - hrp.Position).Magnitude
        isPathfinding = false
        macroLocked = false

        if finalDistance <= 10 then
            updateStatus("READY", Color3.fromRGB(100, 255, 100))
            if callback then callback(true) end
            return true
        else
            updateStatus("TARGET FAILED", Color3.fromRGB(255, 100, 100))
            if callback then callback(false) end
            return false
        end
    else
        isPathfinding = false
        macroLocked = false
        updateStatus("NO PATH", Color3.fromRGB(255, 100, 100))
        if callback then callback(false) end
        return false
    end
end

-- Fungsi untuk teleport ke posisi target
local function teleportToPosition(targetPosition)
    if not hrp then
        return false
    end

    -- Simpan state sebelumnya
    local previousCollision = hrp.CanCollide
    local previousAnchored = false
    if hrp:IsA("Part") then
        previousAnchored = hrp.Anchored
    end

    -- Non-aktifkan collision sementara untuk menghindari stuck
    hrp.CanCollide = false
    if hrp:IsA("Part") then
        hrp.Anchored = true
    end

    -- Teleport ke posisi target
    hrp.CFrame = CFrame.new(targetPosition)

    -- Tunggu sebentar untuk memastikan teleport selesai
    wait(0.1)

    -- Restore collision state
    hrp.CanCollide = previousCollision
    if hrp:IsA("Part") then
        hrp.Anchored = previousAnchored
    end

    -- Verifikasi teleport berhasil
    local distance = (hrp.Position - targetPosition).Magnitude
    return distance <= 5
end

-- MODIFIED: Fungsi untuk mencari sample terdekat dari posisi karakter
local function findNearestSample()
    if not hrp or #samples == 0 then
        return 1
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

    return nearestIndex, minDistance
end

-- MODIFIED: Fungsi untuk move ke posisi sample dengan logika jarak
local function moveToSamplePosition(targetIndex, callback)
    if not hrp or not samples[targetIndex] or not samples[targetIndex].cf then
        if callback then callback(false) end
        return false
    end

    local targetPosition = samples[targetIndex].cf.Position
    local distance = (hrp.Position - targetPosition).Magnitude

    -- Jika sudah dekat (dalam 3 stud), tidak perlu melakukan apa-apa
    if distance <= 3 then
        if callback then callback(true) end
        return true
    end

    -- JIKA LEBIH DARI 40 STUD, LANGSUNG TELEPORT
    if distance > 40 then
        updateStatus("TELEPORTING", Color3.fromRGB(255, 150, 50))

        local teleportSuccess = teleportToPosition(targetPosition)

        if teleportSuccess then
            updateStatus("TELEPORT OK", Color3.fromRGB(100, 255, 100))
            if callback then callback(true) end
        else
            updateStatus("TELEPORT FAIL", Color3.fromRGB(255, 100, 100))
            if callback then callback(false) end
        end
        return teleportSuccess
    end

    -- JIKA KURANG DARI 40 STUD, GUNAKAN PATHFINDING
    updateStatus("PATHFINDING", Color3.fromRGB(255, 200, 50))
    return moveToPosition(targetPosition, function(success)
        if success then
            if callback then callback(true) end
        else
            -- Fallback teleport jika pathfinding gagal (dalam jarak dekat)
            updateStatus("TELEPORTING", Color3.fromRGB(255, 150, 50))

            local teleportSuccess = teleportToPosition(targetPosition)

            if teleportSuccess then
                updateStatus("TELEPORT OK", Color3.fromRGB(100, 255, 100))
                if callback then callback(true) end
            else
                updateStatus("ALL FAILED", Color3.fromRGB(255, 100, 100))
                if callback then callback(false) end
            end
        end
    end)
end

-- MODIFIED: Fungsi untuk move ke posisi sample terdekat
local function moveToNearestSample(callback)
    local targetIndex, distance = findNearestSample()
    local isStartingFromNearest = (targetIndex > 1)

    if isStartingFromNearest then
        if distance > 40 then
            updateStatus("TELEPORT CP", Color3.fromRGB(200, 150, 255))
        else
            updateStatus("PATHFIND CP", Color3.fromRGB(100, 200, 255))
        end
    else
        if distance > 40 then
            updateStatus("TELEPORT START", Color3.fromRGB(200, 150, 255))
        else
            updateStatus("PATHFIND START", Color3.fromRGB(100, 200, 255))
        end
    end

    return moveToSamplePosition(targetIndex, function(success)
        if success then
            if callback then callback(true, targetIndex) end
        else
            -- Jika gagal ke posisi terdekat, coba ke posisi awal
            if isStartingFromNearest then
                updateStatus("RETRY START", Color3.fromRGB(255, 200, 50))
                moveToSamplePosition(1, function(retrySuccess)
                    if retrySuccess then
                        if callback then callback(true, 1) end
                    else
                        if callback then callback(false, 1) end
                    end
                end)
            else
                if callback then callback(false, 1) end
            end
        end
    end)
end

-- NEW: Fungsi untuk mencari macro terdekat dari semua macro yang tersedia
local function findNearestMacro()
    if not hrp or #currentMacros == 0 then
        return 1
    end

    local currentPos = hrp.Position
    local nearestIndex = 1
    local minDistance = math.huge

    for i, macro in ipairs(currentMacros) do
        if macro.samples and #macro.samples > 0 and macro.samples[1].cf then
            local distance = (currentPos - macro.samples[1].cf.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestIndex = i
            end
        end
    end

    return nearestIndex
end

-- Fungsi untuk mencari checkpoint parts di workspace
local function findCheckpointParts()
    Checkpoints = {}

    -- Cari semua part di workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") then
            -- Deteksi berdasarkan nama part
            local nameLower = obj.Name:lower()
            if nameLower:find("checkpoint") or
                nameLower:find("cp") or
                nameLower:find("finish") or
                nameLower:find("end") or
                nameLower:find("goal") then
                table.insert(Checkpoints, {
                    Part = obj,
                    Name = obj.Name,
                    Position = obj.Position
                })
            end
        end
    end

    -- Debug info
    if #Checkpoints > 0 then
        updateStatus("FOUND " .. #Checkpoints .. " CP", Color3.fromRGB(100, 255, 100))
    else
        updateStatus("NO CP FOUND", Color3.fromRGB(255, 150, 50))
    end

    return Checkpoints
end

-- Fungsi untuk mencari checkpoint terdekat
local function findNearestCheckpoint(maxDistance)
    if not hrp then
        return nil, 0
    end

    local playerPos = hrp.Position
    local nearest = nil
    local nearestDistance = math.huge

    for _, checkpoint in pairs(Checkpoints) do
        if checkpoint.Part and checkpoint.Part.Parent then
            local distance = (playerPos - checkpoint.Position).Magnitude
            if distance < nearestDistance and distance <= (maxDistance or 50) then
                nearestDistance = distance
                nearest = checkpoint
            end
        end
    end

    return nearest, nearestDistance
end

-- Fungsi untuk menangani random checkpoint setelah macro selesai
local function findRandomCheckpoint(callback)
    -- Cari checkpoint parts jika belum ada
    if #Checkpoints == 0 then
        findCheckpointParts()
    end

    -- Cari checkpoint terdekat dalam jarak 50 stud
    local nearestCheckpoint, distance = findNearestCheckpoint(50)

    if nearestCheckpoint then
        updateStatus("FOUND CP: " .. nearestCheckpoint.Name .. " (" .. math.floor(distance) .. " stud)",
            Color3.fromRGB(150, 255, 150))

        -- Pathfinding ke checkpoint terdekat
        moveToPosition(nearestCheckpoint.Position, function(success)
            if success then
                updateStatus("REACHED CP", Color3.fromRGB(100, 255, 100))
                if callback then callback(true) end
            else
                updateStatus("CP FAILED", Color3.fromRGB(255, 100, 100))
                if callback then callback(false) end
            end
        end)
    else
        updateStatus("NO CP IN RANGE", Color3.fromRGB(255, 150, 50))
        if callback then callback(false) end
    end
end

-------------------------------------------------------
-- GUI Modern - WITH VISIBLE MACRO LIST (MOBILE FRIENDLY)
-------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MacroGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame - MODIFIED: Ukuran diperbesar untuk fit toggle button
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 230, 0, 350) -- MODIFIED: Height dari 350 ke 380
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
Title.Text = "@LilDanzVert"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

-- MODIFIED: Status Indicator - dipindah ke posisi yang lebih baik
local StatusLabel = Instance.new("TextLabel", TitleBar)
StatusLabel.Text = "READY"
StatusLabel.Size = UDim2.new(0, 110, 0, 18)     -- MODIFIED: Size diperkecil
StatusLabel.Position = UDim2.new(1, -140, 0, 5) -- MODIFIED: Position diperbaiki
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamBold -- MODIFIED: Font jadi bold
StatusLabel.TextSize = 9
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
local StatusCorner = Instance.new("UICorner", StatusLabel)
StatusCorner.CornerRadius = UDim.new(0, 6)

-- Minimize Button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "−"
MinBtn.Size = UDim2.new(0, 20, 0, 20)     -- MODIFIED: Size diperkecil
MinBtn.Position = UDim2.new(1, -25, 0, 4) -- MODIFIED: Position disesuaikan
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

-- Macro List Frame
local macroListFrame = Instance.new("Frame", ContentFrame)
macroListFrame.Size = UDim2.new(0.9, 0, 0, 180)
macroListFrame.Position = UDim2.new(0.05, 0, 0, 20)
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
macroListLabel.Position = UDim2.new(0, 8, 0, 2)
macroListLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
macroListLabel.BackgroundTransparency = 1
macroListLabel.Font = Enum.Font.GothamBold
macroListLabel.TextSize = 11
macroListLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Scroll frame untuk macro list
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

-- Playback functions
local function startPlayback()
    if #samples < 2 then
        updateStatus("NO DATA", Color3.fromRGB(255, 150, 50))
        return
    end

    if isPathfinding then
        updateStatus("WAITING PATH", Color3.fromRGB(255, 200, 50))
        return
    end

    playing = true
    macroLocked = true

    -- MODIFIED: Always use pathfinding at start for ALL maps, not just randomcp ones
    if needsPathfinding then
        updateStatus("FINDING START", Color3.fromRGB(150, 200, 255))

        moveToNearestSample(function(success, startIndex)
            if success then
                playIndex = startIndex
                playbackTime = samples[startIndex].time
                needsPathfinding = false
                startFromNearest = (startIndex > 1)

                wait(0.3)
                if playing then
                    if startFromNearest then
                        updateStatus("PLAYING CP", Color3.fromRGB(50, 200, 150))
                    else
                        updateStatus("PLAYING", Color3.fromRGB(50, 150, 255))
                    end
                end
            else
                playing = false
                macroLocked = false

                -- COBA TELEPORT SEBAGAI LAST RESORT
                updateStatus("FINAL TELEPORT", Color3.fromRGB(255, 150, 50))

                local targetPosition = samples[1].cf.Position
                local teleportSuccess = teleportToPosition(targetPosition)

                if teleportSuccess then
                    updateStatus("TELEPORT OK", Color3.fromRGB(100, 255, 100))
                    playIndex = 1
                    playbackTime = samples[1].time
                    needsPathfinding = false
                    startFromNearest = false

                    wait(0.3)
                    if playing then
                        updateStatus("PLAYING", Color3.fromRGB(50, 150, 255))
                    end
                else
                    updateStatus("ALL FAILED", Color3.fromRGB(255, 100, 100))
                end
            end
        end)
    else
        updateStatus("PLAYING", Color3.fromRGB(50, 150, 255))
    end
end


local function stopPlayback()
    playing = false
    macroLocked = false
    isPathfinding = false
    if hum then
        hum:Move(Vector3.new(), false)
    end
    updateStatus("READY", Color3.fromRGB(100, 200, 100))
end

local function resetPlayback()
    playbackTime = 0
    playIndex = 1
    playing = false
    macroLocked = false
    isPathfinding = false
    needsPathfinding = true
    startFromNearest = false
    if hum then
        hum:Move(Vector3.new(), false)
    end
    updateStatus("RESET", Color3.fromRGB(200, 200, 100))
end

local function togglePlayback()
    if playing then
        stopPlayback()
    else
        startPlayback()
    end
end

-- Function untuk update macro list
local function updateMacroList()
    macroListLabel.Text = "Daftar Checkpoint: (" .. #currentMacros .. ")"

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

    for i, macro in ipairs(currentMacros) do
        local macroBtn = Instance.new("TextButton")
        macroBtn.Size = UDim2.new(0.98, 0, 0, 26)
        macroBtn.LayoutOrder = i
        macroBtn.Text = "  " .. macro.listName .. " • " .. macro.sampleCount .. " samples"

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
            if playing or isPathfinding or macroLocked then
                updateStatus("MACRO LOCKED", Color3.fromRGB(255, 150, 50))
                return
            end

            selectedMacro = macro
            samples = macro.samples
            resetPlayback()
            updateStatus("SELECTED " .. macro.displayName, Color3.fromRGB(150, 200, 255))

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

    macroScrollFrame.CanvasSize = UDim2.new(0, 0, 0, macroListLayout.AbsoluteContentSize.Y)
end



-- NEW: Fungsi untuk melanjutkan ke macro berikutnya dengan looping
local function continueToNextMacro()
    currentPlayIndex = currentPlayIndex + 1

    -- NEW: Looping - jika sudah di akhir dan loop aktif, kembali ke awal
    if currentPlayIndex > #currentMacros then
        if loopPlayAll then
            currentPlayIndex = 1
            updateStatus("LOOPING", Color3.fromRGB(200, 150, 255))
        else
            playingAll = false
            currentPlayIndex = 1
            updateStatus("DONE", Color3.fromRGB(100, 255, 100))
            return
        end
    end

    if currentPlayIndex <= #currentMacros then
        local nextMacro = currentMacros[currentPlayIndex]
        if nextMacro then
            samples = nextMacro.samples
            selectedMacro = nextMacro
            playbackTime = 0
            playIndex = 1
            needsPathfinding = true

            -- NEW: Tampilkan info loop jika sedang looping
            local loopInfo = ""
            if loopPlayAll then
                loopInfo = " (Loop " .. math.floor((currentPlayIndex - 1) / #currentMacros) + 1 .. ")"
            end

            updateStatus(
                "PLAYING " ..
                nextMacro.displayName .. " (" .. currentPlayIndex .. "/" .. #currentMacros .. ")" .. loopInfo,
                Color3.fromRGB(50, 200, 255))
            startPlayback()
        end
    end
end

-- MODIFIED: Playback completion check untuk handle random checkpoint dan looping
local function checkPlaybackCompletion()
    if playing and #samples > 0 and playIndex >= #samples then
        stopPlayback()

        -- MODIFIED: Only use random checkpoint system at the end for maps with randomcp=true
        local hasRandomCP = currentMapData and currentMapData.randomcp == true

        if playingAll and #currentMacros > 0 then
            spawn(function()
                wait(0.3)

                -- MODIFIED: Only use random checkpoint between macros if the map has randomcp enabled
                if hasRandomCP and (currentPlayIndex < #currentMacros or loopPlayAll) then
                    updateStatus("FINDING CP", Color3.fromRGB(200, 150, 255))
                    findRandomCheckpoint(function(success)
                        if success then
                            wait(0.3)
                            continueToNextMacro()
                        else
                            -- Jika gagal pathfinding, tetap lanjut ke macro berikutnya
                            wait(0.2)
                            continueToNextMacro()
                        end
                    end)
                else
                    -- Tidak ada random CP atau sudah macro terakhir (tanpa looping)
                    continueToNextMacro()
                end
            end)
        else
            -- Single macro selesai
            if hasRandomCP then
                updateStatus("FINDING CP", Color3.fromRGB(200, 150, 255))
                findRandomCheckpoint(function(success)
                    if success then
                        wait(0.3)
                        resetPlayback()
                        needsPathfinding = true
                    else
                        resetPlayback()
                    end
                end)
            else
                resetPlayback()
            end
        end
    end
end

-- MODIFIED: Playback loop dengan RenderStepped - DENGAN HADAP BELAKANG
RunService.RenderStepped:Connect(function(dt)
    if playing and hrp and hum and #samples > 1 and not isPathfinding then
        playbackTime = playbackTime + dt * playSpeed

        while playIndex < #samples and samples[playIndex + 1].time <= playbackTime do
            playIndex = playIndex + 1
        end

        checkPlaybackCompletion()

        if playing and playIndex < #samples then
            local s1 = samples[playIndex]
            local s2 = samples[playIndex + 1]

            if s1 and s2 and s1.cf and s2.cf then
                local cf = s1.cf:Lerp(s2.cf, math.clamp((playbackTime - s1.time) / (s2.time - s1.time), 0, 1))

                -- NEW: Handle hadap belakang
                if faceBackwards then
                    -- Putar 180 derajat di sumbu Y
                    local rotation = CFrame.Angles(0, math.pi, 0)
                    cf = cf * rotation
                end

                hrp.CFrame = cf

                local dist = (s1.cf.Position - s2.cf.Position).Magnitude
                if s2.jump then
                    if hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                elseif dist > 0.08 then
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

local function loadDropdownData()
    if #macroLibrary > 0 then
        return true
    end

    updateStatus("LOADING MAPS", Color3.fromRGB(150, 200, 255))

    local success, dropdownJson, dropdownData
    local HttpService = game:GetService("HttpService")

    repeat
        success, dropdownJson = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/maps.json",
                true)
        end)

        if success and dropdownJson then
            local success2
            success2, dropdownData = pcall(function()
                return HttpService:JSONDecode(dropdownJson)
            end)

            if success2 and dropdownData and type(dropdownData) == "table" then
                local filteredMaps = filterMapsByGameId(dropdownData)
                macroLibrary = filteredMaps

                if #filteredMaps > 0 then
                    updateStatus("LOADED MAP", Color3.fromRGB(100, 200, 255))
                    return true
                else
                    updateStatus("GAME NOT SUPPORTED", Color3.fromRGB(255, 100, 100))
                    return false
                end
            end
        end

        updateStatus("FAILED LOAD MAPS - RETRYING...", Color3.fromRGB(255, 150, 100))
        task.wait(3) -- tunggu 3 detik sebelum mencoba lagi
    until success and dropdownData

    return false
end


-- Fungsi untuk load macro data dengan CACHE SYSTEM
local function loadMacroData(params, cpCount)
    if cpCount <= 0 then
        updateStatus("NO DATA", Color3.fromRGB(255, 150, 50))
        return {}
    end

    if loadedMacrosCache[params] then
        updateStatus("CACHE: " .. params, Color3.fromRGB(100, 200, 255))
        currentMacros = loadedMacrosCache[params]
        updateMacroList() -- MODIFIED: Update list langsung
        return currentMacros
    end

    local loadedMacros = {}

    updateStatus("LOADING " .. params .. " (" .. cpCount .. " CP)", Color3.fromRGB(150, 200, 255))

    for i = 1, cpCount do
        local url = string.format("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/%s/%d.json",
            params, i)

        local success, macroData = pcall(function()
            local jsonData = game:HttpGet(url, true)
            return HttpService:JSONDecode(jsonData)
        end)

        if success and macroData then
            local convertedSamples = {}

            if macroData.v and macroData.v == 1 then
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

            -- MODIFIED: Format nama HANYA untuk list - status tetap "CP"
            local listName = ""
            local displayName = ""
            if i == cpCount then
                -- Checkpoint terakhir
                displayName = "Summit"
                listName = "Summit"
            else
                -- Checkpoint biasa
                displayName = "CP " .. i
                listName = "Checkpoint " .. i
            end

            local macro = {
                name = params .. "_CP" .. i,
                displayName = displayName,
                listName = listName,
                samples = convertedSamples,
                params = params,
                cpIndex = i,
                sampleCount = #convertedSamples
            }

            table.insert(loadedMacros, macro)

            -- MODIFIED: Update current macros dan list secara real-time
            currentMacros = loadedMacros
            updateMacroList()

            updateStatus("LOADED CP (" .. i .. "/" .. cpCount .. ")",
                Color3.fromRGB(150, 255, 150))
        else
            updateStatus("FAILED CP (" .. i .. "/" .. cpCount .. ")", Color3.fromRGB(255, 150, 100))
        end

        wait(0.05)
    end

    table.sort(loadedMacros, function(a, b)
        return a.cpIndex < b.cpIndex
    end)

    loadedMacrosCache[params] = loadedMacros
    currentMacros = loadedMacros -- MODIFIED: Pastikan currentMacros terupdate
    updateMacroList()            -- MODIFIED: Update list final

    updateStatus("CACHED: " .. params .. " (" .. #loadedMacros .. " macros)", Color3.fromRGB(100, 255, 200))

    return loadedMacros
end

-- Fungsi untuk load dari cache atau load baru
local function loadOrGetMacros(params, cpCount)
    if loadedMacrosCache[params] then
        currentMacros = loadedMacrosCache[params] -- MODIFIED: Set current macros
        updateMacroList()                         -- MODIFIED: Update list langsung
        return loadedMacrosCache[params]
    else
        return loadMacroData(params, cpCount)
    end
end

-- MODIFIED: Fungsi untuk play semua macro yang sudah diload dengan handle random CP dan mulai dari terdekat
local function playAllMacros()
    if #currentMacros == 0 then
        updateStatus("NO MACROS", Color3.fromRGB(255, 150, 50))
        return
    end

    playingAll = true
    loopPlayAll = true                    -- NEW: Set looping aktif
    currentPlayIndex = findNearestMacro() -- NEW: Mulai dari macro terdekat

    local firstMacro = currentMacros[currentPlayIndex]
    if firstMacro then
        samples = firstMacro.samples
        selectedMacro = firstMacro
        playbackTime = 0
        playIndex = 1
        needsPathfinding = true

        -- MODIFIED: Tampilkan info random CP dan looping
        local randomCPInfo = ""
        if currentMapData and currentMapData.randomcp then
            randomCPInfo = " + RANDOM CP"
        end

        updateStatus("PLAYING ALL (" .. currentPlayIndex .. "/" .. #currentMacros .. ")" .. randomCPInfo .. " LOOP",
            Color3.fromRGB(100, 200, 255))
        startPlayback()
    end
end


function updateStatus(text, color)
    -- NEW: Perpendek text status yang terlalu panjang
    local shortText = text
    if string.len(text) > 15 then
        -- Ambil hanya kata-kata penting
        if text:find("PLAYING") then
            shortText = "PLAYING"
        elseif text:find("PATHFINDING") then
            shortText = "PATHFINDING"
        elseif text:find("TELEPORT") then
            shortText = "TELEPORT"
        elseif text:find("LOADING") then
            shortText = "LOADING"
        elseif text:find("FOUND") then
            shortText = "FOUND CP"
        elseif text:find("CACHED") then
            shortText = "CACHED"
        else
            -- Ambil 12 karakter pertama
            shortText = string.sub(text, 1, 12)
        end
    end
    StatusLabel.Text = shortText
    StatusLabel.TextColor3 = color
end

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Frame:TweenSize(UDim2.new(0, 230, 0, 28), "Out", "Quad", 0.3, true) -- MODIFIED: Width disesuaikan
        ContentFrame.Visible = false
    else
        Frame:TweenSize(UDim2.new(0, 230, 0, 350), "Out", "Quad", 0.3, true) -- MODIFIED: Width disesuaikan
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
local faceBackwardsBtn -- NEW: Tombol toggle hadap belakang

-- Update tampilan tombol play
local function updatePlayButton()
    if playing then
        playToggleBtn.Text = "⏸️" -- MODIFIED: Hanya icon
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    else
        playToggleBtn.Text = "▶️" -- MODIFIED: Hanya icon
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    end
end

-- NEW: Update tampilan tombol hadap belakang
local function updateFaceBackwardsButton()
    if faceBackwards then
        faceBackwardsBtn.Text = "🔁"
        faceBackwardsBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    else
        faceBackwardsBtn.Text = "🔀"
        faceBackwardsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end



-- Control buttons - MODIFIED: Diubah jadi icon saja dan disesuaikan layout
playToggleBtn = createBtn("▶️", UDim2.new(0.05, 0, 0, 235), UDim2.new(0.3, 0, 0, 26), -- MODIFIED: Text jadi icon, width 25%
    function()
        if selectedMacro then
            togglePlayback()
            updatePlayButton()
            updateMacroList()
        else
            updateStatus("SELECT CP FIRST", Color3.fromRGB(255, 150, 50))
        end
    end, Color3.fromRGB(60, 180, 60))

-- MODIFIED: Tombol Play All dengan looping jadi icon
createBtn("ALL", UDim2.new(0.36, 0, 0, 235), UDim2.new(0.28, 0, 0, 26), -- MODIFIED: Text jadi icon, width 25%
    function()
        if #currentMacros > 0 then
            playAllMacros()
            updateMacroList()
        else
            updateStatus("NO CP LOADED", Color3.fromRGB(255, 150, 50))
        end
    end, Color3.fromRGB(100, 150, 255))

createBtn("🔄️", UDim2.new(0.65, 0, 0, 235), UDim2.new(0.3, 0, 0, 26), -- MODIFIED: Text jadi icon, width 25%
    function()
        resetPlayback()
        updatePlayButton()
        playingAll = false
        loopPlayAll = false
        currentPlayIndex = 1
        updateMacroList()
    end, Color3.fromRGB(150, 150, 100))

-- NEW: Toggle Button untuk Hadap Belakang
faceBackwardsBtn = createBtn("🔀", UDim2.new(0.72, 0, 0, 205), UDim2.new(0.23, 0, 0, 26),
    function()
        faceBackwards = not faceBackwards
        updateFaceBackwardsButton()
        if faceBackwards then
            updateStatus("BACKWARD", Color3.fromRGB(100, 200, 200))
        else
            updateStatus("FORWARD", Color3.fromRGB(100, 200, 100))
        end
    end, Color3.fromRGB(60, 60, 60))


-- Speed Control - MODIFIED: Position disesuaikan
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
    updateStatus("SPEED " .. string.format("%.1fx", playSpeed), Color3.fromRGB(150, 200, 255))
end, Color3.fromRGB(80, 100, 180))

createBtn("▶", UDim2.new(0.7, 0, 0, 285), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = math.min(3.0, playSpeed + 0.1)
    speedDisplay.Text = string.format("%.1fx", playSpeed)
    updateStatus("SPEED " .. string.format("%.1fx", playSpeed), Color3.fromRGB(80, 160, 255))
end, Color3.fromRGB(40, 140, 240))

-- MODIFIED: Info label dengan nama map
local infoLabel = Instance.new("TextLabel", ContentFrame)
infoLabel.Text = "Map: None | CP: 0 | Selected: None"
infoLabel.Size = UDim2.new(0.9, 0, 0, 15)
infoLabel.Position = UDim2.new(0.05, 0, 0, 3)
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- FIXED: Update info label function yang lebih reliable
local function updateInfoLabel()
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

    -- Dapatkan nama map yang sedang dimainkan
    local mapName = "None"
    if currentMapData then
        mapName = currentMapData.nama or "Unknown"
    end

    -- Tambahan info looping
    local loopInfo = ""
    if loopPlayAll then
        loopInfo = " | 🔁"
    end

    -- Tambahan info random CP
    local randomCPInfo = ""
    if currentMapData and currentMapData.randomcp then
        randomCPInfo = " | 🎯"
    end

    -- PERBAIKAN: Hapus % yang tidak perlu setelah %d
    infoLabel.Text = string.format("%s | Selected: %s | %d/%d (%d%%)%s%s",
        mapName, selectedName, currentPlay, totalPlay, math.floor(progressPercent), loopInfo,
        randomCPInfo)
end

-- Load button dengan CACHE SYSTEM - DENGAN LOCK CHECK
local loadBtn = createBtn("📥 LOAD CHECKPOINT", UDim2.new(0.05, 0, 0, 205), UDim2.new(0.65, 0, 0, 26),
    function()
        if isLoadingMacros then
            return
        end
        if playing or isPathfinding or macroLocked then
            updateStatus("WAIT MACRO", Color3.fromRGB(255, 150, 50))
            return
        end

        if #macroLibrary > 0 then
            local selectedMap = macroLibrary[1]
            if selectedMap then
                currentMapData = selectedMap

                if selectedMap.cp <= 0 then
                    updateStatus("NO DATA", Color3.fromRGB(255, 150, 50))
                    return
                end

                -- MODIFIED: Only scan for checkpoints if the map has randomcp enabled
                if selectedMap.randomcp then
                    updateStatus("SCANNING CP", Color3.fromRGB(200, 150, 255))
                    findCheckpointParts()
                end

                updateStatus("LOADING CP", Color3.fromRGB(150, 200, 255))

                isLoadingMacros = true

                spawn(function()
                    local loadedMacros = loadOrGetMacros(selectedMap.params, selectedMap.cp)

                    -- MODIFIED: Hapus spawn nested karena sudah dihandle di loadMacroData
                    isLoadingMacros = false

                    if #currentMacros > 0 then
                        local statusMsg = "LOADED " .. #currentMacros .. " CP"
                        if selectedMap.randomcp then
                            statusMsg = statusMsg .. " + RANDOM"
                        end
                        updateStatus(statusMsg, Color3.fromRGB(100, 255, 100))

                        if currentMacros[1] then
                            selectedMacro = currentMacros[1]
                            samples = currentMacros[1].samples
                            resetPlayback()
                        end
                    else
                        updateStatus("NO CP LOADED", Color3.fromRGB(255, 150, 50))
                    end
                end)
            end
        else
            updateStatus("NO MAPS", Color3.fromRGB(255, 150, 50))
        end
    end, Color3.fromRGB(80, 120, 200))

-- Preload data saat startup dan cek game compatibility
spawn(function()
    wait(2)
    if loadDropdownData() then
        if #macroLibrary > 0 then
            updateStatus("GAME SUPPORTED", Color3.fromRGB(100, 255, 100))
            local currentGameId = getCurrentGameId()
            local gameName = "Unknown Game"
            for _, map in ipairs(macroLibrary) do
                if tostring(map.gameId) == currentGameId then
                    gameName = map.nama
                    break
                end
            end
            infoLabel.Text = "Map: " .. gameName .. " | Game ID: " .. currentGameId
        else
            updateStatus("GAME NOT SUPPORTED", Color3.fromRGB(255, 100, 100))
        end
    else
        updateStatus("FAILED LOAD", Color3.fromRGB(255, 100, 100))
    end
end)

-- Initialize toggle buttons
updateFaceBackwardsButton() -- NEW: Initialize tombol hadap belakang

-- Update button status dan timeout check
RunService.Heartbeat:Connect(function()
    -- Update info label setiap frame (lebih responsive)
    updateInfoLabel()

    updatePlayButton()

    -- MODIFIED: Update load button status berdasarkan lock loading
    if isLoadingMacros then
        loadBtn.Text = "⏳ LOADING..."
        loadBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 100)
        loadBtn.AutoButtonColor = false
    elseif playing or isPathfinding or macroLocked then
        loadBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        loadBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        loadBtn.AutoButtonColor = false
    else
        loadBtn.Text = "📥 LOAD CHECKPOINT"
        loadBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        loadBtn.TextColor3 = Color3.new(1, 1, 1)
        loadBtn.AutoButtonColor = true
    end

    if isPathfinding and tick() > pathfindingTimeout then
        isPathfinding = false
        macroLocked = false
        if hum then
            hum:MoveTo(hrp.Position)
        end
        updateStatus("PATH TIMEOUT", Color3.fromRGB(255, 150, 50))
    end

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
