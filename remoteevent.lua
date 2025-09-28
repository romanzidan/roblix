-- RemoteEvent FireServer Tester (Executor)
-- Pilih RemoteEvent dari daftar, masukkan argumen (sebagai ekspresi Lua), lalu tekan Fire

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- cleanup
local old = PlayerGui:FindFirstChild("REE_FireTester")
if old then old:Destroy() end

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "REE_FireTester"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.25, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local UIC = Instance.new("UICorner"); UIC.CornerRadius = UDim.new(0, 8); UIC.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "RemoteEvent FireServer Tester"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(0.48, -12, 1, -56)
ListFrame.Position = UDim2.new(0, 8, 0, 48)
ListFrame.BackgroundTransparency = 1
ListFrame.ScrollBarThickness = 6
ListFrame.Parent = Main

local ListLayout = Instance.new("UIListLayout"); ListLayout.Parent = ListFrame; ListLayout.Padding = UDim.new(0, 6)

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.5, -12, 1, -56)
RightPanel.Position = UDim2.new(0.5, 8, 0, 48)
RightPanel.BackgroundTransparency = 1
RightPanel.Parent = Main

-- Info label
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 28)
Info.Position = UDim2.new(0, 0, 0, 0)
Info.BackgroundTransparency = 1
Info.Text = "Pilih RemoteEvent di kiri → masukkan argumen → FireServer"
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.Font = Enum.Font.Gotham
Info.TextSize = 14
Info.Parent = RightPanel

-- Selected name
local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1, 0, 0, 24)
SelectedLabel.Position = UDim2.new(0, 0, 0, 36)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "Selected: (none)"
SelectedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SelectedLabel.Font = Enum.Font.GothamSemibold
SelectedLabel.TextSize = 14
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = RightPanel

-- TextBox for args
local ArgsBox = Instance.new("TextBox")
ArgsBox.Size = UDim2.new(1, -12, 0, 120)
ArgsBox.Position = UDim2.new(0, 6, 0, 68)
ArgsBox.PlaceholderText =
"Masukkan argumen sebagai ekspresi Lua.\nContoh:\n  1, 'hello'\n  'a', {x=1, y=2}\n  true, 123\n  {}  -- satu tabel\nJika ingin tanpa argumen, kosongkan."
ArgsBox.Text = ""
ArgsBox.ClearTextOnFocus = false
ArgsBox.TextWrapped = true
ArgsBox.TextYAlignment = Enum.TextYAlignment.Top
ArgsBox.Font = Enum.Font.Gotham
ArgsBox.TextSize = 14
ArgsBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
ArgsBox.TextColor3 = Color3.fromRGB(230, 230, 230)
ArgsBox.Parent = RightPanel

local FireBtn = Instance.new("TextButton")
FireBtn.Size = UDim2.new(0.48, -8, 0, 36)
FireBtn.Position = UDim2.new(0, 6, 0, 200)
FireBtn.Text = "FireServer"
FireBtn.Font = Enum.Font.GothamSemibold
FireBtn.TextSize = 16
FireBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
FireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FireBtn.Parent = RightPanel
local FireUIC = Instance.new("UICorner"); FireUIC.Parent = FireBtn

local CopyNameBtn = Instance.new("TextButton")
CopyNameBtn.Size = UDim2.new(0.48, -8, 0, 36)
CopyNameBtn.Position = UDim2.new(0.52, -8, 0, 200)
CopyNameBtn.Text = "Copy Name"
CopyNameBtn.Font = Enum.Font.GothamSemibold
CopyNameBtn.TextSize = 16
CopyNameBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
CopyNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyNameBtn.Parent = RightPanel
local CopyUIC = Instance.new("UICorner"); CopyUIC.Parent = CopyNameBtn

local Log = Instance.new("TextBox")
Log.Size = UDim2.new(1, -12, 0, 120)
Log.Position = UDim2.new(0, 6, 0, 248)
Log.MultiLine = true
Log.TextWrapped = true
Log.ClearTextOnFocus = false
Log.Text = ""
Log.Font = Enum.Font.Gotham
Log.TextSize = 14
Log.PlaceholderText = "Console log..."
Log.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Log.TextColor3 = Color3.fromRGB(220, 220, 220)
Log.Parent = RightPanel

local function logf(...)
    local t = {}
    for i = 1, select("#", ...) do
        t[#t + 1] = tostring(select(i, ...))
    end
    local line = table.concat(t, " ")
    print(line)
    Log.Text = Log.Text .. line .. "\n"
end

-- helper to create list buttons
local function makeListButton(obj)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    b.TextColor3 = Color3.fromRGB(230, 230, 230)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Text = obj:GetFullName()
    b.Parent = ListFrame
    local uc = Instance.new("UICorner"); uc.Parent = b

    b.MouseButton1Click:Connect(function()
        SelectedLabel.Text = "Selected: " .. obj:GetFullName()
        SelectedLabel:SetAttribute("targetPath", obj:GetFullName())
        SelectedLabel:SetAttribute("targetRef", tostring(obj)) -- not reliable to store object, but shows reference
        -- store reference in closure
        SelectedLabel.Target = obj
        -- copy to clipboard best-effort
        pcall(function() setclipboard(obj:GetFullName()) end)
        logf("[SELECT] " .. obj:GetFullName())
    end)
end

-- populate
for _, o in ipairs(game:GetDescendants()) do
    if o:IsA("RemoteEvent") then
        pcall(function() makeListButton(o) end)
    end
end

-- FireServer action
FireBtn.MouseButton1Click:Connect(function()
    local target = SelectedLabel.Target
    if not target or not target.Parent then
        logf("[ERROR] Tidak ada RemoteEvent terpilih atau object sudah tidak ada.")
        return
    end
    if not target:IsA("RemoteEvent") then
        logf("[ERROR] Object terpilih bukan RemoteEvent.")
        return
    end

    local expr = ArgsBox.Text
    local args = {}
    if expr ~= "" then
        -- Safe-ish parse: kita bungkus ekspresi menjadi return ... lalu loadstring
        local chunk, err = loadstring("return " .. expr)
        if not chunk then
            logf("[PARSE ERROR] " .. tostring(err))
            return
        end
        local ok, res = pcall(chunk)
        if not ok then
            logf("[EVAL ERROR] " .. tostring(res))
            return
        end
        -- if chunk returns multiple values, capture them
        if type(res) == "table" and #res == 0 and select("#", chunk()) == 1 then
            -- single table returned; but loadstring returns only first value in res here
            args = { res }
        else
            -- try to call chunk and collect all returns
            local ok2, a1, a2, a3, a4, a5, a6, a7 = pcall(chunk)
            if ok2 then
                -- collect returned values
                local n = select("#", a1, a2, a3, a4, a5, a6, a7)
                for i = 1, n do
                    args[i] = select(i, a1, a2, a3, a4, a5, a6, a7)
                end
            else
                logf("[EVAL ERROR] " .. tostring(a1))
                return
            end
        end
    end

    -- call FireServer in pcall
    local ok, err = pcall(function()
        -- If target.FireServer overwritten or blocked, this may error
        target:FireServer(unpack(args))
    end)
    if ok then
        logf(("[FIRE] Fired %s with %d arg(s)"):format(target:GetFullName(), #args))
    else
        logf(("[FIRE ERROR] %s"):format(tostring(err)))
    end
end)

CopyNameBtn.MouseButton1Click:Connect(function()
    local t = SelectedLabel.Target
    if t and t:GetFullName() then
        pcall(function() setclipboard(t:GetFullName()) end)
        logf("[COPY] " .. t:GetFullName())
    else
        logf("[COPY] Nothing selected")
    end
end)
