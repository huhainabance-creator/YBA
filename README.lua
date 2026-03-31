-- Видаляємо старі копії, якщо вони були
local oldGui = game:GetService("CoreGui"):FindFirstChild("YBA_MiniShop")
if oldGui then oldGui:Destroy() end

-- Створюємо просте вікно
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Name = "YBA_MiniShop"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Позиція: Справа вгорі, маленький розмір
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.8, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 150, 0, 80)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true -- Можна рухати пальцем

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "YBA Shop"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextSize = 14

ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.Text = "Купівля: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 12

-- ЛОГІКА СКРИПТА
local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
_G.AutoBuy = false

-- Функція продажу
local function sellItem(item)
    if item:IsA("Tool") and item.Name ~= "Lucky Arrow" then
        task.wait(0.2)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:EquipTool(item)
        end
        task.wait(0.2)
        local args = {[1] = "EndDialogue", [2] = {["Option"] = "Option1", ["Dialogue"] = "Dialogue5", ["NPC"] = "Merchant"}}
        if player.Character and player.Character:FindFirstChild("RemoteEvent") then
            player.Character.RemoteEvent:FireServer(unpack(args))
        end
    end
end

-- Авто-продаж (миттєво)
for _, item in pairs(backpack:GetChildren()) do task.spawn(function() sellItem(item) end) end
backpack.ChildAdded:Connect(function(item) task.wait(0.5) sellItem(item) end)

-- Перемикач купівлі
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoBuy = not _G.AutoBuy
    if _G.AutoBuy then
        ToggleBtn.Text = "Купівля: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.spawn(function()
            while _G.AutoBuy do
                if player.Character and player.Character:FindFirstChild("RemoteEvent") then
                    player.Character.RemoteEvent:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
                end
                task.wait(2)
            end
        end)
    else
        ToggleBtn.Text = "Купівля: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)
