-- Teleport LocalScript (Executor-Friendly + Mobile Support)
-- By DeepSeek Chat - Fixed Version

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local savedPosition = { X = 0, Y = 100, Z = 0 }
local isMobile = UserInputService.TouchEnabled
local teleportUI = nil

-- Fungsi untuk membuat UI
local function createTeleportUI()
    if teleportUI and teleportUI.Parent then teleportUI:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGUI_Mobile"
    screenGui.Parent = game:GetService("CoreGui") -- Pakai CoreGui agar lebih stabil
    teleportUI = screenGui

    -- Main Frame (Responsif untuk Mobile/Desktop)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = isMobile and UDim2.new(0.8, 0, 0, 220) or UDim2.new(0, 300, 0, 220)
    mainFrame.Position = isMobile and UDim2.new(0.1, 0, 0.5, -110) or UDim2.new(0.5, -150, 0.5, -110)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    mainFrame.Parent = screenGui

    -- Title Bar (Bisa di-drag)
    local titleBar = Instance.new("TextButton") -- Pakai TextButton agar bisa diklik di mobile
    titleBar.Text = "TELEPORT MENU (Drag Me)"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    titleBar.Parent = mainFrame

    -- Input Fields
    local function createInput(text, yPos)
        local textBox = Instance.new("TextBox")
        textBox.PlaceholderText = text
        textBox.Text = ""
        textBox.Size = UDim2.new(0.8, 0, 0, 35)
        textBox.Position = UDim2.new(0.1, 0, 0, yPos)
        textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        textBox.Parent = mainFrame
        return textBox
    end

    local xInput = createInput("X Position", 40)
    local yInput = createInput("Y Position", 85)
    local zInput = createInput("Z Position", 130)

    -- Teleport Button (Lebih besar untuk mobile)
    local teleportButton = Instance.new("TextButton")
    teleportButton.Text = "TELEPORT"
    teleportButton.Size = UDim2.new(0.8, 0, 0, 40)
    teleportButton.Position = UDim2.new(0.1, 0, 0, 170)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    teleportButton.Parent = mainFrame

    -- Drag Functionality (Untuk Mobile)
    local dragging, dragStart, startPos
    titleBar.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = mainFrame.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Teleport Action
    teleportButton.MouseButton1Click:Connect(function()
        local target = CFrame.new(
            tonumber(xInput.Text) or 0,
            tonumber(yInput.Text) or 5, -- Default Y=5 agar tidak terjebak di bawah map
            tonumber(zInput.Text) or 0
        )
        humanoidRootPart.CFrame = target
    end)
end

-- Toggle UI dengan tombol (F4 untuk Desktop / Floating Button untuk Mobile)
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F4 and not gameProcessed then
            createTeleportUI()
        end
    end)
else
    -- Floating Button untuk Mobile
    local openButton = Instance.new("TextButton")
    openButton.Text = "📲"
    openButton.Size = UDim2.new(0, 50, 0, 50)
    openButton.Position = UDim2.new(0.8, 0, 0.7, 0)
    openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    openButton.Parent = game:GetService("CoreGui")
    openButton.MouseButton1Click:Connect(createTeleportUI)
end

print("🎮 Teleport Script Loaded! " .. (isMobile and "Tap 📲 to open." or "Press F4 to open."))