local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Ganti dengan URL raw kamu
local pastebinUrl = "https://pastebin.com/raw/3EmpasGa"

-- Hapus GUI lama kalau ada
if game:GetService("CoreGui"):FindFirstChild("UpdateLogUI") then
    game:GetService("CoreGui").UpdateLogUI:Destroy()
end

-- Ambil data JSON
local success, result = pcall(function()
    return game:HttpGet(pastebinUrl)
end)

if not success then
    warn("Gagal mengambil data update log", result)
    return
end

local decoded
success, decoded = pcall(function()
    return HttpService:JSONDecode(result)
end)

if not success then
    warn("Format JSON salah:", decoded)
    return
end

-- Ambil versi dan data log
local version = decoded[1].version or "Unknown"
local updateData = decoded[2] or {}

-- GUI utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UpdateLogUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0.5, -125, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.15
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

-- Shadow
local shadow = Instance.new("ImageLabel")
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
title.Text = "🛠️ Update v" .. version
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Garis
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 1)
line.Position = UDim2.new(0, 10, 0, 42)
line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
line.BorderSizePixel = 0
line.Parent = frame

-- Scroll area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -80)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
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

-- Buat setiap section log
local function createLogSection(name, items)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Size = UDim2.new(1, -10, 0, 0)
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.Parent = scroll

    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.FillDirection = Enum.FillDirection.Vertical
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Padding = UDim.new(0, 4)
    sectionLayout.Parent = sectionFrame

    -- Nama section
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(140, 180, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = "• " .. name
    nameLabel.AutomaticSize = Enum.AutomaticSize.X
    nameLabel.Size = UDim2.new(0, 0, 0, 20)
    nameLabel.Parent = sectionFrame

    -- Item di dalam section
    for _, item in ipairs(items) do
        local itemLabel = Instance.new("TextLabel")
        itemLabel.BackgroundTransparency = 1
        itemLabel.Font = Enum.Font.Gotham
        itemLabel.TextSize = 13
        itemLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.TextWrapped = false
        itemLabel.AutomaticSize = Enum.AutomaticSize.X
        itemLabel.Size = UDim2.new(0, 0, 0, 18)
        itemLabel.Text = "    - " .. item
        itemLabel.Parent = sectionFrame
    end
end


-- Masukkan semua log ke GUI
for name, items in pairs(updateData) do
    createLogSection(name, items)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Tombol close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 70, 0, 26)
closeBtn.Position = UDim2.new(1, -80, 1, -35)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "CLOSE"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Note disamping tombol close
local noteLabel = Instance.new("TextLabel")
noteLabel.Size = UDim2.new(1, -160, 0, 20)
noteLabel.Position = UDim2.new(0, 10, 1, -32)
noteLabel.BackgroundTransparency = 1
noteLabel.Font = Enum.Font.Gotham
noteLabel.TextSize = 11
noteLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
noteLabel.TextXAlignment = Enum.TextXAlignment.Left
noteLabel.Text = "*Jika ada bug, laporkan ke admin"
noteLabel.Parent = frame

-- Animasi masuk
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.15,
    Size = UDim2.new(0, 260, 0, 260)
}):Play()

-- Hover tombol
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
