-- ⚠️ Requires Executor — Sonny's Gem Farmer
-- Green → Blue Gradient | Rounded Edges | On/Off Toggle | Draggable
-- Source: Your captured remote call + custom UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============ UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonysGemFarmer"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 130)
Main.Position = UDim2.new(0.02, 0, 0.72, 0)
Main.BackgroundColor3 = Color3.new(1,1,1)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

-- Green → Blue Gradient
local Gradient = Instance.new("UIGradient")
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 204, 113)),  -- Emerald Green
    ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 152, 219))   -- Sky Blue
}
Gradient.Parent = Main

-- Rounded Corners
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 18)
Corner.Parent = Main

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(255,255,255)
Border.Thickness = 1.2
Border.Transparency = 0.8
Border.Parent = Main

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "💎 Sonny's Gem Farmer"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.Parent = Main

-- Status Label
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 48)
Status.BackgroundTransparency = 1
Status.Text = "Ready — Tap to start"
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Main

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 42)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 75)
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

-- ============ FARMING LOGIC ============
local isRunning = false
local loopTask = nil

-- CONFIG — Remote from your captured call
local Remote = ReplicatedStorage:WaitForChild("Arcade"):WaitForChild("ArcadeSession")
local INTERVAL = 0.1 -- seconds between calls (don't go too low!)

local function Toggle()
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = "🟢 RUNNING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        Status.Text = "Farming — Tap to stop"
        
        loopTask = task.spawn(function()
            while isRunning do
                Remote:FireServer("quit", 80, 3)
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

print("[SonysGemFarmer] Loaded successfully")
