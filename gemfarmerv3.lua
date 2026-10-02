-- Sonny's Gem Farmer v3
-- Fires ArcadeSession + ArcadeReport together each cycle

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonysGemFarmer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 125)
Main.Position = UDim2.new(0.02, 0, 0.72, 0)
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

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "💎 Sonny's Gem Farmer"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 18)
Status.Position = UDim2.new(0, 0, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Main

local Count = Instance.new("TextLabel")
Count.Size = UDim2.new(1, 0, 0, 18)
Count.Position = UDim2.new(0, 0, 0, 58)
Count.BackgroundTransparency = 1
Count.Text = "Cycles: 0"
Count.TextColor3 = Color3.fromRGB(200, 255, 200)
Count.Font = Enum.Font.Gotham
Count.TextSize = 11
Count.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.75, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.125, 0, 0, 80)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleBtn.Text = "🔴 OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Main
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

-- The two correct remotes
local ArcadeSession = ReplicatedStorage.Arcade.ArcadeSession
local ArcadeReport = ReplicatedStorage.Arcade.ArcadeReport

local running = false
local loop = nil
local cycles = 0
local delay = 0.3

local function Toggle()
    running = not running
    if running then
        ToggleBtn.Text = "🟢 RUNNING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
        Status.Text = "Working..."
        cycles = 0
        loop = task.spawn(function()
            while running do
                -- Remote 1: quit session
                pcall(function()
                    ArcadeSession:FireServer("quit", 1, 6240)
                end)
                -- Remote 2: report kills
                pcall(function()
                    ArcadeReport:FireServer("kills", 40, 2)
                end)
                cycles += 1
                Count.Text = "Cycles: " .. cycles
                task.wait(delay)
            end
        end)
    else
        ToggleBtn.Text = "🔴 OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Status.Text = "Stopped"
        if loop then task.cancel(loop) end
    end
end

ToggleBtn.MouseButton1Click:Connect(Toggle)
print("SonysGemFarmer v3 loaded")
