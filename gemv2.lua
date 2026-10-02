-- ⚠️ Requires Executor — Sonny's Gem Farmer v2
-- Fires BOTH remotes together in a rapid loop: Report + Session
-- Green→Blue Gradient | Rounded Corners | On/Off Toggle | Draggable

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonysGemFarmer"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 140)
Main.Position = UDim2.new(0.02, 0, 0.70, 0)
Main.BackgroundColor3 = Color3.new(1,1,1)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Gradient = Instance.new("UIGradient")
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 204, 113)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 152, 219))
}
Gradient.Parent = Main

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 18)
Corner.Parent = Main

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(255,255,255)
Border.Thickness = 1.2
Border.Transparency = 0.8
Border.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "💎 Sonny's Gem Farmer"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 45)
Status.BackgroundTransparency = 1
Status.Text = "Ready — Tap to start"
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Main

local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(1, 0, 0, 18)
CountLabel.Position = UDim2.new(0, 0, 0, 62)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "Cycles: 0"
CountLabel.TextColor3 = Color3.fromRGB(220, 255, 220)
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 11
CountLabel.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 42)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 88)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.Text = "🔴 OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 15
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Main

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 12)
BtnCorner.Parent = ToggleBtn

-- ============ REMOTES ============
local ClassSystem = ReplicatedStorage:WaitForChild("ClassSystem")
local RollClass = ClassSystem:WaitForChild("RollClass")          -- Report remote
local Arcade = ReplicatedStorage:WaitForChild("Arcade")
local ArcadeSession = Arcade:WaitForChild("ArcadeSession")        -- Session remote

local INTERVAL = 0.1  -- seconds per cycle (both remotes fire each cycle)
local isRunning = false
local loopTask = nil
local cycleCount = 0

local function Toggle()
    isRunning = not isRunning

    if isRunning then
        ToggleBtn.Text = "🟢 RUNNING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        Status.Text = "Farming — Tap to stop"
        cycleCount = 0

        loopTask = task.spawn(function()
            while isRunning do
                -- Remote 1: Report (InvokeServer)
                pcall(function()
                    RollClass:InvokeServer()
                end)

                -- Remote 2: Session (FireServer)
                pcall(function()
                    ArcadeSession:FireServer("quit", 1, 6240)
                end)

                cycleCount += 1
                CountLabel.Text = "Cycles: " .. tostring(cycleCount)
                task.wait(INTERVAL)
            end
        end)
    else
        ToggleBtn.Text = "🔴 OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Status.Text = "Stopped — Tap to start"
        if loopTask then task.cancel(loopTask) end
    end
end

ToggleBtn.MouseButton1Click:Connect(Toggle)
print("[SonysGemFarmer v2] Loaded — dual remote loop ready")
