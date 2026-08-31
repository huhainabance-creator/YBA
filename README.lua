-- =======================================================
-- YBA Auto Shop (Точна послідовність: Sell -> Deal -> One)
-- =======================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("YBA_MiniShop")
if oldGui then oldGui:Destroy() end

local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YBA_MiniShop"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.82, 0, 0.12, 0)
MainFrame.Size = UDim2.new(0, 150, 0, 95)
MainFrame.Active = true
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "YBA Auto Shop"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold

local SellBtn = Instance.new("TextButton")
SellBtn.Parent = MainFrame
SellBtn.Position = UDim2.new(0.08, 0, 0.32, 0)
SellBtn.Size = UDim2.new(0.84, 0, 0, 26)
SellBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SellBtn.Text = "Продаж: OFF"
SellBtn.TextColor3 = Color3.new(1, 1, 1)
SellBtn.TextSize = 12
SellBtn.Font = Enum.Font.Gotham
SellBtn.BorderSizePixel = 0

local BuyBtn = Instance.new("TextButton")
BuyBtn.Parent = MainFrame
BuyBtn.Position = UDim2.new(0.08, 0, 0.65, 0)
BuyBtn.Size = UDim2.new(0.84, 0, 0, 26)
BuyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BuyBtn.Text = "Купівля: OFF"
BuyBtn.TextColor3 = Color3.new(1, 1, 1)
BuyBtn.TextSize = 12
BuyBtn.Font = Enum.Font.Gotham
BuyBtn.BorderSizePixel = 0

-- Перетягування вікна
local UIS = game:GetService("UserInputService")
local dragging, dragStart, startPos, dragInput

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

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ========== НАЛАШТУВАННЯ ТА СПИСОК ІГНОРУ ==========
local AutoSell = false
local AutoBuy = false
local isSelling = false

local DontSell = {
	["Lucky Arrow"] = true,
	["Christmas Present"] = true,
	["Green Candy"] = true,
	["Yellow Candy"] = true,
	["Blue Candy"] = true,
	["Red Candy"] = true,
	["Lucky Stone Mask"] = true
}

local function getMerchant()
	local dialogue = ReplicatedStorage:FindFirstChild("Dialogue")
	return dialogue and dialogue:FindFirstChild("Merchant")
end

-- ========== КЛІК ПО КНОПКАХ ДІАЛОГУ В UI ==========
local function autoClickDialogueButtons()
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end

	local dialogueGui = playerGui:FindFirstChild("DialogueGui") or playerGui:FindFirstChild("Dialogue")
	if not dialogueGui then return end

	for _, btn in ipairs(dialogueGui:GetDescendants()) do
		if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
			local txt = btn.Text or ""
			
			-- 1. "I'd like to sell this..."
			if txt:find("sell this") or txt:find("I'd like to sell") then
				pcall(function()
					if firesignal then firesignal(btn.MouseButton1Click) else btn.Activated:Fire() end
				end)
			-- 2. "Deal."
			elseif txt:find("Deal") or txt == "Deal." then
				pcall(function()
					if firesignal then firesignal(btn.MouseButton1Click) else btn.Activated:Fire() end
				end)
			-- 3. "One. (1)"
			elseif txt:find("One") or txt == "One. (1)" or txt:find("%(1%)") then
				pcall(function()
					if firesignal then firesignal(btn.MouseButton1Click) else btn.Activated:Fire() end
				end)
			end
		end
	end
end

-- ========== ФУНКЦІЯ ПРОДАЖУ ПРЕДМЕТА ==========
local function sellItem(item)
	if not AutoSell or isSelling then return end
	if not item or not item:IsA("Tool") or DontSell[item.Name] then return end

	local character = player.Character
	if not character then return end

	local remote = character:FindFirstChild("RemoteEvent")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local merchant = getMerchant()

	if not remote or not humanoid or not merchant then return end

	isSelling = true

	pcall(function()
		-- 1. Беремо предмет у руки
		humanoid:EquipTool(item)
		task.wait(0.2)

		-- 2. Відкриваємо діалог ("Welcome to The Merchant's Keep...")
		remote:FireServer("PromptTriggered", merchant)
		task.wait(0.15)
		autoClickDialogueButtons()

		-- Крок 1: "I'd like to sell this..."
		remote:FireServer("DialogueType", { Option = "Option1", Dialogue = "Dialogue1", NPC = "Merchant" })
		autoClickDialogueButtons()
		task.wait(0.15)

		-- Крок 2: "Deal."
		remote:FireServer("DialogueType", { Option = "Option1", Dialogue = "Dialogue5", NPC = "Merchant" })
		remote:FireServer("EndDialogue", { Option = "Option1", Dialogue = "Dialogue5", NPC = "Merchant" })
		autoClickDialogueButtons()
		task.wait(0.15)

		-- Крок 3: "One. (1)"
		remote:FireServer("DialogueType", { Option = "Option2", Dialogue = "Dialogue3", NPC = "Merchant" })
		remote:FireServer("EndDialogue", { Option = "Option2", Dialogue = "Dialogue3", NPC = "Merchant" })
		remote:FireServer("DialogueEnd", { Option = "Option2", Dialogue = "Dialogue3", NPC = "Merchant" })
		autoClickDialogueButtons()
		task.wait(0.2)
	end)

	isSelling = false
end

-- ========== СЛУХАЧ БЕКПАКУ ==========
local function setupBackpack(backpack)
	backpack.ChildAdded:Connect(function(item)
		if AutoSell then
			task.wait(0.2)
			sellItem(item)
		end
	end)
end

local function onCharacter(char)
	task.wait(0.5)
	local bp = player:FindFirstChild("Backpack")
	if bp then setupBackpack(bp) end
end

if player.Character then onCharacter(player.Character) end
player.CharacterAdded:Connect(onCharacter)

player.ChildAdded:Connect(function(child)
	if child.Name == "Backpack" then setupBackpack(child) end
end)

-- ========== КНОПКИ УПРАВЛІННЯ ==========
SellBtn.MouseButton1Click:Connect(function()
	AutoSell = not AutoSell
	if AutoSell then
		SellBtn.Text = "Продаж: ON"
		SellBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)

		local bp = player:FindFirstChild("Backpack")
		if bp then
			task.spawn(function()
				for _, item in ipairs(bp:GetChildren()) do
					if not AutoSell then break end
					sellItem(item)
					task.wait(0.35)
				end
			end)
		end
	else
		SellBtn.Text = "Продаж: OFF"
		SellBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end)

BuyBtn.MouseButton1Click:Connect(function()
	AutoBuy = not AutoBuy
	if AutoBuy then
		BuyBtn.Text = "Купівля: ON"
		BuyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
	else
		BuyBtn.Text = "Купівля: OFF"
		BuyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end)

-- ========== АВТОКУПІВЛЯ (Lucky Arrow) ==========
task.spawn(function()
	while true do
		if AutoBuy then
			local char = player.Character
			local remote = char and char:FindFirstChild("RemoteEvent")
			if remote then
				pcall(function()
					remote:FireServer("PurchaseShopItem", { ["ItemName"] = "1x Lucky Arrow" })
				end)
			end
		end
		task.wait(2.5)
	end
end)
