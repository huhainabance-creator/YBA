-- Видаляємо стару копію
local oldGui = game:GetService("CoreGui"):FindFirstChild("YBA_MiniShop")
if oldGui then oldGui:Destroy() end

local player = game:GetService("Players").LocalPlayer

-- Створюємо вікно
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Name = "YBA_MiniShop"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false -- Важливо: GUI не зникає після смерті

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.8, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 140, 0, 70)
MainFrame.Active = true
MainFrame.Draggable = true 

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

-- --- ФУНКЦІЯ ПРОДАЖУ ---
local function sellItem(item)
    if not item or not item:IsA("Tool") or item.Name == "Lucky Arrow" then return end
    
    -- Чекаємо, поки персонаж і RemoteEvent будуть готові
    local character = player.Character
    local remote = character and character:FindFirstChild("RemoteEvent")
    local hum = character and character:FindFirstChild("Humanoid")
    
    if remote and hum then
        hum:EquipTool(item)
        task.wait(0.3)
        remote:FireServer("EndDialogue", {
            ["Option"] = "Option1", 
            ["Dialogue"] = "Dialogue5", 
            ["NPC"] = "Merchant"
        })
    end
end

-- --- ЦИКЛ МОНІТОРИНГУ (ПРАЦЮЄ ЗАВЖДИ) ---
task.spawn(function()
    while true do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            -- Продаємо все поточне
            for _, item in pairs(backpack:GetChildren()) do
                sellItem(item)
            end
            
            -- Якщо підключення ще немає, створюємо його
            if not _G.Connected then
                _G.Connected = true
                backpack.ChildAdded:Connect(function(item)
                    task.wait(0.5)
                    sellItem(item)
                end)
            end
        end
        task.wait(5) -- Перевіряємо інвентар кожні 5 секунд про всяк випадок
    end
end)

-- --- ПЕРЕМИКАЧ КУПІВЛІ ---
_G.AutoBuy = false
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoBuy = not _G.AutoBuy
    if _G.AutoBuy then
        ToggleBtn.Text = "Купівля: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ToggleBtn.Text = "Купівля: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

task.spawn(function()
    while true do
        if _G.AutoBuy then
            local char = player.Character
            local remote = char and char:FindFirstChild("RemoteEvent")
            if remote then
                remote:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
            end
        end
        task.wait(2.5)
    end
end)
