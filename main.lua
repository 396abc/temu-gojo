--[[
    Temu Gojo - Main Controller
    Executes on all accounts, creates GUI only on main
    Uses global variables for role detection
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer

-- GLOBAL CONFIGURATION (can be changed at any time)
_G.MAIN_USER_NAME = "hiUnineo"  -- Change this to your main account

_G.ACCOUNT_ROLES = {
    ["hiUnineo"] = "Main",
    ["hiUnineo1"] = "LeftSpinner",
    ["hiUnineo2"] = "RightSpinner", 
    ["hiUnineo3"] = "FinalAppear",
    ["HiUnineo4"] = "BackLeftSpinner",  -- Note capital H
    ["hiUnineo5"] = "BackRightSpinner",
    ["hiUnineo6"] = "BackFinalAppear"
}

-- GLOBAL ROLE VARIABLES (for other scripts to reference)
_G.LeftSpinner = nil
_G.RightSpinner = nil
_G.FinalAppear = nil
_G.BackLeftSpinner = nil
_G.BackRightSpinner = nil
_G.BackFinalAppear = nil
_G.Main = nil

-- Set global role variables based on this account
local myRole = _G.ACCOUNT_ROLES[localPlayer.Name]
if myRole then
    _G[myRole] = localPlayer
    print("[" .. localPlayer.Name .. "] Set as " .. myRole)
else
    print("[ERROR] No role for " .. localPlayer.Name)
    return
end

-- Base URL for loading scripts
_G.BASE_URL = "https://raw.githubusercontent.com/396abc/temu-gojo/refs/heads/main/"

-- Animation constants (global for all scripts)
_G.ANIMATION_ID = "rbxassetid://109504559118350"
_G.RED_REVERSAL_ANIMATION_ID = "rbxassetid://117285946325983"
_G.BLUE_LAPSE_ANIMATION_ID = "rbxassetid://84375395270649"
_G.HOLLOW_PURPLE_SPEED = 0.7
_G.RED_REVERSAL_SPEED = 1.2
_G.BLUE_LAPSE_SPEED = 0.9
_G.PURPLE_200_SPEED = 0.4

-- State flags (global for coordination)
_G.moveActive = false
_G.currentMove = nil

-- Utility functions (global for all scripts)
function _G.getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

function _G.getHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or _G.getRoot(char)
end

-- Load move scripts
function _G.loadMove(moveName)
    local scriptUrl = _G.BASE_URL .. moveName:lower():gsub(" ", "") .. ".lua"
    print("[LOADING] " .. scriptUrl)
    
    local success, result = pcall(function()
        return game:HttpGet(scriptUrl)
    end)
    
    if success and result then
        local func, err = loadstring(result)
        if func then
            func()
            print("[LOADED] " .. moveName)
        else
            warn("[ERROR] Failed to load " .. moveName .. ": " .. err)
        end
    else
        warn("[ERROR] Failed to fetch " .. moveName)
    end
end

-- Anti-fling system (global)
_G.isAlreadyAntiFling = _G.isAlreadyAntiFling or false
_G.antiFlingConn = nil

function _G.startAntiFling()
    if _G.isAlreadyAntiFling then return end
    
    _G.isAlreadyAntiFling = true
    
    if _G.antiFlingConn then
        _G.antiFlingConn:Disconnect()
    end
    
    _G.antiFlingConn = RunService.Stepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)
end

function _G.stopAntiFling()
    if _G.antiFlingConn then
        _G.antiFlingConn:Disconnect()
        _G.antiFlingConn = nil
    end
    _G.isAlreadyAntiFling = false
end

-- Fix function
_G.fixPerformance = function()
    print("[FIX] Resetting " .. localPlayer.Name)
    _G.moveActive = false
    
    if _G.bp then pcall(function() _G.bp:Destroy() end) _G.bp = nil end
    if _G.bg then pcall(function() _G.bg:Destroy() end) _G.bg = nil end
    
    _G.stopAntiFling()
    
    if _G.unblockAnimations then
        _G.unblockAnimations()
    end
    
    local char = localPlayer.Character
    if char then
        local root = _G.getRoot(char)
        if root then
            root.Anchored = false
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            hum.Sit = false
            hum.WalkSpeed = 16
        end
    end
    print("[FIX] Ready")
end

-- Anti-AFK for alts
if myRole ~= "Main" then
    local last = 0
    RunService.Heartbeat:Connect(function()
        if _G.moveActive then return end
        if tick() - last > 300 then
            last = tick()
            local key = Enum.KeyCode[string.char(65 + math.random(0,3))]
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end)
        end
    end)
end

-- Create GUI only on main account
if myRole == "Main" then
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TemuGojo"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 420)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.Text = "TEMU GOJO - MOVE CONTROLLER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 80, 0, 20)
    statusFrame.Position = UDim2.new(1, -90, 0, 5)
    statusFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    statusFrame.BackgroundTransparency = 0.2
    statusFrame.Parent = title
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "READY"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextSize = 10
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = statusFrame
    
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -40)
    container.Position = UDim2.new(0, 10, 0, 35)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container
    
    local moves = {
        {name = "Hollow Purple", color = Color3.fromRGB(147, 112, 219), desc = "Original technique"},
        {name = "Red Reversal", color = Color3.fromRGB(255, 68, 68), desc = "LeftSpinner - 3s spin then dash"},
        {name = "Blue Lapse", color = Color3.fromRGB(68, 68, 255), desc = "RightSpinner - Orbiting behind"},
        {name = "200% Purple", color = Color3.fromRGB(255, 128, 255), desc = "ALL 6 ACCOUNTS COMBINE"}
    }
    
    for _, moveData in ipairs(moves) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 60)
        button.BackgroundColor3 = moveData.color
        button.BackgroundTransparency = 0.3
        button.Text = ""
        button.Parent = container
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = button
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -20, 0, 20)
        nameLabel.Position = UDim2.new(0, 10, 0, 8)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = moveData.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = button
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -20, 0, 20)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = moveData.desc
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        descLabel.TextSize = 10
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = button
        
        button.MouseButton1Click:Connect(function()
            if _G.moveActive then
                statusFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                statusText.Text = "BUSY"
                task.wait(1)
                statusFrame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                statusText.Text = "ACTIVE"
                return
            end
            
            statusFrame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            statusText.Text = "ACTIVE"
            
            _G.loadMove(moveData.name)
            
            task.wait(15) -- Max move duration
            
            statusFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "READY"
        end)
    end
    
    mainFrame.Parent = screenGui
    print("[GUI] Created")
end

print("=== MAIN CONTROLLER LOADED ===")
print("Role: " .. myRole)
print("Account: " .. localPlayer.Name)
