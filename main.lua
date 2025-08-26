-- 🔑 KEY SYSTEM
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- URL key dari rawgithub (isi file: hanya key string saja, misalnya: ABC123)
local keyURL = "https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/key"
local validKey

-- ambil key dari rawgithub
local success, result = pcall(function()
    return game:HttpGet(keyURL)
end)
if success then
    validKey = result:gsub("%s+", "") -- trim spasi / newline
else
    StarterGui:SetCore("SendNotification", {
        Title = "❌ Error",
        Text = "Gagal mengambil key dari server!",
        Duration = 5
    })
    return
end

-- GUI Key
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "KeySystemGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 160)
Frame.Position = UDim2.new(0.5, -160, 0.5, -80)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0

-- TitleBar
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "🔑 Key Verification - LILDANZ"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

-- Minimize button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 1, 0)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16

-- Content
local ContentFrame = Instance.new("Frame", Frame)
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1

local TextBox = Instance.new("TextBox", ContentFrame)
TextBox.Size = UDim2.new(0.8, 0, 0, 35)
TextBox.Position = UDim2.new(0.1, 0, 0.25, 0)
TextBox.PlaceholderText = "Enter key..."
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TextBox.TextColor3 = Color3.new(1, 1, 1)
TextBox.Font = Enum.Font.SourceSans
TextBox.TextSize = 16

local SubmitBtn = Instance.new("TextButton", ContentFrame)
SubmitBtn.Size = UDim2.new(0.5, 0, 0, 35)
SubmitBtn.Position = UDim2.new(0.25, 0, 0.65, 0)
SubmitBtn.Text = "Submit"
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
SubmitBtn.TextColor3 = Color3.new(1, 1, 1)
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.TextSize = 16

-- Minimize logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        Frame.Size = UDim2.new(0, 320, 0, 30)
        MinBtn.Text = "+"
    else
        ContentFrame.Visible = true
        Frame.Size = UDim2.new(0, 320, 0, 160)
        MinBtn.Text = "-"
    end
end)

-- Drag logic (titlebar only)
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- sebelumnya: local scriptName = "hauknew";
local scriptName = getgenv().scriptName or "hauknew"

-- Validate key
SubmitBtn.MouseButton1Click:Connect(function()
    local userKey = TextBox.Text:gsub("%s+", "")
    if userKey == validKey then
        StarterGui:SetCore("SendNotification", {
            Title = "✅ Access Granted",
            Text = "Key valid, GUI dibuka!",
            Duration = 5
        })
        ScreenGui:Destroy()

        -- >>> jalankan GUI utama di sini <<<
        loadstring(game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/" ..
            scriptName .. ".lua"))()
    else
        StarterGui:SetCore("SendNotification", {
            Title = "❌ Invalid Key",
            Text = "Key salah, coba lagi!",
            Duration = 5
        })
    end
end)


local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- Ganti path sesuai lokasi button di game
local targetButton = plr:WaitForChild("PlayerGui")
    :WaitForChild("ScreenGui") -- nama ScreenGui
    :WaitForChild("Frame")     -- container / frame
    :WaitForChild("Button")    -- tombol asli

-- Auto klik setiap 5 detik
task.spawn(function()
    while task.wait(2) do
        if targetButton and targetButton:IsA("TextButton") then
            targetButton.MouseButton1Click:Fire()
            -- bisa juga pakai :Activate()
            -- targetButton.Activated:Fire()
            print("Button diklik otomatis")
        end
    end
end)
