-- Teleport Script (Executor + Mobile Support)
-- By DeepSeek Chat

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local savedPosition = { X = 0, Y = 100, Z = 0 }
local isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
local uiEnabled = false

-- Fungsi untuk membuat UI yang mobile-friendly
local function createTeleportUI()
    if player.PlayerGui:FindFirstChild("TeleportMobileGUI") then
        player.PlayerGui.TeleportMobileGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportMobileGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false

    -- Main Frame (Responsive untuk Mobile & Desktop)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = isMobile and UDim2.new(0.8, 0, 0, 220) or UDim2.new(0, 300, 0, 220)
    mainFrame.Position = isMobile and UDim2.new(0.1, 0, 0.5, -110) or UDim2.new(0.5, -150, 0.5, -110)
    mainFrame.AnchorPoint = isMobile and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = mainFrame

    -- Title Bar (Bisa di-drag di Mobile)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleText = Instance.new("TextLabel")
    titleText.Text = "🚀 TELEPORT MENU"
    titleText.Size = UDim2.new(0.7, 0, 1, 0)
    titleText.Position = UDim2.new(0.1, 0, 0, 0)
    titleText.TextColor3 = Color3.new(1, 1, 1)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.BackgroundTransparency = 1
    titleText.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Text = "✕"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    -- Input Fields (Optimized for Touch)
    local function createInputField(placeholder, yPos, defaultValue)
        local textBox = Instance.new("TextBox")
        textBox.PlaceholderText = placeholder
        textBox.Text = tostring(defaultValue)
        textBox.Size = UDim2.new(0.8, 0, 0, 35)
        textBox.Position = UDim2.new(0.1, 0, 0, yPos)
        textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        textBox.TextColor3 = Color3.new(1, 1, 1)
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 14
        textBox.ClearTextOnFocus = false
        textBox.Parent = mainFrame

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = textBox

        return textBox
    end

    local xInput = createInputField("X Position", 40, savedPosition.X)
    local yInput = createInputField("Y Position", 85, savedPosition.Y)
    local zInput = createInputField("Z Position", 130, savedPosition.Z)

    -- Big Teleport Button (Easy to Tap on Mobile)
    local teleportButton = Instance.new("TextButton")
    teleportButton.Text = "TELEPORT"
    teleportButton.Size = UDim2.new(0.8, 0, 0, 40)
    teleportButton.Position = UDim2.new(0.1, 0, 0, 170)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 18
    teleportButton.Parent = mainFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = teleportButton

    -- Drag Functionality (Untuk Mobile)
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Close UI
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        uiEnabled = false
    end)

    -- Teleport Function
    teleportButton.MouseButton1Click:Connect(function()
        local targetCFrame = CFrame.new(
            tonumber(xInput.Text) or 0,
            tonumber(yInput.Text) or 0,
            tonumber(zInput.Text) or 0
        )
        
        if humanoidRootPart then
            humanoidRootPart.CFrame = targetCFrame
        end
    end)

    -- Simpan posisi saat UI ditutup
    screenGui.Destroying:Connect(function()
        savedPosition.X = tonumber(xInput.Text) or 0
        savedPosition.Y = tonumber(yInput.Text) or 0
        savedPosition.Z = tonumber(zInput.Text) or 0
    end)
end

-- Toggle UI dengan tombol (F4 di Desktop / Button di Mobile)
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F4 and not gameProcessed then
            if not uiEnabled then
                createTeleportUI()
                uiEnabled = true
            else
                if player.PlayerGui:FindFirstChild("TeleportMobileGUI") then
                    player.PlayerGui.TeleportMobileGUI:Destroy()
                    uiEnabled = false
                end
            end
        end
    end)
else
    -- Jika mobile, buat floating button untuk membuka UI
    local openButton = Instance.new("TextButton")
    openButton.Name = "MobileOpenButton"
    openButton.Text = "📱"
    openButton.Size = UDim2.new(0, 50, 0, 50)
    openButton.Position = UDim2.new(0.8, 0, 0.7, 0)
    openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    openButton.TextColor3 = Color3.new(1, 1, 1)
    openButton.Font = Enum.Font.GothamBold
    openButton.TextSize = 20
    openButton.Parent = player.PlayerGui:WaitForChild("TeleportMobileGUI", 1) or player:WaitForChild("PlayerGui")

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = openButton

    openButton.MouseButton1Click:Connect(function()
        if not uiEnabled then
            createTeleportUI()
            uiEnabled = true
            openButton.Visible = false
        end
    end)
end

print("✅ Teleport Loaded! " .. (isMobile and "Tap the 📱 button to open." or "Press F4 to open."))