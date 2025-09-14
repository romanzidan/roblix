local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- GUI Creation (Dark Mode)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperRingPartsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.Text = "🌪 Super Ring Parts V6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.1, 0, 0.12, 0)
ToggleButton.Text = "Tornado Off"
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Config
local config = {
    radius = 50,
    height = 100,
    rotationSpeed = 10,
    attractionStrength = 1000,
}

local function saveConfig()
    local configStr = HttpService:JSONEncode(config)
    writefile("SuperRingPartsConfig.txt", configStr)
end

local function loadConfig()
    if isfile("SuperRingPartsConfig.txt") then
        local configStr = readfile("SuperRingPartsConfig.txt")
        config = HttpService:JSONDecode(configStr)
    end
end
loadConfig()

-- Function to create control with TextBox + buttons
local function createControl(name, posY, labelText, defaultValue, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 0, 20)
    Label.Position = UDim2.new(0.1, 0, posY, 0)
    Label.Text = labelText
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = MainFrame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.6, 0, 0, 28)
    TextBox.Position = UDim2.new(0.2, 0, posY + 0.04, 0)
    TextBox.Text = tostring(defaultValue)
    TextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 16
    TextBox.Parent = MainFrame

    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 6)
    TextBoxCorner.Parent = TextBox

    local Minus = Instance.new("TextButton")
    Minus.Size = UDim2.new(0.15, 0, 0, 28)
    Minus.Position = UDim2.new(0.03, 0, posY + 0.04, 0)
    Minus.Text = "-"
    Minus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minus.Font = Enum.Font.GothamBold
    Minus.TextSize = 18
    Minus.Parent = MainFrame

    local MinusCorner = Instance.new("UICorner")
    MinusCorner.CornerRadius = UDim.new(0, 6)
    MinusCorner.Parent = Minus

    local Plus = Instance.new("TextButton")
    Plus.Size = UDim2.new(0.15, 0, 0, 28)
    Plus.Position = UDim2.new(0.82, 0, posY + 0.04, 0)
    Plus.Text = "+"
    Plus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    Plus.Font = Enum.Font.GothamBold
    Plus.TextSize = 18
    Plus.Parent = MainFrame

    local PlusCorner = Instance.new("UICorner")
    PlusCorner.CornerRadius = UDim.new(0, 6)
    PlusCorner.Parent = Plus

    local function updateValue(newVal)
        newVal = math.clamp(newVal, 0, 10000)
        TextBox.Text = tostring(newVal)
        callback(newVal)
        saveConfig()
    end

    Minus.MouseButton1Click:Connect(function()
        updateValue((tonumber(TextBox.Text) or 0) - 10)
    end)

    Plus.MouseButton1Click:Connect(function()
        updateValue((tonumber(TextBox.Text) or 0) + 10)
    end)

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newVal = tonumber(TextBox.Text)
            if newVal then updateValue(newVal) else TextBox.Text = tostring(defaultValue) end
        end
    end)
end

createControl("Radius", 0.25, "Radius", config.radius, function(v) config.radius = v end)
createControl("Height", 0.40, "Height", config.height, function(v) config.height = v end)
createControl("RotationSpeed", 0.55, "Rotation Speed", config.rotationSpeed, function(v) config.rotationSpeed = v end)
createControl("AttractionStrength", 0.70, "Attraction", config.attractionStrength,
    function(v) config.attractionStrength = v end)

-- Minimize button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -28, 0, 4)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16
MinimizeButton.Parent = MainFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 260, 0, 32), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "+"
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child ~= Title and child ~= MinimizeButton then
                child.Visible = false
            end
        end
    else
        MainFrame:TweenSize(UDim2.new(0, 260, 0, 360), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "-"
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
    end
end)

-- Dragging
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
        startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Tornado logic (tetap sama)
local ringPartsEnabled = false
local parts = {}
local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then return false end
        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end
local function addPart(part)
    if RetainPart(part) and not table.find(parts, part) then table.insert(parts, part) end
end
local function removePart(part)
    local index = table.find(parts, part)
    if index then table.remove(parts, index) end
end

for _, part in pairs(workspace:GetDescendants()) do addPart(part) end
workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local center = hrp.Position
        for _, part in pairs(parts) do
            if part.Parent and not part.Anchored then
                -- Paksa network ownership agar kita yang kontrol
                local success, err = pcall(function()
                    part:SetNetworkOwner(LocalPlayer)
                end)

                local pos = part.Position
                local distance = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
                local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
                local newAngle = angle + math.rad(config.rotationSpeed)
                local targetPos = Vector3.new(
                    center.X + math.cos(newAngle) * math.min(config.radius, distance),
                    center.Y + (config.height * math.abs(math.sin((pos.Y - center.Y) / config.height))),
                    center.Z + math.sin(newAngle) * math.min(config.radius, distance)
                )

                -- Hitung arah & kecepatan
                local direction = (targetPos - part.Position).Unit
                local velocity = direction * config.attractionStrength

                -- Paksa apply Velocity
                part.AssemblyLinearVelocity = velocity
                part.Velocity = velocity -- fallback untuk part yang belum pakai AssemblyLinearVelocity
            end
        end
    end
end)


ToggleButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    ToggleButton.Text = ringPartsEnabled and "Tornado On" or "Tornado Off"
    ToggleButton.BackgroundColor3 = ringPartsEnabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(70, 70, 70)
end)
