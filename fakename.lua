getgenv().Config = {
    FakeDisplayName = "Lil Danz Vert",
    FakeName = "lildanz",
    FakeId = 1, -- input id
}

if not getgenv().Config then
    getgenv().Config = {
        FakeDisplayName = "LilDanz",
        FakeName = "lildanzvert",
        FakeId = 121212,
    }
end


lp = game:GetService("Players").LocalPlayer
oldUserId = tostring(lp.UserId)
oldName = lp.Name
oldDisplayName = lp.DisplayName
local function processtext(text)
    if string.gsub(text, oldName, Config.FakeName) ~= text then
        return string.gsub(text, oldName, Config.FakeName)
    elseif string.gsub(text, oldUserId, Config.FakeId) ~= text then
        return string.gsub(text, oldUserId, Config.FakeId)
    elseif string.gsub(text, oldDisplayName, Config.FakeDisplayName) ~= text then
        return string.gsub(text, oldDisplayName, Config.FakeDisplayName)
    end
    if text ~= nil then
        return text
    end
    return ''
end
for i, v in next, game:GetDescendants() do
    if v:IsA("TextBox") or v:IsA("TextLabel") or v:IsA("TextButton") then
        v.Text = processtext(v.Text)
        v.Name = processtext(v.Name)
        v.Changed:Connect(function(property)
            v.Text = processtext(v.Text)
            v.Name = processtext(v.Name)
        end)
    end
end
game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("TextBox") or descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
        descendant.Text = processtext(descendant.Text)
        descendant.Name = processtext(descendant.Name)
        descendant.Changed:Connect(function()
            descendant.Text = processtext(descendant.Text)
            descendant.Name = processtext(descendant.Name)
        end)
    end
end)
lp.DisplayName = Config.FakeDisplayName
lp.CharacterAppearanceId = Config.FakeId
