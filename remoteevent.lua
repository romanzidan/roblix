-- RemoteEvent Explorer GUI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteEventExplorer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
MainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Corner radius
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.02, 0) -- Mengurangi corner radius agar lebih modern
UICorner.Parent = MainFrame

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Title.Text = "RemoteEvent Explorer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = MainFrame

-- ScrollFrame untuk list RemoteEvent
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 0.9, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0.1, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5) -- Menambah padding
UIListLayout.Parent = ScrollFrame

-- *PERBAIKAN UTAMA untuk SCROLLING:*
-- Menambahkan UIAspectRatioConstraint agar button memiliki ukuran yang konsisten (opsional)
-- dan menambahkan 'AutomaticSize' pada Y agar ScrollFrame tau kapan harus scroll.
local UIGridLayout = Instance.new("UIGridLayout") -- Menggunakan UIGridLayout lebih baik untuk list item
UIGridLayout.CellSize = UDim2.new(1, 0, 0, 30)    -- Ukuran Cell untuk setiap item (tinggi 30)
UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 5)
UIGridLayout.StartCorner = Enum.StartCorner.TopLeft
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.Parent = ScrollFrame

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)   -- Dihapus karena UIGridLayout/AutomaticSize akan menanganinya
ScrollFrame.AutomaticSize = Enum.AutomaticSize.Y -- KUNCI: Membuat tinggi CanvasSize menyesuaikan konten

---
--- UI Untuk ARGUMENT Prompt/Editor
---

local ArgFrame = Instance.new("Frame")
ArgFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
ArgFrame.Position = UDim2.new(0.5, 5, 0.25, 0) -- Di sebelah kanan MainFrame
ArgFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ArgFrame.BorderSizePixel = 0
ArgFrame.Parent = ScreenGui
ArgFrame.Visible = false -- Sembunyikan secara default

local ArgFrameCorner = Instance.new("UICorner")
ArgFrameCorner.CornerRadius = UDim.new(0.02, 0)
ArgFrameCorner.Parent = ArgFrame

local ArgTitle = Instance.new("TextLabel")
ArgTitle.Name = "Title"
ArgTitle.Size = UDim2.new(1, 0, 0.1, 0)
ArgTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
ArgTitle.Text = "Args for: [REMOTENAME]"
ArgTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ArgTitle.Font = Enum.Font.GothamBold
ArgTitle.TextScaled = true
ArgTitle.Parent = ArgFrame

local ArgTextBox = Instance.new("TextBox")
ArgTextBox.Name = "ArgumentsInput"
ArgTextBox.Size = UDim2.new(1, -10, 0.7, 0)
ArgTextBox.Position = UDim2.new(0, 5, 0.1, 5)
ArgTextBox.MultiLine = true
ArgTextBox.ClearTextOnFocus = false
ArgTextBox.Text = '["string_arg", 123, true]' -- Contoh Format
ArgTextBox.PlaceholderText = 'Enter arguments as a Luau table string, e.g., ["arg1", 10, true]'
ArgTextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
ArgTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ArgTextBox.TextSize = 14
ArgTextBox.Font = Enum.Font.Code
ArgTextBox.Parent = ArgFrame

local FireButton = Instance.new("TextButton")
FireButton.Name = "FireButton"
FireButton.Size = UDim2.new(1, -10, 0.15, 0)
FireButton.Position = UDim2.new(0, 5, 0.85, 0)
FireButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85) -- Warna hijau
FireButton.Text = "Fire Remote"
FireButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FireButton.Font = Enum.Font.GothamBold
FireButton.TextScaled = true
FireButton.Parent = ArgFrame

local FireButtonCorner = Instance.new("UICorner")
FireButtonCorner.CornerRadius = UDim.new(0.2, 0)
FireButtonCorner.Parent = FireButton

local CurrentRemote = nil -- Variabel untuk menyimpan RemoteEvent yang sedang dipilih

local function SafeDecode(str)
    -- Mencoba untuk mengurai string menjadi tabel (Luau/Roblox-style)
    -- PENTING: Fungsi ini hanya placeholder, untuk implementasi nyata
    -- Anda perlu menggunakan sebuah fungsi 'deserialize' yang aman dan
    -- ada di game (misalnya, 'loadstring' jika diaktifkan, atau custom parser).
    -- Karena 'loadstring' dinonaktifkan di game, kita gunakan trik.

    local success, result = pcall(function()
        -- Membuat fungsi sementara untuk menjalankan string sebagai kode Luau
        return game:GetService("ReplicatedStorage"):LoadString(str)()
    end)

    if success and result then
        return result
    else
        warn("Error decoding arguments string:", result)
        return nil
    end
end

-- Template Button
local function CreateButton(remoteObject)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0) -- Size untuk UIGridLayout
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.Text = remoteObject.Name -- Hanya menampilkan nama, bukan full path
    Button.Parent = ScrollFrame

    local UIC = Instance.new("UICorner")
    UIC.CornerRadius = UDim.new(0.2, 0)
    UIC.Parent = Button

    local path = remoteObject:GetFullName()

    Button.MouseButton1Click:Connect(function()
        setclipboard(path) -- 1. Copy full path ke clipboard
        print("Copied RemoteEvent path:", path)

        -- 2. Tampilkan ArgFrame dan set data
        CurrentRemote = remoteObject
        ArgTitle.Text = "Args for: " .. remoteObject.Name
        ArgFrame.Visible = true
    end)
end

-- Koneksi FireButton
FireButton.MouseButton1Click:Connect(function()
    if CurrentRemote then
        local argsString = ArgTextBox.Text
        local args = SafeDecode("return " .. argsString) -- Membungkus dengan 'return' agar menjadi nilai yang valid

        if args and type(args) == "table" then
            print("Attempting to fire", CurrentRemote.Name, "with args:", table.unpack(args))

            -- PENTING: Gunakan :FireServer()
            CurrentRemote:FireServer(table.unpack(args))

            print("Successfully fired RemoteEvent.")
        else
            warn("Failed to parse arguments. Make sure it's a valid Luau table string (e.g., ['hello', 10]).")
        end
    else
        warn("No RemoteEvent selected.")
    end
end)


-- Cari semua RemoteEvent
for _, obj in ipairs(game:GetDescendants()) do
    -- Filter agar tidak mengambil RemoteEvent dari LocalPlayer (biasanya internal GUI)
    if obj:IsA("RemoteEvent") and not obj:IsDescendantOf(PlayerGui) and not obj:IsDescendantOf(LocalPlayer) then
        CreateButton(obj)
    end
end

-- Refresh layout (penting setelah menambahkan semua button)
-- Gunakan RunService.Heartbeat untuk memastikan semua objek GUI sudah dirender
if RunService:IsClient() then
    RunService.Heartbeat:Wait()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIGridLayout.AbsoluteContentSize.Y)
end
