--// WAVE DETECTION INVESTIGATION SCRIPT
-- Run this to find all possible wave detection methods

pcall(function()

print("=" .. string.rep("=", 50))
print("WAVE DETECTION INVESTIGATION - SCANNING FOR TRIGGERS")
print("=" .. string.rep("=", 50))

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local player = Players.LocalPlayer

--// STORAGE FOR FOUND TRIGGERS
local waveTriggers = {
    remotes = {},
    events = {},
    values = {},
    attributes = {},
    bindables = {},
    remoteEvents = {},
    remoteFunctions = {}
}

--// FUNCTION TO SEARCH INSTANCE TREE
local function searchInstance(instance, depth)
    if depth > 15 then return end
    
    -- Look for wave-related names
    local nameLower = string.lower(instance.Name or "")
    if nameLower:match("wave") or nameLower:match("round") or nameLower:match("enemy") or nameLower:match("spawn") then
        local info = {
            name = instance.Name,
            className = instance.ClassName,
            path = instance:GetFullName(),
            parent = instance.Parent and instance.Parent.Name or "nil"
        }
        
        if instance:IsA("RemoteEvent") then
            table.insert(waveTriggers.remoteEvents, info)
        elseif instance:IsA("RemoteFunction") then
            table.insert(waveTriggers.remoteFunctions, info)
        elseif instance:IsA("BindableEvent") then
            table.insert(waveTriggers.bindables, info)
        elseif instance:IsA("IntValue") or instance:IsA("NumberValue") then
            table.insert(waveTriggers.values, info)
            -- Try to get current value
            info.currentValue = instance.Value
        elseif instance:IsA("StringValue") then
            table.insert(waveTriggers.values, info)
            info.currentValue = instance.Value
        elseif instance:IsA("BoolValue") then
            table.insert(waveTriggers.values, info)
            info.currentValue = instance.Value
        end
    end
    
    for _, child in ipairs(instance:GetChildren()) do
        searchInstance(child, depth + 1)
    end
end

--// SEARCH PLAYER OBJECTS
print("\n[1] Searching Player objects...")
searchInstance(player, 0)

-- Check player flags
local playerFlags = player:FindFirstChild("Flags")
if playerFlags then
    print("\n[Player Flags Found]")
    for _, flag in ipairs(playerFlags:GetChildren()) do
        if flag:IsA("BoolValue") or flag:IsA("IntValue") or flag:IsA("NumberValue") then
            print("  - " .. flag.Name .. " = " .. tostring(flag.Value))
            if string.lower(flag.Name):match("wave") or string.lower(flag.Name):match("round") then
                print("    ⭐ POTENTIAL WAVE TRIGGER!")
                table.insert(waveTriggers.values, {
                    name = flag.Name,
                    className = flag.ClassName,
                    path = flag:GetFullName(),
                    currentValue = flag.Value
                })
            end
        end
    end
end

-- Check player leaderstats
local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
    print("\n[Leaderstats Found]")
    for _, stat in ipairs(leaderstats:GetChildren()) do
        if stat:IsA("IntValue") or stat:IsA("NumberValue") then
            print("  - " .. stat.Name .. " = " .. tostring(stat.Value))
            if string.lower(stat.Name):match("wave") or string.lower(stat.Name):match("round") then
                print("    ⭐ POTENTIAL WAVE TRIGGER!")
                table.insert(waveTriggers.values, {
                    name = stat.Name,
                    className = stat.ClassName,
                    path = stat:GetFullName(),
                    currentValue = stat.Value
                })
            end
        end
    end
end

--// SEARCH REPLICATEDSTORAGE
print("\n[2] Searching ReplicatedStorage...")
local remoteEvents = ReplicatedStorage:FindFirstChild("Events")
if remoteEvents then
    searchInstance(remoteEvents, 0)
    
    -- Check specific folders
    local remotes = remoteEvents:FindFirstChild("Remotes")
    if remotes then
        print("\n[Remotes Folder Found]")
        for _, remote in ipairs(remotes:GetChildren()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                print("  - " .. remote.Name .. " (" .. remote.ClassName .. ")")
                if string.lower(remote.Name):match("wave") or string.lower(remote.Name):match("round") or 
                   string.lower(remote.Name):match("next") or string.lower(remote.Name):match("start") then
                    print("    ⭐ POTENTIAL WAVE REMOTE!")
                    table.insert(waveTriggers.remotes, {
                        name = remote.Name,
                        className = remote.ClassName,
                        path = remote:GetFullName()
                    })
                end
            end
        end
    end
    
    -- Check functions folder
    local functions = remoteEvents:FindFirstChild("Functions")
    if functions then
        print("\n[Functions Folder Found]")
        for _, func in ipairs(functions:GetChildren()) do
            if func:IsA("RemoteFunction") then
                print("  - " .. func.Name)
                if string.lower(func.Name):match("wave") or string.lower(func.Name):match("round") then
                    print("    ⭐ POTENTIAL WAVE FUNCTION!")
                    table.insert(waveTriggers.remoteFunctions, {
                        name = func.Name,
                        className = func.ClassName,
                        path = func:GetFullName()
                    })
                end
            end
        end
    end
end

--// SEARCH WORKSPACE FOR ENEMY/SPAWN SIGNALS
print("\n[3] Searching Workspace for enemy/wave signals...")
local function searchWorkspace(instance, depth)
    if depth > 8 then return end
    
    local nameLower = string.lower(instance.Name or "")
    if nameLower:match("enemy") or nameLower:match("spawn") or nameLower:match("wave") or 
       nameLower:match("mob") or nameLower:match("creep") or nameLower:match("zombie") then
        
        print("  Found: " .. instance.Name .. " (" .. instance.ClassName .. ") at " .. instance:GetFullName())
        
        -- Check for attributes
        local attrs = instance:GetAttributes()
        if next(attrs) then
            print("    Attributes:")
            for k, v in pairs(attrs) do
                print("      " .. k .. " = " .. tostring(v))
            end
        end
        
        -- Check for value objects
        for _, child in ipairs(instance:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
                print("    Child Value: " .. child.Name .. " = " .. tostring(child.Value))
            end
        end
    end
    
    for _, child in ipairs(instance:GetChildren()) do
        searchWorkspace(child, depth + 1)
    end
end

searchWorkspace(workspace, 0)

--// LISTEN FOR SIGNALS
print("\n[4] Setting up signal listeners...")

-- Listen for remote events
local function setupRemoteListener(remote)
    if remote:IsA("RemoteEvent") then
        local oldFunc
        oldFunc = remote.OnClientEvent
        remote.OnClientEvent = function(...)
            local args = {...}
            print("[REMOTE EVENT TRIGGERED] " .. remote.Name)
            print("  Args:", args)
            if string.lower(remote.Name):match("wave") or string.lower(remote.Name):match("round") then
                print("  ⭐ THIS MIGHT BE A WAVE EVENT!")
                print("  Full args:", args)
            end
            if oldFunc then oldFunc(...) end
        end
    end
end

-- Find all remote events in ReplicatedStorage
local function findAllRemotes(instance)
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("RemoteEvent") then
            setupRemoteListener(child)
            print("  Listening to: " .. child.Name)
        end
        findAllRemotes(child)
    end
end

findAllRemotes(ReplicatedStorage)

--// CHECK FOR WAVE NUMBER IN UI (MOST RELIABLE METHOD)
print("\n[5] Scanning UI for wave display...")

local function findWaveInGUI(gui)
    local waveTexts = {}
    
    local function searchGUI(instance)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            local text = instance.Text or ""
            local lowerText = string.lower(text)
            
            -- Check for wave patterns
            if lowerText:match("wave") or lowerText:match("round") or lowerText:match("w%d+") then
                local waveNum = text:match("(%d+)")
                table.insert(waveTexts, {
                    instance = instance,
                    text = text,
                    waveNum = waveNum,
                    path = instance:GetFullName()
                })
                print("  Found potential wave display:")
                print("    Text: " .. text)
                print("    Path: " .. instance:GetFullName())
                print("    Wave Number: " .. (waveNum or "unknown"))
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            searchGUI(child)
        end
    end
    
    if gui then
        searchGUI(gui)
    end
    return waveTexts
end

-- Check PlayerGui
local playerGui = player:FindFirstChild("PlayerGui")
if playerGui then
    print("\n[PlayerGui]")
    local waveDisplays = findWaveInGUI(playerGui)
    if #waveDisplays > 0 then
        print("\n⭐ BEST CANDIDATES FOR WAVE DETECTION:")
        for i, display in ipairs(waveDisplays) do
            print(string.format("  %d. %s - Wave: %s", i, display.path, display.waveNum or "???"))
        end
    end
end

-- Check CoreGui
local coreGui = game:GetService("CoreGui")
if coreGui then
    print("\n[CoreGui]")
    local waveDisplays = findWaveInGUI(coreGui)
    if #waveDisplays > 0 then
        for i, display in ipairs(waveDisplays) do
            print(string.format("  %d. %s - Wave: %s", i, display.path, display.waveNum or "???"))
        end
    end
end

--// CREATE LIVE WAVE MONITOR (BEST WORKING METHOD)
print("\n[6] Creating live wave monitor using UI detection...")

local waveMonitorActive = true
local currentWave = 0
local waveMonitorFrame = nil
local waveLabel = nil

-- Create a small display
local monitorGui = Instance.new("ScreenGui")
monitorGui.Name = "WaveMonitor"
monitorGui.ResetOnSpawn = false
monitorGui.Parent = game:GetService("CoreGui")

local monitorFrame = Instance.new("Frame")
monitorFrame.Size = UDim2.new(0, 250, 0, 100)
monitorFrame.Position = UDim2.new(0, 10, 0, 100)
monitorFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
monitorFrame.BorderSizePixel = 2
monitorFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
monitorFrame.BackgroundTransparency = 0.1
monitorFrame.Parent = monitorGui

local monitorTitle = Instance.new("TextLabel")
monitorTitle.Size = UDim2.new(1, 0, 0, 25)
monitorTitle.Text = "🌊 WAVE MONITOR"
monitorTitle.TextColor3 = Color3.new(1, 1, 1)
monitorTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
monitorTitle.Font = Enum.Font.GothamBold
monitorTitle.TextSize = 12
monitorTitle.Parent = monitorFrame

waveLabel = Instance.new("TextLabel")
waveLabel.Size = UDim2.new(1, -10, 0, 40)
waveLabel.Position = UDim2.new(0, 5, 0, 30)
waveLabel.Text = "Current Wave: Detecting..."
waveLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
waveLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
waveLabel.Font = Enum.Font.GothamBold
waveLabel.TextSize = 14
waveLabel.Parent = monitorFrame

local detectedFrom = Instance.new("TextLabel")
detectedFrom.Size = UDim2.new(1, -10, 0, 25)
detectedFrom.Position = UDim2.new(0, 5, 0, 72)
detectedFrom.Text = "Source: Scanning..."
detectedFrom.TextColor3 = Color3.new(0.7, 0.7, 0.7)
detectedFrom.BackgroundTransparency = 1
detectedFrom.Font = Enum.Font.Gotham
detectedFrom.TextSize = 9
detectedFrom.Parent = monitorFrame

-- Monitor function
local lastWaveText = ""
local lastWaveValue = 0

task.spawn(function()
    while waveMonitorActive do
        -- Search for wave display every frame
        local bestMatch = nil
        local bestWave = nil
        
        -- Check all text labels in PlayerGui
        if playerGui then
            local function findWave(instance)
                if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                    local text = instance.Text or ""
                    local waveNum = text:match("Wave%s*(%d+)") or 
                                   text:match("WAVE%s*(%d+)") or 
                                   text:match("wave%s*(%d+)") or
                                   text:match("Round%s*(%d+)") or
                                   text:match("ROUND%s*(%d+)")
                    
                    if waveNum then
                        local num = tonumber(waveNum)
                        if num and (not bestWave or num > bestWave) then
                            bestWave = num
                            bestMatch = instance
                        end
                    end
                end
                
                for _, child in ipairs(instance:GetChildren()) do
                    findWave(child)
                end
            end
            findWave(playerGui)
        end
        
        if bestMatch and bestWave then
            if bestWave ~= lastWaveValue then
                currentWave = bestWave
                lastWaveValue = bestWave
                waveLabel.Text = "🌊 Current Wave: " .. currentWave
                detectedFrom.Text = "Source: " .. bestMatch.Name:sub(1, 30)
                print("[Wave] Current wave: " .. currentWave)
                
                -- Change color based on wave (optional)
                if currentWave >= 408 then
                    waveLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
                    waveLabel.Text = "⚠️ WAVE " .. currentWave .. " - TARGET REACHED! ⚠️"
                else
                    waveLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
                end
            end
        else
            if waveLabel.Text ~= "Current Wave: ??? (No wave display found)" then
                waveLabel.Text = "Current Wave: ??? (No wave display found)"
                detectedFrom.Text = "Source: None detected"
            end
        end
        
        task.wait(0.5)
    end
end)

print("\n" .. "=" .. string.rep("=", 50))
print("INVESTIGATION COMPLETE!")
print("=" .. string.rep("=", 50))
print("\n📊 SUMMARY:")
print("  - Created live wave monitor window")
print("  - Wave detection from UI is most reliable")
print("  - Check output for remote events when wave changes")
print("  - Monitor window shows current wave in real-time")
print("\n💡 TIPS:")
print("  1. Wait for a raid/challenge to start to see wave detection")
print("  2. Watch the output for any wave-related remote events")
print("  3. The wave monitor window will show current wave")
print("  4. When wave 408 is reached, the display will turn red")
print("\n✅ Detection script is running. Keep this running while you play!")

end)
