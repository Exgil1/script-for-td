--// ULTIMATE ORB FARMER - WITH MOBILE GUI
--// Real-time monitoring, stats, and controls

pcall(function()

local player = game:GetService("Players").LocalPlayer
local collectRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Remotes"):WaitForChild("CollectOrb")

--// ORB CONFIGURATION
local orbConfig = {
    Gems = {
        amount = 2,
        delay = 1.5,
        burstLimit = 3,
        burstPause = 5,
        sessionLimit = 50,
        sessionPause = 60,
        currencyName = "Gems",
        color = Color3.fromRGB(100, 200, 255),
        icon = "💎"
    },
    Coins = {
        amount = 18667,
        delay = 1.0,
        burstLimit = 5,
        burstPause = 3,
        sessionLimit = 100,
        sessionPause = 45,
        currencyName = "Coins",
        color = Color3.fromRGB(255, 215, 0),
        icon = "🪙"
    },
    EasterEggs = {
        amount = 5,
        delay = 1.2,
        burstLimit = 4,
        burstPause = 4,
        sessionLimit = 80,
        sessionPause = 50,
        currencyName = "Easter Eggs",
        color = Color3.fromRGB(231, 197, 255),
        icon = "🥚"
    }
}

--// SESSION TRACKING
local sessionCounts = {
    Gems = 0,
    Coins = 0,
    EasterEggs = 0
}

local totalEarned = {
    Gems = 0,
    Coins = 0,
    EasterEggs = 0
}

local farmingActive = false
local farmingThread = nil

--// GET CURRENCY
local function getCurrency(currencyName)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild(currencyName)
        if stat then
            return stat.Value
        end
    end
    return 0
end

--// UPDATE GUI DISPLAY
local function updateDisplay()
    for orbType, config in pairs(orbConfig) do
        local amount = getCurrency(config.currencyName)
        local earned = totalEarned[orbType]
        
        local label = _G["label_" .. orbType]
        if label then
            label.Text = string.format("%s %s: %s (+%s)", 
                config.icon, config.currencyName, 
                formatNumber(amount), formatNumber(earned))
        end
        
        local sessionLabel = _G["session_" .. orbType]
        if sessionLabel then
            sessionLabel.Text = string.format("Session: %d", sessionCounts[orbType])
        end
    end
    
    local totalGems = getCurrency("Gems")
    local totalCoins = getCurrency("Coins")
    local totalEggs = getCurrency("Easter Eggs")
    local totalValue = totalGems + math.floor(totalCoins / 1000) + totalEggs
    
    if _G.totalLabel then
        _G.totalLabel.Text = string.format("📊 Total Value: %s", formatNumber(totalValue))
    end
end

local function formatNumber(num)
    if num >= 1000000000 then
        return string.format("%.1fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

--// SMART COLLECT
local lastCollectTimes = {Gems = 0, Coins = 0, EasterEggs = 0}
local rateLimitActive = false

local function smartCollect(orbType)
    if not farmingActive then return false end
    
    local config = orbConfig[orbType]
    local now = tick()
    
    -- Check session limit
    if sessionCounts[orbType] >= config.sessionLimit then
        if _G["status_" .. orbType] then
            _G["status_" .. orbType].Text = "⏸ Session limit"
        end
        task.wait(config.sessionPause)
        sessionCounts[orbType] = 0
        return false
    end
    
    -- Check burst limit
    local timeSinceLast = now - lastCollectTimes[orbType]
    if sessionCounts[orbType] > 0 and sessionCounts[orbType] % config.burstLimit == 0 then
        if timeSinceLast < config.burstPause then
            local waitTime = config.burstPause - timeSinceLast
            if waitTime > 0 then
                if _G["status_" .. orbType] then
                    _G["status_" .. orbType].Text = string.format("⏳ Burst wait: %.0fs", waitTime)
                end
                task.wait(waitTime)
            end
        end
    end
    
    if _G["status_" .. orbType] then
        _G["status_" .. orbType].Text = "🔄 Collecting..."
    end
    
    local beforeAmount = getCurrency(config.currencyName)
    
    local success = pcall(function()
        collectRemote:FireServer(config.amount, orbType, true)
    end)
    
    task.wait(0.3)
    
    local afterAmount = getCurrency(config.currencyName)
    local gained = afterAmount - beforeAmount
    
    if success and gained > 0 then
        sessionCounts[orbType] = sessionCounts[orbType] + 1
        totalEarned[orbType] = totalEarned[orbType] + gained
        lastCollectTimes[orbType] = tick()
        
        if _G["status_" .. orbType] then
            _G["status_" .. orbType].Text = string.format("✅ +%d", gained)
            _G["status_" .. orbType].TextColor3 = Color3.new(0.3, 1, 0.3)
        end
        
        updateDisplay()
        
        -- Reset status after 2 seconds
        task.wait(2)
        if _G["status_" .. orbType] and farmingActive then
            _G["status_" .. orbType].Text = "🟢 Active"
            _G["status_" .. orbType].TextColor3 = Color3.new(0.5, 0.8, 0.5)
        end
        
        return true
    else
        if _G["status_" .. orbType] then
            _G["status_" .. orbType].Text = "❌ Rate limited"
            _G["status_" .. orbType].TextColor3 = Color3.new(1, 0.3, 0.3)
            
            task.wait(5)
            if farmingActive then
                _G["status_" .. orbType].Text = "🟢 Active"
                _G["status_" .. orbType].TextColor3 = Color3.new(0.5, 0.8, 0.5)
            end
        end
        return false
    end
end

--// MAIN FARMING LOOP
local function startFarming()
    farmingActive = true
    
    if _G.globalStatus then
        _G.globalStatus.Text = "🟢 FARMING ACTIVE"
        _G.globalStatus.TextColor3 = Color3.new(0.3, 1, 0.3)
    end
    
    farmingThread = task.spawn(function()
        while farmingActive do
            -- Farm in priority order
            smartCollect("Gems")
            task.wait(orbConfig.Gems.delay * 0.5)
            
            smartCollect("Coins")
            task.wait(orbConfig.Coins.delay * 0.5)
            
            smartCollect("EasterEggs")
            task.wait(orbConfig.EasterEggs.delay * 0.5)
            
            -- Update rate display
            if _G.rateLabel then
                local totalPerMinute = 0
                for _, config in pairs(orbConfig) do
                    totalPerMinute = totalPerMinute + (config.amount * (60 / config.delay) * 0.3)
                end
                _G.rateLabel.Text = string.format("⚡ Rate: ~%s/min", formatNumber(totalPerMinute))
            end
            
            updateDisplay()
        end
    end)
end

local function stopFarming()
    farmingActive = false
    if farmingThread then
        task.cancel(farmingThread)
        farmingThread = nil
    end
    
    if _G.globalStatus then
        _G.globalStatus.Text = "⚪ FARMING STOPPED"
        _G.globalStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    end
end

--// CREATE GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OrbFarmerGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔮 ULTIMATE ORB FARMER"
title.TextColor3 = Color3.new(0.5, 0.8, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = title

-- Global status
local globalStatus = Instance.new("TextLabel")
globalStatus.Size = UDim2.new(1, -20, 0, 35)
globalStatus.Position = UDim2.new(0, 10, 0, 50)
globalStatus.Text = "⚪ FARMING STOPPED"
globalStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
globalStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
globalStatus.Font = Enum.Font.GothamBold
globalStatus.Parent = mainFrame
_G.globalStatus = globalStatus

-- Control buttons
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.48, -5, 0, 45)
startBtn.Position = UDim2.new(0, 10, 0, 95)
startBtn.Text = "▶ START FARMING"
startBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.TextSize = 14
startBtn.Parent = mainFrame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.48, -5, 0, 45)
stopBtn.Position = UDim2.new(0.52, 0, 0, 95)
stopBtn.Text = "⏹ STOP"
stopBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.TextSize = 14
stopBtn.Parent = mainFrame

-- Stats frame
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -20, 0, 200)
statsFrame.Position = UDim2.new(0, 10, 0, 150)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
statsFrame.Parent = mainFrame

-- Create displays for each orb type
local yPos = 10
for orbType, config in pairs(orbConfig) do
    -- Orb type label
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Size = UDim2.new(1, -20, 0, 25)
    typeLabel.Position = UDim2.new(0, 10, 0, yPos)
    typeLabel.Text = config.icon .. " " .. config.currencyName
    typeLabel.TextColor3 = config.color
    typeLabel.TextSize = 14
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.BackgroundTransparency = 1
    typeLabel.Parent = statsFrame
    
    -- Amount label
    local amountLabel = Instance.new("TextLabel")
    amountLabel.Size = UDim2.new(0.6, -10, 0, 25)
    amountLabel.Position = UDim2.new(0, 10, 0, yPos + 28)
    amountLabel.Text = string.format("%s %s: 0", config.icon, config.currencyName)
    amountLabel.TextColor3 = Color3.new(1, 1, 1)
    amountLabel.TextSize = 12
    amountLabel.TextXAlignment = Enum.TextXAlignment.Left
    amountLabel.BackgroundTransparency = 1
    amountLabel.Parent = statsFrame
    _G["label_" .. orbType] = amountLabel
    
    -- Session label
    local sessionLabel = Instance.new("TextLabel")
    sessionLabel.Size = UDim2.new(0.4, -10, 0, 25)
    sessionLabel.Position = UDim2.new(0.6, 0, 0, yPos + 28)
    sessionLabel.Text = "Session: 0"
    sessionLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    sessionLabel.TextSize = 11
    sessionLabel.TextXAlignment = Enum.TextXAlignment.Right
    sessionLabel.BackgroundTransparency = 1
    sessionLabel.Parent = statsFrame
    _G["session_" .. orbType] = sessionLabel
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, yPos + 55)
    statusLabel.Text = "⚪ Idle"
    statusLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    statusLabel.TextSize = 10
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.BackgroundTransparency = 1
    statusLabel.Parent = statsFrame
    _G["status_" .. orbType] = statusLabel
    
    yPos = yPos + 85
end

-- Total and rate
local totalLabel = Instance.new("TextLabel")
totalLabel.Size = UDim2.new(1, -20, 0, 25)
totalLabel.Position = UDim2.new(0, 10, 0, 360)
totalLabel.Text = "📊 Total Value: 0"
totalLabel.TextColor3 = Color3.new(1, 0.8, 0.3)
totalLabel.TextSize = 12
totalLabel.BackgroundTransparency = 1
totalLabel.Parent = mainFrame
_G.totalLabel = totalLabel

local rateLabel = Instance.new("TextLabel")
rateLabel.Size = UDim2.new(1, -20, 0, 25)
rateLabel.Position = UDim2.new(0, 10, 0, 385)
rateLabel.Text = "⚡ Rate: 0/min"
rateLabel.TextColor3 = Color3.new(0.5, 0.8, 0.5)
rateLabel.TextSize = 11
rateLabel.BackgroundTransparency = 1
rateLabel.Parent = mainFrame
_G.rateLabel = rateLabel

-- Reset stats button
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -20, 0, 30)
resetBtn.Position = UDim2.new(0, 10, 0, 415)
resetBtn.Text = "📊 RESET SESSION STATS"
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.TextSize = 12
resetBtn.Parent = mainFrame

-- Button connections
startBtn.MouseButton1Click:Connect(startFarming)
stopBtn.MouseButton1Click:Connect(stopFarming)

resetBtn.MouseButton1Click:Connect(function()
    for orbType in pairs(orbConfig) do
        sessionCounts[orbType] = 0
        totalEarned[orbType] = 0
    end
    updateDisplay()
    if _G.globalStatus then
        _G.globalStatus.Text = "Stats Reset"
        task.wait(1)
        if farmingActive then
            _G.globalStatus.Text = "🟢 FARMING ACTIVE"
        else
            _G.globalStatus.Text = "⚪ FARMING STOPPED"
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    farmingActive = false
    gui:Destroy()
end)

-- Initial update
updateDisplay()

print("=== ULTIMATE ORB FARMER LOADED ===")
print("Gems: 2 per collect (no cap)")
print("Coins: 18667 per collect (75B cap)")
print("Easter Eggs: 5 per collect (1M cap)")
print("")
print("GUI opened - press START to begin farming!")

end)
