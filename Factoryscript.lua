-- Advanced Remote Detector - Finds Hidden Remotes by Hooking Game Functions
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

print("=== ADVANCED REMOTE DETECTOR ===")
print("This will detect which remote the game ACTUALLY uses")

-- Method 1: Hook into the game's existing remote calls
local function hookRemotes()
    local Communication = ReplicatedStorage:WaitForChild("Communication")
    local Functions = Communication:WaitForChild("Functions")
    local Events = Communication:WaitForChild("Events")
    
    -- Store all remotes
    local allRemotes = {}
    
    for _, child in pairs(Functions:GetChildren()) do
        if child:IsA("RemoteFunction") then
            table.insert(allRemotes, {remote = child, type = "RemoteFunction", index = #allRemotes + 1})
        end
    end
    
    for _, child in pairs(Events:GetChildren()) do
        if child:IsA("RemoteEvent") then
            table.insert(allRemotes, {remote = child, type = "RemoteEvent", index = #allRemotes + 1})
        end
    end
    
    print("Found " .. #allRemotes .. " total remotes to monitor")
    
    -- Hook each remote to log when it's called
    for _, data in pairs(allRemotes) do
        local remote = data.remote
        local originalInvoke = nil
        local originalFire = nil
        
        if data.type == "RemoteFunction" then
            -- Hook InvokeServer
            originalInvoke = remote.InvokeServer
            remote.InvokeServer = function(self, ...)
                local args = {...}
                print(string.rep("=", 50))
                print("🔴 REMOTE FUNCTION CALLED!")
                print("Index:", data.index)
                print("Name: '" .. remote.Name .. "' (empty string)")
                print("Path:", remote:GetFullName())
                print("Arguments:", #args)
                for i, arg in pairs(args) do
                    print("  Arg[" .. i .. "]:", typeof(arg), tostring(arg):sub(1, 100))
                end
                print(string.rep("=", 50))
                return originalInvoke(self, ...)
            end
        else
            -- Hook FireServer
            originalFire = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                print(string.rep("=", 50))
                print("🟢 REMOTE EVENT CALLED!")
                print("Index:", data.index)
                print("Name: '" .. remote.Name .. "' (empty string)")
                print("Path:", remote:GetFullName())
                print("Arguments:", #args)
                for i, arg in pairs(args) do
                    print("  Arg[" .. i .. "]:", typeof(arg), tostring(arg):sub(1, 100))
                end
                print(string.rep("=", 50))
                return originalFire(self, ...)
            end
        end
    end
    
    print("✅ Remote hooks installed!")
    print("Now perform an action in-game (like mining)")
    print("The script will show which remote gets called")
end

-- Method 2: Trace the actual function calls
local function traceFunctionCalls()
    -- Hook the global require function to catch module scripts
    local oldRequire = require
    _G.require = function(module)
        local result = oldRequire(module)
        if type(result) == "table" then
            -- Check if this module has remote functions
            for k, v in pairs(result) do
                if type(v) == "function" then
                    local oldFunc = v
                    result[k] = function(...)
                        local args = {...}
                        -- Check if arguments contain remotes
                        for _, arg in pairs(args) do
                            if arg and (arg:IsA("RemoteFunction") or arg:IsA("RemoteEvent")) then
                                print("🔍 Function call with remote:", arg:GetFullName())
                            end
                        end
                        return oldFunc(...)
                    end
                end
            end
        end
        return result
    end
end

-- Method 3: Scan memory for remote references
local function scanMemoryForRemotes()
    print("Scanning game memory for remote references...")
    
    local foundReferences = {}
    
    -- Check all scripts for references to remotes
    local function scanInstance(instance, depth)
        if depth > 5 then return end
        
        if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
            local success, source = pcall(function()
                return instance.Source
            end)
            
            if success and source then
                -- Look for remote patterns
                local patterns = {
                    {pattern = "Functions:FindFirstChild", name = "FindFirstChild on Functions"},
                    {pattern = 'WaitForChild("")', name = "Empty string WaitForChild"},
                    {pattern = ":InvokeServer", name = "InvokeServer call"},
                    {pattern = ":FireServer", name = "FireServer call"},
                    {pattern = "RemoteFunction", name = "RemoteFunction reference"},
                    {pattern = "RemoteEvent", name = "RemoteEvent reference"},
                }
                
                for _, p in pairs(patterns) do
                    if string.find(source, p.pattern) then
                        table.insert(foundReferences, {
                            script = instance:GetFullName(),
                            pattern = p.name,
                            line = string.match(source, "(.-\n)" .. p.pattern) or "unknown"
                        })
                    end
                end
            end
        end
        
        for _, child in pairs(instance:GetChildren()) do
            scanInstance(child, depth + 1)
        end
    end
    
    scanInstance(game, 0)
    
    print(string.rep("=", 50))
    print("📝 SCRIPT REFERENCES FOUND:")
    for i, ref in pairs(foundReferences) do
        print(i .. ". Script:", ref.script)
        print("   Pattern:", ref.pattern)
        print("   Code snippet:", ref.line:sub(1, 100))
        print("")
    end
end

-- Method 4: Brute force test each remote with actual game state
local function bruteForceFindMiningRemote()
    print("Attempting to find mining remote by testing each one...")
    
    local Communication = ReplicatedStorage:WaitForChild("Communication")
    local Functions = Communication:WaitForChild("Functions")
    
    -- Get all empty remotes
    local emptyRemotes = {}
    for _, child in pairs(Functions:GetChildren()) do
        if child.Name == "" and child:IsA("RemoteFunction") then
            table.insert(emptyRemotes, child)
        end
    end
    
    -- Get plot and asteroid
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        print("No plots found!")
        return
    end
    
    local plot = plots:FindFirstChild("Plot1")
    if not plot then
        print("Plot1 not found!")
        return
    end
    
    local asteroids = plot:FindFirstChild("Asteroids")
    if not asteroids then
        print("No asteroids folder!")
        return
    end
    
    local asteroid = nil
    for _, child in pairs(asteroids:GetChildren()) do
        asteroid = child
        break
    end
    
    if not asteroid then
        print("No asteroids found!")
        return
    end
    
    print("Testing with plot:", plot.Name)
    print("Testing with asteroid:", asteroid.Name)
    print(string.rep("=", 50))
    
    -- Test each remote
    for i, remote in pairs(emptyRemotes) do
        -- Don't spam too fast
        task.wait(0.1)
        
        -- Add visual indicator
        print("Testing remote #" .. i .. "...")
        
        local success, result = pcall(function()
            return remote:InvokeServer(plot, asteroid)
        end)
        
        if success then
            print(string.rep("🎯", 20))
            print("✅ FOUND WORKING REMOTE!")
            print("Index:", i)
            print("Path:", remote:GetFullName())
            print("Type:", remote.ClassName)
            print(string.rep("🎯", 20))
            
            -- Return the working remote
            return remote, i
        end
    end
    
    print("❌ Could not find working remote via brute force")
    return nil
end

-- Method 5: Hook the actual game client scripts
local function hookGameClient()
    local framework = ReplicatedStorage:FindFirstChild("Framework")
    if not framework then
        print("Framework not found!")
        return
    end
    
    local client = framework:FindFirstChild("Client")
    if not client then
        print("Client not found!")
        return
    end
    
    local services = client:FindFirstChild("Services")
    if not services then
        print("Services not found!")
        return
    end
    
    local plotService = services:FindFirstChild("PlotService")
    if not plotService then
        print("PlotService not found!")
        return
    end
    
    local asteroidClient = plotService:FindFirstChild("AsteroidClient")
    if asteroidClient and asteroidClient:IsA("ModuleScript") then
        print("Found AsteroidClient module!")
        
        -- Try to get the module and hook it
        local success, module = pcall(function()
            return require(asteroidClient)
        end)
        
        if success and type(module) == "table" then
            print("AsteroidClient module loaded!")
            
            -- Scan module for remote references
            for k, v in pairs(module) do
                if type(v) == "function" then
                    print("Found function in module:", k)
                elseif type(v) == "table" then
                    for k2, v2 in pairs(v) do
                        if type(v2) == "function" then
                            print("Found nested function:", k .. "." .. k2)
                        end
                    end
                end
            end
        end
    end
end

-- GUI to display results
local function createResultsGUI(foundRemote, index)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RemoteFinderResults"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.Text = "🎯 REMOTE FOUND!"
    title.TextColor3 = Color3.fromRGB(100, 255, 100)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.9, 0, 0, 120)
    info.Position = UDim2.new(0.05, 0, 0.2, 0)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.TextSize = 12
    info.Font = Enum.Font.Gotham
    info.TextWrapped = true
    info.Text = string.format(
        "Remote Type: %s\nIndex: %d\nPath: %s\n\nUse this remote for mining!",
        foundRemote.ClassName,
        index or "?",
        foundRemote:GetFullName()
    )
    info.Parent = frame
    
    local codeLabel = Instance.new("TextLabel")
    codeLabel.Size = UDim2.new(0.9, 0, 0, 40)
    codeLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
    codeLabel.BackgroundTransparency = 1
    codeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    codeLabel.TextSize = 10
    codeLabel.Font = Enum.Font.Gotham
    codeLabel.Text = "local miningRemote = Functions:GetChildren()[INDEX]"
    codeLabel.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.8, 0, 0, 40)
    closeBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    closeBtn.Text = "CLOSE"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Main execution
print(string.rep("=", 60))
print("ADVANCED REMOTE DETECTOR")
print(string.rep("=", 60))

-- Choose detection method
local method = 4 -- Use brute force by default

print("\nChoose detection method:")
print("1 - Hook remotes (watch for game calls)")
print("2 - Trace function calls")
print("3 - Scan scripts for references")
print("4 - Brute force test (RECOMMENDED)")
print("5 - Hook game client")

-- For mobile, just use brute force
local workingRemote, remoteIndex = bruteForceFindMiningRemote()

if workingRemote then
    print("\n✅ SUCCESS! Found the working remote!")
    print("Remote Index in Functions folder:", remoteIndex)
    print("Remote Path:", workingRemote:GetFullName())
    
    -- Create GUI with results
    createResultsGUI(workingRemote, remoteIndex)
    
    -- Save the remote for later use
    _G.foundMiningRemote = workingRemote
    _G.miningRemoteIndex = remoteIndex
    
    print("\n💡 To use this remote in your miner:")
    print("local remote = ReplicatedStorage.Communication.Functions:GetChildren()[" .. remoteIndex .. "]")
    print("remote:InvokeServer(plot, asteroid)")
else
    print("\n❌ Brute force failed. Trying method 1 (remote hooking)...")
    hookRemotes()
    print("\nNow perform a mining action in-game manually!")
    print("The script will detect which remote gets called!")
end

print(string.rep("=", 60))
