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
local faceBackwards = false
local isLoadingMacros = false

-- NEW: Height adjustment system
local recordedHeight = 5.22
local currentHeight = 5.22

-- NEW: R15 Optimization Variables
local isR15 = false
local r15WalkSpeedMultiplier = 1.2
local r15JumpPowerMultiplier = 1.1
local r15WaypointTolerance = 4.5
local r15AgentRadius = 1.8
local r15AgentHeight = 6.0

-- Macro Library System
local macroLibrary = {}
local currentMacros = {}
local selectedMacro = nil
local playingAll = false
local currentPlayIndex = 1
local loopPlayAll = false

-- Local Storage untuk macros yang sudah diload
local loadedMacrosCache = {}

-- Random Checkpoint System
local Checkpoints = {}
local currentMapData = nil

-- Fungsi untuk update status
function updateStatus(text, color)
    if not StatusLabel then return end

    local shortText = text
    if string.len(text) > 15 then
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
            shortText = string.sub(text, 1, 20)
        end
    end

    StatusLabel.Text = shortText
    StatusLabel.TextColor3 = color
end

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

-- Fungsi untuk mendeteksi tipe karakter (R6 atau R15)
local function detectCharacterType()
    local char = player.Character
    if not char then return "Unknown" end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return "Unknown" end

    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        isR15 = true
        return "R15"
    else
        isR15 = false
        return "R6"
    end
end

-- Setup character dengan height detection
local function setupChar(char)
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")

    -- Detect character type
    detectCharacterType()

    -- Apply R15 optimizations if needed
    if isR15 then
        updateStatus("R15 OPTIMIZED", Color3.fromRGB(100, 200, 255))
    else
        updateStatus("R6 DETECTED", Color3.fromRGB(100, 255, 200))
    end
end

player.CharacterAdded:Connect(setupChar)
if player.Character then
    setupChar(player.Character)
end

--// AMBIL GROUND Y (RAYCAST)
local function getGroundY(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local rayOrigin = root.Position
    local rayDirection = Vector3.new(0, -1000, 0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { character }
    params.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(rayOrigin, rayDirection, params)
    if result then
        return result.Position.Y
    end
    return nil
end

--// HITUNG TINGGI KARAKTER DARI KAKI KE KEPALA
local function getCharacterHeight(character)
    local head = character:FindFirstChild("Head")
    if not head then return nil end

    local topY = head.Position.Y + (head.Size.Y / 2)
    local bottomY = nil

    -- Cari part kaki tergantung rig type
    if character:FindFirstChild("LeftFoot") then
        -- R15
        local lf = character.LeftFoot
        bottomY = lf.Position.Y - (lf.Size.Y / 2)
    elseif character:FindFirstChild("RightFoot") then
        local rf = character.RightFoot
        bottomY = rf.Position.Y - (rf.Size.Y / 2)
    elseif character:FindFirstChild("Left Leg") then
        -- R6
        local ll = character["Left Leg"]
        bottomY = ll.Position.Y - (ll.Size.Y / 2)
    elseif character:FindFirstChild("Right Leg") then
        local rl = character["Right Leg"]
        bottomY = rl.Position.Y - (rl.Size.Y / 2)
    else
        bottomY = getGroundY(character) or head.Position.Y - 3
    end

    local height = topY - bottomY
    return height
end

--// RATA-RATAKAN SUPAYA STABIL
local function getStableHeight(character)
    local total, count = 0, 10
    for i = 1, count do
        local h = getCharacterHeight(character)
        if h then total = total + h end
        task.wait(0.05)
    end
    return total / count
end

local function updateCurrentHeight()
    local char = player.Character or player.CharacterAdded:Wait()
    currentHeight = getStableHeight(char)
end

local function adjustSampleHeight(sampleCF, recordedH, currentH)
    if not sampleCF then
        return sampleCF
    end

    -- Jika tinggi sama, skip adjustment untuk performance
    if math.abs(recordedH - currentH) < 0.1 then
        return sampleCF
    end

    -- Adjust position Y berdasarkan perbedaan tinggi
    local heightDifference = currentH - recordedH

    local extraOffset = 0
    if currentH < recordedH then
        -- Karakter LEBIH PENDEK: butuh offset POSITIF agar tidak tenggelam
        extraOffset = 0.4 -- Tambah offset untuk karakter pendek
    else
        -- Karakter LEBIH TINGGI: butuh offset NEGATIF kecil
        extraOffset = -0.4 -- Sedikit offset untuk karakter tinggi
    end

    local totalHeightDifference = heightDifference + extraOffset

    local adjustedPosition = sampleCF.Position + Vector3.new(0, totalHeightDifference, 0)
    return CFrame.new(adjustedPosition) * (sampleCF - sampleCF.Position)
end

local function applyHeightAdjustmentToSamples(samplesArray)
    if not samplesArray then
        return samplesArray
    end

    local adjustedSamples = {}

    for _, sample in ipairs(samplesArray) do
        local adjustedSample = {
            time = sample.time,
            jump = sample.jump or false
        }

        if sample.cf then
            adjustedSample.cf = adjustSampleHeight(sample.cf, recordedHeight, currentHeight)
        end

        table.insert(adjustedSamples, adjustedSample)
    end

    return adjustedSamples
end

-- MODIFIED: Pathfinding System yang dioptimalkan untuk R15
local function moveToPosition(targetPosition, callback)
    if not hrp or not hum or isPathfinding then
        if callback then callback(false) end
        return false
    end

    isPathfinding = true
    macroLocked = true
    pathfindingTimeout = tick() + 12
    updateStatus("PATHFINDING", Color3.fromRGB(255, 200, 50))

    -- Adjust parameters based on character type
    local agentRadius = isR15 and r15AgentRadius or 2
    local agentHeight = isR15 and r15AgentHeight or 5
    local waypointTolerance = isR15 and r15WaypointTolerance or 3.5

    local path = PathfindingService:CreatePath({
        AgentRadius = agentRadius,
        AgentHeight = agentHeight,
        AgentCanJump = true,
        WaypointSpacing = isR15 and 4 or 6,
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

        -- NEW: R15-specific movement smoothing
        local function smoothMoveToWaypoint(waypointPos)
            local maxAttempts = isR15 and 3 or 2
            local attempt = 0

            while attempt < maxAttempts do
                attempt = attempt + 1
                local waypointStartTime = tick()
                hum:MoveTo(waypointPos)

                local distance = (waypointPos - hrp.Position).Magnitude
                while distance > waypointTolerance and isPathfinding do
                    -- Check overall timeout
                    if tick() > pathfindingTimeout then
                        return false
                    end

                    -- Check waypoint timeout
                    if tick() > waypointStartTime + (isR15 and 2.0 or 1.5) then
                        break
                    end

                    -- NEW: For R15, add slight movement assistance
                    if isR15 and distance > 8 then
                        local direction = (waypointPos - hrp.Position).Unit
                        hum:Move(direction * 0.5)
                    end

                    distance = (waypointPos - hrp.Position).Magnitude
                    RunService.Heartbeat:Wait()
                end

                if distance <= waypointTolerance then
                    return true
                end

                -- Small delay before retry
                if attempt < maxAttempts then
                    wait(0.1)
                end
            end

            return false
        end

        -- Follow waypoints
        for i = startIndex, #waypoints do
            if not isPathfinding then break end

            local waypoint = waypoints[i]

            -- Move to waypoint dengan sistem yang lebih smooth
            local success = smoothMoveToWaypoint(waypoint.Position)

            if not success then
                isPathfinding = false
                macroLocked = false
                hum:MoveTo(hrp.Position)
                updateStatus("PATH TIMEOUT", Color3.fromRGB(255, 150, 50))
                if callback then callback(false) end
                return false
            end

            -- Handle jumping dengan delay yang lebih baik untuk R15
            if waypoint.Action == Enum.PathWaypointAction.Jump and isPathfinding then
                if isR15 then
                    wait(0.1)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    wait(0.3)
                else
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    wait(0.2)
                end
            end

            -- Small delay between waypoints (shorter for R15)
            if i < #waypoints then
                wait(isR15 and 0.02 or 0.05)
            end
        end

        -- Check final distance dengan tolerance yang lebih longgar untuk R15
        local finalDistance = (targetPosition - hrp.Position).Magnitude
        local finalTolerance = isR15 and 12 or 10

        isPathfinding = false
        macroLocked = false

        if finalDistance <= finalTolerance then
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

-- MODIFIED: Fungsi untuk move ke posisi sample dengan optimasi R15
local function moveToSamplePosition(targetIndex, callback)
    if not hrp or not samples[targetIndex] or not samples[targetIndex].cf then
        if callback then callback(false) end
        return false
    end

    local targetPosition = samples[targetIndex].cf.Position
    local distance = (hrp.Position - targetPosition).Magnitude

    -- Tolerance yang lebih longgar untuk R15
    local teleportThreshold = isR15 and 50 or 40
    local closeThreshold = isR15 and 4 or 3

    -- Jika sudah dekat, tidak perlu melakukan apa-apa
    if distance <= closeThreshold then
        if callback then callback(true) end
        return true
    end

    -- NEW: Smart teleport system untuk R15
    if distance > teleportThreshold then
        updateStatus("TELEPORTING", Color3.fromRGB(255, 150, 50))

        -- Untuk R15, coba pathfinding dulu untuk jarak medium
        if isR15 and distance <= 70 then
            updateStatus("R15 PATHFINDING", Color3.fromRGB(200, 150, 255))
            return moveToPosition(targetPosition, function(success)
                if success then
                    if callback then callback(true) end
                else
                    -- Fallback ke teleport
                    local teleportSuccess = teleportToPosition(targetPosition)
                    if teleportSuccess then
                        updateStatus("TELEPORT OK", Color3.fromRGB(100, 255, 100))
                        if callback then callback(true) end
                    else
                        updateStatus("TELEPORT FAIL", Color3.fromRGB(255, 100, 100))
                        if callback then callback(false) end
                    end
                end
            end)
        else
            -- Direct teleport untuk jarak jauh
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
    end

    -- Pathfinding untuk jarak dekat-medium
    updateStatus("PATHFINDING", Color3.fromRGB(255, 200, 50))
    return moveToPosition(targetPosition, function(success)
        if success then
            if callback then callback(true) end
        else
            -- Fallback teleport jika pathfinding gagal
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

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 230, 0, 350)
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

-- Status Indicator
StatusLabel = Instance.new("TextLabel", TitleBar)
StatusLabel.Text = "READY"
StatusLabel.Size = UDim2.new(0, 110, 0, 18)
StatusLabel.Position = UDim2.new(1, -140, 0, 5)
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 9
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
local StatusCorner = Instance.new("UICorner", StatusLabel)
StatusCorner.CornerRadius = UDim.new(0, 6)

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

    if needsPathfinding then
        updateStatus("FINDING START", Color3.fromRGB(150, 200, 255))

        moveToNearestSample(function(success, startIndex)
            if success then
                playIndex = startIndex
                playbackTime = samples[startIndex].time
                needsPathfinding = false
                startFromNearest = (startIndex > 1)

                wait(0.1)
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

                updateStatus("FINAL TELEPORT", Color3.fromRGB(255, 150, 50))

                local targetPosition = samples[1].cf.Position
                local teleportSuccess = teleportToPosition(targetPosition)

                if teleportSuccess then
                    updateStatus("TELEPORT OK", Color3.fromRGB(100, 255, 100))
                    playIndex = 1
                    playbackTime = samples[1].time
                    needsPathfinding = false
                    startFromNearest = false

                    wait(0.1)
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

        local hasRandomCP = currentMapData and currentMapData.randomcp == true

        if playingAll and #currentMacros > 0 then
            spawn(function()
                wait(0.1)

                if hasRandomCP and (currentPlayIndex < #currentMacros or loopPlayAll) then
                    updateStatus("FINDING CP", Color3.fromRGB(200, 150, 255))
                    findRandomCheckpoint(function(success)
                        if success then
                            wait(0.1)
                            continueToNextMacro()
                        else
                            wait(0.1)
                            continueToNextMacro()
                        end
                    end)
                else
                    continueToNextMacro()
                end
            end)
        else
            if hasRandomCP then
                updateStatus("FINDING CP", Color3.fromRGB(200, 150, 255))
                findRandomCheckpoint(function(success)
                    if success then
                        wait(0.1)
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

-- MODIFIED: Playback loop dengan optimasi R15
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

                if faceBackwards then
                    local rotation = CFrame.Angles(0, math.pi, 0)
                    cf = cf * rotation
                end

                hrp.CFrame = cf

                local dist = (s1.cf.Position - s2.cf.Position).Magnitude

                if s2.jump then
                    if hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                elseif dist > (isR15 and 0.12 or 0.08) then
                    local moveDirection = (s2.cf.Position - s1.cf.Position).Unit

                    if isR15 then
                        hum:Move(moveDirection * 0.8)
                    else
                        hum:Move(moveDirection, false)
                    end
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
                    updateStatus("GAME UNSUPPORTED", Color3.fromRGB(255, 100, 100))
                    return false
                end
            end
        end

        updateStatus("FAILED LOAD MAPS - RETRYING...", Color3.fromRGB(255, 150, 100))
        task.wait(3)
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
        updateMacroList()
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

            local listName = ""
            local displayName = ""
            if i == cpCount then
                displayName = "Summit"
                listName = "Summit"
            else
                displayName = "CP " .. i
                listName = "Checkpoint " .. i
            end

            local adjustedSamples = applyHeightAdjustmentToSamples(convertedSamples)

            local macro = {
                name = params .. "_CP" .. i,
                displayName = displayName,
                listName = listName,
                samples = adjustedSamples,
                params = params,
                cpIndex = i,
                sampleCount = #adjustedSamples
            }

            table.insert(loadedMacros, macro)

            currentMacros = loadedMacros
            updateMacroList()

            updateStatus("LOADED CP (" .. i .. "/" .. cpCount .. ")", Color3.fromRGB(150, 255, 150))
        else
            updateStatus("FAILED CP (" .. i .. "/" .. cpCount .. ")", Color3.fromRGB(255, 150, 100))
        end

        wait(0.05)
    end

    table.sort(loadedMacros, function(a, b)
        return a.cpIndex < b.cpIndex
    end)

    loadedMacrosCache[params] = loadedMacros
    currentMacros = loadedMacros
    updateMacroList()

    updateStatus("CACHED: " .. params .. " (" .. #loadedMacros .. " macros)", Color3.fromRGB(100, 255, 200))

    return loadedMacros
end

-- Fungsi untuk load dari cache atau load baru
local function loadOrGetMacros(params, cpCount)
    if loadedMacrosCache[params] then
        currentMacros = loadedMacrosCache[params]
        updateMacroList()
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
    loopPlayAll = true
    currentPlayIndex = findNearestMacro()

    local firstMacro = currentMacros[currentPlayIndex]
    if firstMacro then
        samples = firstMacro.samples
        selectedMacro = firstMacro
        playbackTime = 0
        playIndex = 1
        needsPathfinding = true

        local randomCPInfo = ""
        if currentMapData and currentMapData.randomcp then
            randomCPInfo = " + RANDOM CP"
        end

        updateStatus("PLAYING ALL (" .. currentPlayIndex .. "/" .. #currentMacros .. ")" .. randomCPInfo .. " LOOP",
            Color3.fromRGB(100, 200, 255))
        startPlayback()
    end
end

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
local faceBackwardsBtn

-- Update tampilan tombol play
local function updatePlayButton()
    if playing then
        playToggleBtn.Text = "⏸️"
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    else
        playToggleBtn.Text = "▶️"
        playToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    end
end

-- Update tampilan tombol hadap belakang
local function updateFaceBackwardsButton()
    if faceBackwards then
        faceBackwardsBtn.Text = "🔁"
        faceBackwardsBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    else
        faceBackwardsBtn.Text = "🔀"
        faceBackwardsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end

-- Control buttons
playToggleBtn = createBtn("▶️", UDim2.new(0.05, 0, 0, 235), UDim2.new(0.3, 0, 0, 26), function()
    if selectedMacro then
        togglePlayback()
        updatePlayButton()
        updateMacroList()
    else
        updateStatus("SELECT CP FIRST", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(60, 180, 60))

createBtn("ALL", UDim2.new(0.36, 0, 0, 235), UDim2.new(0.28, 0, 0, 26), function()
    if #currentMacros > 0 then
        playAllMacros()
        updateMacroList()
    else
        updateStatus("NO CP LOADED", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(100, 150, 255))

createBtn("🔄️", UDim2.new(0.65, 0, 0, 235), UDim2.new(0.3, 0, 0, 26), function()
    resetPlayback()
    updatePlayButton()
    playingAll = false
    loopPlayAll = false
    currentPlayIndex = 1
    updateMacroList()
end, Color3.fromRGB(150, 150, 100))

faceBackwardsBtn = createBtn("🔀", UDim2.new(0.72, 0, 0, 205), UDim2.new(0.23, 0, 0, 26), function()
    faceBackwards = not faceBackwards
    updateFaceBackwardsButton()
    if faceBackwards then
        updateStatus("BACKWARD", Color3.fromRGB(100, 200, 200))
    else
        updateStatus("FORWARD", Color3.fromRGB(100, 200, 100))
    end
end, Color3.fromRGB(60, 60, 60))

-- Speed Control
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

-- Info label dengan nama map
local infoLabel = Instance.new("TextLabel", ContentFrame)
infoLabel.Text = "Map: None | CP: 0 | Selected: None"
infoLabel.Size = UDim2.new(0.9, 0, 0, 15)
infoLabel.Position = UDim2.new(0.05, 0, 0, 3)
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Update info label function
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

    local mapName = "None"
    if currentMapData then
        mapName = currentMapData.nama or "Unknown"
    end

    local loopInfo = ""
    if loopPlayAll then
        loopInfo = " | 🔁"
    end

    local randomCPInfo = ""
    if currentMapData and currentMapData.randomcp then
        randomCPInfo = " | 🎯"
    end

    infoLabel.Text = string.format("%s | Selected: %s | %d/%d (%d%%)%s%s",
        mapName, selectedName, currentPlay, totalPlay, math.floor(progressPercent), loopInfo, randomCPInfo)
end

-- Load button dengan CACHE SYSTEM
local loadBtn = createBtn("📥 LOAD CHECKPOINT", UDim2.new(0.05, 0, 0, 205), UDim2.new(0.65, 0, 0, 26), function()
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

            updateCurrentHeight()

            if selectedMap.randomcp then
                updateStatus("SCANNING CP", Color3.fromRGB(200, 150, 255))
                findCheckpointParts()
            end

            updateStatus("LOADING CP", Color3.fromRGB(150, 200, 255))

            isLoadingMacros = true

            spawn(function()
                local loadedMacros = loadOrGetMacros(selectedMap.params, selectedMap.cp)

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

-- Initialize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Frame:TweenSize(UDim2.new(0, 230, 0, 28), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = false
    else
        Frame:TweenSize(UDim2.new(0, 230, 0, 350), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = true
    end
end)

-- Initialize toggle buttons
spawn(function()
    wait(0.5)
    updateFaceBackwardsButton()
    detectCharacterType()
    if isR15 then
        updateStatus("R15 OPTIMIZED", Color3.fromRGB(100, 200, 255))
    else
        updateStatus("R6 DETECTED", Color3.fromRGB(100, 255, 200))
    end
end)

-- Preload data saat startup
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
            updateStatus("GAME UNSUPPORTED", Color3.fromRGB(255, 100, 100))
        end
    else
        updateStatus("GAME UNSUPPORTED", Color3.fromRGB(255, 100, 100))
    end
end)

-- Update button status dan timeout check
RunService.Heartbeat:Connect(function()
    updateInfoLabel()
    updatePlayButton()

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
