--// ============== UPDATED CHALLENGE SYSTEM WITH PRECISE COOLDOWN ==============

-- Add this to the CHALLENGE TAB section, replacing the old challenge loop

-- Get player data for cooldown detection
local player = game:GetService("Players").LocalPlayer
local challengesFolder = player:FindFirstChild("Challenges")
local playerFlags = player:FindFirstChild("Flags")
local raidingFlag = playerFlags and playerFlags:FindFirstChild("Raiding")
local challengeActiveFlag = playerFlags and playerFlags:FindFirstChild("ChallengeActive")

-- Challenge duration mapping (in seconds) - for countdown display
local challengeDurations = {
    ["Insane Challenge"] = 22 * 60,  -- 22 minutes
    ["Pro Challenge"] = 20 * 60,     -- 20 minutes
    ["Godly Challenge"] = 20 * 60,   -- 20 minutes
    ["Easter Challenge #1"] = 15 * 60,
    ["Easter Challenge #2"] = 15 * 60,
    ["Novice Challenge"] = 10 * 60,
    ["Advanced Challenge"] = 15 * 60,
}

-- Get remaining cooldown for a challenge (returns seconds)
local function getChallengeCooldown(challengeName)
    if not challengesFolder then return 0 end
    
    -- Find the challenge folder (handle different naming conventions)
    local challengeNode = challengesFolder:FindFirstChild(challengeName)
    if not challengeNode then
        -- Try without spaces
        challengeNode = challengesFolder:FindFirstChild(challengeName:gsub(" ", ""))
    end
    
    if challengeNode then
        local nextAvailable = challengeNode:FindFirstChild("NextAvailableTime")
        if nextAvailable then
            local remaining = nextAvailable.Value - os.time()
            return math.max(0, remaining)
        end
    end
    return 0
end

-- Get time remaining in current challenge (for countdown display)
local function getChallengeTimeRemaining(challengeName)
    local challengeStartTime = player:FindFirstChild("ChallengeStartTime")
    if not challengeStartTime or challengeStartTime.Value == 0 then
        return nil
    end
    
    local duration = challengeDurations[challengeName]
    if not duration then
        return nil
    end
    
    local elapsed = os.time() - challengeStartTime.Value
    local remaining = duration - elapsed
    return math.max(0, remaining)
end

-- Check if a challenge is available (cooldown = 0)
local function isChallengeAvailable(challengeName)
    return getChallengeCooldown(challengeName) == 0
end

-- Check if currently in a challenge/raid
local function isInChallenge()
    return challengeActiveFlag and challengeActiveFlag.Value == true
end

local function isInRaid()
    return raidingFlag and raidingFlag.Value == true
end

-- Wait for challenge to become available
local function waitForChallengeAvailable(challengeName)
    print(string.format("[Auto] Waiting for %s cooldown...", challengeName))
    
    while not isChallengeAvailable(challengeName) do
        local remaining = getChallengeCooldown(challengeName)
        if remaining > 0 then
            local hours = math.floor(remaining / 3600)
            local minutes = math.floor((remaining % 3600) / 60)
            local seconds = remaining % 60
            
            if hours > 0 then
                challengeStatus.Text = string.format("⏰ %s: %dh %02dm", challengeName, hours, minutes)
                countdownDisplay.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            else
                challengeStatus.Text = string.format("⏰ %s: %02d:%02d", challengeName, minutes, seconds)
                countdownDisplay.Text = string.format("%02d:%02d", minutes, seconds)
            end
        end
        task.wait(1)
    end
    
    challengeStatus.Text = string.format("✅ %s READY!", challengeName)
    countdownDisplay.Text = "READY"
    print(string.format("[Auto] ✅ %s is now available!", challengeName))
end

-- Wait for current challenge/raid to end
local function waitForChallengeEnd()
    challengeStatus.Text = "⚔️ Challenge in progress..."
    
    while isInRaid() or isInChallenge() do
        -- Try to get remaining time
        if currentChallengeName then
            local remaining = getChallengeTimeRemaining(currentChallengeName)
            if remaining and remaining > 0 then
                local minutes = math.floor(remaining / 60)
                local seconds = remaining % 60
                countdownDisplay.Text = string.format("%02d:%02d", minutes, seconds)
                challengeStatus.Text = string.format("🏃 %s - %02d:%02d remaining", currentChallengeName, minutes, seconds)
            end
        end
        task.wait(1)
    end
    
    challengeStatus.Text = "✅ Challenge complete!"
    countdownDisplay.Text = "DONE"
    print("[Auto] Challenge complete!")
    task.wait(2)
end

-- Start a challenge
local function startChallengeByName(challengeName)
    print(string.format("[Auto] Starting %s...", challengeName))
    challengeStatus.Text = string.format("🚀 Starting %s...", challengeName)
    countdownDisplay.Text = "START"
    
    pcall(function()
        raidStop:FireServer()
        task.wait(0.5)
        startChallenge:InvokeServer(challengeName)
        task.wait(0.5)
        changeSetting:InvokeServer("AutoRaid", "On")
    end)
    
    currentChallengeName = challengeName
    print(string.format("[Auto] %s started!", challengeName))
end

-- Get the next available challenge from the enabled list
local function getNextAvailableChallenge()
    local earliestTime = math.huge
    local earliestChallenge = nil
    
    for _, ch in ipairs(challengeOrder) do
        if ch.enabled then
            local cooldown = getChallengeCooldown(ch.name)
            if cooldown == 0 then
                return ch.name  -- Found one immediately available
            end
            if cooldown < earliestTime then
                earliestTime = cooldown
                earliestChallenge = ch.name
            end
        end
    end
    
    return earliestChallenge, earliestTime
end

-- Update queue display with cooldown info
local function updateQueueWithCooldowns()
    local enabledList = {}
    for _, ch in ipairs(challengeOrder) do
        if ch.enabled then
            local cooldown = getChallengeCooldown(ch.name)
            if cooldown == 0 then
                table.insert(enabledList, string.format("%s ✅ READY", ch.name))
            else
                local mins = math.floor(cooldown / 60)
                local secs = cooldown % 60
                table.insert(enabledList, string.format("%s ⏰ %02d:%02d", ch.name, mins, secs))
            end
        end
    end
    
    if #enabledList == 0 then
        queueDisplay.Text = "❌ No challenges enabled"
    else
        local text = ""
        for i, ch in ipairs(enabledList) do
            text = text .. i .. ". " .. ch .. "\n"
        end
        queueDisplay.Text = text
    end
end

-- Main auto challenge loop (updated)
local function startChallengeLoop()
    stopChallengeLoop()
    autoChallengeActive = true
    
    challengeLoopThread = task.spawn(function()
        while autoChallengeActive do
            -- Update queue display with cooldowns
            updateQueueWithCooldowns()
            
            -- Find next available challenge
            local nextChallenge, waitTime = getNextAvailableChallenge()
            
            if not nextChallenge then
                challengeStatus.Text = "❌ No challenges enabled!"
                countdownDisplay.Text = "---"
                task.wait(5)
            else
                -- Wait for challenge to be available
                if waitTime and waitTime > 0 then
                    waitForChallengeAvailable(nextChallenge)
                end
                
                if autoChallengeActive then
                    -- Start the challenge
                    startChallengeByName(nextChallenge)
                    
                    -- Wait for challenge to complete
                    waitForChallengeEnd()
                    
                    -- Turn off auto raid after challenge (if enabled)
                    if autoRaidAfterChallenge then
                        turnOffAutoRaid()
                    end
                end
            end
        end
    end)
end

-- Add a refresh button to manually update cooldown display
local refreshCooldownBtn = Instance.new("TextButton")
refreshCooldownBtn.Size = UDim2.new(0.9, 0, 0, 35)
refreshCooldownBtn.Text = "🔄 REFRESH COOLDOWNS"
refreshCooldownBtn.TextSize = 12
refreshCooldownBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
refreshCooldownBtn.TextColor3 = Color3.new(1, 1, 1)
refreshCooldownBtn.BorderSizePixel = 0
refreshCooldownBtn.Parent = challengePanel
refreshCooldownBtn.Position = UDim2.new(0.05, 0, 0, 0)  -- Adjust position as needed

refreshCooldownBtn.MouseButton1Click:Connect(function()
    updateQueueWithCooldowns()
    challengeStatus.Text = "🔄 Cooldowns refreshed!"
    task.wait(1)
    if autoChallengeActive then
        challengeStatus.Text = "Status: ACTIVE"
    else
        challengeStatus.Text = "Status: IDLE"
    end
end)

-- Update the auto challenge toggle to use the new system
autoChallengeToggle.MouseButton1Click:Connect(function()
    if autoChallengeActive then
        stopChallengeLoop()
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: OFF"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        challengeStatus.Text = "Status: Stopped"
        countdownDisplay.Text = "---"
        orderDisplay.Text = "Current: None → Next: None"
    else
        autoChallengeToggle.Text = "🎯 AUTO CHALLENGE: ON"
        autoChallengeToggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
        startChallengeLoop()
    end
    autoSaveConfig()
end)

-- Initial queue update
updateQueueWithCooldowns()

print("[Challenge] Precise cooldown detection active!")
print("[Challenge] Using NextAvailableTime for accurate timing")
