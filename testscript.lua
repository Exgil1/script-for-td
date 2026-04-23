pcall(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveDebug"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(255, 255, 0)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "WAVE DEBUG - FINDING SOURCE"
title.TextColor3 = Color3.new(255, 255, 0)
title.BackgroundColor3 = Color3.new(50, 50, 50)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local waveDisplay = Instance.new("TextLabel")
waveDisplay.Size = UDim2.new(1, 0, 0, 50)
waveDisplay.Position = UDim2.new(0, 0, 0, 50)
waveDisplay.Text = "Current Wave: ???"
waveDisplay.TextColor3 = Color3.new(0, 255, 0)
waveDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
waveDisplay.TextSize = 24
waveDisplay.Font = Enum.Font.SourceSansBold
waveDisplay.Parent = mainFrame

local debugScroll = Instance.new("ScrollingFrame")
debugScroll.Size = UDim2.new(1, 0, 0, 350)
debugScroll.Position = UDim2.new(0, 0, 0, 110)
debugScroll.BackgroundColor3 = Color3.new(20, 20, 20)
debugScroll.Parent = mainFrame

local debugList = Instance.new("UIListLayout")
debugList.Parent = debugScroll
debugList.Padding = UDim.new(0, 2)

local debugContent = Instance.new("Frame")
debugContent.Size = UDim2.new(1, 0, 0, 0)
debugContent.BackgroundTransparency = 1
debugContent.Parent = debugScroll

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 40)
copyBtn.Position = UDim2.new(0.05, 0, 0, 470)
copyBtn.Text = "COPY DEBUG INFO"
copyBtn.BackgroundColor3 = Color3.new(0, 0, 150)
copyBtn.TextColor3 = Color3.new(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.Parent = mainFrame

local foundElements = {}
local currentWave = 0

local function addDebug(text, color)
    color = color or Color3.new(200, 200, 200)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Text = text
    label.TextColor3 = color
    label.BackgroundTransparency = 1
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = debugContent
    
    table.insert(foundElements, text)
    
    task.wait()
    debugScroll.CanvasPosition = Vector2.new(0, 0)
    debugScroll.CanvasSize = UDim2.new(0, 0, 0, #debugContent:GetChildren() * 20)
end

-- SCAN ALL UI ELEMENTS FOR WAVE NUMBERS
local function scanAllUI()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        addDebug("No PlayerGui found!", Color3.new(255, 0, 0))
        return 
    end
    
    addDebug("=== SCANNING UI FOR WAVE NUMBERS ===", Color3.new(255, 255, 0))
    
    local function scan(instance, path)
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then
            local text = instance.Text or ""
            -- Look for numbers in the text
            local numbers = {}
            for num in string.gmatch(text, "(%d+)") do
                table.insert(numbers, tonumber(num))
            end
            
            if #numbers > 0 then
                local info = string.format("[%s] Name: '%s' | Text: '%s' | Numbers: %s", 
                    instance.ClassName, 
                    instance.Name, 
                    text:sub(1, 30),
                    table.concat(numbers, ", "))
                addDebug(info, Color3.new(100, 255, 100))
                
                -- If this looks like a wave display (contains 2-3 digit numbers)
                for _, num in ipairs(numbers) do
                    if num > 0 and num < 500 then
                        addDebug("  -> Possible wave: " .. num, Color3.new(255, 255, 0))
                        -- Update display with this number
                        if num ~= currentWave then
                            currentWave = num
                            waveDisplay.Text = "Current Wave: " .. num
                        end
                    end
                end
            end
        end
        
        for _, child in pairs(instance:GetChildren()) do
            scan(child, path .. "/" .. child.Name)
        end
    end
    
    scan(playerGui, "PlayerGui")
    addDebug("=== SCAN COMPLETE ===", Color3.new(255, 255, 0))
end

-- Continuous monitoring
spawn(function()
    while true do
        scanAllUI()
        wait(3) -- Scan every 3 seconds
    end
end)

copyBtn.MouseButton1Click:Connect(function()
    local data = "WAVE DEBUG INFO\n"
    data = data .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    data = data .. "Current Detected Wave: " .. currentWave .. "\n"
    data = data .. "--------------------\n"
    for i, line in ipairs(foundElements) do
        data = data .. line .. "\n"
    end
    pcall(function()
        setclipboard(data)
        addDebug("Copied to clipboard!", Color3.new(0, 255, 0))
    end)
end)

end)
