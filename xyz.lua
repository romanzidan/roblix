-- LocalScript: Character XYZ Checker with Copy-to-Clipboard + Close Button
-- Tempatkan di StarterPlayerScripts atau StarterGui (LocalScript)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- UI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XYZCheckerGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 50
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 240, 0, 120)
mainFrame.Position = UDim2.new(0, 20, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0, 0)
mainFrame.Parent = screenGui

-- Make draggable
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 0, 28) -- beri ruang untuk tombol close
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XYZ Checker"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansSemibold
title.TextSize = 18
title.Parent = mainFrame

-- Close button (X)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.AnchorPoint = Vector2.new(0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = mainFrame

local coordsLabel = Instance.new("TextLabel")
coordsLabel.Name = "CoordsLabel"
coordsLabel.Size = UDim2.new(1, -10, 0, 52)
coordsLabel.Position = UDim2.new(0, 5, 0, 28)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextWrapped = true
coordsLabel.TextYAlignment = Enum.TextYAlignment.Top
coordsLabel.Text = "X: -\nY: -\nZ: -"
coordsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
coordsLabel.Font = Enum.Font.Code
coordsLabel.TextSize = 14
coordsLabel.Parent = mainFrame

local copyButton = Instance.new("TextButton")
copyButton.Name = "CopyButton"
copyButton.Size = UDim2.new(0, 100, 0, 28)
copyButton.Position = UDim2.new(1, -110, 1, -36)
copyButton.AnchorPoint = Vector2.new(0, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Font = Enum.Font.SourceSans
copyButton.TextSize = 14
copyButton.Text = "Copy coords"
copyButton.Parent = mainFrame

local autoToggle = Instance.new("TextButton")
autoToggle.Name = "AutoToggle"
autoToggle.Size = UDim2.new(0, 110, 0, 28)
autoToggle.Position = UDim2.new(0, 5, 1, -36)
autoToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoToggle.Font = Enum.Font.SourceSans
autoToggle.TextSize = 14
autoToggle.Text = "Auto: ON"
autoToggle.Parent = mainFrame

-- Hidden TextBox fallback for manual copy
local fallbackBox = Instance.new("TextBox")
fallbackBox.Name = "FallbackBox"
fallbackBox.Size = UDim2.new(1, -10, 0, 26)
fallbackBox.Position = UDim2.new(0, 5, 1, -70)
fallbackBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
fallbackBox.TextColor3 = Color3.fromRGB(230, 230, 230)
fallbackBox.Font = Enum.Font.SourceSans
fallbackBox.TextSize = 14
fallbackBox.ClearTextOnFocus = false
fallbackBox.Visible = false
fallbackBox.Text = ""
fallbackBox.Parent = mainFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 0, 18)
infoLabel.Position = UDim2.new(0, 5, 1, -22)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = ""
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.SourceSansItalic
infoLabel.TextSize = 12
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = mainFrame

-- util: format vector3 to string with 3 decimals
local function fmtVector3(v)
    return string.format("X: %.3f  Y: %.3f  Z: %.3f", v.X, v.Y, v.Z)
end

-- state
local autoUpdate = true
local lastCoordsText = "X: -  Y: -  Z: -"

-- update function
local function updateOnce()
    local char = player.Character
    if not char then
        coordsLabel.Text = "X: -\nY: -\nZ: -"
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    if not hrp then
        coordsLabel.Text = "X: -\nY: -\nZ: -"
        return
    end
    local pos = hrp.Position
    coordsLabel.Text = "X: " ..
        string.format("%.3f", pos.X) ..
        "\nY: " .. string.format("%.3f", pos.Y) .. "\nZ: " .. string.format("%.3f", pos.Z)
    lastCoordsText = fmtVector3(pos)
end

-- live updating loop (store connection so we can disconnect on close)
local conn
conn = RunService.RenderStepped:Connect(function()
    if autoUpdate then
        updateOnce()
    end
end)

-- toggle button
autoToggle.MouseButton1Click:Connect(function()
    autoUpdate = not autoUpdate
    autoToggle.Text = "Auto: " .. (autoUpdate and "ON" or "OFF")
    if autoUpdate then
        infoLabel.Text = ""
    else
        infoLabel.Text = "Auto update off — klik Copy untuk ambil posisi sekarang"
    end
end)

-- helper: show temporary message
local function flashInfo(text, dur)
    dur = dur or 2
    infoLabel.Text = text
    delay(dur, function()
        if infoLabel then
            infoLabel.Text = ""
        end
    end)
end

-- Copy behavior
local function tryCopyToClipboard(text)
    local ok, err = pcall(function()
        if setclipboard then
            setclipboard(text)
        else
            error("no setclipboard")
        end
    end)
    return ok, err
end

copyButton.MouseButton1Click:Connect(function()
    -- ensure we have fresh coords if autoUpdate was off
    if not autoUpdate then
        updateOnce()
    end

    local text = lastCoordsText or coordsLabel.Text or ""
    if text == "" then
        flashInfo("Tidak ada koordinat untuk disalin.")
        return
    end

    -- Attempt automatic clipboard set
    local ok, err = tryCopyToClipboard(text)
    if ok then
        flashInfo("Koordinat berhasil disalin ke clipboard.")
        fallbackBox.Visible = false
        return
    end

    -- Fallback: show text in TextBox and select it for manual copy
    fallbackBox.Visible = true
    fallbackBox.Text = text
    fallbackBox:CaptureFocus()
    pcall(function()
        fallbackBox.SelectionStart = 1
        fallbackBox.SelectionLength = #text
    end)
    flashInfo("Salin manual: tekan Ctrl+C (Windows) atau ⌘+C (Mac).")
end)

-- Close button behavior: disconnect loop and destroy GUI
closeButton.MouseButton1Click:Connect(function()
    -- disconnect render loop safely
    if conn then
        pcall(function()
            conn:Disconnect()
        end)
        conn = nil
    end
    -- destroy GUI
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
    -- optional: destroy script if desired
    -- pcall(function() script:Destroy() end)
end)

-- update when character spawns
player.CharacterAdded:Connect(function()
    wait(0.5)
    updateOnce()
end)

-- initial call
task.delay(0.1, updateOnce)

-- cleanup on script destroy (safety)
script.Destroying:Connect(function()
    if conn then
        pcall(function() conn:Disconnect() end)
        conn = nil
    end
end)
