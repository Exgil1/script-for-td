--// COMPLETE MULTI-ORB COLLECTOR (Mobile Optimized)
--// Features: Easter Eggs, Gems, Coins | Optimized gem timing | Rate-limit handling

pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer

    local events = ReplicatedStorage:WaitForChild("Events")
    local remotesFolder = events:WaitForChild("Remotes")
    local collectOrb = remotesFolder:WaitForChild("CollectOrb")

    -- Orb configurations (based on your findings)
    local orbConfigs = {
        EasterEggs = {
            id = 5,
            displayName = "🥚 Easter Eggs",
            color = Color3.fromRGB(255, 200, 100),
            minDelay = 3,
            maxDelay = 8,
            burstLimit = 5,
            sessionLimit = 50,
            cooldownOnFail = 30,
        },
        Gems = {
            id = 1,
            displayName = "💎 Gems",
            color = Color3.fromRGB(100, 200, 255),
            minDelay = 1.2,
            maxDelay = 2.5,
            burstLimit = 2,
            sessionLimit = 20,
            cooldownOnFail = 60,
            optimalDelay = 1.5,
        },
        Coins = {
            id = 18667,
            displayName = "🪙 Coins",
            color = Color3.fromRGB(255, 215, 0),
            minDelay = 2,
            maxDelay = 5,
            burstLimit = 8,
            sessionLimit = 100,
            cooldownOnFail = 20,
        },
    }

    -- Stats per orb type
    local orbStats = {}
    for orbType, cfg in pairs(orbConfigs) do
        orbStats[orbType] = {
            success = 0,
            failed = 0,
            sessionTotal = 0,
            burstCount = 0,
            cooldownUntil = 0,
            enabled = true,
        }
    end

    -- GUI Elements (will be created)
    local gui, mainFrame, startBtn, stopBtn, overallStatus, totalText, cycleText
    local typeCards = {}
    local orbCollectorActive = false
    local orbCollectorThread = nil
    local sessionStartTime = tick()
    local currentCycle = 0
    local settings = { cycleMode = true, globalCooldown = 1.5 }

    -- Helper to update all displays
    local function updateAllDisplays()
        local total = 0
        for orbType, stats in pairs(orbStats) do
            total = total + stats.success
            local card = typeCards[orbType]
            if card then
                card.successLabel.Text = string.format("✅ %d", stats.success)
                card.failLabel.Text = string.format("❌ %d", stats.failed)
                card.sessionLabel.Text = string.format("📊 %d", stats.sessionTotal)
            end
        end
        totalText.Text = string.format("📊 Total: %d", total)
        local elapsed = tick() - sessionStartTime
        local rate = elapsed > 0 and (total / elapsed * 60) or 0
        cycleText.Text = string.format("⚡ Rate: %.1f/min", rate)
    end

    -- Collect a specific orb type (generic)
    local function collectOrbType(orbType)
        local cfg = orbConfigs[orbType]
        local stats = orbStats[orbType]
        local card = typeCards[orbType]
        if not card or not card.enabled then
            return false, "disabled"
        end

        local now = tick()
        if stats.cooldownUntil > now then
            local remaining = math.ceil(stats.cooldownUntil - now)
            card.cardStatus.Text = "⏰ Cooldown"
            card.cardTimer.Text = string.format("%ds", remaining)
            return false, "cooldown"
        end

        card.cardStatus.Text = "🔄 Collecting..."
        card.cardTimer.Text = ""

        -- Random pre‑delay (humanlike)
        local preDelay = math.random(cfg.minDelay * 10, cfg.maxDelay * 10) / 10
        task.wait(preDelay)

        local success = pcall(function()
            collectOrb:FireServer(cfg.id, orbType, true)
        end)

        if success then
            stats.success = stats.success + 1
            stats.sessionTotal = stats.sessionTotal + 1
            stats.burstCount = stats.burstCount + 1
            stats.cooldownUntil = 0
            card.cardStatus.Text = "✅ Success"
            card.cardStatus.TextColor3 = Color3.new(0.3, 1, 0.3)

            -- Burst limit handling
            if stats.burstCount >= cfg.burstLimit then
                stats.cooldownUntil = now + cfg.cooldownOnFail
                stats.burstCount = 0
                card.cardTimer.Text = string.format("Burst CD: %ds", cfg.cooldownOnFail)
            else
                local nextDelay = math.random(cfg.minDelay, cfg.maxDelay)
                card.cardTimer.Text = string.format("Next: %.1fs", nextDelay)
            end

            if stats.sessionTotal >= cfg.sessionLimit then
                stats.cooldownUntil = now + 300
                card.cardStatus.Text = "🔴 Limit reached"
                card.cardTimer.Text = "Relog recommended"
            end

            updateAllDisplays()
            return true, "success"
        else
            stats.failed = stats.failed + 1
            stats.burstCount = 0
            stats.cooldownUntil = now + cfg.cooldownOnFail
            card.cardStatus.Text = "❌ Failed"
            card.cardStatus.TextColor3 = Color3.new(1, 0.3, 0.3)
            card.cardTimer.Text = string.format("CD: %ds", cfg.cooldownOnFail)
            updateAllDisplays()
            return false, "failed"
        end
    end

    -- Specialized gem collector (uses your optimized timing)
    local gemBurstCount = 0
    local function collectGem()
        local cfg = orbConfigs.Gems
        local stats = orbStats.Gems
        local card = typeCards.Gems
        if not card or not card.enabled then
            return false, "disabled"
        end

        local now = tick()
        if stats.cooldownUntil > now then
            local remaining = math.ceil(stats.cooldownUntil - now)
            card.cardStatus.Text = "⏰ Gem cooldown"
            card.cardTimer.Text = string.format("%ds", remaining)
            return false, "cooldown"
        end

        if gemBurstCount >= 2 then
            local wait = 3
            card.cardStatus.Text = "⏸ Burst pause"
            card.cardTimer.Text = string.format("%ds", wait)
            task.wait(wait)
            gemBurstCount = 0
        end

        card.cardStatus.Text = "🔄 Collecting Gem..."
        card.cardTimer.Text = ""

        -- Use the optimal 1.5s delay with small variation
        local preDelay = math.random(120, 180) / 100  -- 1.2–1.8s
        task.wait(preDelay)

        local success = pcall(function()
            collectOrb:FireServer(cfg.id, "Gems", true)
        end)

        if success then
            stats.success = stats.success + 1
            stats.sessionTotal = stats.sessionTotal + 1
            gemBurstCount = gemBurstCount + 1
            stats.burstCount = gemBurstCount
            stats.cooldownUntil = 0
            card.cardStatus.Text = "✅ Gem collected!"
            card.cardStatus.TextColor3 = Color3.new(0.3, 1, 0.3)

            if gemBurstCount >= 2 then
                stats.cooldownUntil = now + cfg.cooldownOnFail
                card.cardTimer.Text = string.format("Burst CD: %ds", cfg.cooldownOnFail)
            else
                card.cardTimer.Text = string.format("Next: %.1fs", cfg.optimalDelay)
            end

            if stats.sessionTotal >= cfg.sessionLimit then
                stats.cooldownUntil = now + 300
                card.cardStatus.Text = "🔴 Gem limit reached"
                card.cardTimer.Text = "Relog recommended"
            end

            updateAllDisplays()
            return true, "success"
        else
            stats.failed = stats.failed + 1
            gemBurstCount = 0
            stats.cooldownUntil = now + cfg.cooldownOnFail
            card.cardStatus.Text = "❌ Too fast"
            card.cardStatus.TextColor3 = Color3.new(1, 0.3, 0.3)
            card.cardTimer.Text = "CD: 5s"
            updateAllDisplays()
            return false, "too_fast"
        end
    end

    -- Main collector loop
    local function startCollector()
        if orbCollectorThread then
            task.cancel(orbCollectorThread)
        end
        orbCollectorActive = true
        overallStatus.Text = "Status: 🟢 ACTIVE"
        overallStatus.TextColor3 = Color3.new(0.3, 1, 0.3)
        sessionStartTime = tick()
        gemBurstCount = 0

        orbCollectorThread = task.spawn(function()
            while orbCollectorActive do
                local anyEnabled = false
                local collected = false
                local order = { "Gems", "EasterEggs", "Coins" }

                for _, orbType in ipairs(order) do
                    if typeCards[orbType] and typeCards[orbType].enabled then
                        anyEnabled = true
                        local success
                        if orbType == "Gems" then
                            success = collectGem()
                        else
                            success = collectOrbType(orbType)
                        end
                        if success then collected = true end
                        task.wait(settings.globalCooldown)
                    end
                end

                if not anyEnabled then
                    overallStatus.Text = "Status: ⚠️ No types enabled"
                    task.wait(5)
                else
                    currentCycle = currentCycle + 1
                    cycleText.Text = string.format("🔄 Cycle: %d", currentCycle)
                    local waitTime = collected and math.random(2, 4) or math.random(4, 8)
                    for i = waitTime, 1, -1 do
                        if not orbCollectorActive then break end
                        cycleText.Text = string.format("Next cycle: %ds", i)
                        task.wait(1)
                    end
                end
            end
        end)
    end

    local function stopCollector()
        orbCollectorActive = false
        if orbCollectorThread then
            task.cancel(orbCollectorThread)
            orbCollectorThread = nil
        end
        overallStatus.Text = "Status: ⚪ IDLE"
        overallStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        for _, card in pairs(typeCards) do
            card.cardStatus.Text = "⚪ Stopped"
            card.cardTimer.Text = ""
        end
    end

    -- Build the GUI
    gui = Instance.new("ScreenGui")
    gui.Name = "OrbCollector"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 520)
    mainFrame.Position = UDim2.new(0, 10, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 150, 200)
    mainFrame.Parent = gui
    mainFrame.Active = true
    mainFrame.Draggable = true

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "🔮 MULTI ORB FARMER"
    title.TextColor3 = Color3.new(0.5, 0.8, 1)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = titleBar

    -- Control buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(1, -20, 0, 50)
    controlFrame.Position = UDim2.new(0, 10, 0, 50)
    controlFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    controlFrame.Parent = mainFrame

    startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0.48, -5, 1, -10)
    startBtn.Position = UDim2.new(0, 5, 0, 5)
    startBtn.Text = "▶ START ALL"
    startBtn.TextSize = 14
    startBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.Parent = controlFrame

    stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.48, -5, 1, -10)
    stopBtn.Position = UDim2.new(0.52, 0, 0, 5)
    stopBtn.Text = "⏹ STOP ALL"
    stopBtn.TextSize = 14
    stopBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.Parent = controlFrame

    -- Overall status card
    local overallCard = Instance.new("Frame")
    overallCard.Size = UDim2.new(1, -20, 0, 70)
    overallCard.Position = UDim2.new(0, 10, 0, 110)
    overallCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    overallCard.Parent = mainFrame

    overallStatus = Instance.new("TextLabel")
    overallStatus.Size = UDim2.new(1, -20, 0, 30)
    overallStatus.Position = UDim2.new(0, 10, 0, 5)
    overallStatus.Text = "Status: ⚪ IDLE"
    overallStatus.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    overallStatus.TextSize = 14
    overallStatus.Font = Enum.Font.GothamBold
    overallStatus.Parent = overallCard

    totalText = Instance.new("TextLabel")
    totalText.Size = UDim2.new(0.5, -5, 0, 25)
    totalText.Position = UDim2.new(0, 10, 0, 38)
    totalText.Text = "📊 Total: 0"
    totalText.TextColor3 = Color3.new(1, 0.8, 0.3)
    totalText.TextSize = 13
    totalText.Parent = overallCard

    cycleText = Instance.new("TextLabel")
    cycleText.Size = UDim2.new(0.5, -5, 0, 25)
    cycleText.Position = UDim2.new(0.5, 0, 0, 38)
    cycleText.Text = "🔄 Cycle: 0"
    cycleText.TextColor3 = Color3.new(0.5, 0.8, 1)
    cycleText.TextSize = 13
    cycleText.Parent = overallCard

    -- Scrollable area for orb type cards
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0, 240)
    scrollFrame.Position = UDim2.new(0, 10, 0, 190)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.Parent = mainFrame

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Parent = scrollFrame
    scrollLayout.Padding = UDim.new(0, 8)

    -- Create cards
    for orbType, cfg in pairs(orbConfigs) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 85)
        card.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        card.BorderSizePixel = 1
        card.BorderColor3 = cfg.color
        card.Parent = scrollFrame

        local typeLabel = Instance.new("TextLabel")
        typeLabel.Size = UDim2.new(0.4, -5, 0, 25)
        typeLabel.Position = UDim2.new(0, 5, 0, 5)
        typeLabel.Text = cfg.displayName
        typeLabel.TextColor3 = cfg.color
        typeLabel.TextSize = 13
        typeLabel.Font = Enum.Font.GothamBold
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        typeLabel.BackgroundTransparency = 1
        typeLabel.Parent = card

        local enableBtn = Instance.new("TextButton")
        enableBtn.Size = UDim2.new(0.2, -5, 0, 25)
        enableBtn.Position = UDim2.new(0.75, 0, 0, 5)
        enableBtn.Text = "✅ ON"
        enableBtn.TextSize = 11
        enableBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        enableBtn.TextColor3 = Color3.new(1, 1, 1)
        enableBtn.BorderSizePixel = 0
        enableBtn.Parent = card

        local successLabel = Instance.new("TextLabel")
        successLabel.Size = UDim2.new(0.33, -5, 0, 20)
        successLabel.Position = UDim2.new(0, 5, 0, 35)
        successLabel.Text = "✅ 0"
        successLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
        successLabel.TextSize = 11
        successLabel.Parent = card

        local failLabel = Instance.new("TextLabel")
        failLabel.Size = UDim2.new(0.33, -5, 0, 20)
        failLabel.Position = UDim2.new(0.33, 0, 0, 35)
        failLabel.Text = "❌ 0"
        failLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
        failLabel.TextSize = 11
        failLabel.Parent = card

        local sessionLabel = Instance.new("TextLabel")
        sessionLabel.Size = UDim2.new(0.33, -5, 0, 20)
        sessionLabel.Position = UDim2.new(0.66, 0, 0, 35)
        sessionLabel.Text = "📊 0"
        sessionLabel.TextColor3 = Color3.new(0.7, 0.7, 1)
        sessionLabel.TextSize = 11
        sessionLabel.Parent = card

        local cardStatus = Instance.new("TextLabel")
        cardStatus.Size = UDim2.new(0.6, -5, 0, 20)
        cardStatus.Position = UDim2.new(0, 5, 0, 58)
        cardStatus.Text = "⚪ Ready"
        cardStatus.TextColor3 = Color3.new(0.5, 0.5, 0.5)
        cardStatus.TextSize = 10
        cardStatus.TextXAlignment = Enum.TextXAlignment.Left
        cardStatus.BackgroundTransparency = 1
        cardStatus.Parent = card

        local cardTimer = Instance.new("TextLabel")
        cardTimer.Size = UDim2.new(0.4, -5, 0, 20)
        cardTimer.Position = UDim2.new(0.6, 0, 0, 58)
        cardTimer.Text = ""
        cardTimer.TextColor3 = Color3.new(1, 0.8, 0.3)
        cardTimer.TextSize = 10
        cardTimer.TextXAlignment = Enum.TextXAlignment.Right
        cardTimer.BackgroundTransparency = 1
        cardTimer.Parent = card

        typeCards[orbType] = {
            card = card,
            enableBtn = enableBtn,
            successLabel = successLabel,
            failLabel = failLabel,
            sessionLabel = sessionLabel,
            cardStatus = cardStatus,
            cardTimer = cardTimer,
            enabled = true,
        }

        enableBtn.MouseButton1Click:Connect(function()
            local enabled = not typeCards[orbType].enabled
            typeCards[orbType].enabled = enabled
            enableBtn.Text = enabled and "✅ ON" or "⭕ OFF"
            enableBtn.BackgroundColor3 = enabled and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 50, 50)
            orbStats[orbType].enabled = enabled
        end)
    end

    -- Reset stats button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, -20, 0, 35)
    resetBtn.Position = UDim2.new(0, 10, 0, 440)
    resetBtn.Text = "📊 RESET ALL STATS"
    resetBtn.TextSize = 12
    resetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.BorderSizePixel = 0
    resetBtn.Parent = mainFrame

    resetBtn.MouseButton1Click:Connect(function()
        for orbType, stats in pairs(orbStats) do
            stats.success = 0
            stats.failed = 0
            stats.sessionTotal = 0
            stats.burstCount = 0
            stats.cooldownUntil = 0
        end
        gemBurstCount = 0
        sessionStartTime = tick()
        updateAllDisplays()
        overallStatus.Text = "Status: Stats Reset"
        task.wait(1)
        if orbCollectorActive then
            overallStatus.Text = "Status: 🟢 ACTIVE"
        else
            overallStatus.Text = "Status: ⚪ IDLE"
        end
    end)

    -- Connect buttons
    startBtn.MouseButton1Click:Connect(startCollector)
    stopBtn.MouseButton1Click:Connect(stopCollector)
    closeBtn.MouseButton1Click:Connect(function()
        orbCollectorActive = false
        gui:Destroy()
    end)

    updateAllDisplays()
    print("✅ Multi-Orb Collector loaded. Gems use optimized 1.5s delay.")
end)
