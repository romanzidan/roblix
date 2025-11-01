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
local currentMoveSpeed = 40
local currentArea = nil
local isMinimized = false

-- 🗺️ Daftar area yang tersedia
local areaList = {
    {
        name = "Area 1",
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
        name = "Area 2",
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

-- 🎨 Buat UI Modern
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallShadowMagnetUI"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 250) -- Diperkecil 30px
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -80, 1, 0) -- Diperkecil untuk tombol minimize
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎯 Ball Shadow Magnet"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -60, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
minimizeButton.BackgroundTransparency = 0.3
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
closeButton.BackgroundTransparency = 0.3
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton
closeCorner:Clone().Parent = minimizeButton

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 0, 45)
toggleButton.Position = UDim2.new(0, 0, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
toggleButton.BackgroundTransparency = 0.1
toggleButton.BorderSizePixel = 0
toggleButton.Text = "🔴 MAGNET: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Speed Control
local speedFrame = Instance.new("Frame")
speedFrame.Name = "SpeedFrame"
speedFrame.Size = UDim2.new(1, 0, 0, 35)
speedFrame.Position = UDim2.new(0, 0, 0, 65)
speedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
speedFrame.BackgroundTransparency = 0.3
speedFrame.BorderSizePixel = 0
speedFrame.Parent = contentFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0.4, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 10, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. currentMoveSpeed
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local decreaseButton = Instance.new("TextButton")
decreaseButton.Name = "DecreaseButton"
decreaseButton.Size = UDim2.new(0, 30, 0, 25)
decreaseButton.Position = UDim2.new(0.4, 5, 0, 5)
decreaseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
decreaseButton.BackgroundTransparency = 0.2
decreaseButton.BorderSizePixel = 0
decreaseButton.Text = "-"
decreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseButton.Font = Enum.Font.GothamBold
decreaseButton.TextSize = 14
decreaseButton.Parent = speedFrame

local increaseButton = Instance.new("TextButton")
increaseButton.Name = "IncreaseButton"
increaseButton.Size = UDim2.new(0, 30, 0, 25)
increaseButton.Position = UDim2.new(0.4, 40, 0, 5)
increaseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
increaseButton.BackgroundTransparency = 0.2
increaseButton.BorderSizePixel = 0
increaseButton.Text = "+"
increaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseButton.Font = Enum.Font.GothamBold
increaseButton.TextSize = 14
increaseButton.Parent = speedFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 4)
buttonCorner.Parent = decreaseButton
buttonCorner:Clone().Parent = increaseButton

-- Status Info
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 110)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Menunggu..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

local areaLabel = Instance.new("TextLabel")
areaLabel.Name = "AreaLabel"
areaLabel.Size = UDim2.new(1, 0, 0, 15)
areaLabel.Position = UDim2.new(0, 0, 0, 135)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Area: Belum dipilih"
areaLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
areaLabel.Font = Enum.Font.Gotham
areaLabel.TextSize = 10
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.Parent = contentFrame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Name = "DistanceLabel"
distanceLabel.Size = UDim2.new(1, 0, 0, 15)
distanceLabel.Position = UDim2.new(0, 0, 0, 155)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "Jarak: -"
distanceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 10
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = contentFrame


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
        mainFrame.Size = UDim2.new(0, 280, 0, 35)
        minimizeButton.Text = "+"
    else
        -- Restore: tampilkan semua content
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 280, 0, 250)
        minimizeButton.Text = "−"
    end
end

-- 🔧 Fungsi untuk toggle magnet dengan safety check
local function toggleMagnet()
    magnetEnabled = not magnetEnabled

    if magnetEnabled then
        -- Safety check: pastikan karakter ada
        local character = player.Character
        if not character then
            statusLabel.Text = "Status: ERROR - Karakter tidak ditemukan"
            magnetEnabled = false
            return
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            statusLabel.Text = "Status: ERROR - HumanoidRootPart tidak ditemukan"
            magnetEnabled = false
            return
        end

        -- Tentukan area terdekat saat magnet diaktifkan
        currentArea = getNearestArea(hrp.Position)
        if not currentArea then
            statusLabel.Text = "Status: ERROR - Area tidak ditemukan"
            magnetEnabled = false
            return
        end

        -- Hitung bounds untuk area yang dipilih
        currentArea.bounds = calculateAreaBounds(currentArea.corners)

        local bounds = currentArea.bounds
        areaLabel.Text = string.format("Area: %s (X:%.1f-%.1f, Z:%.1f-%.1f)",
            currentArea.name, bounds.minX, bounds.maxX, bounds.minZ, bounds.maxZ)

        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        toggleButton.Text = "🟢 MAGNET: ON"
        statusLabel.Text = "Status: Mencari BallShadow..."

        -- Mulai magnet system dengan safety check
        if magnetConnection then
            magnetConnection:Disconnect()
        end

        magnetConnection = RunService.Heartbeat:Connect(function(dt)
            -- Safety check berulang
            local character = player.Character
            if not character then
                statusLabel.Text = "Status: ERROR - Karakter hilang"
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if not (humanoid and hrp and currentArea) then
                statusLabel.Text = "Status: ERROR - Komponen karakter hilang"
                return
            end

            -- Cek posisi karakter saat ini (hanya X dan Z)
            local currentPos = hrp.Position
            if not isInArea(currentPos, currentArea.bounds) then
                -- Jika karakter keluar area, bawa kembali ke area terdekat
                local safePos = clampToArea(currentPos, currentArea.bounds)
                hrp.CFrame = CFrame.new(safePos)
                statusLabel.Text = "Status: Karakter dikembalikan ke area!"
                return
            end

            -- Dapatkan posisi BallShadow yang aman (hanya X dan Z)
            local targetPosition, isClamped = getSafeBallShadowPosition()
            if not targetPosition then
                statusLabel.Text = "Status: BallShadow tidak ditemukan"
                distanceLabel.Text = "Jarak: -"
                return -- JANGAN gerakkan karakter jika BallShadow tidak ditemukan
            end

            -- Hitung jarak hanya di bidang XZ (abaikan Y)
            local currentXZ = Vector3.new(currentPos.X, 0, currentPos.Z)
            local targetXZ = Vector3.new(targetPosition.X, 0, targetPosition.Z)
            local distance = (targetXZ - currentXZ).Magnitude

            -- Update distance display
            distanceLabel.Text = string.format("Jarak: %.1f studs", distance)

            -- Jika jarak lebih dari 50 studs, nonaktifkan magnet
            if distance > 50 then
                statusLabel.Text = string.format("Status: Jarak terlalu jauh (%.1f studs)", distance)
                return
            end

            -- Update status dengan info clamping
            if isClamped then
                statusLabel.Text = string.format("Status: BallShadow di luar area (%.1f studs)", distance)
            else
                statusLabel.Text = string.format("Status: Mengikuti BallShadow (%.1f studs)", distance)
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
                statusLabel.Text = "Status: Bergerak di batas area"
            end

            -- Terapkan gerakan (hanya update X dan Z, pertahankan Y)
            hrp.CFrame = CFrame.new(
                newPosition.X, currentPos.Y, newPosition.Z
            ) * CFrame.Angles(0, math.atan2(directionXZ.X, directionXZ.Z), 0)
        end)
    else
        -- Reset area ketika magnet dimatikan
        currentArea = nil
        areaLabel.Text = "Area: Belum dipilih"
        distanceLabel.Text = "Jarak: -"

        toggleButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        toggleButton.Text = "🔴 MAGNET: OFF"
        statusLabel.Text = "Status: Nonaktif"

        -- Hentikan magnet system
        if magnetConnection then
            magnetConnection:Disconnect()
            magnetConnection = nil
        end
    end
end

-- 🖱️ Event handlers untuk UI
toggleButton.MouseButton1Click:Connect(toggleMagnet)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()

    -- Hentikan magnet jika aktif
    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end
end)

minimizeButton.MouseButton1Click:Connect(toggleMinimize)

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

-- Efek hover untuk tombol
local function setupButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = normalColor
    end)
end

setupButtonHover(toggleButton,
    magnetEnabled and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(220, 60, 60),
    magnetEnabled and Color3.fromRGB(50, 160, 70) or Color3.fromRGB(200, 50, 50)
)

setupButtonHover(closeButton,
    Color3.fromRGB(45, 45, 50),
    Color3.fromRGB(55, 55, 60)
)

setupButtonHover(minimizeButton,
    Color3.fromRGB(45, 45, 50),
    Color3.fromRGB(55, 55, 60)
)

setupButtonHover(decreaseButton,
    Color3.fromRGB(60, 60, 70),
    Color3.fromRGB(70, 70, 80)
)

setupButtonHover(increaseButton,
    Color3.fromRGB(60, 60, 70),
    Color3.fromRGB(70, 70, 80)
)

-- Update toggle button hover effect when toggled
toggleButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
    if magnetEnabled then
        setupButtonHover(toggleButton,
            Color3.fromRGB(60, 180, 80),
            Color3.fromRGB(50, 160, 70)
        )
    else
        setupButtonHover(toggleButton,
            Color3.fromRGB(220, 60, 60),
            Color3.fromRGB(200, 50, 50)
        )
    end
end)
