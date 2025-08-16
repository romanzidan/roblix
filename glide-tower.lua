-- win position = x: 60, y: 888, z: -770
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- === fungsi bawaanmu ===
local function GetPing()
    return (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) / 1000
end

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

local function TeleportTO(posX, posY, posZ, player, method)
    pcall(function()
        if method == "safe" then
            task.spawn(function()
                for i = 1, 30 do
                    task.wait()
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                    if player == "pos" then
                        GetRoot(plr).CFrame = CFrame.new(posX, posY, posZ)
                    else
                        GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position) + Vector3.new(0, 2, 0)
                    end
                end
            end)
        else
            GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
            if player == "pos" then
                GetRoot(plr).CFrame = CFrame.new(posX, posY, posZ)
            else
                GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position) + Vector3.new(0, 2, 0)
            end
        end
    end)
end

-- === buat GUI sederhana ===
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
ScreenGui.Name = "TeleportGui"

local StartBtn = Instance.new("TextButton", ScreenGui)
StartBtn.Size = UDim2.new(0, 120, 0, 40)
StartBtn.Position = UDim2.new(0, 20, 0, 200)
StartBtn.Text = "Start Teleport"
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18

local StopBtn = Instance.new("TextButton", ScreenGui)
StopBtn.Size = UDim2.new(0, 120, 0, 40)
StopBtn.Position = UDim2.new(0, 20, 0, 250)
StopBtn.Text = "Stop Teleport"
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18

-- === kontrol teleport ===
local teleporting = false
local teleportConn

-- fungsi respawn setelah 2 detik
local function RespawnAfterDelay()
    task.wait(2) -- tunggu 2 detik
    local RsP = GetRoot(plr).Position
    plr.Character.Humanoid.Health = 0
    plr.CharacterAdded:Wait()
    task.wait(GetPing() + 0.1)
    TeleportTO(RsP.X, RsP.Y, RsP.Z, "pos", "safe")
end

StartBtn.MouseButton1Click:Connect(function()
    if teleporting then return end
    teleporting = true

    teleportConn = RunService.Heartbeat:Connect(function()
        TeleportTO(60, 888, -770, "pos", "safe")
    end)

    -- langsung mulai hitung respawn setelah start teleport
    task.spawn(RespawnAfterDelay)
end)

StopBtn.MouseButton1Click:Connect(function()
    teleporting = false
    if teleportConn then
        teleportConn:Disconnect()
        teleportConn = nil
    end
end)
