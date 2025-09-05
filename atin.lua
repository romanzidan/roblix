-- =========================================================
-- Mount Atin: Teleport Sequence + Server Hop (Public)
-- =========================================================

-- -- ===== Auto-hide "Gameplay Paused" (GUI + Blur) =====
-- do
--     local CoreGui  = game:GetService("CoreGui")
--     local Lighting = game:GetService("Lighting")

--     local function hidePausedOnce()
--         -- sembunyikan tulisan "Gameplay Paused"
--         for _, inst in ipairs(CoreGui:GetDescendants()) do
--             if inst:IsA("TextLabel") then
--                 local t = ((inst.Text or ""):lower())
--                 if (t:find("gameplay") and t:find("paused")) or t == "game paused" then
--                     pcall(function() inst.Visible = false end)
--                     if inst.Parent and inst.Parent:IsA("GuiObject") then
--                         pcall(function() inst.Parent.Visible = false end)
--                     end
--                 end
--             elseif inst:IsA("GuiObject") then
--                 local n = inst.Name:lower()
--                 if n:find("pause") or n:find("ingamemenu") then
--                     pcall(function() inst.Visible = false end)
--                 end
--             end
--         end
--         -- matikan blur
--         for _, eff in ipairs(Lighting:GetChildren()) do
--             if eff:IsA("BlurEffect") then
--                 pcall(function()
--                     eff.Enabled = false
--                     eff.Size = 0
--                 end)
--             end
--         end
--     end

--     -- jalankan sekali + loop per 0.25s
--     hidePausedOnce()
--     task.spawn(function()
--         while task.wait(0.25) do
--             pcall(hidePausedOnce)
--         end
--     end)

--     CoreGui.DescendantAdded:Connect(function() task.defer(hidePausedOnce) end)
--     Lighting.ChildAdded:Connect(function(child)
--         if child:IsA("BlurEffect") then
--             pcall(function()
--                 child.Enabled = false
--                 child.Size = 0
--             end)
--         end
--     end)
-- end


-- Services
local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local StarterGui      = game:GetService("StarterGui")

-- === NOTIF saat script aktif ===
StarterGui:SetCore("SendNotification", {
    Title = "Script Aktif",
    Text = "Running sequence...",
    Duration = 3
})

-- Target game check
local TARGET_GAME_ID = 8384560791
if game.GameId ~= TARGET_GAME_ID then
    warn("GameId tidak sesuai, script tidak dijalankan. Sekarang:", game.GameId)
    return
end

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(3)

-- Player setup
local lp   = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
lp.CharacterAdded:Connect(function(c)
    char = c
    hrp  = char:WaitForChild("HumanoidRootPart")
end)

-- ===== Server hop helper =====
local function http_get(url)
    if syn and syn.request then
        local r = syn.request({ Url = url, Method = "GET" })
        if r and r.StatusCode == 200 then return r.Body end
    end
    if http_request then
        local r = http_request({ Url = url, Method = "GET" })
        if r and r.StatusCode == 200 then return r.Body end
    end
    if request then
        local r = request({ Url = url, Method = "GET" })
        if r and r.StatusCode == 200 then return r.Body end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok then return body end
    return nil
end

local function pick_public_server(placeId, excludeJobId, maxPages)
    maxPages = maxPages or 5
    local cursor, picks = nil, {}
    for _ = 1, maxPages do
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100%s"):format(
            placeId, cursor and ("&cursor=" .. HttpService:UrlEncode(cursor)) or ""
        )
        local body = http_get(url)
        if not body then break end
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok or not data or not data.data then break end
        for _, s in ipairs(data.data) do
            local canJoin   = (s.playing or 0) < (s.maxPlayers or 0)
            local different = (s.id ~= excludeJobId)
            if canJoin and different then table.insert(picks, s) end
        end
        if #picks > 0 then break end
        cursor = data.nextPageCursor
        if not cursor then break end
    end
    if #picks > 0 then
        local idx = math.random(1, #picks)
        return picks[idx].id
    end
    return nil
end

-- ===== Sequence =====
local function runSequence()
    local pos1 = Vector3.new(625.41, 1799.81, 3432.70) -- Pos 1
    local pos2 = Vector3.new(779.35, 2184.12, 3945.30) -- Pos 2

    local function tp(vec3)
        if hrp then hrp.CFrame = CFrame.new(vec3) end
    end

    -- Teleport 1
    tp(pos1)
    task.wait(1.5)

    -- Teleport 2
    tp(pos2)
    task.wait(1.5)

    -- Server hop
    local placeId, currentJobId = game.PlaceId, game.JobId
    local targetJobId = pick_public_server(placeId, currentJobId, 6)

    if targetJobId then
        TeleportService:TeleportToPlaceInstance(placeId, targetJobId, lp)
    else
        warn("[ServerHop] Tidak menemukan server publik lain; fallback ke Teleport biasa.")
        TeleportService:Teleport(placeId, lp)
    end
end

-- Auto-run sekali saat dijalankan
runSequence()
