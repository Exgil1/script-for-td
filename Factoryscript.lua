-- Manual test - Find all Functions
local RS = game:GetService("ReplicatedStorage")
local Comm = RS:FindFirstChild("Communication")
if Comm then
    local Funcs = Comm:FindFirstChild("Functions")
    if Funcs then
        print("Functions folder found!")
        print("Number of children:", #Funcs:GetChildren())
        for i, child in pairs(Funcs:GetChildren()) do
            print(i, child.ClassName, child.Name == "" and "(EMPTY)" or child.Name)
        end
    end
end

-- Also check Events
local Events = Comm:FindFirstChild("Events")
if Events then
    print("\nEvents folder found!")
    print("Number of children:", #Events:GetChildren())
    for i, child in pairs(Events:GetChildren()) do
        print(i, child.ClassName, child.Name == "" and "(EMPTY)" or child.Name)
    end
end
