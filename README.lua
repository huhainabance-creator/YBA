local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

-- Налаштування для мобільних (змінюємо позицію та покращуємо клікабельність)
local Window = Library:CreateWindow({ 
    Title = 'YBA Shop', 
    Center = false, 
    AutoShow = true,
    -- Трохи змістив від самого краю, щоб палець попадав по кнопці
    Position = UDim2.new(0.75, 0, 0.15, 0), 
    Size = UDim2.fromOffset(210, 150) 
})

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- --- АВТО-ПРОДАЖ ---
local function sellItem(item)
    if item:IsA("Tool") and item.Name ~= "Lucky Arrow" then
        task.wait(0.1)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:EquipTool(item)
        end
        task.wait(0.2)
        local sellArgs = {
            [1] = "EndDialogue",
            [2] = {["Option"] = "Option1", ["Dialogue"] = "Dialogue5", ["NPC"] = "Merchant"}
        }
        if player.Character and player.Character:FindFirstChild("RemoteEvent") then
            player.Character.RemoteEvent:FireServer(unpack(sellArgs))
        end
    end
end

-- Логіка продажу (старі + нові предмети)
for _, item in pairs(backpack:GetChildren()) do task.spawn(function() sellItem(item) end) end
backpack.ChildAdded:Connect(function(item) task.wait(0.5) sellItem(item) end)

-- --- МІНІ-GUI ---
local Tabs = { Main = Window:AddTab('Головна') }
local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Магазин (75k)')

_G.AutoBuyLucky = false
LeftGroupBox:AddToggle('BuyLuckyToggle', {
    Text = 'Авто-купівля',
    Default = false,
    Callback = function(Value)
        _G.AutoBuyLucky = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyLucky do
                    if player.Character and player.Character:FindFirstChild("RemoteEvent") then
                        player.Character.RemoteEvent:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- Додаємо спеціальну кнопку для закриття/відкриття меню (важливо для мобільних)
Library:SetWatermark('YBA Mobile Fix')
Library.KeybindFrame.Visible = true -- Показує кнопку переключення

Library:Notify("Якщо кнопка не тиснеться, спробуйте трохи змістити камеру")
