-- Simple Remote Finder for Rebirth & Upgrades
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteFinder"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 480)
mainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🎯 REMOTE FINDER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Hook Button
local hookBtn = Instance.new("TextButton")
hookBtn.Size = UDim2.new(0.9, 0, 0, 50)
hookBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
hookBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
hookBtn.Text = "🎣 START DETECTING"
hookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hookBtn.TextSize = 16
hookBtn.Font = Enum.Font.GothamBold
hookBtn.Parent = mainFrame

local hookCorner = Instance.new("UICorner")
hookCorner.CornerRadius = UDim.new(0, 8)
hookCorner.Parent = hookBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Not detecting\nPress START and perform actions"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Results Frame
local resultsFrame = Instance.new("Frame")
resultsFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
resultsFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
resultsFrame.BackgroundTransparency = 0.3
resultsFrame.BorderSizePixel = 0
resultsFrame.Parent = mainFrame

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 8)
resultsCorner.Parent = resultsFrame

local resultsList = Instance.new("ScrollingFrame")
resultsList.Size = UDim2.new(1, -10, 1, -10)
resultsList.Position = UDim2.new(0, 5, 0, 5)
resultsList.BackgroundTransparency = 1
resultsList.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsList.ScrollBarThickness = 4
resultsList.Parent = resultsFrame

-- Copy Buttons
local copyMiningBtn = Instance.new("TextButton")
copyMiningBtn.Size = UDim2.new(0.43, 0, 0, 35)
copyMiningBtn.Position = UDim2.new(0.05, 0, 0.93, 0)
copyMiningBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
copyMiningBtn.Text = "⛏️ COPY MINING"
copyMiningBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyMiningBtn.TextSize = 11
copyMiningBtn.Font = Enum.Font.GothamBold
copyMiningBtn.Parent = mainFrame

local copyMiningCorner = Instance.new("UICorner")
copyMiningCorner.CornerRadius = UDim.new(0, 6)
copyMiningCorner.Parent = copyMiningBtn

local copyRebirthBtn = Instance.new("TextButton")
copyRebirthBtn.Size = UDim2.new(0.43, 0, 0, 35)
copyRebirthBtn.Position = UDim2.new(0.52, 0, 0.93, 0)
copyRebirthBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
copyRebirthBtn.Text = "🔄 COPY REBIRTH"
copyRebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyRebirthBtn.TextSize = 11
copyRebirthBtn.Font = Enum.Font.GothamBold
copyRebirthBtn.Parent = mainFrame

local copyRebirthCorner = Instance.new("UICorner")
copyRebirthCorner.CornerRadius = UDim.new(0, 6)
copyRebirthCorner.Parent = copyRebirthBtn

-- Dragging
local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Store detected remotes
local detected = {
    mining = nil,
    rebirth = nil,
    upgrade = nil,
    miningArgs = nil,
    rebirthArgs = nil,
    upgradeArgs = nil
}

local logs = {}

local function addLog(text, color)
    table.insert(logs, {text = text, time = os.date("%H:%M:%S")})
    
    -- Update display
    for _, child in pairs(resultsList:GetChildren()) do
        child:Destroy()
    end
    
    local yOffset = 5
    for i, log in pairs(logs) do
        local logLabel = Instance.new("TextLabel")
        logLabel.Size = UDim2.new(1, -10, 0, 30)
        logLabel.Position = UDim2.new(0, 5, 0, yOffset)
        logLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        logLabel.BackgroundTransparency = 0.3
        logLabel.Text = "[" .. log.time .. "] " .. log.text
        logLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
        logLabel.TextSize = 10
        logLabel.Font = Enum.Font.Gotham
        logLabel.TextWrapped = true
        logLabel.TextXAlignment = Enum.TextXAlignment.Left
        logLabel.Parent = resultsList
        
        local logCorner = Instance.new("UICorner")
        logCorner.CornerRadius = UDim.new(0, 4)
        logCorner.Parent = logLabel
        
        yOffset = yOffset + 35
    end
    
    resultsList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- Hook system
local isHooking = false
local hookedRemotes = {}

local function startHooking()
    if isHooking then
        addLog("Already hooking!", Color3.fromRGB(255, 200, 100))
        return
    end
    
    addLog("Starting remote detection...", Color3.fromRGB(100, 255, 100))
    addLog("Now perform actions in-game:", Color3.fromRGB(255, 200, 100))
    addLog("  • Mine an asteroid", Color3.fromRGB(200, 200, 200))
    addLog("  • Rebirth", Color3.fromRGB(200, 200, 200))
    addLog("  • Upgrade field/equipment", Color3.fromRGB(200, 200, 200))
    
    local Communication = ReplicatedStorage:FindFirstChild("Communication")
    if not Communication then
        addLog("Communication not found!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local Functions = Communication:FindFirstChild("Functions")
    if not Functions then
        addLog("Functions not found!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Get all empty remotes
    local emptyRemotes = {}
    for _, child in pairs(Functions:GetChildren()) do
        if child.Name == "" and child:IsA("RemoteFunction") then
            table.insert(emptyRemotes, child)
        end
    end
    
    addLog("Found " .. #emptyRemotes .. " empty remote functions", Color3.fromRGB(100, 200, 255))
    
    -- Hook each remote
    for index, remote in pairs(emptyRemotes) do
        local originalInvoke = remote.InvokeServer
        
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local argsPreview = {}
            local detectedType = nil
            
            for i, arg in pairs(args) do
                if type(arg) == "string" then
                    local lowerArg = string.lower(arg)
                    table.insert(argsPreview, string.sub(arg, 1, 30))
                    
                    -- Detect by keyword
                    if string.find(lowerArg, "mine") or string.find(lowerArg, "ore") or string.find(lowerArg, "asteroid") then
                        detectedType = "mining"
                    elseif string.find(lowerArg, "rebirth") or string.find(lowerArg, "prestige") or string.find(lowerArg, "reset") then
                        detectedType = "rebirth"
                    elseif string.find(lowerArg, "upgrade") or string.find(lowerArg, "level") or string.find(lowerArg, "improve") then
                        detectedType = "upgrade"
                    end
                elseif typeof(arg) == "Instance" then
                    if arg.ClassName == "Folder" and string.match(arg.Name, "^{.*}$") then
                        detectedType = "mining"
                        table.insert(argsPreview, "[ASTEROID]")
                    else
                        table.insert(argsPreview, "[" .. arg.ClassName .. "]")
                    end
                elseif type(arg) == "number" then
                    table.insert(argsPreview, tostring(arg))
                    if arg > 0 and arg < 100 then
                        -- Could be level or upgrade value
                        if detectedType == nil then
                            detectedType = "upgrade"
                        end
                    end
                else
                    table.insert(argsPreview, tostring(arg))
                end
            end
            
            -- Check if this looks like mining
            if not detectedType then
                for i, arg in pairs(args) do
                    if type(arg) == "Instance" and arg:IsA("Folder") and arg.Parent and arg.Parent.Name == "Asteroids" then
                        detectedType = "mining"
                    end
                end
            end
            
            local logMsg = string.format("[#%d] %s(%s)", index, remote.ClassName, table.concat(argsPreview, ", "))
            
            if detectedType == "mining" then
                addLog("⛏️ MINING: " .. logMsg, Color3.fromRGB(100, 255, 100))
                detected.mining = index
                detected.miningArgs = argsPreview
            elseif detectedType == "rebirth" then
                addLog("🔄 REBIRTH: " .. logMsg, Color3.fromRGB(200, 100, 255))
                detected.rebirth = index
                detected.rebirthArgs = argsPreview
            elseif detectedType == "upgrade" then
                addLog("⬆️ UPGRADE: " .. logMsg, Color3.fromRGB(255, 200, 100))
                detected.upgrade = index
                detected.upgradeArgs = argsPreview
            else
                -- Still log but with normal color
                addLog(logMsg, Color3.fromRGB(150, 150, 150))
            end
            
            -- Update status
            statusLabel.Text = string.format(
                "Status: Detecting...\n🎯 Mining: %s\n🔄 Rebirth: %s\n⬆️ Upgrade: %s",
                detected.mining and "#" .. detected.mining or "?",
                detected.rebirth and "#" .. detected.rebirth or "?",
                detected.upgrade and "#" .. detected.upgrade or "?"
            )
            
            return originalInvoke(self, ...)
        end
    end
    
    isHooking = true
    hookBtn.Text = "🎣 DETECTING..."
    hookBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end

-- Copy functions
local function copyToClipboard(text, btn, originalText)
    local success = pcall(function()
        setclipboard(text)
    end)
    
    if success then
        local originalColor = btn.BackgroundColor3
        btn.Text = "✓ COPIED!"
        btn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        task.wait(1.5)
        btn.Text = originalText
        btn.BackgroundColor3 = originalColor
        addLog("Copied to clipboard!", Color3.fromRGB(100, 255, 100))
    else
        btn.Text = "❌ FAILED"
        task.wait(1.5)
        btn.Text = originalText
        addLog("Failed to copy!", Color3.fromRGB(255, 100, 100))
    end
end

copyMiningBtn.MouseButton1Click:Connect(function()
    if detected.mining then
        local code = string.format([[
-- MINING REMOTE (Index #%d)
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local miningRemote = Functions:GetChildren()[%d]

-- Usage:
local plot = workspace.Plots.Plot1
local asteroid = plot.Asteroids:GetChildren()[1]
miningRemote:InvokeServer(plot, asteroid)
]], detected.mining, detected.mining)
        copyToClipboard(code, copyMiningBtn, "⛏️ COPY MINING")
    else
        addLog("No mining remote detected yet!", Color3.fromRGB(255, 100, 100))
    end
end)

copyRebirthBtn.MouseButton1Click:Connect(function()
    if detected.rebirth then
        local code = string.format([[
-- REBIRTH REMOTE (Index #%d)
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local rebirthRemote = Functions:GetChildren()[%d]

-- Usage:
rebirthRemote:InvokeServer()  -- Try with or without arguments
-- Try: rebirthRemote:InvokeServer(true)
-- Or: rebirthRemote:InvokeServer("Rebirth")
]], detected.rebirth, detected.rebirth)
        copyToClipboard(code, copyRebirthBtn, "🔄 COPY REBIRTH")
    else
        addLog("No rebirth remote detected yet! Perform a rebirth action.", Color3.fromRGB(255, 100, 100))
    end
end)

-- Also add upgrade copy button
local copyUpgradeBtn = Instance.new("TextButton")
copyUpgradeBtn.Size = UDim2.new(0.43, 0, 0, 35)
copyUpgradeBtn.Position = UDim2.new(0.05, 0, 0.98, 0)
copyUpgradeBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
copyUpgradeBtn.Text = "⬆️ COPY UPGRADE"
copyUpgradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyUpgradeBtn.TextSize = 11
copyUpgradeBtn.Font = Enum.Font.GothamBold
copyUpgradeBtn.Parent = mainFrame

local copyUpgradeCorner = Instance.new("UICorner")
copyUpgradeCorner.CornerRadius = UDim.new(0, 6)
copyUpgradeCorner.Parent = copyUpgradeBtn

copyUpgradeBtn.MouseButton1Click:Connect(function()
    if detected.upgrade then
        local code = string.format([[
-- UPGRADE REMOTE (Index #%d)
local Functions = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Functions")
local upgradeRemote = Functions:GetChildren()[%d]

-- Usage (try different argument patterns):
upgradeRemote:InvokeServer()  -- No args
upgradeRemote:InvokeServer(1)  -- Level number
upgradeRemote:InvokeServer("upgrade")  -- String
upgradeRemote:InvokeServer(true)  -- Boolean
]], detected.upgrade, detected.upgrade)
        copyToClipboard(code, copyUpgradeBtn, "⬆️ COPY UPGRADE")
    else
        addLog("No upgrade remote detected yet! Perform an upgrade action.", Color3.fromRGB(255, 100, 100))
    end
end)

-- Adjust positions
copyMiningBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
copyRebirthBtn.Position = UDim2.new(0.52, 0, 0.92, 0)
copyUpgradeBtn.Position = UDim2.new(0.28, 0, 0.96, 0)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Start hooking automatically
task.wait(0.5)
startHooking()

print("=== REMOTE FINDER LOADED ===")
print("The script is now detecting remote calls")
print("Perform these actions in-game:")
print("  • Mine an asteroid")
print("  • Rebirth")
print("  • Upgrade your field/equipment")
print("The remotes will be detected and shown in the GUI")
