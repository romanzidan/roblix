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

-- 🗺️ Batas area kotak (hanya X dan Z)
local areaCorners = {
    Vector3.new(-103.95, -518.31, -146.48),
    Vector3.new(-61.86, -518.30, -145.44),
    Vector3.new(-21.00, -518.30, -146.16),
    Vector3.new(-21.28, -518.30, -115.72),
    Vector3.new(-20.68, -518.30, -74.05),
    Vector3.new(-62.75, -518.30, -73.71),
    Vector3.new(-103.96, -518.30, -74.21),
    Vector3.new(-104.56, -518.30, -115.14)
}

-- Hitung batas min/max untuk X dan Z saja
local minX, maxX = math.huge, -math.huge
local minZ, maxZ = math.huge, -math.huge

for _, corner in ipairs(areaCorners) do
    minX = math.min(minX, corner.X)
    maxX = math.max(maxX, corner.X)
    minZ = math.min(minZ, corner.Z)
    maxZ = math.max(maxZ, corner.Z)
end

print(string.format("📦 Batas Area: X(%.2f to %.2f) Z(%.2f to %.2f)", minX, maxX, minZ, maxZ))

-- 🔧 Fungsi untuk cek apakah posisi berada dalam area (hanya X dan Z)
local function isInArea(position)
    return position.X >= minX and position.X <= maxX and
        position.Z >= minZ and position.Z <= maxZ
end

-- 🔧 Fungsi untuk membatasi posisi ke dalam area (hanya X dan Z)
local function clampToArea(position)
    local clamped = Vector3.new(
        math.clamp(position.X, minX, maxX),
        position.Y, -- Pertahankan Y asli
        math.clamp(position.Z, minZ, maxZ)
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

    -- Jika BallShadow di luar area, batasi ke area terdekat (hanya X dan Z)
    if not isInArea(targetPos) then
        targetPos = clampToArea(ballPos)
        return targetPos, true -- Return true untuk menandai posisi dibatasi
    end

    return targetPos, false
end

-- 🎨 Buat UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallShadowMagnetUI"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Ball Shadow Magnet"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 0, 40)
toggleButton.Position = UDim2.new(0, 0, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "MAGNET: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 60)
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
areaLabel.Position = UDim2.new(0, 0, 0, 85)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = string.format("Area: X(%.1f-%.1f) Z(%.1f-%.1f)", minX, maxX, minZ, maxZ)
areaLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
areaLabel.Font = Enum.Font.Gotham
areaLabel.TextSize = 10
areaLabel.TextXAlignment = Enum.TextXAlignment.Left
areaLabel.Parent = contentFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(1, 0, 0, 40)
infoLabel.Position = UDim2.new(0, 0, 0, 105)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Magnet hanya mengikuti X dan Z BallShadow. Karakter tetap dalam area."
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = contentFrame

-- 🔧 Fungsi untuk toggle magnet
local function toggleMagnet()
    magnetEnabled = not magnetEnabled

    if magnetEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        toggleButton.Text = "MAGNET: ON"
        statusLabel.Text = "Status: Mencari BallShadow..."

        -- Mulai magnet system
        if magnetConnection then
            magnetConnection:Disconnect()
        end

        magnetConnection = RunService.Heartbeat:Connect(function(dt)
            local character = player.Character
            if not character then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if not (humanoid and hrp) then return end

            -- Cek posisi karakter saat ini (hanya X dan Z)
            local currentPos = hrp.Position
            if not isInArea(currentPos) then
                -- Jika karakter keluar area, bawa kembali ke area terdekat
                local safePos = clampToArea(currentPos)
                hrp.CFrame = CFrame.new(safePos)
                statusLabel.Text = "Status: Karakter dikembalikan ke area!"
                return
            end

            -- Dapatkan posisi BallShadow yang aman (hanya X dan Z)
            local targetPosition, isClamped = getSafeBallShadowPosition()
            if not targetPosition then
                statusLabel.Text = "Status: BallShadow tidak ditemukan"
                return
            end

            -- Hitung jarak hanya di bidang XZ (abaikan Y)
            local currentXZ = Vector3.new(currentPos.X, 0, currentPos.Z)
            local targetXZ = Vector3.new(targetPosition.X, 0, targetPosition.Z)
            local distance = (targetXZ - currentXZ).Magnitude

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

            -- Gerakan smooth dengan kecepatan normal
            local moveSpeed = 40 -- Kecepatan normal berjalan
            local moveDistance = moveSpeed * dt

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
            if not isInArea(newPosition) then
                newPosition = clampToArea(newPosition)
                statusLabel.Text = "Status: Bergerak di batas area"
            end

            -- Terapkan gerakan (hanya update X dan Z, pertahankan Y)
            hrp.CFrame = CFrame.new(
                newPosition.X, currentPos.Y, newPosition.Z
            ) * CFrame.Angles(0, math.atan2(directionXZ.X, directionXZ.Z), 0)
        end)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        toggleButton.Text = "MAGNET: OFF"
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

-- Efek hover untuk tombol
toggleButton.MouseEnter:Connect(function()
    if magnetEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 160, 70)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(235, 50, 50)
    end
end)

toggleButton.MouseLeave:Connect(function()
    if magnetEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    end
end)

closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(235, 40, 40)
end)

closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
end)
