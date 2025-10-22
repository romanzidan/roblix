local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local UserInputService = game:GetService("UserInputService")

-- Default speed
local normalSpeed = 16
local stepSpeed = 5
hum.WalkSpeed = normalSpeed

-- === NOTIF saat script aktif ===
StarterGui:SetCore("SendNotification", {
    Title = "Script Aktif",
    Text = "GUI Speed Controller berhasil dijalankan!",
    Duration = 4
})

-- === GUI SETUP ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedGui"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0.05, 0, 0.7, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Label judul
local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(0.7, 0, 0.2, 0)
label.Position = UDim2.new(0.05, 0, 0, 0)
label.Text = "Set Speed (Default 16)"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.BackgroundTransparency = 1
label.TextScaled = true

-- Tombol close (X)
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0.2, 0, 0.2, 0)
closeBtn.Position = UDim2.new(0.75, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.SourceSansBold

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- TextBox untuk input speed
local textBox = Instance.new("TextBox", frame)
textBox.Size = UDim2.new(0.6, 0, 0.3, 0)
textBox.Position = UDim2.new(0.05, 0, 0.25, 0)
textBox.Text = tostring(normalSpeed)
textBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextScaled = true
textBox.ClearTextOnFocus = false

-- Tombol aktifkan
local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0.3, 0, 0.3, 0)
applyBtn.Position = UDim2.new(0.7, 0, 0.25, 0)
applyBtn.Text = "Aktifkan"
applyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.TextScaled = true
applyBtn.Font = Enum.Font.SourceSansBold

-- === Tombol Tambah & Kurang ===
local minusBtn = Instance.new("TextButton", frame)
minusBtn.Size = UDim2.new(0.45, 0, 0.25, 0)
minusBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
minusBtn.Text = "- Kurang"
minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.TextScaled = true
minusBtn.Font = Enum.Font.SourceSansBold

local plusBtn = Instance.new("TextButton", frame)
plusBtn.Size = UDim2.new(0.45, 0, 0.25, 0)
plusBtn.Position = UDim2.new(0.5, 0, 0.65, 0)
plusBtn.Text = "+ Tambah"
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.TextScaled = true
plusBtn.Font = Enum.Font.SourceSansBold

-- === Fungsi ubah speed ===
local function setSpeedFromInput()
    local newSpeed = tonumber(textBox.Text)
    if newSpeed and newSpeed > 0 then
        hum.WalkSpeed = newSpeed
        StarterGui:SetCore("SendNotification", {
            Title = "Speed Updated",
            Text = "Kecepatan diatur ke " .. newSpeed,
            Duration = 3
        })
    else
        hum.WalkSpeed = normalSpeed
        textBox.Text = tostring(normalSpeed)
        StarterGui:SetCore("SendNotification", {
            Title = "Speed Reset",
            Text = "Input tidak valid, kembali ke " .. normalSpeed,
            Duration = 3
        })
    end
end

-- Event Enter di TextBox
textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        setSpeedFromInput()
    end
end)

-- Event klik tombol "Aktifkan"
applyBtn.MouseButton1Click:Connect(function()
    setSpeedFromInput()
end)

-- Tombol kurang
minusBtn.MouseButton1Click:Connect(function()
    local current = tonumber(textBox.Text) or normalSpeed
    current = math.max(1, current - stepSpeed)
    textBox.Text = tostring(current)
    setSpeedFromInput()
end)

-- Tombol tambah
plusBtn.MouseButton1Click:Connect(function()
    local current = tonumber(textBox.Text) or normalSpeed
    current = current + stepSpeed
    textBox.Text = tostring(current)
    setSpeedFromInput()
end)

-- Deteksi tombol Q atau M untuk aktifkan cepat
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.M then
        setSpeedFromInput()
    end
end)

-- Reset kalau respawn
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")

    local savedSpeed = tonumber(textBox.Text)
    if savedSpeed and savedSpeed > 0 then
        hum.WalkSpeed = savedSpeed
    else
        hum.WalkSpeed = normalSpeed
        textBox.Text = tostring(normalSpeed)
    end
end)
