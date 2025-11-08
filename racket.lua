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
local autoJumpEnabled = false
local autoJumpConnection = nil
local rightMouseDown = false
local rightMouseConnection = nil

-- 🆕 Variabel untuk Sensitive Magnet
local sensitiveMagnetEnabled = false
local originalMoveSpeed = currentMoveSpeed
local sensitiveSpeed = 100
local sensitiveDistance = 25
local isInSensitiveMode = false
local hasCompletedApproach = false

-- 🆕 Variabel untuk timer sampai Sensitive Mode
local reachStartTime = 0
local reachConfirmationTime = 0.3 -- 0.5 detik
local isConfirmingReach = false

-- 🆕 Variabel untuk auto dash
local lastDashTime = 0
local dashCooldown = 0.5 -- Cooldown 1 detik antara dash


-- 🆕 Variabel untuk smash release button
local isSmashButtonLocked = false
local isSmashButtonDragging = false
local smashButtonDragStart = nil
local smashButtonStartPosition = nil

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

-- 🆕 Fungsi untuk melakukan dash sekali
local function performDash()
    local currentTime = tick()

    -- Cek cooldown
    if (currentTime - lastDashTime) < dashCooldown then
        return false
    end

    local virtualInput = game:GetService("VirtualInputManager")

    -- Press dan release Q dengan cepat
    virtualInput:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.1) -- Tahan sebentar
    virtualInput:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

    lastDashTime = currentTime
    return true
end

-- 🎨 Buat UI Modern Minimalis
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallShadowMagnetUI"
screenGui.Parent = CoreGui

-- Main Frame (Tinggi ditambah untuk tombol baru)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 190) -- Increased height for new button
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
titleLabel.Text = "Racket Rivals"
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

-- Content Frame (diperbesar sedikit untuk row baru)
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

-- 🆕 Sensitive Magnet Toggle Button
local sensitiveMagnetButton = Instance.new("TextButton")
sensitiveMagnetButton.Name = "SensitiveMagnetButton"
sensitiveMagnetButton.Size = UDim2.new(0.97, 0, 0, 25)
sensitiveMagnetButton.Position = UDim2.new(0.02, 0, 0, 35)
sensitiveMagnetButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180) -- Warna sama
sensitiveMagnetButton.BackgroundTransparency = 0.1
sensitiveMagnetButton.BorderSizePixel = 0
sensitiveMagnetButton.Text = "🎯 SENSITIVE: OFF"
sensitiveMagnetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sensitiveMagnetButton.Font = Enum.Font.GothamMedium
sensitiveMagnetButton.TextSize = 11
sensitiveMagnetButton.Parent = contentFrame

local sensitiveMagnetCorner = Instance.new("UICorner")
sensitiveMagnetCorner.CornerRadius = UDim.new(0, 5)
sensitiveMagnetCorner.Parent = sensitiveMagnetButton

-- 🆕 ROW BARU: Hit, Smash, Jump dalam satu baris
local actionRowFrame = Instance.new("Frame")
actionRowFrame.Name = "ActionRowFrame"
actionRowFrame.Size = UDim2.new(1, 0, 0, 25)
actionRowFrame.Position = UDim2.new(0, 0, 0, 65)
actionRowFrame.BackgroundTransparency = 1
actionRowFrame.Parent = contentFrame

-- Hit Button (diperkecil dan dipersingkat)
local autoHitButton = Instance.new("TextButton")
autoHitButton.Name = "AutoHitButton"
autoHitButton.Size = UDim2.new(0.32, -2, 1, 0)               -- 1/3 lebar minus margin
autoHitButton.Position = UDim2.new(0.02, 0, 0, 0)
autoHitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180) -- Warna sama
autoHitButton.BackgroundTransparency = 0.1
autoHitButton.BorderSizePixel = 0
autoHitButton.Text = "HIT: OFF"
autoHitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoHitButton.Font = Enum.Font.GothamMedium
autoHitButton.TextSize = 10 -- Diperkecil
autoHitButton.Parent = actionRowFrame

local autoHitCorner = Instance.new("UICorner")
autoHitCorner.CornerRadius = UDim.new(0, 5)
autoHitCorner.Parent = autoHitButton

-- Smash Button (diperkecil dan dipersingkat)
local autoSmashButton = Instance.new("TextButton")
autoSmashButton.Name = "AutoSmashButton"
autoSmashButton.Size = UDim2.new(0.31, -2, 1, 0)
autoSmashButton.Position = UDim2.new(0.35, 0, 0, 0)            -- Posisi tengah
autoSmashButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180) -- Warna sama
autoSmashButton.BackgroundTransparency = 0.1
autoSmashButton.BorderSizePixel = 0
autoSmashButton.Text = "SMASH: OFF"
autoSmashButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSmashButton.Font = Enum.Font.GothamMedium
autoSmashButton.TextSize = 10 -- Diperkecil
autoSmashButton.Parent = actionRowFrame

local autoSmashCorner = Instance.new("UICorner")
autoSmashCorner.CornerRadius = UDim.new(0, 5)
autoSmashCorner.Parent = autoSmashButton

-- Jump Button (diperkecil dan dipersingkat)
local autoJumpButton = Instance.new("TextButton")
autoJumpButton.Name = "AutoJumpButton"
autoJumpButton.Size = UDim2.new(0.32, 0, 1, 0)
autoJumpButton.Position = UDim2.new(0.67, 0, 0, 0)            -- Posisi kanan
autoJumpButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180) -- Warna sama
autoJumpButton.BackgroundTransparency = 0.1
autoJumpButton.BorderSizePixel = 0
autoJumpButton.Text = "JUMP: OFF"
autoJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJumpButton.Font = Enum.Font.GothamMedium
autoJumpButton.TextSize = 10 -- Diperkecil
autoJumpButton.Parent = actionRowFrame

local autoJumpCorner = Instance.new("UICorner")
autoJumpCorner.CornerRadius = UDim.new(0, 5)
autoJumpCorner.Parent = autoJumpButton

-- Area Info Label (posisi disesuaikan)
local areaLabel = Instance.new("TextLabel")
areaLabel.Name = "AreaLabel"
areaLabel.Size = UDim2.new(1, 0, 0, 20)
areaLabel.Position = UDim2.new(0.03, 0, 0, 95) -- Posisi setelah action row
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Area: -"
areaLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
areaLabel.Font = Enum.Font.Gotham
areaLabel.TextSize = 10
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.Parent = contentFrame

-- 🆕 Speed Control yang diperbaiki
local speedFrame = Instance.new("Frame")
speedFrame.Name = "SpeedFrame"
speedFrame.Size = UDim2.new(0.97, 0, 0, 30)      -- Tinggi ditambah
speedFrame.Position = UDim2.new(0.02, 0, 0, 120) -- Posisi disesuaikan
speedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
speedFrame.BackgroundTransparency = 0.4
speedFrame.BorderSizePixel = 0
speedFrame.Parent = contentFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 5)
speedCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0.6, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 5, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. currentMoveSpeed
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local decreaseButton = Instance.new("TextButton")
decreaseButton.Name = "DecreaseButton"
decreaseButton.Size = UDim2.new(0, 50, 0, 25)       -- Ukuran diperbesar
decreaseButton.Position = UDim2.new(0.4, 5, 0.5, 0) -- Posisi center Y
decreaseButton.AnchorPoint = Vector2.new(0, 0.5)
decreaseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
decreaseButton.BackgroundTransparency = 0.3
decreaseButton.BorderSizePixel = 0
decreaseButton.Text = "-"
decreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseButton.Font = Enum.Font.GothamBold
decreaseButton.TextSize = 14 -- Diperbesar
decreaseButton.Parent = speedFrame

local increaseButton = Instance.new("TextButton")
increaseButton.Name = "IncreaseButton"
increaseButton.Size = UDim2.new(0, 50, 0, 25)        -- Ukuran diperbesar
increaseButton.Position = UDim2.new(0.72, 5, 0.5, 0) -- Posisi center Y
increaseButton.AnchorPoint = Vector2.new(0, 0.5)
increaseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
increaseButton.BackgroundTransparency = 0.3
increaseButton.BorderSizePixel = 0
increaseButton.Text = "+"
increaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseButton.Font = Enum.Font.GothamBold
increaseButton.TextSize = 14 -- Diperbesar
increaseButton.Parent = speedFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 4)
buttonCorner.Parent = decreaseButton
buttonCorner:Clone().Parent = increaseButton

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

-- 🆕 Auto Smash Release Button (Tombol luar frame)
local smashReleaseButton = Instance.new("TextButton")
smashReleaseButton.Name = "SmashReleaseButton"
smashReleaseButton.Size = UDim2.new(0, 80, 0, 80)
smashReleaseButton.Position = UDim2.new(1, -100, 1, -100)
smashReleaseButton.AnchorPoint = Vector2.new(1, 1)
smashReleaseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
smashReleaseButton.BackgroundTransparency = 0.2
smashReleaseButton.BorderSizePixel = 0
smashReleaseButton.Text = "RELEASE\nSMASH"
smashReleaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smashReleaseButton.Font = Enum.Font.GothamBold
smashReleaseButton.TextSize = 12
smashReleaseButton.TextWrapped = true
smashReleaseButton.Visible = false
smashReleaseButton.ZIndex = 10
smashReleaseButton.Parent = screenGui

local smashReleaseCorner = Instance.new("UICorner")
smashReleaseCorner.CornerRadius = UDim.new(1, 0)
smashReleaseCorner.Parent = smashReleaseButton

-- Glass effect untuk release button
local releaseGradient = Instance.new("UIGradient")
releaseGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 80, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 60, 60))
})
releaseGradient.Rotation = 90
releaseGradient.Parent = smashReleaseButton

-- 🆕 Lock Button untuk Smash Release
local smashLockButton = Instance.new("TextButton")
smashLockButton.Name = "SmashLockButton"
smashLockButton.Size = UDim2.new(0, 25, 0, 25)
smashLockButton.Position = UDim2.new(1, -30, 0, 5)
smashLockButton.AnchorPoint = Vector2.new(1, 0)
smashLockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
smashLockButton.BackgroundTransparency = 0.3
smashLockButton.BorderSizePixel = 0
smashLockButton.Text = "🔓"
smashLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smashLockButton.Font = Enum.Font.Gotham
smashLockButton.TextSize = 12
smashLockButton.Visible = false
smashLockButton.ZIndex = 11
smashLockButton.Parent = smashReleaseButton

local smashLockCorner = Instance.new("UICorner")
smashLockCorner.CornerRadius = UDim.new(1, 0)
smashLockCorner.Parent = smashLockButton

-- 🔧 Variabel untuk Auto Smash baru
local isFHeld = false
local lastReleaseTime = 0

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
        mainFrame.Size = UDim2.new(0, 220, 0, 28)
        minimizeButton.Text = "+"
    else
        -- Restore: tampilkan semua content
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 220, 0, 190)
        minimizeButton.Text = "−"
    end
end

-- 🔧 Fungsi untuk toggle UI visibility
local function toggleUIVisibility()
    isUIVisible = not isUIVisible
    mainFrame.Visible = isUIVisible
    toggleUIButton.Text = isUIVisible and "SHOW" or "HIDE"
end

-- 🆕 Fungsi untuk toggle lock smash button
local function toggleSmashButtonLock()
    isSmashButtonLocked = not isSmashButtonLocked

    if isSmashButtonLocked then
        smashLockButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        smashLockButton.Text = "🔒"
        smashReleaseButton.Draggable = false
    else
        smashLockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
        smashLockButton.Text = "🔓"
        smashReleaseButton.Draggable = true
    end
end

-- 🆕 Fungsi untuk handle drag smash release button
local function setupSmashButtonDrag()
    smashReleaseButton.Draggable = true

    smashReleaseButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not isSmashButtonLocked then
            isSmashButtonDragging = true
            smashButtonDragStart = input.Position
            smashButtonStartPosition = smashReleaseButton.Position
            smashReleaseButton.BackgroundTransparency = 0.4 -- Sedikit transparan saat didrag
        end
    end)

    smashReleaseButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isSmashButtonDragging then
            local delta = input.Position - smashButtonDragStart
            local newPosition = UDim2.new(
                smashButtonStartPosition.X.Scale,
                smashButtonStartPosition.X.Offset + delta.X,
                smashButtonStartPosition.Y.Scale,
                smashButtonStartPosition.Y.Offset + delta.Y
            )
            smashReleaseButton.Position = newPosition
        end
    end)

    smashReleaseButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isSmashButtonDragging then
            isSmashButtonDragging = false
            smashReleaseButton.BackgroundTransparency = 0.2 -- Kembali ke normal
        end
    end)
end

-- Panggil setup drag saat script mulai
setupSmashButtonDrag()

-- 🆕 Fungsi untuk toggle Sensitive Magnet
local function toggleSensitiveMagnet()
    sensitiveMagnetEnabled = not sensitiveMagnetEnabled
    isInSensitiveMode = false
    hasCompletedApproach = false

    if sensitiveMagnetEnabled then
        sensitiveMagnetButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        sensitiveMagnetButton.Text = "🎯 SENSITIVE: ON"
        areaLabel.Text = "Sensitive Mode: ON"
    else
        sensitiveMagnetButton.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
        sensitiveMagnetButton.Text = "🎯 SENSITIVE: OFF"

        -- Reset kecepatan jika sedang dalam sensitive mode
        if isInSensitiveMode then
            currentMoveSpeed = originalMoveSpeed
            updateSpeedDisplay()
            isInSensitiveMode = false
        end

        areaLabel.Text = currentArea and string.format("Area: %s", currentArea.name) or "Area: -"
    end
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
    isInSensitiveMode = false
    hasCompletedApproach = false
    isConfirmingReach = false -- 🆕 Reset timer

    -- Kembalikan kecepatan ke normal
    currentMoveSpeed = originalMoveSpeed
    updateSpeedDisplay()

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

        -- Simpan kecepatan asli
        originalMoveSpeed = currentMoveSpeed

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

            -- 🆕 PERBAIKAN: Cek posisi - hanya matikan magnet jika keluar lebih dari 20 stud dari area
            local currentPos = hrp.Position
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
                -- Reset state jika BallShadow hilang
                if isInSensitiveMode then
                    currentMoveSpeed = originalMoveSpeed
                    updateSpeedDisplay()
                    isInSensitiveMode = false
                end
                hasCompletedApproach = false
                isConfirmingReach = false -- 🆕 Reset timer
                return
            end

            -- Hitung jarak hanya di bidang XZ
            local currentXZ = Vector3.new(currentPos.X, 0, currentPos.Z)
            local targetXZ = Vector3.new(targetPosition.X, 0, targetPosition.Z)
            local distance = (targetXZ - currentXZ).Magnitude

            -- Cek jika sangat dekat (< 3 stud)
            local isVeryClose = distance < 5
            local currentTime = tick()

            -- 🆕 LOGIKA TIMER SAMPAI
            if isVeryClose and isInSensitiveMode and not isConfirmingReach then
                -- Mulai timer konfirmasi sampai
                isConfirmingReach = true
                reachStartTime = currentTime
                areaLabel.Text = string.format("Area: %s - Reaching...", currentArea.name)
            elseif isVeryClose and isInSensitiveMode and isConfirmingReach then
                -- Cek apakah sudah 0.5 detik dalam jarak dekat
                if (currentTime - reachStartTime) >= reachConfirmationTime then
                    -- 🔴 KONFIRMASI SAMPAI: Reset speed dan tandai sudah complete approach
                    isInSensitiveMode = false
                    hasCompletedApproach = true
                    isConfirmingReach = false
                    currentMoveSpeed = originalMoveSpeed
                    updateSpeedDisplay()
                    areaLabel.Text = string.format("Area: %s - Reached!", currentArea.name)
                else
                    -- Masih dalam proses konfirmasi
                    local timeLeft = reachConfirmationTime - (currentTime - reachStartTime)
                    areaLabel.Text = string.format("Area: %s - Reaching... (%.1fs)", currentArea.name, timeLeft)
                end
            elseif not isVeryClose and isConfirmingReach then
                -- 🆕 Batalkan konfirmasi jika jarak bertambah lagi
                isConfirmingReach = false
                areaLabel.Text = string.format("Area: %s", currentArea.name)
            end

            -- 🆕 CEK APAKAH BALLSHADOW KELUAR DARI AREA
            local isBallShadowOutOfArea = false
            if currentArea then
                isBallShadowOutOfArea = not isInArea(targetPosition, currentArea.bounds)
                if isBallShadowOutOfArea then
                    areaLabel.Text = string.format("Area: %s - Shuttle Out", currentArea.name)
                    isConfirmingReach = false -- 🆕 Reset timer jika keluar area
                end
            end

            -- 🆕 LOGIKA SENSITIVE MAGNET
            if sensitiveMagnetEnabled then
                if distance < sensitiveDistance and not isInSensitiveMode and not hasCompletedApproach and not isBallShadowOutOfArea and not isConfirmingReach then
                    -- 🟢 MASUK sensitive mode: pertama kali mendekati BallShadow (dalam area)
                    isInSensitiveMode = true
                    currentMoveSpeed = sensitiveSpeed
                    updateSpeedDisplay()
                    areaLabel.Text = string.format("Area: %s - SENSITIVE!", currentArea.name)
                elseif (distance >= sensitiveDistance or isBallShadowOutOfArea) and hasCompletedApproach then
                    hasCompletedApproach = false
                    isConfirmingReach = false -- 🆕 Reset timer
                    if isBallShadowOutOfArea then
                        areaLabel.Text = string.format("Area: %s - Shuttle Out, Ready", currentArea.name)
                    else
                        areaLabel.Text = string.format("Area: %s - Ready for Next", currentArea.name)
                    end
                end
            else
                -- Jika sensitive mode dimatikan, reset semua state
                if isInSensitiveMode or hasCompletedApproach or isConfirmingReach then
                    isInSensitiveMode = false
                    hasCompletedApproach = false
                    isConfirmingReach = false
                    currentMoveSpeed = originalMoveSpeed
                    updateSpeedDisplay()
                end
            end

            -- 🆕 AUTO DASH: Jika jarak antara 30-50 stud, lakukan dash
            if distance >= 30 and distance <= 50 then
                local dashed = performDash()
                if dashed then
                    areaLabel.Text = string.format("Area: %s - DASH!", currentArea.name)
                end
            end

            -- Jika sudah dekat dan konfirmasi sampai, tidak perlu bergerak
            if isVeryClose and isConfirmingReach then
                return
            end

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
    end
end

-- 🔧 Fungsi untuk Auto Smash baru (hold F terus menerus)
local function startAutoSmash()
    if autoSmashConnection then
        autoSmashConnection:Disconnect()
        autoSmashConnection = nil
    end

    local virtualInput = game:GetService("VirtualInputManager")

    autoSmashConnection = RunService.Heartbeat:Connect(function()
        -- Jika auto smash dimatikan oleh user, hentikan hold
        if not autoSmashEnabled then
            if isFHeld then
                virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                isFHeld = false
            end
            return
        end
    end)
end

-- 🔧 Fungsi untuk release lalu re-hold F (contohnya untuk klik kanan)
local function releaseAndReholdF()
    if not autoSmashEnabled then
        return
    end

    local virtualInput = game:GetService("VirtualInputManager")

    -- Lepas dulu
    virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    isFHeld = false

    -- Setelah 0.1 detik, tekan lagi
    task.wait(0.35)
    virtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    isFHeld = true
end

local function setupMouseInput()
    if rightMouseConnection then
        rightMouseConnection:Disconnect()
    end

    rightMouseConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            releaseAndReholdF()
        end
    end)
end

-- Panggil setup mouse input saat script mulai
setupMouseInput()

-- 🔧 Fungsi untuk toggle auto smash
local function toggleAutoSmash()
    autoSmashEnabled = not autoSmashEnabled

    if autoSmashEnabled then
        autoSmashButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        autoSmashButton.Text = "SMASH: ON"

        -- Tampilkan release button dan lock button
        smashReleaseButton.Visible = true
        smashLockButton.Visible = true

        -- Aktifkan mouse input untuk auto smash
        setupMouseInput()

        -- Cek status BallShadow saat pertama kali dinyalakan
        local ballShadow = workspace:FindFirstChild("BallShadow", true)
        if ballShadow and ballShadow:IsA("BasePart") then
            areaLabel.Text = "Area: Auto Smash Started"
        else
            areaLabel.Text = "Area: Auto Smash ON - Waiting for Shuttle..."
        end

        startAutoSmash()
    else
        autoSmashButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        autoSmashButton.Text = "SMASH: OFF"

        -- Sembunyikan release button dan lock button
        smashReleaseButton.Visible = false
        smashLockButton.Visible = false

        -- Nonaktifkan mouse input
        if rightMouseConnection then
            rightMouseConnection:Disconnect()
            rightMouseConnection = nil
        end

        -- Release tombol F ketika dimatikan
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        isFHeld = false

        if autoSmashConnection then
            autoSmashConnection:Disconnect()
            autoSmashConnection = nil
        end

        areaLabel.Text = currentArea and string.format("Area: %s", currentArea.name) or "Area: -"
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

-- 🆕 Fungsi untuk Auto Jump (hanya aktif ketika ada BallShadow dan dalam jarak <10 stud)
local function startAutoJump()
    if autoJumpConnection then
        autoJumpConnection:Disconnect()
        autoJumpConnection = nil
    end

    local lastJumpTime = 0
    local lastBallShadowState = false

    autoJumpConnection = RunService.Heartbeat:Connect(function()
        -- Jika auto jump dimatikan oleh user, keluar
        if not autoJumpEnabled then
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
            isInRange = distance < 27
        end

        if ballShadowExists and isInRange then
            if not lastBallShadowState then
                areaLabel.Text = "Area: Auto Jump Active"
                lastBallShadowState = true
            end
        else
            if lastBallShadowState then
                areaLabel.Text = "Area: Waiting for Shuttle..."
                lastBallShadowState = false
            end
            return -- Jangan lanjutkan jika BallShadow tidak ada atau terlalu jauh
        end

        -- Safety check: pastikan karakter ada dan tidak sedang jatuh
        local character = player.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end

        local currentTime = tick()

        -- Tekan tombol Space setiap 0.5 detik hanya jika BallShadow ada dan dalam jarak
        if (currentTime - lastJumpTime) > 0.5 then
            -- Cek apakah karakter bisa melompat (di tanah)
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                -- Langsung gunakan Humanoid.Jump
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

                lastJumpTime = currentTime

                -- Update area label untuk menunjukkan status aktif
                if currentArea then
                    areaLabel.Text = string.format("Area: %s - Auto Jumping", currentArea.name)
                else
                    areaLabel.Text = "Area: Auto Jumping"
                end
            else
                -- Karakter di udara, tunggu sampai mendarat
                if currentArea then
                    areaLabel.Text = string.format("Area: %s - In Air", currentArea.name)
                else
                    areaLabel.Text = "Area: In Air"
                end
            end
        end
    end)
end

-- 🆕 Fungsi untuk toggle auto jump
local function toggleAutoJump()
    autoJumpEnabled = not autoJumpEnabled

    if autoJumpEnabled then
        autoJumpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        autoJumpButton.Text = "JUMP: ON"
        areaLabel.Text = "Area: Auto Jump ON" -- Feedback jelas

        startAutoJump()
    else
        autoJumpButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        autoJumpButton.Text = "JUMP: OFF"

        if autoJumpConnection then
            autoJumpConnection:Disconnect()
            autoJumpConnection = nil
        end

        areaLabel.Text = currentArea and string.format("Area: %s", currentArea.name) or "Area: -"
    end
end

-- Event handler untuk semua toggle button
toggleButton.MouseButton1Click:Connect(toggleMagnet)
sensitiveMagnetButton.MouseButton1Click:Connect(toggleSensitiveMagnet) -- 🆕 Added sensitive magnet handler
autoSmashButton.MouseButton1Click:Connect(toggleAutoSmash)
autoHitButton.MouseButton1Click:Connect(toggleAutoHit)
autoJumpButton.MouseButton1Click:Connect(toggleAutoJump) -- 🆕 Added auto jump handler

-- 🆕 Event handler untuk release button
smashReleaseButton.MouseButton1Click:Connect(releaseAndReholdF)

-- 🆕 Event handler untuk lock button
smashLockButton.MouseButton1Click:Connect(toggleSmashButtonLock)

-- Tambahkan dalam closeButton event handler
closeButton.MouseButton1Click:Connect(function()
    -- Cleanup semua koneksi
    if rightMouseConnection then
        rightMouseConnection:Disconnect()
        rightMouseConnection = nil
    end

    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end

    if autoSmashConnection then
        autoSmashConnection:Disconnect()
        autoSmashConnection = nil
    end

    if autoHitConnection then
        autoHitConnection:Disconnect()
        autoHitConnection = nil
    end

    if autoJumpConnection then
        autoJumpConnection:Disconnect()
        autoJumpConnection = nil
    end

    -- Release tombol F
    local virtualInput = game:GetService("VirtualInputManager")
    virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)

    screenGui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(toggleMinimize)
toggleUIButton.MouseButton1Click:Connect(toggleUIVisibility)

-- Speed control handlers (diperbarui untuk max speed 200)
decreaseButton.MouseButton1Click:Connect(function()
    if currentMoveSpeed > 10 then
        currentMoveSpeed = currentMoveSpeed - 10
        originalMoveSpeed = currentMoveSpeed -- Update original speed too
        updateSpeedDisplay()
    end
end)

increaseButton.MouseButton1Click:Connect(function()
    if currentMoveSpeed < 200 then           -- Diubah dari 100 menjadi 200
        currentMoveSpeed = currentMoveSpeed + 10
        originalMoveSpeed = currentMoveSpeed -- Update original speed too
        updateSpeedDisplay()
    end
end)
