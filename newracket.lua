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

-- 🔧 Fungsi untuk mendapatkan posisi BallShadow
local function getBallShadowPosition()
    local ballShadow = workspace:FindFirstChild("BallShadow", true)
    if not ballShadow or not ballShadow:IsA("BasePart") then
        return nil
    end
    return ballShadow.Position
end

-- 🆕 Fungsi untuk membuat karakter terbang ke atas
local function makeCharacterFly(character)
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        -- Terbang ke atas 10 stud
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        bodyVelocity.MaxForce = Vector3.new(0, 10000, 0)
        bodyVelocity.Parent = hrp

        -- Hapus setelah 0.2 detik
        task.delay(0.2, function()
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end)
    end
end

-- 🆕 Fungsi untuk mematikan magnet dengan proper cleanup
local function disableMagnet()
    magnetEnabled = false
    currentArea = nil

    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
    toggleButton.Text = "🔴 MAGNET OFF"

    if magnetConnection then
        magnetConnection:Disconnect()
        magnetConnection = nil
    end
end

-- 🔧 FUNGSI TOGGLE MAGNET YANG DIPERBAIKI
local function toggleMagnet()
    -- Cek karakter
    local character = player.Character
    if not character then
        areaLabel.Text = "Error: No character"
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        areaLabel.Text = "Error: No HRP"
        return
    end

    if magnetEnabled then
        -- Nonaktifkan magnet
        disableMagnet()
        areaLabel.Text = "Magnet: OFF"
    else
        -- Aktifkan magnet
        magnetEnabled = true

        -- Cari area terdekat
        local nearestArea = nil
        local nearestDistance = math.huge

        for _, areaData in ipairs(areaList) do
            local bounds = calculateAreaBounds(areaData.corners)
            local centerX = (bounds.minX + bounds.maxX) / 2
            local centerZ = (bounds.minZ + bounds.maxZ) / 2
            local areaCenter = Vector3.new(centerX, hrp.Position.Y, centerZ)

            local distance = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(areaCenter.X, 0, areaCenter.Z))
            .Magnitude

            if distance < nearestDistance then
                nearestDistance = distance
                nearestArea = areaData
            end
        end

        if nearestArea then
            currentArea = nearestArea
            currentArea.bounds = calculateAreaBounds(currentArea.corners)
            areaLabel.Text = "Area: " .. currentArea.name
        else
            areaLabel.Text = "Area: Not found"
        end

        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        toggleButton.Text = "🟢 MAGNET ON"

        -- Mulai magnet system
        if magnetConnection then
            magnetConnection:Disconnect()
        end

        magnetConnection = RunService.Heartbeat:Connect(function()
            if not magnetEnabled then return end

            local character = player.Character
            if not character then
                disableMagnet()
                return
            end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                disableMagnet()
                return
            end

            -- Dapatkan posisi BallShadow
            local ballPos = getBallShadowPosition()
            if not ballPos then
                areaLabel.Text = "Area: " .. (currentArea and currentArea.name or "Unknown") .. " - No shuttle"
                return
            end

            -- Cek apakah BallShadow dalam area
            if currentArea and not isInArea(ballPos, currentArea.bounds) then
                areaLabel.Text = "Area: " .. currentArea.name .. " - Shuttle out"
                return
            end

            -- TELEPORT INSTANT ke posisi BallShadow
            hrp.CFrame = CFrame.new(ballPos.X, hrp.Position.Y, ballPos.Z)

            -- Buat karakter terbang
            makeCharacterFly(character)

            areaLabel.Text = "Area: " .. (currentArea and currentArea.name or "Unknown") .. " - Active"
        end)
    end
end

-- 🔧 FUNGSI AUTO HIT YANG DIPERBAIKI
local function startAutoHit()
    if autoHitConnection then
        autoHitConnection:Disconnect()
        autoHitConnection = nil
    end

    local lastHitTime = 0

    autoHitConnection = RunService.Heartbeat:Connect(function()
        if not autoHitEnabled then return end

        -- Cek BallShadow
        local ballPos = getBallShadowPosition()
        if not ballPos then
            areaLabel.Text = "Auto Hit: Waiting for shuttle"
            return
        end

        -- Cek karakter
        local character = player.Character
        if not character then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Hitung jarak
        local distance = (Vector3.new(ballPos.X, 0, ballPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z))
        .Magnitude

        -- Jika dalam jarak 15 stud, lakukan hit
        if distance <= 15 then
            local currentTime = tick()
            if (currentTime - lastHitTime) > 0.1 then
                local virtualInput = game:GetService("VirtualInputManager")
                virtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                virtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)

                lastHitTime = currentTime
                areaLabel.Text = "Auto Hit: Hitting!"
            end
        else
            areaLabel.Text = "Auto Hit: Too far (" .. math.floor(distance) .. " studs)"
        end
    end)
end

-- 🔧 Fungsi untuk toggle auto hit
local function toggleAutoHit()
    autoHitEnabled = not autoHitEnabled

    if autoHitEnabled then
        autoHitButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        autoHitButton.Text = "HIT: ON"
        areaLabel.Text = "Auto Hit: ON"

        startAutoHit()
    else
        autoHitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        autoHitButton.Text = "HIT: OFF"

        if autoHitConnection then
            autoHitConnection:Disconnect()
            autoHitConnection = nil
        end

        areaLabel.Text = currentArea and "Area: " .. currentArea.name or "Area: -"
    end
end

-- 🎨 Buat UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallShadowMagnetUI"
screenGui.Parent = CoreGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 120)
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

-- Title Bar
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

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -10, 1, -35)
contentFrame.Position = UDim2.new(0, 5, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Toggle Button Magnet
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.97, 0, 0, 30)
toggleButton.Position = UDim2.new(0.02, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
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
autoHitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
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

-- Show/Hide Toggle Button
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
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 220, 0, 28)
        minimizeButton.Text = "+"
    else
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

-- Event handler
toggleButton.MouseButton1Click:Connect(toggleMagnet)
autoHitButton.MouseButton1Click:Connect(toggleAutoHit)

closeButton.MouseButton1Click:Connect(function()
    if magnetConnection then
        magnetConnection:Disconnect()
    end
    if autoHitConnection then
        autoHitConnection:Disconnect()
    end
    screenGui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(toggleMinimize)
toggleUIButton.MouseButton1Click:Connect(toggleUIVisibility)
