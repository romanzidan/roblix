-- Teleport System with UI
-- By DeepSeek Chat

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Buat remote event jika belum ada
local TeleportEvent = Instance.new("RemoteEvent")
TeleportEvent.Name = "TeleportPlayer"
TeleportEvent.Parent = ReplicatedStorage

-- Default position jika belum diatur
local savedPosition = {
    X = 0,
    Y = 0,
    Z = 0
}

-- Fungsi untuk menyimpan posisi
local function savePosition(x, y, z)
    savedPosition.X = x
    savedPosition.Y = y
    savedPosition.Z = z
    print(string.format("Position saved: X=%.2f, Y=%.2f, Z=%.2f", x, y, z))
end

-- Fungsi untuk memuat posisi (bisa diganti dengan DataStore untuk penyimpanan permanen)
local function loadPosition()
    return savedPosition.X, savedPosition.Y, savedPosition.Z
end

-- Handler untuk teleport
TeleportEvent.OnServerEvent:Connect(function(player, x, y, z)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(Vector3.new(x, y, z))
            print(string.format("%s teleported to X=%.2f, Y=%.2f, Z=%.2f", player.Name, x, y, z))
        end
    end
end)

-- UI untuk client
local function createTeleportUI(player)
    local PlayerGui = player:WaitForChild("PlayerGui")
    
    -- Buat ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportUI"
    screenGui.Parent = PlayerGui
    
    -- Frame utama
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Judul
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "TELEPORT SYSTEM"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Input fields
    local function createInputField(name, yPosition, defaultValue)
        local frame = Instance.new("Frame")
        frame.Name = name .. "Frame"
        frame.Size = UDim2.new(0.8, 0, 0, 30)
        frame.Position = UDim2.new(0.1, 0, 0, yPosition)
        frame.BackgroundTransparency = 1
        frame.Parent = mainFrame
        
        local label = Instance.new("TextLabel")
        label.Name = name .. "Label"
        label.Text = name .. ":"
        label.Size = UDim2.new(0.3, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = frame
        
        local textBox = Instance.new("TextBox")
        textBox.Name = name .. "Box"
        textBox.Size = UDim2.new(0.7, 0, 1, 0)
        textBox.Position = UDim2.new(0.3, 0, 0, 0)
        textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 14
        textBox.Text = tostring(defaultValue)
        textBox.Parent = frame
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = textBox
        
        return textBox
    end
    
    -- Load saved position
    local x, y, z = loadPosition()
    
    local xBox = createInputField("X", 50, x)
    local yBox = createInputField("Y", 90, y)
    local zBox = createInputField("Z", 130, z)
    
    -- Tombol Save
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Text = "SAVE POSITION"
    saveButton.Size = UDim2.new(0.8, 0, 0, 35)
    saveButton.Position = UDim2.new(0.1, 0, 0, 170)
    saveButton.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.Font = Enum.Font.GothamBold
    saveButton.TextSize = 14
    saveButton.Parent = mainFrame
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 4)
    saveCorner.Parent = saveButton
    
    -- Tombol Teleport
    local teleportButton = Instance.new("TextButton")
    teleportButton.Name = "TeleportButton"
    teleportButton.Text = "TELEPORT"
    teleportButton.Size = UDim2.new(0.8, 0, 0, 35)
    teleportButton.Position = UDim2.new(0.1, 0, 0, 210)
    teleportButton.BackgroundColor3 = Color3.fromRGB(70, 200, 70)
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 14
    teleportButton.Parent = mainFrame
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 4)
    teleportCorner.Parent = teleportButton
    
    -- Tombol close
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = title
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeButton
    
    -- Fungsi toggle UI
    local function toggleUI()
        mainFrame.Visible = not mainFrame.Visible
    end
    
    -- Bind tombol (misalnya F3 untuk toggle UI)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F3 and not gameProcessed then
            toggleUI()
        end
    end)
    
    -- Event handlers
    saveButton.MouseButton1Click:Connect(function()
        local xValue = tonumber(xBox.Text) or 0
        local yValue = tonumber(yBox.Text) or 0
        local zValue = tonumber(zBox.Text) or 0
        
        savePosition(xValue, yValue, zValue)
    end)
    
    teleportButton.MouseButton1Click:Connect(function()
        local xValue = tonumber(xBox.Text) or 0
        local yValue = tonumber(yBox.Text) or 0
        local zValue = tonumber(zBox.Text) or 0
        
        TeleportEvent:FireServer(xValue, yValue, zValue)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Buat UI untuk pemain yang bergabung
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1) -- Tunggu sedikit untuk memastikan semua komponen siap
        createTeleportUI(player)
    end)
end)

-- Untuk pemain yang sudah ada saat script dijalankan
for _, player in ipairs(Players:GetPlayers()) do
    createTeleportUI(player)
end

print("Teleport system loaded!")