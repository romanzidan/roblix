local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local savedCheckpoint = nil -- tempat simpan posisi

--=== Fungsi Checkpoint ===--

local function updateCharacter(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(updateCharacter)

local function saveCheckpoint()
    if hrp then
        savedCheckpoint = hrp.CFrame
        StarterGui:SetCore("SendNotification", {
            Title = "Checkpoint",
            Text = "Checkpoint berhasil disimpan!",
            Duration = 3
        })
    end
end

local function loadCheckpoint()
    if savedCheckpoint and hrp then
        hrp.CFrame = savedCheckpoint
        StarterGui:SetCore("SendNotification", {
            Title = "Checkpoint",
            Text = "Kembali ke checkpoint!",
            Duration = 3
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Checkpoint",
            Text = "Belum ada checkpoint tersimpan!",
            Duration = 3
        })
    end
end

local function clearCheckpoint()
    savedCheckpoint = nil
    StarterGui:SetCore("SendNotification", {
        Title = "Checkpoint",
        Text = "Checkpoint berhasil dihapus!",
        Duration = 3
    })
end

--=== Keyboard shortcut (PC) ===--
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        saveCheckpoint()
    elseif input.KeyCode == Enum.KeyCode.R then
        loadCheckpoint()
    elseif input.KeyCode == Enum.KeyCode.T then
        clearCheckpoint()
    end
end)

--=== GUI Bagian ===--

local playerGui = player:WaitForChild("PlayerGui")

local function makeDraggable(dragHandle, dragTarget)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position

            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(changed)
                if dragging and (changed.UserInputType == Enum.UserInputType.MouseMovement
                        or changed.UserInputType == Enum.UserInputType.Touch) then
                    local delta = changed.Position - dragStart
                    dragTarget.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if moveConn then moveConn:Disconnect() end
                end
            end)
        end
    end)
end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "CheckpointGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(180, 70)
panel.Position = UDim2.new(0.05, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

-- Header (buat drag)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 24)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
header.BorderSizePixel = 0
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "CP"
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(230, 230, 240)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.new(1, -4, 0.5, 0)
closeBtn.Size = UDim2.fromOffset(20, 20)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Container tombol icon
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 5, 0, 28)
body.Size = UDim2.new(1, -10, 1, -33)
body.Parent = panel

local layout = Instance.new("UIListLayout", body)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

local function makeIconButton(symbol, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(40, 40)
    b.Text = symbol
    b.Font = Enum.Font.GothamBold
    b.TextSize = 20
    b.BackgroundColor3 = Color3.fromRGB(58, 58, 72)
    b.TextColor3 = Color3.fromRGB(240, 240, 250)
    b.Parent = body
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseButton1Click:Connect(callback)
end

makeIconButton("💾", saveCheckpoint)
makeIconButton("⏪", loadCheckpoint)
makeIconButton("🗑️", clearCheckpoint)

-- Tombol mini (muncul saat panel ditutup)
local mini = Instance.new("TextButton")
mini.Size = UDim2.fromOffset(40, 40)
mini.Position = UDim2.new(1, -50, 1, -60)
mini.AnchorPoint = Vector2.new(0, 0)
mini.Text = "CP"
mini.Font = Enum.Font.GothamBold
mini.TextSize = 16
mini.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
mini.TextColor3 = Color3.fromRGB(235, 235, 245)
mini.Visible = false
mini.Parent = gui
Instance.new("UICorner", mini).CornerRadius = UDim.new(1, 0)

local function showPanel(show)
    panel.Visible = show
    mini.Visible = not show
end

closeBtn.MouseButton1Click:Connect(function()
    showPanel(false)
end)
mini.MouseButton1Click:Connect(function()
    showPanel(true)
end)

makeDraggable(header, panel)
makeDraggable(mini, mini)

showPanel(true)
