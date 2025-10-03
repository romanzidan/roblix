--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PosSaverGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 250)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BackgroundTransparency = 0.2
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "📍 XYZ Position Saver"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TitleBar

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -40)
Content.Position = UDim2.new(0, 10, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Buttons
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.5, -5, 0, 30)
SaveBtn.Position = UDim2.new(0, 0, 0, 0)
SaveBtn.Text = "💾 Save Position"
SaveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.Gotham
SaveBtn.TextSize = 14
SaveBtn.Parent = Content

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.5, -5, 0, 30)
CopyBtn.Position = UDim2.new(0.5, 5, 0, 0)
CopyBtn.Text = "📋 Copy JSON"
CopyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Gotham
CopyBtn.TextSize = 14
CopyBtn.Parent = Content

-- Scrollable list
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.BackgroundTransparency = 0.2
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollingFrame.Parent = Content

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Status Label
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 1, -20)
Status.BackgroundTransparency = 1
Status.Text = "📌 Saved: 0"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.Parent = Content

-- Logic
local savedPositions = {}
local minimized = false

-- Popup Konfirmasi Hapus
local function showDeleteConfirm(index)
    local ConfirmFrame = Instance.new("Frame")
    ConfirmFrame.Size = UDim2.new(0, 250, 0, 100)
    ConfirmFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
    ConfirmFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ConfirmFrame.BackgroundTransparency = 0.1
    ConfirmFrame.Active = true
    ConfirmFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = ConfirmFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = "Hapus posisi #" .. index .. "?"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = ConfirmFrame

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0.5, -10, 0, 30)
    YesBtn.Position = UDim2.new(0, 5, 1, -35)
    YesBtn.Text = "✅ Ya"
    YesBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 14
    YesBtn.Parent = ConfirmFrame

    local NoBtn = Instance.new("TextButton")
    NoBtn.Size = UDim2.new(0.5, -10, 0, 30)
    NoBtn.Position = UDim2.new(0.5, 5, 1, -35)
    NoBtn.Text = "❌ Batal"
    NoBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 14
    NoBtn.Parent = ConfirmFrame

    YesBtn.MouseButton1Click:Connect(function()
        table.remove(savedPositions, index)
        Status.Text = "📌 Saved: " .. tostring(#savedPositions)
        ConfirmFrame:Destroy()
        refreshList()
    end)

    NoBtn.MouseButton1Click:Connect(function()
        ConfirmFrame:Destroy()
    end)
end

function refreshList()
    -- hapus item lama (kecuali UIListLayout)
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child ~= UIListLayout then
            child:Destroy()
        end
    end

    for i, pos in ipairs(savedPositions) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -10, 0, 25)
        itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        itemFrame.Parent = ScrollingFrame

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -50, 1, 0)
        text.Position = UDim2.new(0, 5, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = string.format("%d. X: %.1f Y: %.1f Z: %.1f", i, pos.x, pos.y, pos.z)
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextSize = 13
        text.Font = Enum.Font.Gotham
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Parent = itemFrame

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 40, 1, 0)
        delBtn.Position = UDim2.new(1, -45, 0, 0)
        delBtn.Text = "🗑"
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 14
        delBtn.Parent = itemFrame

        delBtn.MouseButton1Click:Connect(function()
            showDeleteConfirm(i)
        end)
    end

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #savedPositions * 27)
end

SaveBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local pos = root.Position
        table.insert(savedPositions, { x = pos.X, y = pos.Y, z = pos.Z })
        Status.Text = "📌 Saved: " .. tostring(#savedPositions)
        refreshList()
    end
end)

CopyBtn.MouseButton1Click:Connect(function()
    if #savedPositions == 0 then
        Status.Text = "⚠️ No positions saved!"
        return
    end

    local function fmt(n)
        -- format dengan 2 angka di belakang koma
        return string.format("%.2f", n)
    end

    local parts = {}
    table.insert(parts, "[\n")

    for i, pos in ipairs(savedPositions) do
        -- urutkan key => x, y, z (ubah kalau mau urutan lain)
        local line = string.format('  {"x":%s,"y":%s,"z":%s}', fmt(pos.x), fmt(pos.y), fmt(pos.z))
        if i < #savedPositions then
            line = line .. ",\n"
        else
            line = line .. "\n"
        end
        table.insert(parts, line)
    end

    table.insert(parts, "]")
    local json = table.concat(parts)

    -- untuk exploit / executor gunakan setclipboard, kalau di Studio gunakan print(json)
    if setclipboard then
        setclipboard(json)
    else
        print(json)
    end

    Status.Text = "✅ Copied " .. #savedPositions .. " positions!"
end)



MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        MainFrame.Size = UDim2.new(0, 320, 0, 30)
        MinimizeBtn.Text = "+"
    else
        Content.Visible = true
        MainFrame.Size = UDim2.new(0, 320, 0, 250)
        MinimizeBtn.Text = "-"
    end
end)
