-- Target game check - mt.atin
local TARGET_GAME_ID = 8384560791
if game.GameId ~= TARGET_GAME_ID then
    warn("GameId tidak sesuai, script tidak dijalankan. Sekarang:", game.GameId)
    return
end

-- Teleport GUI MT.ATIN
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Daftar lokasi terurut
local locations = {
    { name = "Jembatan 1", pos = Vector3.new(5.12, 12.65, -400.31) },
    { name = "Pos 3",      pos = Vector3.new(-168.79, 228.95, 656.24) },
    { name = "Pos 4",      pos = Vector3.new(-37.89, 406.84, 616.60) },
    { name = "Pos 5",      pos = Vector3.new(129.95, 651.83, 613.21) },
    { name = "Pos 6",      pos = Vector3.new(-244.76, 665.58, 733.05) },
    { name = "Pos 7",      pos = Vector3.new(-685.45, 640.41, 882.83) },
    { name = "Pos 8",      pos = Vector3.new(-663.86, 687.19, 1457.13) },
    { name = "Pos 9",      pos = Vector3.new(-492.69, 901.35, 1856.33) },
    { name = "Pos 10",     pos = Vector3.new(60.18, 945.20, 2076.71) },
    { name = "Pos 11",     pos = Vector3.new(51.23, 981.60, 2450.48) },
    { name = "Pos 12",     pos = Vector3.new(71.28, 1095.97, 2452.95) },
    { name = "Pos 13",     pos = Vector3.new(254.69, 1271.94, 2029.97) },
    { name = "Pos 14",     pos = Vector3.new(-414.10, 1302.82, 2398.97) },
    { name = "Pos 15",     pos = Vector3.new(-770.07, 1312.90, 2659.37) },
    { name = "Pos 16",     pos = Vector3.new(-842.59, 1472.73, 2616.56) },
    { name = "Pos 17",     pos = Vector3.new(-468.43, 1465.02, 2773.50) },
    { name = "Pos 18",     pos = Vector3.new(-467.83, 1537.41, 2836.68) },
    { name = "Pos 20",     pos = Vector3.new(-213.85, 1665.63, 2752.88) },
    { name = "Pos 21",     pos = Vector3.new(-233.38, 1742.11, 2792.95) },
    { name = "Pos 22",     pos = Vector3.new(-423.26, 1740.84, 2797.96) },
    { name = "Pos 23",     pos = Vector3.new(-421.14, 1711.45, 3421.71) },
    { name = "Pos 24",     pos = Vector3.new(70.45, 1718.79, 3426.43) },
    { name = "Pos 25",     pos = Vector3.new(435.56, 1720.69, 3429.07) },
    { name = "Pos 26",     pos = Vector3.new(625.44, 1799.35, 3432.75) },
}

-- GUI creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MT_ATIN_Teleport"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui -- bisa diganti CoreGui jika perlu

-- Frame diperkecil agar enak di mobile
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 320)
frame.Position = UDim2.new(0.05, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 12)

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MT.ATIN - LILDANZVERT"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 36, 0, 24)
minimize.Position = UDim2.new(1, -44, 0.5, -12)
minimize.AnchorPoint = Vector2.new(0, 0)
minimize.BackgroundTransparency = 0.2
minimize.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.Parent = titleBar
local minCorner = Instance.new("UICorner", minimize)
minCorner.CornerRadius = UDim.new(0, 6)

-- Dragging support (PC + Mobile)
local dragging, dragStart, startPos
local function inputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end
local function inputChanged(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end
titleBar.InputBegan:Connect(inputBegan)
titleBar.InputChanged:Connect(inputChanged)
UserInputService.InputChanged:Connect(inputChanged)

-- Scrolling area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -46)
scroll.Position = UDim2.new(0, 6, 0, 40)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = frame

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local sizeY = listLayout.AbsoluteContentSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, sizeY + 10)
end)

-- Create buttons
for idx, loc in ipairs(locations) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = string.format("%02d. %s", idx, loc.name)
    btn.LayoutOrder = idx
    btn.Parent = scroll
    local bCorner = Instance.new("UICorner", btn)
    bCorner.CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(loc.pos + Vector3.new(0, 3, 0))
    end)
end

-- Minimize toggle
local minimized = false
local originalSize = frame.Size
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        scroll.Visible = false
        frame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 36)
        minimize.Text = "+"
    else
        scroll.Visible = true
        frame.Size = originalSize
        minimize.Text = "-"
    end
end)
