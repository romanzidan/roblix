-- === KEY SYSTEM ===
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- URL raw GitHub tempat kamu taruh key
local keyURL = "https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/key"

-- Ambil key dari rawgithub
local success, validKey = pcall(function()
    return game:HttpGet(keyURL)
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Error",
        Text = "Gagal mengambil key dari server!",
        Duration = 5
    })
    return -- stop script
end

-- GUI Input untuk memasukkan key
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "KeySystemGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "🔑 Enter Access Key"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(0.8, 0, 0, 35)
TextBox.Position = UDim2.new(0.1, 0, 0.4, 0)
TextBox.PlaceholderText = "Enter key..."
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TextBox.TextColor3 = Color3.new(1, 1, 1)
TextBox.Font = Enum.Font.SourceSans
TextBox.TextSize = 16

local SubmitBtn = Instance.new("TextButton", Frame)
SubmitBtn.Size = UDim2.new(0.5, 0, 0, 35)
SubmitBtn.Position = UDim2.new(0.25, 0, 0.75, 0)
SubmitBtn.Text = "Submit"
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
SubmitBtn.TextColor3 = Color3.new(1, 1, 1)
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.TextSize = 16

-- Key validation
SubmitBtn.MouseButton1Click:Connect(function()
    local userKey = TextBox.Text
    if userKey == validKey then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✅ Success",
            Text = "Key valid, akses diberikan!",
            Duration = 5
        })
        ScreenGui:Destroy() -- hapus key gui
        -- === panggil GUI utama di sini ===
        loadstring(game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/hauk.lua"))()
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Invalid",
            Text = "Key salah!",
            Duration = 5
        })
    end
end)
