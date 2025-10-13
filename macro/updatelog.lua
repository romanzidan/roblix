--// Update Log GUI (v1.1)
local TweenService = game:GetService("TweenService")

-- Hapus jika sudah ada
if game:GetService("CoreGui"):FindFirstChild("UpdateLogUI") then
    game:GetService("CoreGui").UpdateLogUI:Destroy()
end

-- GUI utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UpdateLogUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Frame utama (card)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 260) -- width dikurangi
frame.Position = UDim2.new(0.5, -160, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.15 -- sedikit transparan
frame.Parent = screenGui

-- Sudut membulat
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

-- Shadow lembut
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Size = UDim2.new(1, 25, 1, 25)
shadow.Position = UDim2.new(0, -12, 0, -12)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.85
shadow.Parent = frame

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🛠️ Update v1.1"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- Garis pemisah
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 1)
line.Position = UDim2.new(0, 10, 0, 42)
line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
line.BorderSizePixel = 0
line.Parent = frame

-- Scroll area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -70)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingTop = UDim.new(0, 5)
padding.Parent = scroll

-- Data update log
local updateData = {
    ["Yahayuk"] = {
        "Fix Checkpoint Path",
        "Added Version to Checkpoint 1"
    }
    -- ["Atin"] = {
    --     "Added Checkpoint 1"
    -- }
}

-- Fungsi buat isi log
local function createLogSection(name, items)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(140, 180, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = "• " .. name
    nameLabel.Parent = scroll

    for _, item in ipairs(items) do
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Size = UDim2.new(1, -20, 0, 18)
        itemLabel.BackgroundTransparency = 1
        itemLabel.Font = Enum.Font.Gotham
        itemLabel.TextSize = 13
        itemLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.Text = "    - " .. item
        itemLabel.Parent = scroll
    end
end

-- Buat semua section
for name, items in pairs(updateData) do
    createLogSection(name, items)
end

-- Auto scroll size
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Tombol Close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 70, 0, 26)
closeBtn.Position = UDim2.new(1, -80, 1, -35)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "CLOSE"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 0
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Animasi masuk (fade + scale)
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.15,
    Size = UDim2.new(0, 250, 0, 260)
}):Play()

-- Hover efek tombol
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(220, 80, 80) }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(200, 60, 60) }):Play()
end)

-- Tutup animasi
closeBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Wait()
    screenGui:Destroy()
end)
