-- ⚙️ Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- 🧠 Variabel status
local magnetEnabled = false
local magnetConnection = nil
local currentArea = nil
local isMinimized = false
local isUIVisible = true
local autoHitEnabled = false
local autoHitConnection = nil

-- 🗺️ Daftar area yang tersedia
local areaList = {
    {
        name = "Ranked RED",
        corners = {
            Vector3.new(-103.95, -518.31, -146.48),
            Vector3.new(-61.86, -518.30, -145.44),
            Vector3.new(-21.00, -518.30, -146.16),
            Vector3.new(-21.28, -518.30, -115.72),
            Vector3.new(-20.68, -518.30, -74.05),
            Vector3.new(-62.75, -518.30, -73.71),
            Vector3.new(-103.96, -518.30, -74.21),
            Vector3.new(-104.56, -518.30, -115.14)
        }
    },
    {
        name = "Ranked BLUE",
        corners = {
            Vector3.new(-20.72, -518.30, 6.75),
            Vector3.new(-20.67, -518.30, -29.21),
            Vector3.new(-20.17, -518.31, -64.73),
            Vector3.new(-62.89, -518.30, -65.28),
            Vector3.new(-103.96, -518.31, -65.02),
            Vector3.new(-104.56, -518.30, -23.12),
            Vector3.new(-62.36, -518.35, 1.67),
            Vector3.new(-62.81, -518.30, 7.84)
        }
    },
    {
        name = "Court 1 (RED)",
        corners = {
            Vector3.new(-104.13, -518.30, -74.33),
            Vector3.new(-62.31, -518.30, -73.71),
            Vector3.new(-20.65, -518.30, -74.20),
            Vector3.new(-20.49, -518.30, -115.81),
            Vector3.new(-20.65, -518.30, -146.15),
            Vector3.new(-62.86, -518.30, -146.26),
            Vector3.new(-103.87, -518.30, -145.93),
            Vector3.new(-103.94, -518.30, -112.58)
        }
    },
    {
        name = "Court 1 (BLUE)",
        corners = {
            Vector3.new(-20.56, -518.30, -65.27),
            Vector3.new(-63.07, -518.30, -65.29),
            Vector3.new(-103.95, -518.30, -64.92),
            Vector3.new(-104.06, -518.31, -23.49),
            Vector3.new(-104.03, -518.30, 6.65),
            Vector3.new(-62.38, -518.30, 6.90),
            Vector3.new(-20.81, -518.30, 5.93),
            Vector3.new(-20.65, -518.30, -26.41)
        }
    },
    {
        name = "Court 2 (BLUE)",
        corners = {
            Vector3.new(-612.61, -523.30, -65.29),
            Vector3.new(-654.32, -523.30, -65.29),
            Vector3.new(-696.04, -523.30, -65.12),
            Vector3.new(-696.09, -523.30, -23.65),
            Vector3.new(-696.09, -523.30, 7.38),
            Vector3.new(-654.81, -523.30, 7.74),
            Vector3.new(-612.81, -523.30, 6.98),
            Vector3.new(-612.63, -523.31, -24.28)
        }
    },
    {
        name = "Court 2 (RED)",
        corners = {
            Vector3.new(-696.11, -523.30, -73.77),
            Vector3.new(-654.45, -523.30, -73.73),
            Vector3.new(-612.69, -523.31, -73.69),
            Vector3.new(-612.67, -523.30, -113.31),
            Vector3.new(-612.62, -523.30, -145.94),
            Vector3.new(-654.27, -523.31, -145.89),
            Vector3.new(-696.11, -523.30, -145.97),
            Vector3.new(-696.12, -523.30, -116.71)
        }
    },
    {
        name = "Court 3 (BLUE)",
        corners = {
            Vector3.new(-1212.60, -523.30, -65.28),
            Vector3.new(-1255.00, -523.30, -65.28),
            Vector3.new(-1296.11, -523.30, -65.29),
            Vector3.new(-1296.12, -523.31, -22.96),
            Vector3.new(-1296.09, -523.31, 7.51),
            Vector3.new(-1254.22, -523.30, 7.51),
            Vector3.new(-1212.68, -523.30, 6.79),
            Vector3.new(-1212.63, -523.30, -22.42)
        }
    },
    {
        name = "Court 3 (RED)",
        corners = {
            Vector3.new(-1296.13, -523.31, -73.74),
            Vector3.new(-1254.49, -523.30, -73.70),
            Vector3.new(-1212.60, -523.30, -73.70),
            Vector3.new(-1212.64, -523.30, -118.76),
            Vector3.new(-1212.63, -523.31, -146.01),
            Vector3.new(-1254.88, -523.30, -146.22),
            Vector3.new(-1296.12, -523.30, -145.75),
            Vector3.new(-1296.13, -523.30, -116.54)
        }
    },
    {
        name = "Court 4 (BLUE)",
        corners = {
            Vector3.new(-1812.62, -523.30, -65.29),
            Vector3.new(-1854.25, -523.30, -65.28),
            Vector3.new(-1896.13, -523.30, -65.29),
            Vector3.new(-1896.12, -523.30, -19.76),
            Vector3.new(-1896.10, -523.30, 7.28),
            Vector3.new(-1854.81, -523.30, 7.85),
            Vector3.new(-1812.64, -523.30, 7.67),
            Vector3.new(-1812.66, -523.30, -26.78)
        }
    },
    {
        name = "Court 4 (RED)",
        corners = {
            Vector3.new(-1896.09, -523.30, -73.76),
            Vector3.new(-1854.42, -523.30, -73.72),
            Vector3.new(-1812.61, -523.30, -73.74),
            Vector3.new(-1812.60, -523.30, -116.88),
            Vector3.new(-1812.63, -523.30, -145.54),
            Vector3.new(-1854.45, -523.30, -146.71),
            Vector3.new(-1896.11, -523.30, -146.02),
            Vector3.new(-1896.12, -523.30, -117.15)
        }
    }
}

-- 🔧 Fungsi untuk menghitung batas area
local function calculateAreaBounds(corners)
    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge

    for _, corner in ipairs(corners) do
        minX = math.min(minX, corner.X)
        maxX = math.max(maxX, corner.X)
        minZ = math.min(minZ, corner.Z)
        maxZ = math.max(maxZ, corner.Z)
    end

    return {
        minX = minX,
        maxX = maxX,
        minZ = minZ,
        maxZ = maxZ
    }
end

-- 🔧 Fungsi untuk cek apakah posisi berada dalam area (hanya X dan Z)
local function isInArea(position, bounds)
    return position.X >= bounds.minX and position.X <= bounds.maxX and
        position.Z >= bounds.minZ and position.Z <= bounds.maxZ
end

-- 🔧 Fungsi untuk membatasi posisi ke dalam area (hanya X dan Z)
local function clampToArea(position, bounds)
    local clamped = Vector3.new(
        math.clamp(position.X, bounds.minX, bounds.maxX),
        position.Y, -- Pertahankan Y asli
        math.clamp(position.Z, bounds.minZ, bounds.maxZ)
    )
    return clamped
end

-- 🔧 Fungsi untuk mendapatkan posisi BallShadow yang aman (hanya X dan Z)
local function getSafeBallShadowPosition()
    local ballShadow = workspace:FindFirstChild("BallShadow", true)
    if not ballShadow or not ballShadow:IsA("BasePart") then
        return nil
    end

    local ballPos = ballShadow.Position
    local targetPos = ballPos + Vector3.new(0, 3, 0) -- Tinggi karakter

    -- 🆕 Jika tidak ada area yang aktif, return posisi asli
    if not currentArea then
        return targetPos, false
    end

    -- Jika BallShadow di luar area, batasi ke area terdekat (hanya X dan Z)
    if not isInArea(targetPos, currentArea.bounds) then
        targetPos = clampToArea(ballPos, currentArea.bounds)
        return targetPos, true -- Return true untuk menandai posisi dibatasi
    end

    return targetPos, false
end

local flightHeight = nil

-- 🔧 Fungsi untuk membuat karakter terbang ke atas 10 stud dari posisi saat ini
local function makeCharacterFly(character)
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        -- Simpan ketinggian terbang berdasarkan posisi Y saat ini + 10 stud
        flightHeight = hrp.Position.Y + 10
        local newPos = Vector3.new(hrp.Position.X, flightHeight, hrp.Position.Z)
        hrp.CFrame = CFrame.new(newPos)
    end
end

-- 🔧 Fungsi untuk mengembalikan karakter ke posisi normal
local function returnCharacterToNormal(character)
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        -- Reset ketinggian terbang
        flightHeight = nil
    end
end

-- 🎨 Buat UI Modern Minimalis
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallShadowMagnetUI"
screenGui.Parent = CoreGui

-- Main Frame (Tinggi disesuaikan)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 120) -- Height reduced
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Glass Effect
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
})
gradient.Rotation = 90
gradient.Parent = mainFrame

-- Title Bar Minimalis
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 27)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 7, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Racket Rivals 1.2"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = titleBar

-- Tombol Minimize
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 40, 0, 20)
minimizeButton.Position = UDim2.new(1, -70, 0, 4)
minimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
minimizeButton.BackgroundTransparency = 0.3
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 14
minimizeButton.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BackgroundTransparency = 0.2
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton
closeCorner:Clone().Parent = minimizeButton

-- Content Frame (disesuaikan)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -10, 1, -35)
contentFrame.Position = UDim2.new(0, 5, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Toggle Button Modern
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.97, 0, 0, 30)
toggleButton.Position = UDim2.new(0.02, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180) -- Warna sama untuk semua button non-aktif
toggleButton.BackgroundTransparency = 0.1
toggleButton.BorderSizePixel = 0
toggleButton.Text = "🔴 MAGNET OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamMedium
toggleButton.TextSize = 12
toggleButton.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

-- Auto Hit Button
local autoHitButton = Instance.new("TextButton")
autoHitButton.Name = "AutoHitButton"
autoHitButton.Size = UDim2.new(0.97, 0, 0, 30)
autoHitButton.Position = UDim2.new(0.02, 0, 0, 35)
autoHitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180) -- Warna sama
autoHitButton.BackgroundTransparency = 0.1
autoHitButton.BorderSizePixel = 0
autoHitButton.Text = "HIT: OFF"
autoHitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoHitButton.Font = Enum.Font.GothamMedium
autoHitButton.TextSize = 12
autoHitButton.Parent = contentFrame

local autoHitCorner = Instance.new("UICorner")
autoHitCorner.CornerRadius = UDim.new(0, 6)
autoHitCorner.Parent = autoHitButton

-- Area Info Label
local areaLabel = Instance.new("TextLabel")
areaLabel.Name = "AreaLabel"
areaLabel.Size = UDim2.new(1, 0, 0, 20)
areaLabel.Position = UDim2.new(0.03, 0, 0, 70)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Area: -"
areaLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
areaLabel.Font = Enum.Font.Gotham
areaLabel.TextSize = 10
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.Parent = contentFrame

-- Show/Hide Toggle Button (Pojok Kanan Bawah)
local toggleUIButton = Instance.new("TextButton")
toggleUIButton.Name = "ToggleUIButton"
toggleUIButton.Size = UDim2.new(0, 50, 0, 30)
toggleUIButton.Position = UDim2.new(1, -10, 1, -10)
toggleUIButton.AnchorPoint = Vector2.new(1, 1)
toggleUIButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleUIButton.BackgroundTransparency = 0.7
toggleUIButton.BorderSizePixel = 0
toggleUIButton.Text = "HIDE"
toggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleUIButton.Font = Enum.Font.GothamBold
toggleUIButton.TextSize = 12
toggleUIButton.ZIndex = 10
toggleUIButton.Parent = screenGui

local toggleUICorner = Instance.new("UICorner")
toggleUICorner.CornerRadius = UDim.new(0, 8)
toggleUICorner.Parent = toggleUIButton

-- Glass effect untuk toggle button
local toggleGradient = Instance.new("UIGradient")
toggleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
})
toggleGradient.Rotation = 90
toggleGradient.Parent = toggleUIButton

-- 🔧 Fungsi untuk toggle minimize
local function toggleMinimize()
    isMinimized = not isMinimized

    if isMinimized then
        -- Minimize: hanya tampilkan title bar
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 220, 0, 28)
        minimizeButton.Text = "+"
    else
        -- Restore: tampilkan semua content
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 220, 0, 120)
        minimizeButton.Text = "−"
    end
end

-- 🔧 Fungsi untuk toggle UI visibility
local function toggleUIVisibility()
    isUIVisible = not isUIVisible
    mainFrame.Visible = isUIVisible
    toggleUIButton.Text = isUIVisible and "SHOW" or "HIDE"
end

-- Mengukur jarak ke pusat area (center point)
-- 🔧 Fungsi untuk cek jarak ke area terdekat
local function getDistanceToNearestArea(characterPosition)
    local nearestArea = nil
    local nearestDistance = math.huge

    for _, areaData in ipairs(areaList) do
        local bounds = calculateAreaBounds(areaData.corners)
        -- Hitung pusat area
        local centerX = (bounds.minX + bounds.maxX) / 2
        local centerZ = (bounds.minZ + bounds.maxZ) / 2
        local areaCenter = Vector3.new(centerX, characterPosition.Y, centerZ)

        -- Hitung jarak ke pusat area (hanya XZ)
        local charXZ = Vector3.new(characterPosition.X, 0, characterPosition.Z)
        local areaXZ = Vector3.new(areaCenter.X, 0, areaCenter.Z)
        local distance = (charXZ - areaXZ).Magnitude

        if distance < nearestDistance then
            nearestDistance = distance
            nearestArea = areaData
        end
    end

    return nearestDistance, nearestArea
end

-- mengecek jarak tepi area
local function getDistanceToAreaEdge(position, areaBounds)
    -- Hitung titik terdekat di dalam area bounds
    local closestPoint = Vector3.new(
        math.clamp(position.X, areaBounds.minX, areaBounds.maxX),
        position.Y,
        math.clamp(position.Z, areaBounds.minZ, areaBounds.maxZ)
    )

    -- Hitung jarak ke titik terdekat (hanya di bidang XZ)
    local currentXZ = Vector3.new(position.X, 0, position.Z)
    local closestXZ = Vector3.new(closestPoint.X, 0, closestPoint.Z)

    return (currentXZ - closestXZ).Magnitude
end

-- 🆕 Fungsi untuk mematikan magnet dengan proper cleanup
local function disableMagnet()
    magnetEnabled = false
    currentArea = nil

    -- Kembalikan karakter ke posisi normal
    local character = player.Character
    if character then
        returnCharacterToNormal(character)
    end

    -- Kembalikan tombol ke warna merah ketika nonaktif
    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
    toggleButton.Text = "🔴 MAGNET OFF"

    -- Hentikan magnet system
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end
end

-- 🔧 Fungsi untuk toggle magnet dengan pengecekan jarak
local function toggleMagnet()
    -- Safety check: pastikan karakter ada
    local character = player.Character
    if not character then
        areaLabel.Text = "Area: ERROR - No Character"
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        areaLabel.Text = "Area: ERROR - No HRP"
        return
    end

    -- Cek jarak ke area terdekat sebelum mengaktifkan magnet
    local distanceToArea, nearestArea = getDistanceToNearestArea(hrp.Position)

    if magnetEnabled then
        -- Nonaktifkan magnet
        disableMagnet()
    else
        -- Cek jarak sebelum mengaktifkan magnet
        if distanceToArea > 50 then
            areaLabel.Text = string.format("ENTER THE COURT FIRST", distanceToArea)

            -- Tampilkan notifikasi sementara
            local originalText = toggleButton.Text
            toggleButton.Text = "❌ NOT IN GAME!"
            toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)

            -- Kembalikan teks setelah 1.5 detik
            task.delay(1.5, function()
                if toggleButton then
                    toggleButton.Text = originalText
                    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
                end
            end)

            return -- Hentikan aktivasi magnet
        end

        -- Aktifkan magnet (jarak <= 50 studs)
        magnetEnabled = true

        -- Tentukan area terdekat
        currentArea = nearestArea

        -- Hitung bounds untuk area yang dipilih
        currentArea.bounds = calculateAreaBounds(currentArea.corners)

        areaLabel.Text = string.format("Area: %s ", currentArea.name, distanceToArea)

        -- Ubah tombol menjadi hijau ketika aktif
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        toggleButton.Text = "🟢 MAGNET ON"

        -- Mulai magnet system
        if magnetConnection then
            magnetConnection:Disconnect()
        end

        magnetConnection = RunService.Heartbeat:Connect(function(dt)
            -- Safety check berulang
            local character = player.Character
            if not character then
                areaLabel.Text = "Area: ERROR - No Char"
                disableMagnet()
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if not (humanoid and hrp and currentArea) then
                areaLabel.Text = "Area: ERROR - No Comp"
                disableMagnet()
                return
            end

            local currentPos = hrp.Position

            -- 🆕 PERBAIKAN: Cek posisi - hanya matikan magnet jika keluar lebih dari 20 stud dari area
            if not isInArea(currentPos, currentArea.bounds) then
                -- Hitung jarak ke tepi area currentArea
                local distanceToEdge = getDistanceToAreaEdge(currentPos, currentArea.bounds)

                if distanceToEdge > 30 then
                    -- Matikan magnet hanya jika lebih dari 30 stud dari tepi area
                    areaLabel.Text = "Area: OUT OF AREA"
                    disableMagnet()
                    return
                else
                    -- Masih dalam 20 stud dari tepi area, beri warning tapi biarkan magnet aktif
                    areaLabel.Text = string.format("Area: %s - NEAR EDGE", currentArea.name)
                end
            end

            -- Dapatkan posisi BallShadow yang aman
            local targetPosition, isClamped = getSafeBallShadowPosition()
            if not targetPosition then
                areaLabel.Text = string.format("Area: %s - No Shuttle", currentArea.name)
                -- Kembalikan karakter ke posisi normal ketika tidak ada BallShadow
                returnCharacterToNormal(character)
                return
            end

            -- Hitung jarak hanya di bidang XZ
            local currentXZ = Vector3.new(currentPos.X, 0, currentPos.Z)
            local targetXZ = Vector3.new(targetPosition.X, 0, targetPosition.Z)
            local distance = (targetXZ - currentXZ).Magnitude


            -- 🆕 CEK APAKAH BALLSHADOW KELUAR DARI AREA
            local isBallShadowOutOfArea = false
            if currentArea then
                isBallShadowOutOfArea = not isInArea(targetPosition, currentArea.bounds)
                if isBallShadowOutOfArea then
                    areaLabel.Text = string.format("Area: %s - Shuttle Out", currentArea.name)
                    -- Kembalikan karakter ke posisi normal ketika BallShadow keluar area
                    returnCharacterToNormal(character)
                end
            end

            -- Cek apakah BallShadow ada dan dalam jarak
            local ballShadow = workspace:FindFirstChild("BallShadow", true)
            local ballShadowExists = ballShadow and ballShadow:IsA("BasePart")

            -- Safety check karakter
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            local isInRange = false
            if ballShadowExists and hrp then
                -- Hitung jarak ke BallShadow (hanya XZ)
                local ballPos = ballShadow.Position
                local charPos = hrp.Position
                local distance = (Vector3.new(ballPos.X, 0, ballPos.Z) - Vector3.new(charPos.X, 0, charPos.Z)).Magnitude
                isInRange = distance <= 15
            end

            -- Update area label dengan info clamping
            if isClamped then
                areaLabel.Text = string.format("Area: %s - Edge", currentArea.name)
            else
                areaLabel.Text = string.format("Area: %s - Active", currentArea.name)
            end

            -- 🆕 LOGIKA TERBANG: Hanya ketika BallShadow < 20 stud
            if isInRange then
                -- Jika belum terbang, buat karakter terbang ke atas 10 stud
                if not flightHeight then
                    makeCharacterFly(character)
                    areaLabel.Text = string.format("Area: %s - FLYING!", currentArea.name)
                else
                    -- Jika sudah terbang, pertahankan ketinggian yang sama
                    local newPos = Vector3.new(currentPos.X, flightHeight, currentPos.Z)
                    hrp.CFrame = CFrame.new(newPos)
                end
            else
                -- Jika jarak >= 20 stud, kembalikan ke posisi normal
                if flightHeight then
                    returnCharacterToNormal(character)
                    areaLabel.Text = string.format("Area: %s - Back to Ground", currentArea.name)
                end
            end

            -- Jika jarak lebih dari 50 studs, nonaktifkan magnet
            if distance > 50 then
                areaLabel.Text = string.format("Area: %s - Too Far", currentArea.name)
                -- Kembalikan karakter ke posisi normal ketika terlalu jauh
                returnCharacterToNormal(character)
                return
            end

            -- 🆕 TELEPORT INSTANT KE POSISI BALLSHADOW
            -- Jika sedang terbang, pertahankan ketinggian terbang, jika tidak gunakan posisi Y saat ini
            local targetY = flightHeight or currentPos.Y

            local newPosition = Vector3.new(
                targetPosition.X,
                targetY, -- Gunakan ketinggian terbang atau posisi Y saat ini
                targetPosition.Z
            )

            -- Terapkan teleport
            hrp.CFrame = CFrame.new(newPosition)
        end)
    end
end

-- 🔧 Fungsi untuk Auto Hit baru (hanya aktif ketika BallShadow ada dan dalam jarak <=5 stud)
local function startAutoHit()
    if autoHitConnection then
        autoHitConnection:Disconnect()
        autoHitConnection = nil
    end

    local lastHitTime = 0
    local lastBallShadowState = false

    autoHitConnection = RunService.Heartbeat:Connect(function()
        if not autoHitEnabled then
            return
        end

        -- Cek apakah BallShadow ada dan dalam jarak
        local ballShadow = workspace:FindFirstChild("BallShadow", true)
        local ballShadowExists = ballShadow and ballShadow:IsA("BasePart")

        -- Safety check karakter
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local isInRange = false
        if ballShadowExists and hrp then
            -- Hitung jarak ke BallShadow (hanya XZ)
            local ballPos = ballShadow.Position
            local charPos = hrp.Position
            local distance = (Vector3.new(ballPos.X, 0, ballPos.Z) - Vector3.new(charPos.X, 0, charPos.Z)).Magnitude
            isInRange = distance <= 15
        end

        -- Update status di UI
        if ballShadowExists and isInRange then
            if not lastBallShadowState then
                areaLabel.Text = string.format("Area: %s - Auto Hit Active", currentArea and currentArea.name or "Auto")
                lastBallShadowState = true
            end
        else
            if lastBallShadowState then
                areaLabel.Text = "Area: Waiting for Shuttle..."
                lastBallShadowState = false
            end
            return -- Jangan lanjutkan jika BallShadow tidak ada atau terlalu jauh
        end

        local currentTime = tick()

        if (currentTime - lastHitTime) > 0.1 then
            local virtualInput = game:GetService("VirtualInputManager")

            -- Press dan release F dengan cepat
            virtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)

            lastHitTime = currentTime

            if currentArea then
                areaLabel.Text = string.format("Area: %s - Auto Hitting", currentArea.name)
            else
                areaLabel.Text = "Area: Auto Hitting"
            end
        end
    end)
end

-- 🔧 Fungsi untuk toggle auto hit
local function toggleAutoHit()
    autoHitEnabled = not autoHitEnabled

    if autoHitEnabled then
        autoHitButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        autoHitButton.Text = "HIT: ON"
        areaLabel.Text = "Area: Auto Hit ON" -- Feedback jelas

        startAutoHit()
    else
        autoHitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        autoHitButton.Text = "HIT: OFF"

        if autoHitConnection then
            autoHitConnection:Disconnect()
            autoHitConnection = nil
        end

        areaLabel.Text = currentArea and string.format("Area: %s", currentArea.name) or "Area: -"
    end
end

-- Event handler untuk semua toggle button
toggleButton.MouseButton1Click:Connect(toggleMagnet)
autoHitButton.MouseButton1Click:Connect(toggleAutoHit)

-- Tambahkan dalam closeButton event handler
closeButton.MouseButton1Click:Connect(function()
    -- Cleanup semua koneksi
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end

    if autoHitConnection then
        autoHitConnection:Disconnect()
        autoHitConnection = nil
    end

    screenGui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(toggleMinimize)
toggleUIButton.MouseButton1Click:Connect(toggleUIVisibility)
