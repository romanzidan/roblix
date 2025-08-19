-- TimeUI.client.lua
-- UI kecil untuk admin: input angka 0–24 lalu kirim ke server

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local setTimeEvent = ReplicatedStorage:WaitForChild("SetTimeEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "TimeAdminUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 110)
frame.Position = UDim2.fromScale(0.02, 0.2)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 28)
title.Position = UDim2.fromOffset(8, 8)
title.BackgroundTransparency = 1
title.Text = "Set Time (0-24)"
title.TextSize = 18
title.Font = Enum.Font.GothamSemibold
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -16, 0, 32)
input.Position = UDim2.fromOffset(8, 44)
input.PlaceholderText = "Contoh: 13.5"
input.Text = ""
input.ClearTextOnFocus = false
input.Font = Enum.Font.Gotham
input.TextSize = 16
input.BackgroundTransparency = 0.1
input.Parent = frame
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -16, 0, 28)
button.Position = UDim2.fromOffset(8, 82)
button.Text = "Apply"
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Parent = frame
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

button.MouseButton1Click:Connect(function()
    local n = tonumber(input.Text)
    if n then
        setTimeEvent:FireServer(n)
    end
end)

-- TimeController.server.lua
-- Kontrol waktu Lighting dari server, dengan whitelist admin + chat command + RemoteEvent

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ganti dengan UserId admin kamu
local ADMIN_USER_IDS = {
    [123456789] = true, -- contoh
    -- [UserIdLain] = true,
}

-- RemoteEvent untuk set waktu dari UI admin (opsional)
local setTimeEvent = Instance.new("RemoteEvent")
setTimeEvent.Name = "SetTimeEvent"
setTimeEvent.Parent = ReplicatedStorage

local function setTime(hour)
    if typeof(hour) ~= "number" then return end
    hour = math.clamp(hour, 0, 24)
    Lighting.ClockTime = hour
end

-- Terima dari UI admin (client) tapi tetap divalidasi & dibatasi
setTimeEvent.OnServerEvent:Connect(function(player, hour)
    if not ADMIN_USER_IDS[player.UserId] then return end
    setTime(hour)
end)

-- Perintah chat untuk admin:  !time 13.5
local function handleChatted(player, msg)
    if not ADMIN_USER_IDS[player.UserId] then return end
    local num = msg:match("^%s*!time%s+([%d%.]+)%s*$")
    if num then
        setTime(tonumber(num))
    end
end

local function onPlayerAdded(plr)
    plr.Chatted:Connect(function(message)
        handleChatted(plr, message)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end
