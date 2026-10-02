-- ⚠️ Requires Executor — Sonny's Gem Farmer
-- Features: Toggle On/Off, Green→Blue Gradient UI, Rounded Corners, Fast Repeat
-- WARNING: This spams a remote call rapidly. Use at your own risk.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============ UI SETUP ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonysGemFarmer"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 110)
MainFrame.Position = UDim2.new(0.02, 0, 0.75, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Green → Blue Gradient
local Gradient = Instance.new("UIGradient")
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 200, 85)),  -- Green
    ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 110, 230)) -- Blue
}
Gradient.Parent = MainFrame

-- Rounded Edges
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.85
Stroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "💎 Sonny's Gem Farmer"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.Text = "🔴 OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 15
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 12)
BtnCorner.Parent = ToggleBtn

-- ============ FARMING LOGIC ============
local isRunning = false
local connection = nil

-- CONFIG — update this to match your remote
local RemoteEvent = ReplicatedStorage:WaitForChild("Arcade"):WaitForChild("ArcadeSession")
local FARM_DELAY = 0.05 -- seconds between calls (adjust if needed)

local function ToggleFarming()
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = "🟢 RUNNING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
        
        connection = task.spawn(function()
            while isRunning do
                -- This is the call captured by SimpleSpy
                local args = {
                    [1] = "quit",
                    [2] = 80,
                    [3] = 3
                }
                RemoteEvent:FireServer(unpack(args))
                task.wait(FARM_DELAY)
            end
        end)
    else
        ToggleBtn.Text = "🔴 OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if connection then task.cancel(connection) end
    end
end

-- ============ CONNECTIONS ============
ToggleBtn.MouseButton1Click:Connect(ToggleFarming)

print("[SonysGemFarmer] Loaded — Tap button to start/stop")
