--// ULTIMATE ORB FARMER - MAXIMUM EFFICIENCY
-- Based on game's actual config files and your testing

local player = game:GetService("Players").LocalPlayer
local collectRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Remotes"):WaitForChild("CollectOrb")

-- Optimal values from game config + testing
local orbConfig = {
    Gems = {
        amount = 2,           -- Max per collect (from testing)
        delay = 1.5,         -- Optimal delay between collects
        burstLimit = 3,      -- From your "3 times in 10 seconds" observation
        burstPause = 5,      -- Short pause after burst
        sessionLimit = 50,   -- Estimated before rate limit
        sessionPause = 60,   -- Pause to reset
        currencyName = "Gems"
    },
    Coins = {
        amount = 18667,       -- Max working amount
        delay = 1.0,          -- Coins are more forgiving
        burstLimit = 5,
        burstPause = 3,
        sessionLimit = 100,
        sessionPause = 45,
        currencyName = "Coins"
    },
    EasterEggs = {
        amount = 5,           -- Max per collect
        delay = 1.2,
        burstLimit = 4,
        burstPause = 4,
        sessionLimit = 80,
        sessionPause = 50,
        currencyName = "EasterEggs"
    }
}

-- Track session counts
local sessionCounts = {
    Gems = 0,
    Coins = 0,
    EasterEggs = 0
}

-- Track last collect times for burst detection
local lastCollectTimes = {
    Gems = 0,
    Coins = 0,
    EasterEggs = 0
}

-- Get actual currency (to verify it's working)
local function getCurrency(currencyName)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild(currencyName)
        if stat then
            return stat.Value
        end
    end
    return nil
end

-- Smart collect with rate limit avoidance
local function smartCollect(orbType)
    local config = orbConfig[orbType]
    local now = tick()
    
    -- Check session limit
    if sessionCounts[orbType] >= config.sessionLimit then
        print(string.format("[%s] Session limit reached. Pausing %ds", orbType, config.sessionPause))
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
                print(string.format("[%s] Burst limit. Waiting %.1fs", orbType, waitTime))
                task.wait(waitTime)
            end
        end
    end
    
    -- Record before amount
    local beforeAmount = getCurrency(config.currencyName)
    
    -- Attempt collect
    local success = pcall(function()
        collectRemote:FireServer(config.amount, orbType, true)
    end)
    
    task.wait(0.3)  -- Wait for server to process
    
    -- Verify it worked
    local afterAmount = getCurrency(config.currencyName)
    local gained = (afterAmount or 0) - (beforeAmount or 0)
    
    if success and gained > 0 then
        sessionCounts[orbType] = sessionCounts[orbType] + 1
        lastCollectTimes[orbType] = tick()
        print(string.format("[✓] %s +%d (Total this session: %d)", orbType, gained, sessionCounts[orbType]))
        return true
    elseif success and gained == 0 then
        print(string.format("[⚠️] %s - Remote succeeded but no reward (rate limited?)", orbType))
        -- Increase delay slightly
        config.delay = math.min(config.delay + 0.1, 3)
        return false
    else
        print(string.format("[✗] %s - Failed", orbType))
        return false
    end
end

-- Find optimal delay (auto-learn)
local function findOptimalDelays()
    print("\n=== FINDING OPTIMAL DELAYS ===")
    
    local testDelays = {0.5, 0.8, 1.0, 1.2, 1.5, 1.8, 2.0, 2.5}
    
    for _, orbType in ipairs({"Gems", "Coins", "EasterEggs"}) do
        print("\nTesting", orbType)
        local config = orbConfig[orbType]
        
        for _, delay in ipairs(testDelays) do
            local successes = 0
            local totalGain = 0
            
            for i = 1, 10 do
                local before = getCurrency(config.currencyName)
                pcall(function()
                    collectRemote:FireServer(config.amount, orbType, true)
                end)
                task.wait(delay)
                local after = getCurrency(config.currencyName)
                local gained = (after or 0) - (before or 0)
                
                if gained > 0 then
                    successes = successes + 1
                    totalGain = totalGain + gained
                end
            end
            
            local successRate = (successes / 10) * 100
            print(string.format("  Delay %.1fs: %d/%d successes (%.0f%%) - Gained %d", 
                delay, successes, 10, successRate, totalGain))
            
            if successRate >= 80 then
                config.delay = delay
                print(string.format("  ✓ Optimal delay for %s: %.1fs", orbType, delay))
                break
            end
        end
    end
end

-- Main farming loop (optimized)
local function startOptimizedFarming()
    print("\n=== STARTING OPTIMIZED ORB FARMING ===")
    print("Gems: max 2 per collect")
    print("Coins: max 18667 per collect")
    print("EasterEggs: max 5 per collect")
    print("")
    
    -- First, find optimal delays
    findOptimalDelays()
    
    print("\n=== FARMING ACTIVE ===")
    
    while true do
        -- Farm in priority order (Gems most valuable first)
        smartCollect("Gems")
        task.wait(orbConfig.Gems.delay * 0.5)
        
        smartCollect("Coins")
        task.wait(orbConfig.Coins.delay * 0.5)
        
        smartCollect("EasterEggs")
        task.wait(orbConfig.EasterEggs.delay * 0.5)
        
        -- Show stats every 30 seconds
        if math.floor(tick()) % 30 == 0 then
            local totalGems = getCurrency("Gems") or 0
            local totalCoins = getCurrency("Coins") or 0
            local totalEggs = getCurrency("Easter Eggs") or 0
            
            print(string.format("\n📊 STATS - Gems: %d, Coins: %d, Eggs: %d", 
                totalGems, totalCoins, totalEggs))
            print(string.format("   Session - Gems: %d, Coins: %d, Eggs: %d",
                sessionCounts.Gems, sessionCounts.Coins, sessionCounts.EasterEggs))
        end
    end
end

-- Start farming
startOptimizedFarming()
