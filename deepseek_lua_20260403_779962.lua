--// ULTIMATE ORB FARMER - MOBILE FIXED (No GUI issues)

local player = game:GetService("Players").LocalPlayer
local collectRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Remotes"):WaitForChild("CollectOrb")

-- Simple console output (no GUI)
print("==========================================")
print("     ULTIMATE ORB FARMER - MOBILE")
print("==========================================")

-- Check if remote exists
if not collectRemote then
    print("[ERROR] CollectOrb remote not found!")
    return
else
    print("[✓] CollectOrb remote found!")
end

-- Get current currency to verify
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

print("[✓] Current Gems:", getCurrency("Gems"))
print("[✓] Current Coins:", getCurrency("Coins"))
print("[✓] Current Easter Eggs:", getCurrency("Easter Eggs"))

-- Test a single collect first
print("\n[TEST] Single orb collect...")
local beforeGems = getCurrency("Gems")
pcall(function()
    collectRemote:FireServer(2, "Gems", true)
end)
task.wait(1)
local afterGems = getCurrency("Gems")

if afterGems > beforeGems then
    print("[✓] SUCCESS! Gems increased by", afterGems - beforeGems)
else
    print("[✗] FAILED! Gems did not increase")
    print("    Make sure you're in a raid/orb event!")
end

-- Simple farming loop (no GUI)
local farming = false
local sessionCount = 0

local function startFarming()
    if farming then
        print("[!] Already farming!")
        return
    end
    
    farming = true
    print("\n[START] Farming started!")
    print("Press Ctrl+C to stop (or use stop command)")
    
    while farming do
        -- Try to collect gems
        local beforeGems = getCurrency("Gems")
        pcall(function()
            collectRemote:FireServer(2, "Gems", true)
        end)
        task.wait(1.5)
        
        local afterGems = getCurrency("Gems")
        local gained = afterGems - beforeGems
        
        if gained > 0 then
            sessionCount = sessionCount + 1
            print(string.format("[✓] +%d Gems (Total this session: %d)", gained, sessionCount))
        else
            print("[✗] No gems gained - rate limited?")
        end
        
        -- Try coins
        local beforeCoins = getCurrency("Coins")
        pcall(function()
            collectRemote:FireServer(18667, "Coins", true)
        end)
        task.wait(1)
        
        local afterCoins = getCurrency("Coins")
        local coinGain = afterCoins - beforeCoins
        if coinGain > 0 then
            print(string.format("[✓] +%d Coins", coinGain))
        end
        
        -- Show stats every 10 cycles
        if sessionCount % 10 == 0 then
            print(string.format("\n[STATS] Gems: %d | Coins: %d | Eggs: %d", 
                getCurrency("Gems"), getCurrency("Coins"), getCurrency("Easter Eggs")))
        end
    end
end

local function stopFarming()
    farming = false
    print("\n[STOP] Farming stopped!")
    print("Total collects this session:", sessionCount)
end

-- Simple commands
print("\n==========================================")
print("COMMANDS:")
print("  startfarming() - Start farming")
print("  stopfarming()  - Stop farming")
print("  status()       - Show current stats")
print("==========================================")

function status()
    print(string.format("\n[STATUS] Gems: %d | Coins: %d | Easter Eggs: %d", 
        getCurrency("Gems"), getCurrency("Coins"), getCurrency("Easter Eggs")))
end

-- Try to find why orbs aren't working
print("\n[CHECK] Are you in a raid? Orbs only spawn during raids!")
print("[CHECK] Try joining an active raid or event first!")

-- Optional: Auto-detect if in raid
local function checkRaidStatus()
    local workspace = game:GetService("Workspace")
    local plots = {"CommunityPlot", "EventPlot", "RaftPlot"}
    
    for _, plotName in ipairs(plots) do
        local plot = workspace:FindFirstChild(plotName)
        if plot then
            local raidStuff = plot:FindFirstChild("RaidStuff")
            if raidStuff then
                local raidActive = raidStuff:FindFirstChild("RaidActive")
                if raidActive and raidActive.Value then
                    print("[✓] Raid ACTIVE in", plotName)
                    return true
                end
            end
        end
    end
    print("[!] No active raid found!")
    return false
end

checkRaidStatus()
