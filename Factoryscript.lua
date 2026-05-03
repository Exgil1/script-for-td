-- Simple Remote Scanner with Copy Logs Button
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteScanner"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title Bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BackgroundTransparency = 0.05
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 REMOTE SCANNER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Scan Button
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.8, 0, 0, 50)
scanBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
scanBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
scanBtn.Text = "🔍 START SCAN"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 16
scanBtn.Font = Enum.Font.GothamBold
scanBtn.Parent = mainFrame

local scanCorner = Instance.new("UICorner")
scanCorner.CornerRadius = UDim.new(0, 8)
scanCorner.Parent = scanBtn

-- Copy Button
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.8, 0, 0, 40)
copyBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
copyBtn.Text = "📋 COPY LOGS"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 14
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyBtn

-- Results Scrolling Frame
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(0.9, 0, 0.55, 0)
resultsFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
resultsFrame.BackgroundTransparency = 0.2
resultsFrame.BorderSizePixel = 0
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.ScrollBarThickness = 4
resultsFrame.Parent = mainFrame

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 8)
resultsCorner.Parent = resultsFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0.87, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

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

-- Scanner Function
local foundRemotes = {}
local logText = ""

local function deepScan(parent, depth)
    depth = depth or 0
    if depth > 15 then return end
    
    for _, child in pairs(parent:GetChildren()) do
        -- Check for RemoteFunction and RemoteEvent
        if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
            local remoteName = child.Name
            if remoteName == "" then
                remoteName = "(EMPTY STRING)"
            end
            
            table.insert(foundRemotes, {
                Name = remoteName,
                ClassName = child.ClassName,
                Path = child:GetFullName()
            })
        end
        
        -- Recursively scan
        pcall(function()
            deepScan(child, depth + 1)
        end)
    end
end

local function performScan()
    -- Clear previous results
    foundRemotes = {}
    for _, child in pairs(resultsFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    statusLabel.Text = "Scanning..."
    scanBtn.Text = "🔄 SCANNING..."
    scanBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    
    -- Perform scan
    task.wait()
    deepScan(ReplicatedStorage)
    deepScan(game:GetService("ReplicatedStorage"))
    
    -- Build log text
    logText = "=== REMOTE SCAN RESULTS ===\n"
    logText = logText .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    logText = logText .. "Total Remotes Found: " .. #foundRemotes .. "\n"
    logText = logText .. "===========================\n\n"
    
    -- Display results
    local yOffset = 5
    local resultCount = 0
    
    if #foundRemotes == 0 then
        local noResult = Instance.new("TextLabel")
        noResult.Size = UDim2.new(1, -10, 0, 40)
        noResult.Position = UDim2.new(0, 5, 0, yOffset)
        noResult.BackgroundTransparency = 1
        noResult.Text = "❌ No remotes found!"
        noResult.TextColor3 = Color3.fromRGB(255, 100, 100)
        noResult.TextSize = 12
        noResult.Font = Enum.Font.GothamBold
        noResult.Parent = resultsFrame
        yOffset = yOffset + 45
        logText = logText .. "No remotes found.\n"
    else
        for i, remote in pairs(foundRemotes) do
            local resultLabel = Instance.new("TextLabel")
            resultLabel.Size = UDim2.new(1, -10, 0, 35)
            resultLabel.Position = UDim2.new(0, 5, 0, yOffset)
            resultLabel.BackgroundTransparency = 1
            resultLabel.Text = string.format("%d. [%s] %s", i, remote.ClassName, remote.Name)
            resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            resultLabel.TextSize = 11
            resultLabel.Font = Enum.Font.Gotham
            resultLabel.TextXAlignment = Enum.TextXAlignment.Left
            resultLabel.Parent = resultsFrame
            
            -- Add path as smaller text
            local pathLabel = Instance.new("TextLabel")
            pathLabel.Size = UDim2.new(1, -10, 0, 20)
            pathLabel.Position = UDim2.new(0, 5, 0, yOffset + 18)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text = "📁 " .. remote.Path
            pathLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
            pathLabel.TextSize = 9
            pathLabel.Font = Enum.Font.Gotham
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.Parent = resultsFrame
            
            yOffset = yOffset + 42
            resultCount = resultCount + 1
            
            -- Add to log
            logText = logText .. string.format("%d. Name: %s\n", i, remote.Name)
            logText = logText .. string.format("   Type: %s\n", remote.ClassName)
            logText = logText .. string.format("   Path: %s\n\n", remote.Path)
        end
    end
    
    resultsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    
    statusLabel.Text = string.format("✅ Found %d remotes", resultCount)
    scanBtn.Text = "🔍 SCAN COMPLETE"
    scanBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    
    task.wait(2)
    scanBtn.Text = "🔍 START SCAN"
    scanBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
end

-- Copy function
copyBtn.MouseButton1Click:Connect(function()
    if logText == "" then
        statusLabel.Text = "⚠️ Scan first before copying!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
        task.wait(1.5)
        copyBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
        return
    end
    
    local success = pcall(function()
        setclipboard(logText)
    end)
    
    if success then
        copyBtn.Text = "✓ COPIED!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        statusLabel.Text = "✅ Logs copied to clipboard!"
        task.wait(1.5)
        copyBtn.Text = "📋 COPY LOGS"
        copyBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    else
        copyBtn.Text = "❌ FAILED"
        copyBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        statusLabel.Text = "❌ Failed to copy!"
        task.wait(1.5)
        copyBtn.Text = "📋 COPY LOGS"
        copyBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    end
end)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Auto scan on startup
task.wait(0.5)
performScan()

print("=== Remote Scanner Loaded ===")
print("Tap START SCAN to search for remotes")
print("Tap COPY LOGS to copy results")
