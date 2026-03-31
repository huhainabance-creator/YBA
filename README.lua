local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

-- Налаштування позиції та розміру
local Window = Library:CreateWindow({ 
    Title = 'YBA Shop', 
    Center = false, -- Вимикаємо центр
    AutoShow = true,
    -- Позиція: 80% по горизонталі (справа), 40% по вертикалі
    Position = UDim2.new(0.8, 0, 0.4, 0), 
    Size = UDim2.fromOffset(200, 160) -- Дуже маленьке вікно
})

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- --- АВТО-ПРОДАЖ (МИТТЄВО) ---
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

-- Логіка продажу
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
        task.spawn(function()
            while _G.AutoBuyLucky do
                if player.Character and player.Character:FindFirstChild("RemoteEvent") then
                    player.Character.RemoteEvent:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
                end
                task.wait(2)
            end
        end)
    end
})

Library:Notify("Скрипт з'явився справа!")
