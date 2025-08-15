-- Teleport LocalScript (Client-Side, Executor Compatible)
-- By DeepSeek Chat

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local savedPosition = {
    X = 0,
    Y = 100,
    Z = 0
}

-- Fungsi untuk membuat UI
local function createTeleportUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGUI"
    screenGui.Parent = player.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Text = "TELEPORT MENU (EXECUTOR)"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 2)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = title

    -- Input Fields
    local function createInput(text, yPos, default)
        local textBox = Instance.new("TextBox")
        textBox.PlaceholderText = text
        textBox.Text = tostring(default)
        textBox.Size = UDim2.new(0.8, 0, 0, 30)
        textBox.Position = UDim2.new(0.1, 0, 0, yPos)
        textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        textBox.TextColor3 = Color3.new(1, 1, 1)
        textBox.Font = Enum.Font.Gotham
        textBox.Parent = mainFrame
        return textBox
    end

    local xInput = createInput("X Position", 40, savedPosition.X)
    local yInput = createInput("Y Position", 80, savedPosition.Y)
    local zInput = createInput("Z Position", 120, savedPosition.Z)

    -- Teleport Button
    local teleportButton = Instance.new("TextButton")
    teleportButton.Text = "TELEPORT"
    teleportButton.Size = UDim2.new(0.8, 0, 0, 35)
    teleportButton.Position = UDim2.new(0.1, 0, 0, 160)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.Parent = mainFrame

    -- Close UI
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
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
end

-- Toggle UI dengan tombol (misalnya F4)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F4 and not gameProcessed then
        if not player.PlayerGui:FindFirstChild("TeleportGUI") then
            createTeleportUI()
        else
            player.PlayerGui.TeleportGUI:Destroy()
        end
    end
end)

print("Executor Teleport Loaded! Press F4 to open UI.")