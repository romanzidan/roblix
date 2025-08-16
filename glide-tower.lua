-- fly to position (smooth movement) GUI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

local function GetCharacter(Player)
    if Player.Character then
        return Player.Character
    end
end

local function GetRoot(Player)
    if GetCharacter(Player):FindFirstChild("HumanoidRootPart") then
        return GetCharacter(Player).HumanoidRootPart
    end
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

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
ScreenGui.Name = "FlyGui"

local StartBtn = Instance.new("TextButton", ScreenGui)
StartBtn.Size = UDim2.new(0, 120, 0, 40)
StartBtn.Position = UDim2.new(0, 20, 0, 200)
StartBtn.Text = "Start Fly"
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18

local StopBtn = Instance.new("TextButton", ScreenGui)
StopBtn.Size = UDim2.new(0, 120, 0, 40)
StopBtn.Position = UDim2.new(0, 20, 0, 250)
StopBtn.Text = "Stop Fly"
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18

-- === kontrol ===
local activeTween

StartBtn.MouseButton1Click:Connect(function()
    if activeTween then return end
    local target = Vector3.new(60, 888, -770) -- posisi tujuan
    activeTween = FlyTo(target, 80)           -- speed bisa diatur

    if activeTween then
        activeTween.Completed:Connect(function()
            task.wait(2)        -- tunggu 2 detik setelah sampai
            plr:LoadCharacter() -- reset ke spawn awal
            activeTween = nil
        end)
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
end)
