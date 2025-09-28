-- RemoteEvent Explorer GUI (Improved for executor)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Bersihkan GUI lama kalau ada
local old = PlayerGui:FindFirstChild("RemoteEventExplorer")
if old then old:Destroy() end

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteEventExplorer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Frame utama (lebih besar / lebih lebar)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.44, 0, 0.72, 0) -- lebar 44% tinggi 72%
MainFrame.Position = UDim2.new(0.28, 0, 0.14, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.03, 0)
UICorner.Parent = MainFrame

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.08, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Title.Text = "RemoteEvent Explorer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.03, 0)
TitleCorner.Parent = Title

-- ScrollingFrame untuk list RemoteEvent
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "List"
ScrollFrame.Size = UDim2.new(1, -12, 1, -(Title.Size.Y.Offset + 12))   -- sisakan ruang untuk title
ScrollFrame.Position = UDim2.new(0, 6, 0.08, 6)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.Parent = MainFrame
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ScrollFrame

-- Update CanvasSize otomatis saat content berubah
local function updateCanvas()
    local y = UIListLayout.AbsoluteContentSize.Y
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 12)
end
-- Hubungkan perubahan ukuran konten
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- Template Button
local function CreateButton(remoteObj)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.Text = remoteObj:GetFullName()
    Button.LayoutOrder = UIListLayout.AbsoluteContentSize.Y + 1
    Button.Parent = ScrollFrame

    local UIC = Instance.new("UICorner")
    UIC.CornerRadius = UDim.new(0.12, 0)
    UIC.Parent = Button

    -- Store reference on button (closure)
    local target = remoteObj

    Button.MouseButton1Click:Connect(function()
        local full = target:GetFullName()
        -- copy to clipboard (best-effort)
        pcall(function() setclipboard(full) end)
        print(("=== RemoteEvent Explorer ===\nSelected: %s"):format(full))

        -- Basic info
        print("ClassName:", target.ClassName, "Name:", target.Name, "Parent:", tostring(target.Parent))

        -- Try to list connections using getconnections if available (exploit API)
        local ok, res = pcall(function()
            if typeof(getconnections) == "function" then
                local info = {}
                local c1 = getconnections(target.OnClientEvent)
                local c2 = getconnections(target.OnServerEvent)
                print(("OnClientEvent connections: %d | OnServerEvent connections: %d"):format(#c1, #c2))
                -- optionally print function sources if available
                for i, conn in ipairs(c1) do
                    local func = conn.Function
                    if typeof(func) == "function" then
                        local s = pcall(function() return debug and debug.getinfo and debug.getinfo(func) end)
                        print(("  [OnClientEvent #%d] function: %s"):format(i, tostring(func)))
                    end
                end
            else
                print("getconnections() not available in this environment.")
            end
        end)
        if not ok then
            -- ignore
        end

        -- Attach monitor to OnClientEvent to log server->client args (if any)
        pcall(function()
            if not target:FindFirstChild("__REE_ClientMonitor") then
                local monitorConn = target.OnClientEvent:Connect(function(...)
                    local args = { ... }
                    local parts = {}
                    for i, v in ipairs(args) do
                        table.insert(parts, tostring(v))
                    end
                    print(("[Monitor] OnClientEvent fired for %s with %d args: %s"):format(full, #args,
                        table.concat(parts, ", ")))
                end)
                -- store for cleanup (we store Reference in a folder value)
                local tag = Instance.new("Folder")
                tag.Name = "__REE_ClientMonitor"
                tag.Parent = target
                local cv = Instance.new("StringValue")
                cv.Name = "MonitorInfo"
                cv.Value = "attached"
                cv.Parent = tag
                -- store the connection to disconnect later if needed (only possible in Lua closure)
                -- We'll keep a weak reference in a table
            else
                print("OnClientEvent monitor already attached.")
            end
        end)

        -- Try to wrap FireServer (to capture args when client calls it)
        pcall(function()
            -- mark wrapper so we don't double-wrap
            if not target:GetAttribute("__REE_wrapped") then
                -- Try to replace FireServer with a wrapper (may fail depending on environment)
                local success, err = pcall(function()
                    local orig = target.FireServer
                    -- create wrapper
                    target.FireServer = function(self, ...)
                        local args = { ... }
                        local parts = {}
                        for i, v in ipairs(args) do
                            table.insert(parts, tostring(v))
                        end
                        print(("[Monitor] FireServer called on %s with %d args: %s"):format(full, #args,
                            table.concat(parts, ", ")))
                        -- call original (if exists)
                        if type(orig) == "function" then
                            return orig(self, ...)
                        end
                    end
                    target:SetAttribute("__REE_wrapped", true)
                end)
                if not success then
                    print("Wrapping FireServer failed (environment may block modifying methods).", err)
                else
                    print("Wrapped FireServer (will log args when FireServer is called).")
                end
            else
                print("FireServer already wrapped for this RemoteEvent.")
            end
        end)

        print("=== End selection ===")
    end)
end

-- Populate list
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        pcall(function() CreateButton(obj) end)
    end
end

-- jika tidak ada, beri tanda
if #ScrollFrame:GetChildren() <= 1 then
    local none = Instance.new("TextLabel")
    none.Size = UDim2.new(1, -8, 0, 30)
    none.BackgroundTransparency = 1
    none.Text = "No RemoteEvent found in game:GetDescendants()"
    none.TextColor3 = Color3.fromRGB(200, 200, 200)
    none.Font = Enum.Font.Gotham
    none.TextSize = 14
    none.Parent = ScrollFrame
end

-- Pastikan canvas diupdate sekali lagi
updateCanvas()
