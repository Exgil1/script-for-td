--// UPDATED ORB CONFIGURATION - OPTIMIZED GEM TIMING
local orbConfigs = {
    EasterEggs = {
        id = 5,
        displayName = "🥚 Easter Eggs",
        color = Color3.fromRGB(255, 200, 100),
        priority = 2,
        minDelay = 3,
        maxDelay = 8,
        burstLimit = 5,
        sessionLimit = 50,
        cooldownOnFail = 30,
        -- Special: Can collect multiple in quick succession
        allowBurst = true
    },
    Gems = {
        id = 1,
        displayName = "💎 Gems",
        color = Color3.fromRGB(100, 200, 255),
        priority = 1,  -- Highest priority
        minDelay = 1,   -- 1 second minimum (works consistently)
        maxDelay = 3,   -- 3 seconds maximum
        burstLimit = 2,  -- Only 2 gems per burst
        sessionLimit = 20,
        cooldownOnFail = 60,
        -- SPECIAL: Gems need precise timing
        requirePreciseTiming = true,
        optimalDelay = 1.5,  -- Sweet spot delay
        maxPerBurst = 2       -- Max 2 gems before cooldown
    },
    Coins = {
        id = 18667,
        displayName = "🪙 Coins",
        color = Color3.fromRGB(255, 215, 0),
        priority = 3,
        minDelay = 2,
        maxDelay = 6,
        burstLimit = 8,
        sessionLimit = 100,
        cooldownOnFail = 20,
        allowBurst = true
    }
}

--// SPECIALIZED GEM COLLECTOR FUNCTION
local gemLastCollectTime = 0
local gemConsecutiveSuccess = 0
local gemBurstCount = 0

local function collectGem()
    local config = orbConfigs.Gems
    local stats = orbStats.Gems
    local card = typeCards.Gems
    
    if not card or not card.enabled then
        return false, "disabled"
    end
    
    local now = tick()
    
    -- Check cooldown
    if stats.cooldownUntil > now then
        local remaining = math.ceil(stats.cooldownUntil - now)
        if card then
            card.cardStatus.Text = "⏰ Gem cooldown"
            card.cardTimer.Text = string.format("%ds", remaining)
            card.cardStatus.TextColor3 = Color3.new(1, 0.5, 0)
        end
        return false, "cooldown"
    end
    
    -- Check if we've collected 2 gems recently (burst limit)
    if gemBurstCount >= 2 then
        local waitTime = 3  -- Wait 3 seconds after 2 gems
        if card then
            card.cardStatus.Text = "⏸ Burst pause"
            card.cardTimer.Text = string.format("%ds", waitTime)
        end
        task.wait(waitTime)
        gemBurstCount = 0
    end
    
    if card then
        card.cardStatus.Text = "🔄 Collecting Gem..."
        card.cardTimer.Text = ""
    end
    
    -- Add small random variation to seem human (0.8-1.5 seconds)
    local preDelay = math.random(80, 150) / 100
    task.wait(preDelay)
    
    local success = pcall(function()
        collectOrb:FireServer(config.id, "Gems", true)
    end)
    
    local responseTime = tick() - now
    
    if success then
        -- SUCCESS
        stats.success = stats.success + 1
        stats.sessionTotal = stats.sessionTotal + 1
        gemConsecutiveSuccess = gemConsecutiveSuccess + 1
        gemBurstCount = gemBurstCount + 1
        gemLastCollectTime = now
        stats.rateLimited = false
        
        if card then
            card.cardStatus.Text = "✅ Gem collected!"
            card.cardStatus.TextColor3 = Color3.new(0.3, 1, 0.3)
            card.cardTimer.Text = string.format("+1 (%.1fs)", responseTime)
        end
        
        -- After successful collection, wait optimal delay before next
        local optimalDelay = config.optimalDelay or 1.5
        local variation = math.random(-30, 30) / 100  -- -0.3 to +0.3 seconds
        local nextDelay = math.max(0.8, optimalDelay + variation)
        
        if card then
            card.cardTimer.Text = string.format("Next: %.1fs", nextDelay)
        end
        
        -- Check session limit
        if stats.sessionTotal >= config.sessionLimit then
            stats.rateLimited = true
            stats.cooldownUntil = now + 300
            if card then
                card.cardStatus.Text = "🔴 Gem limit reached"
                card.cardTimer.Text = "Relog recommended"
            end
        end
        
        updateAllDisplays()
        return true, "success"
        
    else
        -- FAILURE - Probably went too fast
        stats.failed = stats.failed + 1
        gemConsecutiveSuccess = 0
        gemBurstCount = 0
        
        if card then
            card.cardStatus.Text = "❌ Too fast! Slowing down"
            card.cardStatus.TextColor3 = Color3.new(1, 0.3, 0.3)
            card.cardTimer.Text = "CD: 5s"
        end
        
        -- Increase delay on failure
        orbConfigs.Gems.minDelay = math.min(orbConfigs.Gems.minDelay + 0.5, 5)
        orbConfigs.Gems.maxDelay = math.min(orbConfigs.Gems.maxDelay + 1, 8)
        
        stats.cooldownUntil = now + 5  -- Short cooldown on fail
        
        updateAllDisplays()
        return false, "too_fast"
    end
end

--// UPDATED MAIN COLLECTION LOOP WITH GEM OPTIMIZATION
local function startCollector()
    if orbCollectorThread then
        task.cancel(orbCollectorThread)
    end
    
    orbCollectorActive = true
    overallStatus.Text = "Status: 🟢 ACTIVE"
    overallStatus.TextColor3 = Color3.new(0.3, 1, 0.3)
    sessionStartTime = tick()
    
    -- Reset gem counters
    gemBurstCount = 0
    gemConsecutiveSuccess = 0
    
    orbCollectorThread = task.spawn(function()
        while orbCollectorActive do
            local anyEnabled = false
            local collected = false
            
            if settings.cycleMode then
                -- Cycle through all enabled types (Gems first if priority)
                local order = {"Gems", "EasterEggs", "Coins"}
                for _, orbType in ipairs(order) do
                    if typeCards[orbType] and typeCards[orbType].enabled then
                        anyEnabled = true
                        local success, reason
                        
                        if orbType == "Gems" then
                            -- Use specialized gem collector
                            success, reason = collectGem()
                        else
                            success, reason = collectOrbType(orbType)
                        end
                        
                        if success then
                            collected = true
                        end
                        
                        -- Wait between different orb types
                        task.wait(settings.globalCooldown)
                    end
                end
            else
                -- Priority mode: Gems only (optimized)
                if typeCards.Gems and typeCards.Gems.enabled then
                    anyEnabled = true
                    local success, reason = collectGem()
                    if success then
                        collected = true
                    end
                end
            end
            
            if not anyEnabled then
                overallStatus.Text = "Status: ⚠️ No types enabled"
                task.wait(5)
            else
                -- Update cycle counter
                currentCycle = currentCycle + 1
                cycleText.Text = string.format("🔄 Cycle: %d", currentCycle)
                
                -- Dynamic wait based on what was collected
                local waitTime = cycleDelay
                if collected then
                    -- If we collected something, shorter wait
                    waitTime = math.random(2, 4)
                else
                    -- If nothing collected, longer wait
                    waitTime = math.random(4, 8)
                end
                
                for i = waitTime, 1, -1 do
                    if not orbCollectorActive then break end
                    cycleText.Text = string.format("Next cycle: %ds", i)
                    task.wait(1)
                end
            end
        end
    end)
end