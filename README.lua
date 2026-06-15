-- Видаляємо стару копію GUI, якщо вона є
local oldGui = game:GetService("CoreGui"):FindFirstChild("YBA_MiniShop")
if oldGui then oldGui:Destroy() end

local player = game:GetService("Players").LocalPlayer

-- Створюємо інтерфейс
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Name = "YBA_MiniShop"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.8, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 140, 0, 70)
MainFrame.Active = true

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

-- --- ПЛАВНЕ ПЕРЕТЯГУВАННЯ (Замість застарілого Draggable) ---
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)


-- --- ФУНКЦІЯ ПРОДАЖУ ---
local function sellItem(item)
    if not item or not item:IsA("Tool") or item.Name == "Lucky Arrow" then return end
    
    local character = player.Character
    local remote = character and character:FindFirstChild("RemoteEvent")
    local hum = character and character:FindFirstChild("Humanoid")
    
    if remote and hum then
        hum:EquipTool(item)
        task.wait(0.15) -- Зменшено затримку для швидкості, але залишено безпечний поріг
        remote:FireServer("EndDialogue", {
            ["Option"] = "Option1", 
            ["Dialogue"] = "Dialogue5", 
            ["NPC"] = "Merchant"
        })
    end
end

-- --- ОПТИМІЗОВАНИЙ МОНІТОРИНГ БЕЗ ЛАГІВ ---
local function setupBackpackListener(backpack)
    -- Продаємо все, що вже лежить в інвентарі (швидко, без великих затримок)
    for _, item in ipairs(backpack:GetChildren()) do
        task.spawn(sellItem, item)
    end

    -- Підключаємо подію ОДИН РАЗ для цього бекпаку
    backpack.ChildAdded:Connect(function(item)
        task.wait(0.2) -- Невелика пауза, щоб предмет стабільно з'явився
        sellItem(item)
    end)
end

-- Слідкуємо за появою Backpack (після смерті або перезаходу він оновлюється)
player.ChildAdded:Connect(function(child)
    if child.Name == "Backpack" then
        setupBackpackListener(child)
    end
end)

-- Перший запуск для поточного бекпаку
local initialBackpack = player:FindFirstChild("Backpack")
if initialBackpack then
    setupBackpackListener(initialBackpack)
end


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

-- Цикл автокупівлі (оптимізовано через task.wait)
task.spawn(function()
    while true do
        if _G.AutoBuy then
            local char = player.Character
            local remote = char and char:FindFirstChild("RemoteEvent")
            if remote then
                remote:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
            end
        end
        task.wait(2.5) -- Перерва між спробами купівлі
    end
end)
