-- Teleport System 2025 (Executor Friendly)
-- By DeepSeek Chat - Updated for 2025

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local NotificationService = game:GetService("NotificationService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10) or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart")

-- Configuration
local savedPosition = { X = 0, Y = 100, Z = 0 }
local isMobile = UserInputService.TouchEnabled
local uiEnabled = false
local lastNotification = 0

-- Fungsi untuk menampilkan notifikasi
local function showNotification(message)
    local now = tick()
    if now - lastNotification < 2 then return end -- Anti spam
    lastNotification = now
    
    if NotificationService then
        NotificationService:SendNotification(message)
    else
        -- Fallback untuk executor yang tidak support NotificationService
        local notif = Instance.new("ScreenGui")
        local text = Instance.new("TextLabel")
        
        notif.Name = "ScriptNotification"
        notif.Parent = CoreGui
        notif.ResetOnSpawn = false
        
        text.Text = "🔔 "..message
        text.Size = UDim2.new(0, 300, 0, 40)
        text.Position = UDim2.new(0.5, -150, 0.1, 0)
        text.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 14
        text.Parent = notif
        
        task.delay(3, function()
            notif:Destroy()
        end)
    end
end

-- Fungsi untuk membuat UI teleport
local function createTeleportUI()
    -- Hapus UI lama jika ada
    if CoreGui:FindFirstChild("TeleportGUI2025") then
        CoreGui.TeleportGUI2025:Destroy()
    end
    
    -- Buat ScreenGui utama
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGUI2025"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    uiEnabled = true

    -- Frame utama
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = isMobile and UDim2.new(0.85, 0, 0, 250) or UDim2.new(0, 350, 0, 250)
    mainFrame.Position = isMobile and UDim2.new(0.075, 0, 0.5, -125) or UDim2.new(0.5, -175, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Efek UI modern
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(80, 80, 90)
    uiStroke.Thickness = 2
    uiStroke.Parent = mainFrame

    -- Header dengan shadow
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Text = "🚀 TELEPORT SYSTEM 2025"
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.15, 0, 0, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.Parent = header

    -- Tombol close
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "✕"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header

    -- Input fields
    local function createInputField(name, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.9, 0, 0, 40)
        frame.Position = UDim2.new(0.05, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = mainFrame

        local label = Instance.new("TextLabel")
        label.Text = name..":"
        label.Size = UDim2.new(0.3, 0, 1, 0)
        label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = frame

        local textBox = Instance.new("TextBox")
        textBox.PlaceholderText = "Enter "..name
        textBox.Text = tostring(savedPosition[name:upper()])
        textBox.Size = UDim2.new(0.7, 0, 1, 0)
        textBox.Position = UDim2.new(0.3, 0, 0, 0)
        textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        textBox.TextColor3 = Color3.new(1, 1, 1)
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 14
        textBox.Parent = frame

        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 6)
        boxCorner.Parent = textBox

        return textBox
    end

    local xInput = createInputField("X", 50)
    local yInput = createInputField("Y", 100)
    local zInput = createInputField("Z", 150)

    -- Teleport button
    local teleportButton = Instance.new("TextButton")
    teleportButton.Text = "TELEPORT NOW"
    teleportButton.Size = UDim2.new(0.9, 0, 0, 40)
    teleportButton.Position = UDim2.new(0.05, 0, 0, 200)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 16
    teleportButton.Parent = mainFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = teleportButton

    -- Drag functionality
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Close button action
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        uiEnabled = false
    end)

    -- Teleport button action
    teleportButton.MouseButton1Click:Connect(function()
        savedPosition.X = tonumber(xInput.Text) or 0
        savedPosition.Y = tonumber(yInput.Text) or 100
        savedPosition.Z = tonumber(zInput.Text) or 0
        
        local targetCFrame = CFrame.new(savedPosition.X, savedPosition.Y, savedPosition.Z)
        
        if humanoidRootPart then
            humanoidRootPart.CFrame = targetCFrame
            showNotification("Teleported to "..math.floor(savedPosition.X)..", "..math.floor(savedPosition.Y)..", "..math.floor(savedPosition.Z))
        else
            showNotification("⚠️ Error: Character part not found")
        end
    end)
end

-- Floating button for mobile
if isMobile then
    local openButton = Instance.new("TextButton")
    openButton.Name = "MobileTeleportButton2025"
    openButton.Text = "🚀"
    openButton.Size = UDim2.new(0, 60, 0, 60)
    openButton.Position = UDim2.new(0.8, 0, 0.7, 0)
    openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    openButton.TextColor3 = Color3.new(1, 1, 1)
    openButton.Font = Enum.Font.GothamBold
    openButton.TextSize = 24
    openButton.Parent = CoreGui
    openButton.ZIndex = 999
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = openButton
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(100, 100, 120)
    buttonStroke.Thickness = 2
    buttonStroke.Parent = openButton
    
    openButton.MouseButton1Click:Connect(function()
        if not uiEnabled then
            createTeleportUI()
        end
    end)
end

-- Keybind for desktop (F4)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isMobile and input.KeyCode == Enum.KeyCode.F4 and not gameProcessed then
        if not uiEnabled then
            createTeleportUI()
        else
            if CoreGui:FindFirstChild("TeleportGUI2025") then
                CoreGui.TeleportGUI2025:Destroy()
                uiEnabled = false
            end
        end
    end
end)

-- Initial notification
showNotification("Teleport System 2025 Loaded! "..(isMobile and "Tap 🚀 to open" or "Press F4 to open"))

-- Auto-update character reference
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10) or newChar:FindFirstChild("UpperTorso") or newChar:FindFirstChildWhichIsA("BasePart")
    showNotification("Character updated!")
end)