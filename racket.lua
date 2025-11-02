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
local currentMoveSpeed = 50
local currentArea = nil
local isMinimized = false
local isUIVisible = true
local autoSmashEnabled = false
local autoSmashConnection = nil
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

-- 🔧 Fungsi untuk mendapatkan area terdekat dari posisi karakter
local function getNearestArea(characterPosition)
    local nearestArea = nil
    local nearestDistance = math.huge

    for _, areaData in ipairs(areaList) do
        local bounds = calculateAreaBounds(areaData.corners)
        -- Hitung pusat area
        local centerX = (bounds.minX + bounds.maxX) / 2
        local centerZ = (bounds.minZ + bounds.maxZ) / 2
        local areaCenter = Vector3.new(centerX, characterPosition.Y, centerZ)

        -- Hitung jarak ke pusat area
        local distance = (characterPosition - areaCenter).Magnitude

        if distance < nearestDistance then
            nearestDistance = distance
            nearestArea = areaData
        end
    end

    return nearestArea
end

-- 🔧 Fungsi untuk mendapatkan posisi BallShadow yang aman (hanya X dan Z)
local function getSafeBallShadowPosition()
    local ballShadow = workspace:FindFirstChild("BallShadow", true)
    if not ballShadow or not ballShadow:IsA("BasePart") then
        return nil
    end

    local ballPos = ballShadow.Position
    local targetPos = ballPos + Vector3.new(0, 3, 0) -- Tinggi karakter

    -- Jika BallShadow di luar area, batasi ke area terdekat (hanya X dan Z)
    if not isInArea(targetPos, currentArea.bounds) then
        targetPos = clampToArea(ballPos, currentArea.bounds)
        return targetPos, true -- Return true untuk menandai posisi dibatasi
    end

    return targetPos, false
end

-- 🎨 Buat UI Modern Minimalis
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallShadowMagnetUI"
screenGui.Parent = CoreGui

-- Main Frame (Diperbesar untuk menampung lebih banyak tombol)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 170) -- Diperbesar dari 140 ke 170
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
titleBar.Size = UDim2.new(1, 0, 0, 25)
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
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Racket Rivals"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamMedium
titleLabel.TextSize = 12
titleLabel.Parent = titleBar

-- Tombol Minimize
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(1, -50, 0, 2)
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
closeButton.Position = UDim2.new(1, -25, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BackgroundTransparency = 0.2
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton
closeCorner:Clone().Parent = minimizeButton

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -10, 1, -35)
contentFrame.Position = UDim2.new(0, 5, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Toggle Button Modern
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 0, 30) -- Diperkecil dari 40 ke 30
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
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

-- Auto Smash Toggle Button (Menggantikan Auto Hit sebelumnya)
local autoSmashButton = Instance.new("TextButton")
autoSmashButton.Name = "AutoSmashButton"
autoSmashButton.Size = UDim2.new(1, 0, 0, 25)
autoSmashButton.Position = UDim2.new(0, 0, 0, 35) -- Diposisikan lebih rendah
autoSmashButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
autoSmashButton.BackgroundTransparency = 0.1
autoSmashButton.BorderSizePixel = 0
autoSmashButton.Text = "🎾 AUTO SMASH: OFF"
autoSmashButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSmashButton.Font = Enum.Font.GothamMedium
autoSmashButton.TextSize = 11
autoSmashButton.Parent = contentFrame

local autoSmashCorner = Instance.new("UICorner")
autoSmashCorner.CornerRadius = UDim.new(0, 5)
autoSmashCorner.Parent = autoSmashButton

-- Auto Hit Toggle Button Baru (Tombol F terus menerus)
local autoHitButton = Instance.new("TextButton")
autoHitButton.Name = "AutoHitButton"
autoHitButton.Size = UDim2.new(1, 0, 0, 25)
autoHitButton.Position = UDim2.new(0, 0, 0, 65) -- Diposisikan di bawah Auto Smash
autoHitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
autoHitButton.BackgroundTransparency = 0.1
autoHitButton.BorderSizePixel = 0
autoHitButton.Text = "🔘 AUTO HIT: OFF"
autoHitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoHitButton.Font = Enum.Font.GothamMedium
autoHitButton.TextSize = 11
autoHitButton.Parent = contentFrame

local autoHitCorner = Instance.new("UICorner")
autoHitCorner.CornerRadius = UDim.new(0, 5)
autoHitCorner.Parent = autoHitButton

-- Area Info Label
local areaLabel = Instance.new("TextLabel")
areaLabel.Name = "AreaLabel"
areaLabel.Size = UDim2.new(1, 0, 0, 20)
areaLabel.Position = UDim2.new(0, 0, 0, 95) -- Diposisikan lebih rendah
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Area: -"
areaLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
areaLabel.Font = Enum.Font.Gotham
areaLabel.TextSize = 10
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.Parent = contentFrame

-- Speed Control Minimalis
local speedFrame = Instance.new("Frame")
speedFrame.Name = "SpeedFrame"
speedFrame.Size = UDim2.new(1, 0, 0, 25)
speedFrame.Position = UDim2.new(0, 0, 0, 115) -- Diposisikan lebih rendah
speedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
speedFrame.BackgroundTransparency = 0.4
speedFrame.BorderSizePixel = 0
speedFrame.Parent = contentFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 5)
speedCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 5, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. currentMoveSpeed
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local decreaseButton = Instance.new("TextButton")
decreaseButton.Name = "DecreaseButton"
decreaseButton.Size = UDim2.new(0, 20, 0, 20)
decreaseButton.Position = UDim2.new(0.5, 5, 0, 2)
decreaseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
decreaseButton.BackgroundTransparency = 0.3
decreaseButton.BorderSizePixel = 0
decreaseButton.Text = "-"
decreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseButton.Font = Enum.Font.GothamBold
decreaseButton.TextSize = 12
decreaseButton.Parent = speedFrame

local increaseButton = Instance.new("TextButton")
increaseButton.Name = "IncreaseButton"
increaseButton.Size = UDim2.new(0, 20, 0, 20)
increaseButton.Position = UDim2.new(0.5, 50, 0, 2)
increaseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
increaseButton.BackgroundTransparency = 0.3
increaseButton.BorderSizePixel = 0
increaseButton.Text = "+"
increaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseButton.Font = Enum.Font.GothamBold
increaseButton.TextSize = 12
increaseButton.Parent = speedFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 4)
buttonCorner.Parent = decreaseButton
buttonCorner:Clone().Parent = increaseButton

-- Show/Hide Toggle Button (Pojok Kanan Bawah)
local toggleUIButton = Instance.new("TextButton")
toggleUIButton.Name = "ToggleUIButton"
toggleUIButton.Size = UDim2.new(0, 40, 0, 40)
toggleUIButton.Position = UDim2.new(1, -50, 1, -50)
toggleUIButton.AnchorPoint = Vector2.new(1, 1)
toggleUIButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleUIButton.BackgroundTransparency = 0.2
toggleUIButton.BorderSizePixel = 0
toggleUIButton.Text = "⚙️"
toggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleUIButton.Font = Enum.Font.Gotham
toggleUIButton.TextSize = 16
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

-- 🔧 Fungsi untuk update speed display
local function updateSpeedDisplay()
    speedLabel.Text = "Speed: " .. currentMoveSpeed
end

-- 🔧 Fungsi untuk toggle minimize
local function toggleMinimize()
    isMinimized = not isMinimized

    if isMinimized then
        -- Minimize: hanya tampilkan title bar
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 220, 0, 25)
        minimizeButton.Text = "+"
    else
        -- Restore: tampilkan semua content
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 220, 0, 170)
        minimizeButton.Text = "−"
    end
end

-- 🔧 Fungsi untuk toggle UI visibility
local function toggleUIVisibility()
    isUIVisible = not isUIVisible
    mainFrame.Visible = isUIVisible
    toggleUIButton.Text = isUIVisible and "⬇️" or "⚙️"
end

-- 🔧 Fungsi untuk toggle magnet dengan safety check
local function toggleMagnet()
    magnetEnabled = not magnetEnabled

    if magnetEnabled then
        -- Safety check: pastikan karakter ada
        local character = player.Character
        if not character then
            areaLabel.Text = "Area: ERROR - No Character"
            magnetEnabled = false
            return
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            areaLabel.Text = "Area: ERROR - No HRP"
            magnetEnabled = false
            return
        end

        -- Tentukan area terdekat saat magnet diaktifkan
        currentArea = getNearestArea(hrp.Position)
        if not currentArea then
            areaLabel.Text = "Area: ERROR - No Area"
            magnetEnabled = false
            return
        end

        -- Hitung bounds untuk area yang dipilih
        currentArea.bounds = calculateAreaBounds(currentArea.corners)

        local bounds = currentArea.bounds
        areaLabel.Text = string.format("Area: %s", currentArea.name)

        -- Ubah tombol menjadi hijau ketika aktif
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        toggleButton.Text = "🟢 MAGNET ON"

        -- Mulai magnet system dengan safety check
        if magnetConnection then
            magnetConnection:Disconnect()
        end

        magnetConnection = RunService.Heartbeat:Connect(function(dt)
            -- Safety check berulang
            local character = player.Character
            if not character then
                areaLabel.Text = "Area: ERROR - No Char"
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if not (humanoid and hrp and currentArea) then
                areaLabel.Text = "Area: ERROR - No Comp"
                return
            end

            -- Cek posisi karakter saat ini (hanya X dan Z)
            local currentPos = hrp.Position
            if not isInArea(currentPos, currentArea.bounds) then
                -- Jika karakter keluar area, bawa kembali ke area terdekat
                local safePos = clampToArea(currentPos, currentArea.bounds)
                hrp.CFrame = CFrame.new(safePos)
                return
            end

            -- Dapatkan posisi BallShadow yang aman (hanya X dan Z)
            local targetPosition, isClamped = getSafeBallShadowPosition()
            if not targetPosition then
                areaLabel.Text = string.format("Area: %s - No Ball", currentArea.name)
                return -- JANGAN gerakkan karakter jika BallShadow tidak ditemukan
            end

            -- Hitung jarak hanya di bidang XZ (abaikan Y)
            local currentXZ = Vector3.new(currentPos.X, 0, currentPos.Z)
            local targetXZ = Vector3.new(targetPosition.X, 0, targetPosition.Z)
            local distance = (targetXZ - currentXZ).Magnitude

            -- Jika jarak lebih dari 50 studs, nonaktifkan magnet
            if distance > 50 then
                areaLabel.Text = string.format("Area: %s - Too Far", currentArea.name)
                return
            end

            -- Update area label dengan info clamping
            if isClamped then
                areaLabel.Text = string.format("Area: %s - Edge", currentArea.name)
            else
                areaLabel.Text = string.format("Area: %s - Active", currentArea.name)
            end

            -- Jika sudah dekat, tidak perlu bergerak
            if distance < 3 then
                return
            end

            -- Hitung arah hanya di bidang XZ (abaikan Y)
            local directionXZ = (targetXZ - currentXZ).Unit

            -- Gerakan smooth dengan kecepatan yang bisa diatur
            local moveDistance = currentMoveSpeed * dt

            -- Batasi gerakan agar tidak teleport
            if moveDistance > distance then
                moveDistance = distance
            end

            -- Posisi target setelah bergerak (hanya update X dan Z)
            local newPosition = Vector3.new(
                currentPos.X + directionXZ.X * moveDistance,
                currentPos.Y, -- Pertahankan Y asli
                currentPos.Z + directionXZ.Z * moveDistance
            )

            -- Pastikan posisi baru tetap dalam area
            if not isInArea(newPosition, currentArea.bounds) then
                newPosition = clampToArea(newPosition, currentArea.bounds)
            end

            -- Terapkan gerakan (hanya update X dan Z, pertahankan Y)
            hrp.CFrame = CFrame.new(
                newPosition.X, currentPos.Y, newPosition.Z
            ) * CFrame.Angles(0, math.atan2(directionXZ.X, directionXZ.Z), 0)
        end)
    else
        -- Reset area ketika magnet dimatikan
        currentArea = nil
        areaLabel.Text = "Area: -"

        -- Kembalikan tombol ke warna merah ketika nonaktif
        toggleButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        toggleButton.Text = "🔴 MAGNET OFF"

        -- Hentikan magnet system
        if magnetConnection then
            magnetConnection:Disconnect()
            magnetConnection = nil
        end
    end
end

-- 🔧 Fungsi untuk Auto Smash (menggunakan logika yang sama dengan Auto Hit sebelumnya)
local function startAutoSmash()
    if autoSmashConnection then
        autoSmashConnection:Disconnect()
        autoSmashConnection = nil
    end

    local lastActionTime = 0
    local isPressing = false
    local lastBallShadowState = true

    autoSmashConnection = RunService.Heartbeat:Connect(function()
        -- Cek apakah BallShadow ada
        local ballShadow = workspace:FindFirstChild("BallShadow", true)
        local ballShadowExists = ballShadow and ballShadow:IsA("BasePart")

        -- Update area label berdasarkan status BallShadow
        if ballShadowExists then
            if lastBallShadowState == false then
                -- BallShadow baru saja muncul kembali
                areaLabel.Text = string.format("Area: %s - Auto Smash Resumed",
                    currentArea and currentArea.name or "Auto")
                lastBallShadowState = true
            end
        else
            if lastBallShadowState == true then
                -- BallShadow baru saja hilang
                areaLabel.Text = "Area: Waiting for Ball..."
                lastBallShadowState = false
            end

            -- Release tombol F jika BallShadow tidak ditemukan
            if isPressing then
                local virtualInput = game:GetService("VirtualInputManager")
                virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                isPressing = false
            end
            return -- Jangan lanjutkan jika BallShadow tidak ada
        end

        -- Jika auto smash dimatikan oleh user, keluar
        if not autoSmashEnabled then
            if isPressing then
                local virtualInput = game:GetService("VirtualInputManager")
                virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                isPressing = false
            end
            return
        end

        local currentTime = tick()
        local virtualInput = game:GetService("VirtualInputManager")

        -- Cycle: Press F 0.45 detik, lalu release, tunggu 0.45 detik, repeat
        if not isPressing and (currentTime - lastActionTime) > 0.45 then
            -- PRESS F
            virtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            isPressing = true
            lastActionTime = currentTime
            areaLabel.Text = string.format("Area: %s - Smashing", currentArea and currentArea.name or "Auto")
        elseif isPressing and (currentTime - lastActionTime) > 0.45 then
            virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            isPressing = false
            lastActionTime = currentTime
        end
    end)
end

-- 🔧 Fungsi untuk toggle auto smash
local function toggleAutoSmash()
    autoSmashEnabled = not autoSmashEnabled

    if autoSmashEnabled then
        autoSmashButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        autoSmashButton.Text = "🎾 AUTO SMASH: ON"

        -- Cek status BallShadow saat pertama kali dinyalakan
        local ballShadow = workspace:FindFirstChild("BallShadow", true)
        if ballShadow and ballShadow:IsA("BasePart") then
            areaLabel.Text = "Area: Auto Smash Started"
        else
            areaLabel.Text = "Area: Auto Smash ON - Waiting for Ball..."
        end

        startAutoSmash()
    else
        autoSmashButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
        autoSmashButton.Text = "🎾 AUTO SMASH: OFF"

        -- Release tombol F ketika dimatikan
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)

        if autoSmashConnection then
            autoSmashConnection:Disconnect()
            autoSmashConnection = nil
        end

        areaLabel.Text = currentArea and string.format("Area: %s", currentArea.name) or "Area: -"
    end
end

-- 🔧 Fungsi untuk Auto Hit baru (tombol F terus menerus setiap 0.1 detik)
-- 🔧 Fungsi untuk Auto Hit baru (tombol F terus menerus setiap 0.1 detik, hanya saat BallShadow ada)
local function startAutoHit()
    if autoHitConnection then
        autoHitConnection:Disconnect()
        autoHitConnection = nil
    end

    local lastHitTime = 0
    local lastBallShadowState = true

    autoHitConnection = RunService.Heartbeat:Connect(function()
        -- Cek apakah BallShadow ada
        local ballShadow = workspace:FindFirstChild("BallShadow", true)
        local ballShadowExists = ballShadow and ballShadow:IsA("BasePart")

        -- Update area label berdasarkan status BallShadow
        if ballShadowExists then
            if lastBallShadowState == false then
                -- BallShadow baru saja muncul kembali
                areaLabel.Text = string.format("Area: %s - Auto Hit Resumed", currentArea and currentArea.name or "Auto")
                lastBallShadowState = true
            end
        else
            if lastBallShadowState == true then
                -- BallShadow baru saja hilang
                areaLabel.Text = "Area: Waiting for Ball..."
                lastBallShadowState = false
            end
            return -- Jangan lanjutkan jika BallShadow tidak ada
        end

        -- Jika auto hit dimatikan oleh user, keluar
        if not autoHitEnabled then
            return
        end

        local currentTime = tick()

        -- Tekan tombol F setiap 0.1 detik hanya jika BallShadow ada
        if (currentTime - lastHitTime) > 0.1 then
            local virtualInput = game:GetService("VirtualInputManager")

            -- Press dan release F dengan cepat
            virtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)

            lastHitTime = currentTime

            -- Update area label untuk menunjukkan status aktif
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
        autoHitButton.Text = "🟢 AUTO HIT: ON"

        -- Cek status BallShadow saat pertama kali dinyalakan
        local ballShadow = workspace:FindFirstChild("BallShadow", true)
        if ballShadow and ballShadow:IsA("BasePart") then
            areaLabel.Text = "Area: Auto Hit Started"
        else
            areaLabel.Text = "Area: Auto Hit ON - Waiting for Ball..."
        end

        startAutoHit()
    else
        autoHitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        autoHitButton.Text = "🔘 AUTO HIT: OFF"

        if autoHitConnection then
            autoHitConnection:Disconnect()
            autoHitConnection = nil
        end

        areaLabel.Text = currentArea and string.format("Area: %s", currentArea.name) or "Area: -"
    end
end

-- Event handler untuk auto smash dan auto hit
autoSmashButton.MouseButton1Click:Connect(toggleAutoSmash)
autoHitButton.MouseButton1Click:Connect(toggleAutoHit)

-- 🖱️ Event handlers untuk UI
toggleButton.MouseButton1Click:Connect(toggleMagnet)

-- Tambahkan dalam closeButton event handler
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()

    -- Hentikan magnet jika aktif
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end

    -- Hentikan auto smash jika aktif
    if autoSmashConnection then
        autoSmashConnection:Disconnect()
        autoSmashConnection = nil
    end

    -- Hentikan auto hit jika aktif
    if autoHitConnection then
        autoHitConnection:Disconnect()
        autoHitConnection = nil
    end

    -- Release tombol F
    local virtualInput = game:GetService("VirtualInputManager")
    virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end)

minimizeButton.MouseButton1Click:Connect(toggleMinimize)
toggleUIButton.MouseButton1Click:Connect(toggleUIVisibility)

-- Speed control handlers
decreaseButton.MouseButton1Click:Connect(function()
    if currentMoveSpeed > 10 then
        currentMoveSpeed = currentMoveSpeed - 10
        updateSpeedDisplay()
    end
end)

increaseButton.MouseButton1Click:Connect(function()
    if currentMoveSpeed < 100 then
        currentMoveSpeed = currentMoveSpeed + 10
        updateSpeedDisplay()
    end
end)
