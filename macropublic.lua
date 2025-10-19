-- Service
local StarterGui = game:GetService("StarterGui")

-- -- Cegah execute berulang
if _G.MacroLoaderExecuted then
    StarterGui:SetCore("SendNotification", {
        Title = "@LILDANZVERT",
        Text = "Script sudah berjalan!",
        Icon = "rbxassetid://139272023821134",
        Duration = 5
    })
    return
end
_G.MacroLoaderExecuted = true

-- Service
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--// Whitelist Checker System //--
local WhitelistPassed = false
local WhitelistGUI = nil
local CountdownGUI = nil
local ScriptStarted = false

-- Fungsi untuk kick player
local function kickPlayer(reason)
    pcall(function()
        Players.LocalPlayer:Kick(reason)
    end)
end

-- Fungsi untuk menghapus semua GUI macro
local function cleanupMacroGUI()
    pcall(function()
        if Instance.new("ScreenGui") and Instance.new("ScreenGui").Parent then
            Instance.new("ScreenGui"):Destroy()
        end
    end)
end


-- Fungsi untuk membuat GUI countdown kecil di pojok kanan bawah (HANYA JIKA WHITELIST VALID)
local function createCountdownGUI()
    if CountdownGUI then CountdownGUI:Destroy() end

    CountdownGUI = Instance.new("ScreenGui")
    CountdownGUI.Name = "CountdownGUI"
    CountdownGUI.ResetOnSpawn = false
    CountdownGUI.Parent = game:GetService("CoreGui")

    local padding = 10

    -- Buat frame dulu (sementara)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = CountdownGUI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Label waktu
    local timeLabel = Instance.new("TextLabel")
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 12
    timeLabel.Text = "Loading..."
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = frame

    -- Fungsi untuk update ukuran frame otomatis
    local function updateSize()
        local textBounds = timeLabel.TextBounds
        local frameWidth = textBounds.X + (padding * 2)
        local frameHeight = textBounds.Y + (padding * 2)

        frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
        timeLabel.Size = UDim2.new(1, -padding * 2, 1, -padding * 2)
        timeLabel.Position = UDim2.new(0, padding, 0, padding)

        -- posisikan di pojok kanan bawah dengan margin 5px
        frame.Position = UDim2.new(1, -(frameWidth + 5), 1, -(frameHeight + 5))
    end

    -- Update otomatis kalau teks berubah
    timeLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)

    -- Jalankan sekali di awal
    updateSize()

    return timeLabel
end


-- Fungsi untuk membuat GUI expired notification
local function createExpiredGUI(message)
    -- Hancurkan CountdownGUI jika ada (tidak tampilkan GUI pojok kanan saat expired)
    if CountdownGUI then
        CountdownGUI:Destroy()
        CountdownGUI = nil
    end

    if WhitelistGUI then WhitelistGUI:Destroy() end

    WhitelistGUI = Instance.new("ScreenGui")
    WhitelistGUI.Name = "ExpiredNotification"
    WhitelistGUI.ResetOnSpawn = false
    WhitelistGUI.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 140)
    frame.Position = UDim2.new(0.5, -150, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = WhitelistGUI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 30)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ WHITELIST EXPIRED"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(255, 100, 100)
    title.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 50)
    messageLabel.Position = UDim2.new(0, 10, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextWrapped = true
    messageLabel.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 80, 0, 25)
    closeBtn.Position = UDim2.new(0.5, -40, 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.Text = "CLOSE"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Parent = frame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        _G.MacroLoaderExecuted = false
        local link = "https://discord.com/users/631024330427334656"
        setclipboard(link)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Discord Admin",
            Text = "Link Discord Admin disalin ke clipboard!",
            Duration = 3
        })

        WhitelistGUI:Destroy()
        WhitelistGUI = nil
    end)

    -- Tidak bisa di-close dengan cara lain
    frame.Active = false
    frame.Draggable = false

    return WhitelistGUI
end

-- Fungsi format waktu
local function formatTime(seconds)
    if seconds < 0 then
        return "0 detik"
    end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02dj %02dm %02ds", h, m, s)
end

-- Fungsi untuk handle expired selama runtime
local function handleRuntimeExpired()
    -- Tandai bahwa script sudah berjalan sebelumnya
    ScriptStarted = true

    -- Hapus semua GUI macro
    cleanupMacroGUI()

    -- Tampilkan notifikasi expired
    createExpiredGUI("Masa aktif whitelist Anda telah habis.\nAnda akan dikick dari game.", false)

    -- Tunggu sebentar lalu kick player
    wait(3)
    kickPlayer("Whitelist expired. Silakan perpanjang untuk menggunakan script.")
end

-- Fungsi utama cek whitelist
-- Fungsi utama cek whitelist
local function checkWhitelist()
    local username = game:GetService("Players").LocalPlayer.Name
    local whitelistURL = "https://pastebin.com/raw/Y1yit0ZF"

    local success, result = pcall(function()
        return game:HttpGet(whitelistURL)
    end)

    if not success then
        createExpiredGUI("Gagal terhubung ke server whitelist.\nSilakan coba lagi nanti.", true)
        return false
    end

    local successDecode, whitelistData = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)

    if not successDecode then
        createExpiredGUI("Format data whitelist tidak valid.\nHubungi developer.", true)
        return false
    end

    local foundEntry
    for _, entry in ipairs(whitelistData) do
        if entry.username:lower() == username:lower() then
            foundEntry = entry
            break
        end
    end

    if not foundEntry then
        createExpiredGUI(
            "Username Anda tidak terdaftar dalam whitelist.\nScript tidak dapat dijalankan.\n\nHubungi Admin : @lildanz.",
            true)
        return false
    end

    -- Parse tanggal expired
    local pattern = "(%d+)%-(%d+)%-(%d+)%s+(%d+):(%d+)"
    local y, m, d, h, min = string.match(foundEntry.expired, pattern)
    if not (y and m and d and h and min) then
        createExpiredGUI("Format tanggal expired tidak valid.\n\nHubungi developer.", true)
        return false
    end

    -- Asumsikan expired di WIB (+7 jam dari UTC)
    local expiredUTC = os.time({
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = tonumber(h),
        min = tonumber(min)
    }) - (7 * 3600)

    local function updateCountdown()
        local now = os.time()
        local remaining = expiredUTC - now

        if remaining > 0 then
            return true, remaining
        else
            return false, 0
        end
    end

    -- Update pertama kali
    local isValid, remainingTime = updateCountdown()

    if isValid then
        -- BUAT COUNTDOWN GUI HANYA JIKA WHITELIST VALID
        local timeLabel = createCountdownGUI()
        timeLabel.Text = "Expired: " .. formatTime(remainingTime)

        -- Jalankan update real-time
        spawn(function()
            while CountdownGUI and CountdownGUI.Parent do
                local stillValid, timeLeft = updateCountdown()
                if stillValid then
                    timeLabel.Text = "Expired: " .. formatTime(timeLeft)
                else
                    -- Jika expired selama runtime, handle dengan kick player
                    if ScriptStarted then
                        handleRuntimeExpired()
                    else
                        -- Jika expired di awal, hanya tampilkan notifikasi
                        CountdownGUI:Destroy()
                        CountdownGUI = nil
                        createExpiredGUI(
                            "Masa aktif whitelist Anda telah habis.\nSilakan perpanjang untuk menggunakan script.\n\nHubungi Admin : @lildanz.",
                            true)
                    end
                    break
                end
                wait(1)
            end
        end)

        return true
    else
        -- JANGAN BUAT COUNTDOWN GUI JIKA EXPIRED DI AWAL
        createExpiredGUI(
            "Masa aktif whitelist Anda telah habis.\nSilakan perpanjang untuk menggunakan script.\n\nHubungi Admin : @lildanz.",
            true)
        return false
    end
end

-- Cek whitelist terlebih dahulu
WhitelistPassed = checkWhitelist()

if not WhitelistPassed then
    -- Hentikan eksekusi script jika whitelist gagal
    return
end

-- Tandai bahwa script sudah mulai berjalan
ScriptStarted = true

-- Setting SCript sudah berjalan
_G.MacroLoaderExecuted = true
StarterGui:SetCore("SendNotification", {
    Title = "AUTO WALK",
    Text = "Created by @lildanzvert",
    Icon = "rbxassetid://139272023821134",
    Duration = 5
})

-- Services
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

-- Variabel karakter akan di-set ulang setiap kali karakter berubah
local character, hrp, hum

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
local currentHeight = 5.20

-- Macro Library System
local macroLibrary = {}
local currentMacros = {}
local selectedMacro = nil
local playingAll = false
local currentPlayIndex = 1
local loopPlayAll = false

-- Tambahkan variabel untuk smooth rotation
local smoothRotationProgress = 0
local smoothRotationTarget = 0
local smoothRotationDuration = 0.2
local smoothRotationStartTime = 0

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

-- MODIFIED: Fungsi untuk mendapatkan karakter dengan safety check
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- MODIFIED: Fungsi untuk mendapatkan HRP dengan safety check
local function getHRP()
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

-- MODIFIED: Fungsi untuk mendapatkan Humanoid dengan safety check
local function getHumanoid()
    if not character then return nil end
    return character:FindFirstChild("Humanoid")
end

-- Fungsi untuk mendeteksi tipe karakter (R6 atau R15)
local function detectCharacterType()
    local char = player.Character
    if not char then return "Unknown" end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return "Unknown" end
end

local function stopPlayback()
    playing = false
    macroLocked = false
    isPathfinding = false

    character = getCharacter()
    hum = getHumanoid()

    if hum then
        hum:Move(Vector3.new(), false)
    end
    updateStatus("READY", Color3.fromRGB(100, 200, 100))
end

-- Setup character dengan height detection
local function setupChar(char)
    character = char

    -- Tunggu sampai Humanoid dan HRP tersedia
    local success, humanoid = pcall(function()
        return char:WaitForChild("Humanoid")
    end)

    local success2, humanoidRootPart = pcall(function()
        return char:WaitForChild("HumanoidRootPart")
    end)

    if success and success2 then
        hum = humanoid
        hrp = humanoidRootPart

        -- Detect character type
        detectCharacterType()

        -- Reset playback state ketika karakter baru spawn
        if playing then
            stopPlayback()
            updateStatus("RESPAWNED", Color3.fromRGB(255, 150, 50))
        end

        updateStatus("READY", Color3.fromRGB(100, 200, 100))
    else
        updateStatus("CHAR FAILED", Color3.fromRGB(255, 100, 100))
    end
end

-- MODIFIED: Handle karakter mati dan respawn
local function onCharacterAdded(char)
    setupChar(char)

    -- Deteksi ketika karakter mati
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        updateStatus("DIED (RESPAWN)", Color3.fromRGB(255, 100, 100))

        -- Stop semua aktivitas
        playing = false
        isPathfinding = false
        macroLocked = false

        -- Reset referensi karakter
        character = nil
        hrp = nil
        hum = nil
    end)
end

-- MODIFIED: Inisialisasi karakter pertama kali
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- fungsi hitung tinggi karakter
local function getCharacterHeight(char)
    local minY, maxY = math.huge, -math.huge
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local y1 = part.Position.Y - (part.Size.Y / 2)
            local y2 = part.Position.Y + (part.Size.Y / 2)
            minY = math.min(minY, y1)
            maxY = math.max(maxY, y2)
        end
    end
    return maxY - minY
end

local function updateCurrentHeight()
    currentHeight = getCharacterHeight(character)
    return currentHeight
end

local recordHRPtoFeetDistance = 2.85 -- jarak hrp ke kaki dari karakter Record
-- Fungsi untuk mendapatkan jarak HRP ke kaki terendah
local function getHRPToFeetDistance(character)
    if not character then return 0 end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end

    local leftFoot = character:FindFirstChild("LeftFoot")
    local rightFoot = character:FindFirstChild("RightFoot")

    -- Jika tidak ada kaki (misal R6), fallback ke Torso
    if not leftFoot or not rightFoot then
        leftFoot = character:FindFirstChild("LeftLeg")
        rightFoot = character:FindFirstChild("RightLeg")
    end

    if not leftFoot or not rightFoot then return 0 end

    local minFootY = math.min(leftFoot.Position.Y, rightFoot.Position.Y)
    local distance = hrp.Position.Y - minFootY

    return distance
end

local function adjustSampleHeight(sampleCF)
    character = getCharacter()

    if not sampleCF then
        return sampleCF
    end

    local charHRPtoFeet = getHRPToFeetDistance(character)

    -- Jika tinggi sama, skip adjustment untuk performance
    if math.abs(charHRPtoFeet - recordHRPtoFeetDistance) < 0.1 then
        return sampleCF
    end

    if charHRPtoFeet < 0 then
        charHRPtoFeet = charHRPtoFeet - 0.1
    else
        charHRPtoFeet = charHRPtoFeet + 0.1
    end

    -- Adjust position Y berdasarkan perbedaan tinggi
    local heightDifference = charHRPtoFeet - recordHRPtoFeetDistance

    -- Jika tinggi sama, skip adjustment untuk performance
    if math.abs(heightDifference) < 0.1 then
        return sampleCF
    end

    local adjustedPosition = sampleCF.Position + Vector3.new(0, heightDifference + 0.1, 0)
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
            adjustedSample.cf = adjustSampleHeight(sample.cf)
        end

        table.insert(adjustedSamples, adjustedSample)
    end

    return adjustedSamples
end

local function moveToPosition(targetPosition, callback)
    -- Safety check
    character = getCharacter()
    hrp = getHRP()
    hum = getHumanoid()

    if not hrp or not hum or isPathfinding then
        if callback then callback(false) end
        return false
    end

    isPathfinding = true
    macroLocked = true
    pathfindingTimeout = tick() + 20

    -- SIMPAN walkspeed asli untuk restore nanti
    local originalWalkSpeed = hum.WalkSpeed
    local adjustedWalkSpeed = false

    -- CEK DAN SET WALKSPEED JIKA DIBAWAH 20
    if hum.WalkSpeed < 20 then
        hum.WalkSpeed = hum.WalkSpeed + 3
        if hum.WalkSpeed > 20 then
            hum.WalkSpeed = 20
        end
        adjustedWalkSpeed = true
    end

    local charHeight = getCharacterHeight(character)

    -- buat path dengan tinggi karakter
    local pathParams = {
        AgentHeight = charHeight,
        AgentRadius = 2,
        AgentCanJump = true,
        AgentJumpHeight = 10,
    }

    local path = PathfindingService:CreatePath(pathParams)

    -- Safety check sebelum compute path
    if not character or not character.PrimaryPart then
        isPathfinding = false
        macroLocked = false
        if adjustedWalkSpeed and hum then
            hum.WalkSpeed = originalWalkSpeed
        end
        if callback then callback(false) end
        return false
    end

    path:ComputeAsync(character.PrimaryPart.Position, targetPosition)

    -- Compute path
    if path.Status ~= Enum.PathStatus.Success then
        isPathfinding = false
        macroLocked = false
        -- RESTORE WALKSPEED asli sebelum return
        if adjustedWalkSpeed and hum then
            hum.WalkSpeed = originalWalkSpeed
        end
        updateStatus("PATH ERROR", Color3.fromRGB(255, 100, 100))
        if callback then callback(false) end
        return false
    end

    -- fungsi untuk deteksi stuck
    local function isStuck(lastPos, newPos, threshold)
        return (lastPos - newPos).Magnitude < threshold
    end

    -- variabel kontrol
    local lastPos = character.PrimaryPart.Position
    local stuckTime = 0
    local checkInterval = 0.5
    local stuckThreshold = 0.2
    local stuckTimeout = 2

    if path.Status == Enum.PathStatus.Success then
        -- loop cek posisi & anti-stuck
        task.spawn(function()
            while isPathfinding and character and character.Parent do
                task.wait(checkInterval)
                local currentPos = character.PrimaryPart.Position
                if isStuck(lastPos, currentPos, stuckThreshold) then
                    stuckTime = stuckTime + checkInterval
                    if stuckTime >= stuckTimeout then
                        if hum then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                        stuckTime = 0
                    end
                else
                    stuckTime = 0
                end
                lastPos = currentPos
            end
        end)

        local waypoints = path:GetWaypoints()
        -- jalankan pathfinding
        for _, waypoint in ipairs(waypoints) do
            if not isPathfinding or not character or not character.Parent then break end
            hum:MoveTo(waypoint.Position)
            hum.MoveToFinished:Wait()
        end

        if #waypoints == 0 then
            isPathfinding = false
            macroLocked = false
            -- RESTORE WALKSPEED asli
            if adjustedWalkSpeed and hum then
                hum.WalkSpeed = originalWalkSpeed
            end
            updateStatus("AT TARGET", Color3.fromRGB(100, 255, 100))
            if callback then callback(true) end
            return true
        end

        -- Check final distance dengan tolerance yang lebih longgar untuk R15
        local finalDistance = (targetPosition - character.PrimaryPart.Position).Magnitude
        local finalTolerance = 5

        isPathfinding = false
        macroLocked = false

        -- RESTORE WALKSPEED asli sebelum return
        if adjustedWalkSpeed and hum then
            hum.WalkSpeed = originalWalkSpeed
        end

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
        -- RESTORE WALKSPEED asli
        if adjustedWalkSpeed and hum then
            hum.WalkSpeed = originalWalkSpeed
        end
        updateStatus("NO PATH", Color3.fromRGB(255, 100, 100))
        if callback then callback(false) end
        return false
    end
end

-- Fungsi untuk teleport ke posisi target
local function teleportToPosition(targetPosition)
    character = getCharacter()
    hrp = getHRP()

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
    character = getCharacter()
    hrp = getHRP()

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

-- MODIFIED: Fungsi untuk move ke posisi sample terdekat
local function moveToSamplePosition(targetIndex, callback)
    if not hrp or not samples[targetIndex] or not samples[targetIndex].cf then
        if callback then callback(false) end
        return false
    end

    local targetPosition = samples[targetIndex].cf.Position
    local distance = (hrp.Position - targetPosition).Magnitude

    -- Jika sudah dekat, tidak perlu melakukan apa-apa
    if distance <= 3 then
        if callback then callback(true) end
        return true
    end

    -- MODIFIED: Direct teleport untuk semua jarak > 40 stud (baik R15 maupun R6)
    if distance > 40 then
        updateStatus("TELEPORTING", Color3.fromRGB(255, 150, 50))

        -- Direct teleport untuk semua kasus jarak jauh
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

    -- Pathfinding hanya untuk jarak dekat-medium (3-40 stud)
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
            updateStatus("FINDING CP", Color3.fromRGB(100, 200, 255))
        end
    else
        if distance > 40 then
            updateStatus("TELEPORT START", Color3.fromRGB(200, 150, 255))
        else
            updateStatus("FINDING START", Color3.fromRGB(100, 200, 255))
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
                -- nameLower:find("parts") or // summit to base yahayuk
                nameLower:find("goal") then
                table.insert(Checkpoints, {
                    Part = obj,
                    Name = obj.Name,
                    Position = obj.Position
                })
            end
        end
    end

    return Checkpoints
end

-- Fungsi untuk mencari checkpoint terdekat
local function findNearestCheckpoint(maxDistance)
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
    findCheckpointParts()

    -- Cari checkpoint terdekat dalam jarak 50 stud
    local nearestCheckpoint, distance = findNearestCheckpoint(50)

    if nearestCheckpoint then
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

-- MODIFIED: Fungsi untuk memilih versi dalam threshold group
local function selectNearestVersionOrRandom(macro)
    if not macro or not macro.versions or #macro.versions == 0 then
        return nil
    end

    -- Jika hanya satu versi, langsung return
    if #macro.versions == 1 then
        return macro.versions[1]
    end

    -- Cari versi terdekat berdasarkan posisi karakter
    if hrp then
        local currentPos = hrp.Position
        local thresholdDistance = 10 -- STUD: Semua versi dalam 10 stud dianggap "sama dekat"
        local eligibleVersions = {}  -- Simpan versi yang dalam threshold

        -- Cari versi terdekat untuk threshold reference
        local absoluteMinDistance = math.huge
        for _, version in ipairs(macro.versions) do
            if version.samples and #version.samples > 0 then
                local versionMinDistance = math.huge
                for _, sample in ipairs(version.samples) do
                    if sample.cf then
                        local distance = (currentPos - sample.cf.Position).Magnitude
                        if distance < versionMinDistance then
                            versionMinDistance = distance
                        end
                    end
                end

                if versionMinDistance < absoluteMinDistance then
                    absoluteMinDistance = versionMinDistance
                end
            end
        end

        -- Kumpulkan semua versi yang dalam threshold (10 stud dari yang terdekat)
        for _, version in ipairs(macro.versions) do
            if version.samples and #version.samples > 0 then
                local versionMinDistance = math.huge
                for _, sample in ipairs(version.samples) do
                    if sample.cf then
                        local distance = (currentPos - sample.cf.Position).Magnitude
                        if distance < versionMinDistance then
                            versionMinDistance = distance
                        end
                    end
                end

                -- Jika versi ini dalam 10 stud dari versi terdekat absolut, masukkan ke eligible
                if versionMinDistance <= absoluteMinDistance + thresholdDistance then
                    table.insert(eligibleVersions, {
                        version = version,
                        distance = versionMinDistance
                    })
                end
            end
        end

        -- Jika ada versi dalam threshold group, pilih random
        if #eligibleVersions > 0 then
            local selected = eligibleVersions[math.random(1, #eligibleVersions)]
            return selected.version
        end
    end

    -- Fallback: random dari semua versi
    local randomVersion = macro.versions[math.random(1, #macro.versions)]
    updateStatus("RANDOM " .. randomVersion.name, Color3.fromRGB(200, 150, 255))
    return randomVersion
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

local function resetPlayback()
    playbackTime = 0
    playIndex = 1
    playing = false
    macroLocked = false
    isPathfinding = false
    needsPathfinding = true
    startFromNearest = false
    playingAll = false
    loopPlayAll = false

    character = getCharacter()
    hum = getHumanoid()

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

-- MODIFIED: Function untuk update macro list dengan SATU entry per checkpoint
local function updateMacroList()
    macroListLabel.Text = "Daftar Checkpoint: (" .. #currentMacros .. ")"

    for _, child in ipairs(macroScrollFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for i, macro in ipairs(currentMacros) do
        local macroBtn = Instance.new("TextButton")
        macroBtn.Size = UDim2.new(0.98, 0, 0, 26)
        macroBtn.LayoutOrder = i

        -- Tampilkan satu entry dengan keterangan versi
        local versionInfo = ""
        if macro.isMultiVersion then
            versionInfo = " (" .. macro.versionCount .. " versi)"
        end

        macroBtn.Text = "  " .. macro.listName .. versionInfo

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
                updateStatus("CHECKPOINT LOCKED", Color3.fromRGB(255, 150, 50))
                return
            end

            -- NEW: Auto-detect versi terdekat atau random
            local selectedVersion = selectNearestVersionOrRandom(macro)

            if selectedVersion then
                selectedMacro = {
                    name = macro.name .. selectedVersion.suffix,
                    displayName = macro.displayName,
                    listName = macro.listName,
                    samples = selectedVersion.samples,
                    params = macro.params,
                    cpIndex = macro.cpIndex,
                    version = selectedVersion.name,
                    versionSuffix = selectedVersion.suffix,
                    sampleCount = selectedVersion.sampleCount,
                    isMultiVersion = macro.isMultiVersion
                }
                samples = selectedVersion.samples
                resetPlayback()

                local versionInfo = ""
                if macro.isMultiVersion then
                    versionInfo = " [" .. selectedVersion.name .. "]"
                end

                updateStatus(macro.displayName .. versionInfo, Color3.fromRGB(150, 200, 255))
            else
                updateStatus("NO VERSION AVAILABLE", Color3.fromRGB(255, 100, 100))
                return
            end

            -- Highlight button yang dipilih
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

-- MODIFIED: Fungsi untuk mendapatkan random version dari checkpoint tertentu
local function getRandomVersionForCP(cpIndex)
    for _, macro in ipairs(currentMacros) do
        if macro.cpIndex == cpIndex and macro.versions and #macro.versions > 0 then
            if #macro.versions == 1 then
                return macro.versions[1]
            else
                -- Random selection untuk multi-version
                return macro.versions[math.random(1, #macro.versions)]
            end
        end
    end
    return nil
end

-- MODIFIED: Fungsi untuk create macro object dari version data
local function createMacroFromVersion(macroData, versionData)
    return {
        name = macroData.name .. (versionData.suffix or ""),
        displayName = macroData.displayName,
        listName = macroData.listName,
        samples = versionData.samples,
        params = macroData.params,
        cpIndex = macroData.cpIndex,
        version = versionData.name or "Base",
        versionSuffix = versionData.suffix or "",
        sampleCount = versionData.sampleCount,
        isMultiVersion = macroData.isMultiVersion
    }
end

-- MODIFIED: Fungsi untuk mencari posisi terdekat dengan threshold PER CP
local function findNearestPositionAcrossAllMacros()
    if not hrp or #currentMacros == 0 then
        return nil, nil, nil, math.huge
    end

    local currentPos = hrp.Position
    local thresholdDistance = 10
    local cpCandidates = {} -- Group candidates by CP index

    -- Cari absolute min distance PER CP
    local cpMinDistances = {}
    for _, macro in ipairs(currentMacros) do
        if macro.versions then
            local cpMinDistance = math.huge
            for _, version in ipairs(macro.versions) do
                if version.samples and #version.samples > 0 then
                    for sampleIndex, sample in ipairs(version.samples) do
                        if sample.cf then
                            local distance = (currentPos - sample.cf.Position).Magnitude
                            if distance < cpMinDistance then
                                cpMinDistance = distance
                            end
                        end
                    end
                end
            end
            cpMinDistances[macro.cpIndex] = cpMinDistance
        end
    end

    -- Kumpulkan candidates PER CP yang dalam threshold
    for _, macro in ipairs(currentMacros) do
        if macro.versions then
            local cpCandidatesList = {}
            for _, version in ipairs(macro.versions) do
                if version.samples and #version.samples > 0 then
                    for sampleIndex, sample in ipairs(version.samples) do
                        if sample.cf then
                            local distance = (currentPos - sample.cf.Position).Magnitude
                            local cpMinDistance = cpMinDistances[macro.cpIndex] or math.huge

                            if distance <= cpMinDistance + thresholdDistance then
                                table.insert(cpCandidatesList, {
                                    macro = macro,
                                    version = version,
                                    sampleIndex = sampleIndex,
                                    distance = distance
                                })
                            end
                        end
                    end
                end
            end

            if #cpCandidatesList > 0 then
                cpCandidates[macro.cpIndex] = cpCandidatesList
            end
        end
    end

    -- Cari CP dengan jarak terdekat secara absolut
    local nearestCpIndex = nil
    local nearestCpDistance = math.huge

    for cpIndex, candidates in pairs(cpCandidates) do
        local cpDistance = cpMinDistances[cpIndex]
        if cpDistance < nearestCpDistance then
            nearestCpDistance = cpDistance
            nearestCpIndex = cpIndex
        end
    end

    -- Random select dari CP terdekat
    if nearestCpIndex and cpCandidates[nearestCpIndex] then
        local candidates = cpCandidates[nearestCpIndex]
        local selected = candidates[math.random(1, #candidates)]
        return selected.macro, selected.version, selected.sampleIndex, selected.distance
    end

    return nil, nil, nil, math.huge
end

local function handleEndSummit(endSummitType, callback)
    -- Safety check: hanya jalankan jika dalam mode playAll
    if not playingAll then
        if callback then callback() end
        return
    end

    if endSummitType == "none" then
        -- Tidak ada aksi khusus, langsung lanjut
        updateStatus("SUMMIT COMPLETE", Color3.fromRGB(100, 255, 100))
        if callback then callback() end
    elseif endSummitType == "die" then
        -- MATI INSTAN - Hanya di playall
        updateStatus("PLAYALL: INSTANT DEATH", Color3.fromRGB(255, 100, 100))

        -- Cek dan pastikan karakter ada
        character = getCharacter()
        hum = getHumanoid()

        if character and hum then
            -- Method 1: Set health langsung ke 0
            pcall(function()
                hum.Health = 0
            end)

            -- Method 2: Fallback - gunakan BreakJoints untuk memastikan karakter hancur
            pcall(function()
                character:BreakJoints()
            end)
        end

        -- Tunggu respawn
        updateStatus("PLAYALL: WAITING RESPAWN", Color3.fromRGB(200, 200, 100))

        local respawnConnection
        local respawnTimeout = 15 -- maksimal 15 detik

        respawnConnection = player.CharacterAdded:Connect(function(newChar)
            if respawnConnection then
                respawnConnection:Disconnect()
                respawnConnection = nil
            end

            -- Setup karakter baru
            setupChar(newChar)

            -- Tunggu sedikit untuk memastikan karakter sudah siap
            wait(2)

            updateStatus("RESPAWNED - CONTINUING", Color3.fromRGB(100, 255, 100))
            if callback then callback() end
        end)

        -- Fallback: jika tidak respawn dalam waktu tertentu, lanjut saja
        delay(respawnTimeout, function()
            if respawnConnection then
                respawnConnection:Disconnect()
                respawnConnection = nil
            end
            updateStatus("RESPAWN TIMEOUT - CONTINUING", Color3.fromRGB(255, 150, 50))
            if callback then callback() end
        end)
    elseif endSummitType == "rejoin" then
        -- Rejoin game - Hanya di playall
        updateStatus("PLAYALL: REJOINING GAME", Color3.fromRGB(150, 150, 255))

        -- Simpan state sebelum rejoin
        local savedMacros = currentMacros
        local savedMapData = currentMapData
        local savedLoop = loopPlayAll

        -- Rejoin game
        local teleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local player = game.Players.LocalPlayer

        pcall(function()
            teleportService:Teleport(placeId, player)
        end)

        -- Fallback: jika teleport gagal, tunggu dan callback
        delay(5, function()
            updateStatus("REJOIN FAILED - CONTINUING", Color3.fromRGB(255, 100, 100))
            if callback then callback() end
        end)
    else
        -- Default behavior untuk tipe tidak dikenali
        updateStatus("SUMMIT COMPLETE", Color3.fromRGB(100, 255, 100))
        if callback then callback() end
    end
end

-- MODIFIED: Fungsi untuk melanjutkan ke macro berikutnya dengan sistem posisi terdekat + pathfinding
local function continueToNextMacro()
    if not playingAll then
        return
    end

    -- NEW: Cek jika ini adalah summit terakhir dan perlu endsummit handling HANYA di playall
    local endSummitType = currentMapData and currentMapData.endsummit or "none"
    local isAtFinalSummit = (currentPlayIndex >= #currentMacros)

    if isAtFinalSummit and endSummitType ~= "none" then
        handleEndSummit(endSummitType, function()
            if loopPlayAll then
                -- Setelah endsummit, reset ke checkpoint 1
                currentPlayIndex = 0
                updateStatus("LOOPING AFTER ENDSUMMIT", Color3.fromRGB(200, 150, 255))
                continueToNextMacro()
            else
                playingAll = false
                updateStatus("ALL COMPLETE WITH ENDSUMMIT", Color3.fromRGB(100, 255, 100))
            end
        end)
        return
    end

    -- CARI POSISI TERDEKAT DARI SEMUA MACRO
    local nearestMacro, nearestVersion, nearestSampleIndex, nearestDistance = findNearestPositionAcrossAllMacros()

    if not nearestMacro or not nearestVersion then
        -- Fallback ke sequential jika tidak ditemukan
        currentPlayIndex = currentPlayIndex + 1

        -- NEW: Cek endsummit HANYA di playall sebelum melanjutkan
        if currentPlayIndex > #currentMacros then
            if loopPlayAll then
                handleEndSummit(endSummitType, function()
                    currentPlayIndex = 1
                    updateStatus("LOOPING AFTER ENDSUMMIT", Color3.fromRGB(200, 150, 255))
                    continueToNextMacro()
                end)
            else
                handleEndSummit(endSummitType, function()
                    playingAll = false
                    updateStatus("ALL COMPLETE WITH ENDSUMMIT", Color3.fromRGB(100, 255, 100))
                end)
            end
            return
        end

        if currentPlayIndex > #currentMacros then
            if loopPlayAll then
                currentPlayIndex = 1
                updateStatus("LOOPING", Color3.fromRGB(200, 150, 255))
            else
                playingAll = false
                updateStatus("ALL COMPLETE", Color3.fromRGB(100, 255, 100))
                return
            end
        end

        local nextMacroData = currentMacros[currentPlayIndex]
        if not nextMacroData then
            continueToNextMacro()
            return
        end

        -- Dapatkan random version untuk checkpoint ini
        local versionData = getRandomVersionForCP(nextMacroData.cpIndex)

        if versionData then
            local nextMacro = createMacroFromVersion(nextMacroData, versionData)
            samples = nextMacro.samples
            selectedMacro = nextMacro
            playbackTime = 0
            playIndex = 1
            needsPathfinding = true

            local versionInfo = ""
            if nextMacro.isMultiVersion then
                versionInfo = " [" .. nextMacro.version .. "]"
            end

            updateStatus(
                "PLAYING " .. nextMacro.displayName .. versionInfo ..
                " (" .. currentPlayIndex .. "/" .. #currentMacros .. ")",
                Color3.fromRGB(50, 200, 255))

            startPlayback()
        else
            updateStatus("SKIP " .. nextMacroData.displayName .. " (NO DATA)", Color3.fromRGB(255, 150, 100))
            continueToNextMacro()
        end
        return
    end

    -- GUNAKAN POSISI TERDEKAT YANG DITEMUKAN
    local nextMacro = createMacroFromVersion(nearestMacro, nearestVersion)
    samples = nextMacro.samples
    selectedMacro = nextMacro

    -- **FIX: CEK ANTI-LOOPING SEBELUM UPDATE currentPlayIndex**
    local justFinishedMacro = false
    if currentPlayIndex > 0 then
        -- Skip jika macro terdekat adalah macro yang baru selesai
        justFinishedMacro = (nearestMacro.cpIndex == currentPlayIndex)

        -- Juga skip macro sebelumnya (untuk handle edge cases)
        if not justFinishedMacro and nearestMacro.cpIndex == (currentPlayIndex - 1) then
            justFinishedMacro = true
        end
    end

    if justFinishedMacro then
        -- Jika yang terdekat adalah macro yang baru selesai, lanjut ke macro berikutnya secara sequential
        updateStatus("NEXT CP", Color3.fromRGB(255, 150, 100))

        -- CARI MACRO BERIKUTNYA SECARA SEQUENTIAL
        local nextIndex = currentPlayIndex + 1
        if nextIndex > #currentMacros then
            if loopPlayAll then
                nextIndex = 1
            else
                playingAll = false
                updateStatus("ALL COMPLETE", Color3.fromRGB(100, 255, 100))
                return
            end
        end

        currentPlayIndex = nextIndex

        -- **FIX: JANGAN RECURSION, LOAD DAN START MACRO BERIKUTNYA LANGSUNG**
        local nextMacroData = currentMacros[currentPlayIndex]
        if nextMacroData then
            local versionData = getRandomVersionForCP(nextMacroData.cpIndex)
            if versionData then
                local sequentialMacro = createMacroFromVersion(nextMacroData, versionData)
                samples = sequentialMacro.samples
                selectedMacro = sequentialMacro
                playbackTime = 0
                playIndex = 1
                needsPathfinding = true

                local versionInfo = ""
                if sequentialMacro.isMultiVersion then
                    versionInfo = " [" .. sequentialMacro.version .. "]"
                end

                updateStatus(
                    "PLAYING " .. sequentialMacro.displayName .. versionInfo ..
                    " (" .. currentPlayIndex .. "/" .. #currentMacros .. ")",
                    Color3.fromRGB(50, 200, 255))

                startPlayback() -- **FIX: START PLAYBACK LANGSUNG**
            else
                continueToNextMacro()
            end
        else
            continueToNextMacro()
        end
        return
    end

    -- **FIX: UPDATE currentPlayIndex SETELAH ANTI-LOOPING CHECK**
    currentPlayIndex = nearestMacro.cpIndex

    local versionInfo = ""
    if nextMacro.isMultiVersion then
        versionInfo = " [" .. nextMacro.version .. "]"
    end

    -- JALANKAN PATHFINDING KE POSISI TERDEKAT TERLEBIH DAHULU
    local targetPosition = samples[nearestSampleIndex].cf.Position
    local currentDistance = (hrp.Position - targetPosition).Magnitude

    if currentDistance > 3 then -- Hanya pathfinding jika jarak > 3 stud
        updateStatus(
            nextMacro.displayName .. versionInfo,
            Color3.fromRGB(255, 200, 100))

        moveToSamplePosition(nearestSampleIndex, function(success)
            if success then
                -- Setelah pathfinding berhasil, mulai playback dari frame terdekat
                playIndex = nearestSampleIndex
                playbackTime = samples[playIndex].time
                needsPathfinding = false

                updateStatus(
                    nextMacro.displayName .. versionInfo,
                    Color3.fromRGB(100, 255, 150))

                startPlayback()
            else
                -- Jika pathfinding gagal, fallback ke teleport
                updateStatus("PATH FAILED", Color3.fromRGB(255, 150, 100))

                local teleportSuccess = teleportToPosition(targetPosition)
                if teleportSuccess then
                    playIndex = nearestSampleIndex
                    playbackTime = samples[playIndex].time
                    needsPathfinding = false

                    updateStatus(
                        nextMacro.displayName .. versionInfo,
                        Color3.fromRGB(100, 255, 150))

                    startPlayback()
                else
                    -- Jika semua gagal, cari macro berikutnya
                    updateStatus("ALL FAILED", Color3.fromRGB(255, 100, 100))
                    wait(.5)
                    continueToNextMacro()
                end
            end
        end)
    else
        -- Jika sudah dekat, langsung mulai playback
        playIndex = nearestSampleIndex
        playbackTime = samples[playIndex].time
        needsPathfinding = false

        updateStatus(
            nextMacro.displayName,
            Color3.fromRGB(100, 255, 150))

        startPlayback()
    end
end

-- MODIFIED: Playback completion check untuk handle play all dengan endsummit HANYA di playall
local function checkPlaybackCompletion()
    if playing and #samples > 0 and playIndex >= #samples then
        stopPlayback()

        local hasRandomCP = currentMapData and currentMapData.randomcp == true
        local endSummitType = currentMapData and currentMapData.endsummit or "none"

        if playingAll and #currentMacros > 0 then
            if hasRandomCP and (currentPlayIndex < #currentMacros or loopPlayAll) then
                updateStatus("FINDING CP", Color3.fromRGB(200, 150, 255))
                findRandomCheckpoint(function(success)
                    if success then
                        continueToNextMacro()
                    else
                        continueToNextMacro()
                    end
                end)
            else
                -- NEW: Handle endsummit condition HANYA ketika playall dan mencapai summit terakhir
                if currentPlayIndex >= #currentMacros then
                    handleEndSummit(endSummitType, function()
                        if loopPlayAll then
                            -- Setelah endsummit, lanjut ke checkpoint 1
                            currentPlayIndex = 0
                            continueToNextMacro()
                        else
                            playingAll = false
                            updateStatus("ALL COMPLETE", Color3.fromRGB(100, 255, 100))
                        end
                    end)
                else
                    continueToNextMacro()
                end
            end
        else
            -- SINGLE MACRO COMPLETION - TIDAK trigger endsummit
            if hasRandomCP then
                updateStatus("FINDING CP", Color3.fromRGB(200, 150, 255))
                findRandomCheckpoint(function(success)
                    if success then
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

-- MODIFIED: Pisahkan RenderStepped menjadi Heartbeat untuk pergerakan dan RenderStepped untuk animasi
RunService.Heartbeat:Connect(function(dt)
    character = getCharacter()
    hrp = getHRP()
    hum = getHumanoid()

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
                    -- Hitung progress rotasi smooth
                    if smoothRotationTarget ~= math.pi then
                        smoothRotationTarget = math.pi
                        smoothRotationStartTime = tick()
                        smoothRotationProgress = 0
                    end

                    local elapsed = tick() - smoothRotationStartTime
                    smoothRotationProgress = math.min(elapsed / smoothRotationDuration, 1)

                    -- Apply smooth rotation
                    local currentRotation = smoothRotationProgress * math.pi
                    local rotation = CFrame.Angles(0, currentRotation, 0)
                    cf = cf * rotation
                else
                    -- Reset ke depan
                    if smoothRotationTarget ~= 0 then
                        smoothRotationTarget = 0
                        smoothRotationStartTime = tick()
                        smoothRotationProgress = 0
                    end

                    local elapsed = tick() - smoothRotationStartTime
                    smoothRotationProgress = math.min(elapsed / smoothRotationDuration, 1)

                    -- Apply smooth rotation kembali ke depan
                    local currentRotation = (1 - smoothRotationProgress) * math.pi
                    local rotation = CFrame.Angles(0, currentRotation, 0)
                    cf = cf * rotation
                end

                -- Apply CFrame ke HumanoidRootPart
                hrp.CFrame = cf
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    character = getCharacter()
    hrp = getHRP()
    hum = getHumanoid()

    if playing and hrp and hum and #samples > 1 and not isPathfinding and playIndex < #samples then
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
-- Macro Library System - WITH LOCAL CACHE
-------------------------------------------------------
---
-- MODIFIED: Fungsi untuk mendeteksi semua versi yang tersedia dengan sequential checking
local function detectAvailableVersions(params, cpIndex)
    local versions = {}
    local baseUrl = string.format("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/maps/%s/%d",
        params, cpIndex)

    -- Cek versi base (tanpa suffix) pertama
    local success = pcall(function()
        game:HttpGet(baseUrl .. ".json", true)
    end)

    if success then
        table.insert(versions, {
            name = "v1",
            suffix = "",
            url = baseUrl .. ".json"
        })
    else
        return versions -- Langsung return jika base version gagal
    end

    -- Cek versi v2, v3, dst secara sequential - STOP jika ada yang gagal
    for i = 2, 5 do
        local versionSuffix = "_v" .. i
        local versionUrl = baseUrl .. versionSuffix .. ".json"

        local versionSuccess = pcall(function()
            game:HttpGet(versionUrl, true)
        end)

        if versionSuccess then
            table.insert(versions, {
                name = "v" .. i,
                suffix = versionSuffix,
                url = versionUrl
            })
        else
            break -- STOP immediately jika versi tidak ditemukan
        end
    end

    return versions
end

local function loadMapsData()
    if #macroLibrary > 0 then
        return true
    end

    updateStatus("LOADING MAPS", Color3.fromRGB(150, 200, 255))

    local success, mapsJson, mapsData

    repeat
        success, mapsJson = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/maps.json",
                true)
        end)

        if success and mapsJson then
            local success2
            success2, mapsData = pcall(function()
                return HttpService:JSONDecode(mapsJson)
            end)

            if success2 and mapsData and type(mapsData) == "table" then
                local filteredMaps = filterMapsByGameId(mapsData)
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
        task.wait(2)
    until success and mapsData

    return false
end

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
    local totalCheckpointsLoaded = 0

    updateStatus("LOADING (" .. cpCount .. " CP)", Color3.fromRGB(150, 200, 255))

    for i = 1, cpCount do
        -- Deteksi semua versi yang tersedia untuk checkpoint ini
        local availableVersions = detectAvailableVersions(params, i)

        if #availableVersions == 0 then
            updateStatus("SKIP CP " .. i .. " (NO DATA)", Color3.fromRGB(255, 150, 100))
        end

        local versionsData = {}

        for _, version in ipairs(availableVersions) do
            local success, macroData = pcall(function()
                local jsonData = game:HttpGet(version.url, true)
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

                local adjustedSamples = applyHeightAdjustmentToSamples(convertedSamples)

                table.insert(versionsData, {
                    name = version.name,
                    suffix = version.suffix,
                    samples = adjustedSamples,
                    sampleCount = #adjustedSamples
                })

                updateStatus("LOADED CP" .. i .. " " .. version.name, Color3.fromRGB(150, 255, 150))
            else
                updateStatus("FAILED CP" .. i .. " " .. version.name,
                    Color3.fromRGB(255, 150, 100))
                break
            end

            wait(0.05)
        end

        if #versionsData > 0 then
            local listName = ""
            local displayName = ""

            if i == cpCount then
                displayName = "Summit"
                listName = "Checkpoint " .. (i - 1) .. " → Summit"
            elseif i == 1 then
                displayName = "Start → CP 1"
                listName = "Start → Checkpoint 1"
            else
                displayName = "CP " .. (i - 1) .. " → CP " .. i
                listName = "Checkpoint " .. (i - 1) .. " → " .. i
            end

            local macro = {
                name = params .. "_CP" .. i,
                displayName = displayName,
                listName = listName,
                params = params,
                cpIndex = i,
                versions = versionsData,
                versionCount = #versionsData,
                sampleCount = versionsData[1].sampleCount, -- Sample count dari versi pertama
                isMultiVersion = (#versionsData > 1)
            }

            table.insert(loadedMacros, macro)
            totalCheckpointsLoaded = totalCheckpointsLoaded + 1

            updateStatus("LOADED CP" .. i .. " (" .. #versionsData .. ")", Color3.fromRGB(100, 200, 255))
        end
    end

    -- Sort macros by checkpoint index
    table.sort(loadedMacros, function(a, b)
        return a.cpIndex < b.cpIndex
    end)

    loadedMacrosCache[params] = loadedMacros
    currentMacros = loadedMacros
    updateMacroList()

    updateStatus("LOADED: (" .. #loadedMacros .. " CP)", Color3.fromRGB(100, 255, 200))

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
    if playing or isPathfinding then
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

-- MODIFIED: Button callback untuk play all
local allBtn = createBtn("ALL", UDim2.new(0.36, 0, 0, 235), UDim2.new(0.28, 0, 0, 26), function()
    if #currentMacros > 0 then
        if playing or isPathfinding or macroLocked then
            updateStatus("PLAYING ALL", Color3.fromRGB(255, 150, 50))
            return
        end

        -- Reset state sebelum mulai play all
        resetPlayback()
        playingAll = true
        loopPlayAll = true
        currentPlayIndex = 0

        -- Tampilkan info pencarian posisi terdekat
        updateStatus("SCANNING", Color3.fromRGB(200, 200, 100))


        -- Mulai dari posisi terdekat
        continueToNextMacro()
    else
        updateStatus("NO CP LOADED", Color3.fromRGB(255, 150, 50))
    end
end, Color3.fromRGB(100, 150, 255))

createBtn("RESET", UDim2.new(0.65, 0, 0, 235), UDim2.new(0.3, 0, 0, 26), function()
    resetPlayback()
    updatePlayButton()
    playingAll = false
    loopPlayAll = false
    currentPlayIndex = 1
    selectedMacro = nil
    samples = {}
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
    hum.WalkSpeed = hum.WalkSpeed - 1
    speedDisplay.Text = string.format("%.1fx", playSpeed)
    updateStatus("SPEED " .. string.format("%.1fx", playSpeed), Color3.fromRGB(150, 200, 255))
end, Color3.fromRGB(80, 100, 180))

createBtn("▶", UDim2.new(0.7, 0, 0, 285), UDim2.new(0.25, 0, 0, 22), function()
    playSpeed = math.min(3.0, playSpeed + 0.1)
    hum.WalkSpeed = hum.WalkSpeed + 1
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
-- MODIFIED: Update info label function dengan version info
local function updateInfoLabel()
    local progressPercent = 0
    if samples and #samples > 0 and playbackTime > 0 then
        local totalTime = samples[#samples].time
        if totalTime > 0 then
            progressPercent = (playbackTime / totalTime) * 100
        end
    end

    local selectedName = "None"
    local versionInfo = ""
    local currentPlay = 0
    local totalPlay = 1

    if selectedMacro then
        selectedName = selectedMacro.displayName or "Unknown"
        if selectedMacro.isMultiVersion then
            versionInfo = " [" .. (selectedMacro.version or "Unknown") .. "]"
        end
        currentPlay = selectedMacro.cpIndex or 0
    end

    if playingAll and currentMacros then
        totalPlay = #currentMacros
        currentPlay = currentPlayIndex or 1
    end

    local mapName = "None"
    if currentMapData then
        mapName = currentMapData.nama or "Unknown"
    end

    local totalCP = 0
    if currentMapData then
        totalCP = currentMapData.cp or 0
    end

    local loopInfo = ""
    if loopPlayAll then
        loopInfo = " | 🔁"
    end

    local randomCPInfo = ""
    if currentMapData and currentMapData.randomcp then
        randomCPInfo = " | 🎲"
    end

    infoLabel.Text = string.format("%s | %s%s | %d/%d (%d%%)%s%s",
        mapName, selectedName, versionInfo, currentPlay, totalCP, math.floor(progressPercent),
        loopInfo, randomCPInfo)
end

-- Load button dengan CACHE SYSTEM
local loadBtn = createBtn("📥 LOAD CHECKPOINT", UDim2.new(0.05, 0, 0, 205), UDim2.new(0.65, 0, 0, 26), function()
    if isLoadingMacros then
        return
    end
    if playing or isPathfinding or macroLocked then
        updateStatus("PLAYING", Color3.fromRGB(255, 150, 50))
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
end)

-- Preload data saat startup
spawn(function()
    wait(2)
    if loadMapsData() then
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
            infoLabel.Text = gameName .. "Click 'Load Checkpoint' to play"
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

    -- Safety check untuk karakter
    character = getCharacter()
    hrp = getHRP()
    hum = getHumanoid()

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
        if hum and hrp then
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

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/updatelog.lua",
        true))()
end)
