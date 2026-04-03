--// ULTIMATE ORB FARMER - FIXED FOR MOBILE

local player = game:GetService("Players").LocalPlayer
local collectRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Remotes"):WaitForChild("CollectOrb")

-- Check if remote exists
if not collectRemote then
    print("[ERROR] CollectOrb remote not found!")
    return
end

-- Get currency safely
local function getCurrency(currencyName)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild(currencyName)
        if stat and type(stat.Value) == "number" then
            return stat.Value
        end
    end
    return 0
end

-- Create simple GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OrbFarmer"
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "🔮 ORB FARMER"
title.TextColor3 = Color3.new(0.5, 0.8, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 3)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = title

-- Status
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 0, 35)
statusText.Position = UDim2.new(0, 10, 0, 45)
statusText.Text = "Status: IDLE"
statusText.TextColor3 = Color3.new(1, 1, 0)
statusText.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
statusText.Font = Enum.Font.GothamBold
statusText.Parent = mainFrame

-- Currency display
local gemsLabel = Instance.new("TextLabel")
gemsLabel.Size = UDim2.new(1, -20, 0, 30)
gemsLabel.Position = UDim2.new(0, 10, 0, 90)
gemsLabel.Text = "💎 Gems: 0"
gemsLabel.TextColor3 = Color3.new(0.5, 0.8, 1)
gemsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
gemsLabel.Parent = mainFrame

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(1, -20, 0, 30)
coinsLabel.Position = UDim2.new(0, 10, 0, 125)
coinsLabel.Text = "🪙 Coins: 0"
coinsLabel.TextColor3 = Color3.new(1, 0.8, 0.3)
coinsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
coinsLabel.Parent = mainFrame

local eggsLabel = Instance.new("TextLabel")
eggsLabel.Size = UDim2.new(1, -20, 0, 30)
eggsLabel.Position = UDim2.new(0, 10, 0, 160)
eggsLabel.Text = "🥚 Easter Eggs: 0"
eggsLabel.TextColor3 = Color3.new(1, 0.7, 0.7)
eggsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
eggsLabel.Parent = mainFrame

-- Session stats
local sessionLabel = Instance.new("TextLabel")
sessionLabel.Size = UDim2.new(1, -20, 0, 30)
sessionLabel.Position = UDim2.new(0, 10, 0, 200)
sessionLabel.Text = "Session: 0 collects"
sessionLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
sessionLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
sessionLabel.Parent = mainFrame

-- Buttons
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.45, -5, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 245)
startBtn.Text = "▶ START"
startBtn.TextSize = 14
startBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Parent = mainFrame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.45, -5, 0, 40)
stopBtn.Position = UDim2.new(0.52, 0, 0, 245)
stopBtn.Text = "⏹ STOP"
stopBtn.TextSize = 14
stopBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Parent = mainFrame

-- Reset button
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -20, 0, 30)
resetBtn.Position = UDim2.new(0, 10, 0, 295)
resetBtn.Text = "📊 RESET SESSION"
resetBtn.TextSize = 12
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.Parent = mainFrame

-- Farming variables
local farming = false
local farmingThread = nil
local sessionCount = 0

-- Update display function
local function updateDisplay()
    local gems = getCurrency("Gems")
    local coins = getCurrency("Coins")
    local eggs = getCurrency("Easter Eggs")
    
    gemsLabel.Text = string.format("💎 Gems: %d", gems)
    
    -- Format coins (K/M)
    if coins >= 1000000 then
        coinsLabel.Text = string.format("🪙 Coins: %.1fM", coins / 1000000)
    elseif coins >= 1000 then
        coinsLabel.Text = string.format("🪙 Coins: %.1fK", coins / 1000)
    else
        coinsLabel.Text = string.format("🪙 Coins: %d", coins)
    end
    
    eggsLabel.Text = string.format("🥚 Easter Eggs: %d", eggs)
    sessionLabel.Text = string.format("Session: %d collects", sessionCount)
end

-- Farming loop
local function startFarming()
    if farming then
        statusText.Text = "Status: RUNNING"
        return
    end
    
    farming = true
    sessionCount = 0
    statusText.Text = "Status: FARMING 🟢"
    statusText.TextColor3 = Color3.new(0.3, 1, 0.3)
    
    farmingThread = task.spawn(function()
        while farming do
            -- Collect Gems
            local before = getCurrency("Gems")
            pcall(function()
                collectRemote:FireServer(2, "Gems", true)
            end)
            task.wait(0.5)
            local after = getCurrency("Gems")
            
            if after > before then
                sessionCount = sessionCount + 1
            end
            
            -- Collect Coins
            pcall(function()
                collectRemote:FireServer(18667, "Coins", true)
            end)
            task.wait(0.5)
            
            -- Collect Easter Eggs
            pcall(function()
                collectRemote:FireServer(5, "EasterEggs", true)
            end)
            task.wait(0.5)
            
            updateDisplay()
        end
    end)
end

local function stopFarming()
    farming = false
    if farmingThread then
        task.cancel(farmingThread)
        farmingThread = nil
    end
    statusText.Text = "Status: IDLE ⚪"
    statusText.TextColor3 = Color3.new(1, 1, 0)
    updateDisplay()
end

-- Button connections
startBtn.MouseButton1Click:Connect(startFarming)
stopBtn.MouseButton1Click:Connect(stopFarming)

resetBtn.MouseButton1Click:Connect(function()
    sessionCount = 0
    updateDisplay()
    statusText.Text = "Status: RESET"
    task.wait(1)
    if farming then
        statusText.Text = "Status: FARMING 🟢"
    else
        statusText.Text = "Status: IDLE ⚪"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    stopFarming()
    gui:Destroy()
end)

-- Initial update
updateDisplay()

print("==========================================")
print("   ORB FARMER LOADED!")
print("   Look for the window on your screen")
print("   Tap START to begin farming")
print("==========================================")
