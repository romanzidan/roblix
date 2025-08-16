local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local plr = Players.LocalPlayer

local function GetCharacter(Player)
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRoot(Player)
    local char = GetCharacter(Player)
    return char:WaitForChild("HumanoidRootPart")
end

-- fungsi smooth fly ke posisi
local function FlyTo(targetPos, speed)
    local root = GetRoot(plr)
    if not root then return end

    local distance = (root.Position - targetPos).Magnitude
    local time = distance / speed -- lama perjalanan tergantung jarak

    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = { CFrame = CFrame.new(targetPos) }

    local tween = TweenService:Create(root, tweenInfo, goal)
    tween:Play()
    return tween
end

-- daftar posisi
local checkpoints = {
    Vector3.new(54, 53, 359),   -- posisi awal terbang
    Vector3.new(42, 157, -66),  -- 1
    Vector3.new(44, 520, -255), -- 2
    Vector3.new(48, 665, -412), -- 3
    Vector3.new(48, 876, -625), -- 4
    Vector3.new(60, 888, -770), -- win
    Vector3.new(48, 876, -625), -- 4
    Vector3.new(48, 665, -412), -- 3
    Vector3.new(44, 520, -255), -- 2
}

-- kontrol global
local running = false

-- fly berurutan ke semua checkpoint
local function FlyRoute(speed)
    while running do
        for i, pos in ipairs(checkpoints) do
            if not running then break end
            local tween = FlyTo(pos, speed)
            if tween then
                tween.Completed:Wait()
                task.wait(.1) -- jeda 1 detik tiap checkpoint
            end
        end

        if running then
            -- setelah sampai win, bunuh karakter (darah jadi 0)
            task.wait(1)
            local char = GetCharacter(plr)
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
            -- tunggu respawn
            plr.CharacterAdded:Wait()
            task.wait(1)
        end
    end
end

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyRouteGui"
ScreenGui.Parent = CoreGui -- supaya tidak hilang saat mati

local StartBtn = Instance.new("TextButton", ScreenGui)
StartBtn.Size = UDim2.new(0, 140, 0, 40)
StartBtn.Position = UDim2.new(0, 20, 0, 200)
StartBtn.Text = "Start Route Fly"
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18

local StopBtn = Instance.new("TextButton", ScreenGui)
StopBtn.Size = UDim2.new(0, 140, 0, 40)
StopBtn.Position = UDim2.new(0, 20, 0, 250)
StopBtn.Text = "Stop Fly"
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18

-- === tombol ===
StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    task.spawn(function()
        FlyRoute(80) -- speed bisa diatur
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    running = false
end)
