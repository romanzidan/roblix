--// Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// GUI utama
local ScreenGui = Instance.new("ScreenGui", playerGui)
ScreenGui.Name = "GameListUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 360)
Frame.Position = UDim2.new(0.5, -125, 0.5, -180)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.BackgroundTransparency = 0.25
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame", Frame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Header.BackgroundTransparency = 0.9
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Game List"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 55, 0, 28)
CloseBtn.Position = UDim2.new(1, -60, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = "Close"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 45)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.GothamSemibold
Status.TextSize = 16
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.Text = "Loading data..."

-- Scroll list
local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(1, -20, 1, -85)
Scroll.Position = UDim2.new(0, 10, 0, 75)
Scroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Scroll.BackgroundTransparency = 0.95
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

-- Ambil data maps
local success, response = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/macro/maps.json", true)
end)

if not success then
    Status.Text = "Gagal mengambil data."
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    return
end

local data = HttpService:JSONDecode(response)
local currentId = tostring(game.GameId)
local supported = false
local activePopup

for _, map in ipairs(data) do
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, -4, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Text = string.format("%s • CP:%s", map.nama, map.cp)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    if tostring(map.gameId) == currentId then
        Btn.BackgroundColor3 = Color3.fromRGB(60, 150, 80)
        supported = true
    end

    Btn.MouseButton1Click:Connect(function()
        if activePopup then
            activePopup:Destroy()
            activePopup = nil
        end

        -- Popup konfirmasi
        local popup = Instance.new("Frame", Frame)
        activePopup = popup
        popup.Size = UDim2.new(0, 220, 0, 120)
        popup.Position = UDim2.new(0.5, -110, 0.5, -60)
        popup.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        popup.BackgroundTransparency = 0.1
        popup.BorderSizePixel = 0
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 10)

        local label = Instance.new("TextLabel", popup)
        label.Size = UDim2.new(1, -20, 0, 50)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.BackgroundTransparency = 1
        label.Text = "Join map:\n" .. map.nama .. " ?"
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 16
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextWrapped = true

        local yes = Instance.new("TextButton", popup)
        yes.Size = UDim2.new(0.45, 0, 0, 30)
        yes.Position = UDim2.new(0.05, 0, 1, -40)
        yes.BackgroundColor3 = Color3.fromRGB(80, 180, 100)
        yes.Text = "Join"
        yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        yes.Font = Enum.Font.GothamBold
        yes.TextSize = 14
        Instance.new("UICorner", yes).CornerRadius = UDim.new(0, 8)

        local cancel = Instance.new("TextButton", popup)
        cancel.Size = UDim2.new(0.45, 0, 0, 30)
        cancel.Position = UDim2.new(0.5, 0, 1, -40)
        cancel.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        cancel.Text = "Cancel"
        cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        cancel.Font = Enum.Font.GothamBold
        cancel.TextSize = 14
        Instance.new("UICorner", cancel).CornerRadius = UDim.new(0, 8)

        cancel.MouseButton1Click:Connect(function()
            popup:Destroy()
            activePopup = nil
        end)

        yes.MouseButton1Click:Connect(function()
            popup:Destroy()
            activePopup = nil

            local placeId = tostring(map.gameId)

            local dataServer = HttpService:JSONDecode(result)
            if dataServer.data and #dataServer.data > 0 then
                local serverId = dataServer.data[1].id
                local success, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(tonumber(placeId), serverId, player)
                end)
                if not success then
                    BrowserService:OpenBrowserWindow("https://www.roblox.com/games/" .. placeId)
                end
            else
                BrowserService:OpenBrowserWindow("https://www.roblox.com/games/" .. placeId)
            end
        end)
    end)
end

if supported then
    Status.Text = "Game Supported"
    Status.TextColor3 = Color3.fromRGB(100, 255, 120)
else
    Status.Text = "Game Not Supported"
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
end
