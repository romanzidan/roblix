game:GetService("StarterGui"):SetCore("SendNotification",
    { Title = "MT.HAUK", Text = "Created by: @lildanzvert", Duration = 5, })

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer

local function GetCharacter(Player)
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRoot(Player)
    local char = GetCharacter(Player)
    return char:WaitForChild("HumanoidRootPart")
end

-- fungsi teleport langsung
local function TeleportTo(targetPos)
    local root = GetRoot(plr)
    if root then
        root.CFrame = CFrame.new(targetPos)
    end
end

-- tunggu character siap
local function WaitForCharacter(player)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    return char, root
end

-- Tunggu map terload
local function WaitForLoadedArea(targetPos, radius)
    local loaded = false
    while not loaded do
        local parts = workspace:GetPartBoundsInBox(
            CFrame.new(targetPos),
            Vector3.new(radius, radius, radius)
        )
        if #parts > 0 then
            loaded = true
        else
            task.wait(1) -- tunggu 1 detik lalu cek lagi
        end
    end
end

-- daftar posisi camp → summit
local checkpoints = {
    Vector3.new(523.19, 40.07, 8.46),    -- camp1
    Vector3.new(-1217.43, 498.24, 1053), -- camp9
    Vector3.new(-2857, 1517.24, -596)    -- summit
}

-- kontrol global
local running = false

-- teleport berurutan ke semua checkpoint
local function TeleportRoute()
    while running do
        for _, pos in ipairs(checkpoints) do
            if not running then break end
            TeleportTo(pos)
            WaitForCharacter(plr)
            WaitForLoadedArea(pos, 200)
            task.wait(1) -- jeda 1 detik tiap checkpoint
        end

        if running then
            -- setelah sampai summit → jalan 1 detik lalu mati
            local char = GetCharacter(plr)
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local root = GetRoot(plr)

            if humanoid and root then
                -- jalan ke depan 10 stud
                local walkTarget = root.Position + (root.CFrame.LookVector * 10)
                humanoid:MoveTo(walkTarget)
                -- tunggu 0.2 detik biar mulai jalan, lalu lompat
                task.wait(0.5)
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                -- tunggu sebentar lalu lompat lagi (masih jalan)
                task.wait(0.5)
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                -- biarkan jalan total 1 detik
                task.wait(0.4)

                -- mati
                humanoid.Health = 0
            end

            -- tunggu respawn
            plr.CharacterAdded:Wait()
            task.wait(2)
        end
    end
end

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportRouteGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Frame utama
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true -- biar bisa digeser (PC & mobile)

-- Title bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -25, 1, 0)
Title.Text = "MT. HAUK"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 5, 0, 0)

-- Tombol minimize
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 25, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -25, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18

-- Container tombol
local ButtonFrame = Instance.new("Frame", MainFrame)
ButtonFrame.Size = UDim2.new(1, 0, 1, -25)
ButtonFrame.Position = UDim2.new(0, 0, 0, 25)
ButtonFrame.BackgroundTransparency = 1

-- Start button
local StartBtn = Instance.new("TextButton", ButtonFrame)
StartBtn.Size = UDim2.new(0, 160, 0, 40)
StartBtn.Position = UDim2.new(0.5, -80, 0, 10)
StartBtn.Text = "Start Summit"
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18

-- Stop button
local StopBtn = Instance.new("TextButton", ButtonFrame)
StopBtn.Size = UDim2.new(0, 160, 0, 40)
StopBtn.Position = UDim2.new(0.5, -80, 0, 60)
StopBtn.Text = "Stop Summit"
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18

-- === tombol logic ===
StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "🚀 Teleport Started", Text = "Created by: @lildanzvert", Duration = 5, })
    task.spawn(function()
        TeleportRoute()
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "⛔ Teleport Stopped", Text = "Created by: @lildanzvert", Duration = 5, })
    running = false
end)

-- === Minimize logic ===
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ButtonFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 200, 0, 25)
        MinimizeBtn.Text = "+"
    else
        ButtonFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 200, 0, 120)
        MinimizeBtn.Text = "-"
    end
end)
