-- Sonny's Gem Farmer v6 — Full Clean Rewrite
-- ✅ Learned & rebuilt from the working original
-- ✅ Only OUR UI shows — no extra windows
-- ✅ All the original's hidden logic included

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ======================================
-- 🔍 LEARNED: The original's key logic
-- ======================================
-- 1. Finds the gem prompt ONCE and reuses it
-- 2. Disables the game's own autoplay GUI
-- 3. Clears session attributes every frame (bypasses cooldowns)
-- 4. Uses 4 parallel loops for reliability
-- 5. Report FIRST → Quit SECOND with correct values
-- 6. Adjusts prompt settings so it works from anywhere

-- ============ OUR UI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonysGemFarmer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 140)
Main.Position = UDim2.new(0.02, 0, 0.70, 0)
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
Count.Text = "Gems Collected: 0"
Count.TextColor3 = Color3.fromRGB(200, 255, 200)
Count.Font = Enum.Font.Gotham
Count.TextSize = 11
Count.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.75, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.125, 0, 0, 90)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleBtn.Text = "🔴 OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Main
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

-- ============ FARMING STATE ============
local State = {
    AutoFarmGems = false,
    TotalFarmedGems = 0
}

-- ============ SETUP — Hide game's autoplay GUI ============
task.spawn(function()
    task.wait(0.3)
    local oldGui = PlayerGui:FindFirstChild("ArcadeAutoplayGui")
    if oldGui then oldGui:Destroy() end -- Remove it entirely, not just hide
end)

-- ============ GET REMOTES ============
local Arcade = ReplicatedStorage:WaitForChild("Arcade")
local ArcadeReport = Arcade:WaitForChild("ArcadeReport")
local ArcadeSession = Arcade:WaitForChild("ArcadeSession")

-- ============ FIND GEM PROMPT (cache it once) ============
local gemPrompt = nil

local function FindGemPrompt()
    if gemPrompt then return gemPrompt end
    
    -- Search workspace first
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "Collect" then
            gemPrompt = descendant
            -- Make it work instantly from anywhere
            gemPrompt.HoldDuration = 0
            gemPrompt.MaxActivationDistance = math.huge
            gemPrompt.RequiresLineOfSight = false
            return gemPrompt
        end
    end
    
    -- Search entire game if not found in workspace
    for _, descendant in ipairs(game:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "Collect" then
            gemPrompt = descendant
            gemPrompt.HoldDuration = 0
            gemPrompt.MaxActivationDistance = math.huge
            gemPrompt.RequiresLineOfSight = false
            return gemPrompt
        end
    end
    
    return nil
end

-- ============ CLEAR SESSION COOLDOWNS ============
RunService.RenderStepped:Connect(function()
    if State.AutoFarmGems then
        -- Clear any session tracking attributes the game sets
        LocalPlayer:SetAttribute("ArcadeSessionStartTime", nil)
        LocalPlayer:SetAttribute("ArcadeLastQuitTime", nil)
        
        -- Also disable the game's built-in autoplay toggle if it exists
        local autoPlayToggle = PlayerGui:FindFirstChild("AutoPlayToggle", true)
        if autoPlayToggle and autoPlayToggle:IsA("GuiObject") then
            autoPlayToggle.Visible = false
        end
    end
end)

-- ============ FARMING LOOP ============
local function FarmingWorker()
    while State.AutoFarmGems do
        local prompt = FindGemPrompt()
        
        if prompt then
            -- Step 1: Fire the gem pickup
            if fireproximityprompt then
                fireproximityprompt(prompt, 0)
            else
                prompt:InputHoldBegin()
                task.wait(0.05)
                prompt:InputHoldEnd()
            end
            
            task.wait(0.08)
            
            -- Step 2: Report kills FIRST (correct order!)
            pcall(function()
                ArcadeReport:FireServer("kills", 40, 2)
            end)
            
            task.wait(0.05)
            
            -- Step 3: Quit session SECOND
            pcall(function()
                ArcadeSession:FireServer("quit", 1, 6240)
            end)
            
            -- Increment counter
            State.TotalFarmedGems += 2
            Count.Text = "Gems Collected: " .. State.TotalFarmedGems
        end
        
        task.wait(0.15)
    end
end

-- ============ TOGGLE ============
local runningWorkers = {}

ToggleBtn.MouseButton1Click:Connect(function()
    State.AutoFarmGems = not State.AutoFarmGems
    
    if State.AutoFarmGems then
        ToggleBtn.Text = "🟢 RUNNING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
        Status.Text = "Farming Gems..."
        gemPrompt = nil -- Reset prompt cache
        State.TotalFarmedGems = 0
        
        -- Start 4 parallel workers like original (more reliable!)
        for i = 1, 4 do
            runningWorkers[i] = task.spawn(FarmingWorker)
            task.wait(0.05)
        end
    else
        ToggleBtn.Text = "🔴 OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        Status.Text = "Stopped"
        -- Stop all workers on next loop check
        State.AutoFarmGems = false
    end
end)

print("💎 Sonny's Gem Farmer v6 Loaded — Clean Rewrite Complete")
print("✅ Original UI removed")
print("✅ All critical logic rebuilt and working")
