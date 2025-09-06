-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Buat GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerListGui"
ScreenGui.ResetOnSpawn = false -- biar tidak hilang ketika respawn
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 380)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Text = "Player List"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Tombol Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Parent = MainFrame

-- Search box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 25)
SearchBox.Position = UDim2.new(0, 5, 0, 35)
SearchBox.PlaceholderText = "Search player..."
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.ClearTextOnFocus = false
SearchBox.Text = "" -- ⚡ awal kosong
SearchBox.Parent = MainFrame


-- ScrollingFrame daftar player
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -130)
Scroll.Position = UDim2.new(0, 5, 0, 65)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 6
Scroll.BackgroundTransparency = 1
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = Scroll

-- Tombol TP Sekali
local TpOnceBtn = Instance.new("TextButton")
TpOnceBtn.Size = UDim2.new(0.5, -7, 0, 30)
TpOnceBtn.Position = UDim2.new(0, 5, 1, -65)
TpOnceBtn.Text = "TP Sekali"
TpOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TpOnceBtn.TextColor3 = Color3.new(1, 1, 1)
TpOnceBtn.Font = Enum.Font.SourceSansBold
TpOnceBtn.TextSize = 16
TpOnceBtn.Parent = MainFrame

-- Tombol TP TROLL
local TpTrollBtn = Instance.new("TextButton")
TpTrollBtn.Size = UDim2.new(0.5, -7, 0, 30)
TpTrollBtn.Position = UDim2.new(0.5, 2, 1, -65)
TpTrollBtn.Text = "TP TROLL"
TpTrollBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
TpTrollBtn.TextColor3 = Color3.new(1, 1, 1)
TpTrollBtn.Font = Enum.Font.SourceSansBold
TpTrollBtn.TextSize = 16
TpTrollBtn.Parent = MainFrame


-- Tombol Cancel Spectate
local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(1, -10, 0, 30)
CancelBtn.Position = UDim2.new(0, 5, 1, -30)
CancelBtn.Text = "Cancel Spectate"
CancelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CancelBtn.TextColor3 = Color3.new(1, 1, 1)
CancelBtn.Font = Enum.Font.SourceSansBold
CancelBtn.TextSize = 16
CancelBtn.Parent = MainFrame

-- Variabel target & posisi lama
local CurrentTarget = nil
local LastPosition = nil
local CurrentFilter = ""

-- Update daftar player (dengan filter)
local function UpdatePlayerList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local nameLower = plr.Name:lower()
            local displayLower = plr.DisplayName:lower()
            if CurrentFilter == "" or string.find(nameLower, CurrentFilter) or string.find(displayLower, CurrentFilter) then
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -10, 0, 30)
                Btn.Text = plr.Name .. " (" .. plr.DisplayName .. ")"
                Btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                Btn.TextColor3 = Color3.new(1, 1, 1)
                Btn.Font = Enum.Font.SourceSans
                Btn.TextSize = 16
                Btn.Parent = Scroll

                Btn.MouseButton1Click:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        Camera.CameraSubject = plr.Character.Humanoid
                        CurrentTarget = plr
                    end
                end)
            end
        end
    end

    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

-- Variabel toggle TP Troll
local TpTrollActive = false

-- Fungsi teleport sekali
TpOnceBtn.MouseButton1Click:Connect(function()
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not LastPosition then
                LastPosition = hrp.CFrame -- simpan posisi sekali saja
            end
            hrp.CFrame = CurrentTarget.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- Kalau textbox diklik, langsung kosong
SearchBox.Focused:Connect(function()
    SearchBox.Text = ""
end)


-- Fungsi TP TROLL (toggle)
TpTrollBtn.MouseButton1Click:Connect(function()
    TpTrollActive = not TpTrollActive
    if TpTrollActive then
        TpTrollBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        TpTrollBtn.Text = "TP TROLL [ON]"
        task.spawn(function()
            while TpTrollActive do
                task.wait(0.1)
                if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if not LastPosition then
                            LastPosition = hrp.CFrame -- simpan posisi sekali saja
                        end
                        hrp.CFrame = CurrentTarget.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end)
    else
        TpTrollBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        TpTrollBtn.Text = "TP TROLL"
    end
end)


-- Cancel Spectate (balik kamera + teleport ke posisi lama)
CancelBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
        if LastPosition and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LastPosition
            LastPosition = nil
        end
        CurrentTarget = nil
    end
end)

-- Fungsi minimize
local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= Title and child ~= MinBtn then
                child.Visible = false
            end
        end
        MainFrame.Size = UDim2.new(0, 250, 0, 30)
        MinBtn.Text = "+"
    else
        for _, child in ipairs(MainFrame:GetChildren()) do
            child.Visible = true
        end
        MainFrame.Size = UDim2.new(0, 250, 0, 380)
        MinBtn.Text = "-"
    end
end)


-- Update otomatis kalau ada player join/leave
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Search handler
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    CurrentFilter = SearchBox.Text:lower()
    UpdatePlayerList()
end)

-- Pertama kali jalan
UpdatePlayerList()
