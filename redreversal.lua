--[[
    Red Reversal - LeftSpinner exclusive
    3 second spin then 300 stud dash
]]

if _G.moveActive then return end
_G.moveActive = true
_G.currentMove = "RedReversal"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local myRole = _G.ACCOUNT_ROLES[localPlayer.Name]

-- Verify role
if myRole ~= "LeftSpinner" then
    print("[RED] Not LeftSpinner, exiting")
    _G.moveActive = false
    return
end

-- State
local bp = nil
local bg = nil
local spinPhase = 0
local spinSpeed = 0
local spinAxis = Vector3.new(0,1,0)
local currentOffset = Vector3.zero
local frozenY = nil
local moveStartTime = tick()

-- Get main player
local mainPlayer = Players:FindFirstChild(_G.MAIN_USER_NAME)
if not mainPlayer then 
    print("[ERROR] Main not found")
    _G.moveActive = false
    return 
end

-- Wait for main character
local mainChar = mainPlayer.Character
for i = 1, 50 do
    if mainChar then break end
    task.wait(0.1)
    mainChar = mainPlayer.Character
end
if not mainChar then 
    print("[ERROR] Main char missing")
    _G.moveActive = false
    return 
end

local mainHead = _G.getHead(mainChar)

-- Get own character
local myChar = localPlayer.Character
for i = 1, 50 do
    if myChar then break end
    task.wait(0.1)
    myChar = localPlayer.Character
end
if not myChar then 
    print("[ERROR] Own char missing")
    _G.moveActive = false
    return 
end

local function initFlight(root)
    if not root then return end
    
    if bp then pcall(function() bp:Destroy() end) end
    if bg then pcall(function() bg:Destroy() end) end
    
    bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 20000
    bp.D = 500
    bp.Parent = root
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 20000
    bg.D = 500
    bg.Parent = root
    
    local hum = root.Parent:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end
    
    root.Anchored = false
end

local function setSpin(speed, axis)
    spinSpeed = speed
    spinAxis = axis or Vector3.new(0,1,0)
    spinPhase = 0
end

local function updatePosition(head, offset)
    if not bp or not _G.moveActive then return end
    
    local headPos = head.Position
    local headCF = head.CFrame
    
    if not frozenY then
        frozenY = headPos.Y
    end
    
    local targetPos = headPos + 
        headCF.LookVector * offset.Z +
        headCF.RightVector * offset.X
    
    targetPos = Vector3.new(targetPos.X, frozenY, targetPos.Z)
    
    bp.Position = targetPos
    bg.CFrame = CFrame.lookAt(bp.Position, bp.Position + headCF.LookVector)
    
    if spinSpeed > 0 then
        spinPhase = spinPhase + (spinSpeed * 0.05)
        bg.CFrame = bg.CFrame * CFrame.Angles(
            math.rad(spinPhase * 30 * spinAxis.X),
            math.rad(spinPhase * 30 * spinAxis.Y),
            math.rad(spinPhase * 30 * spinAxis.Z)
        )
    end
end

local function cleanup()
    if bp then pcall(function() bp:Destroy() end) bp = nil end
    if bg then pcall(function() bg:Destroy() end) bg = nil end
    
    if myChar then
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        end
    end
end

-- Start
_G.startAntiFling()

local myRoot = _G.getRoot(myChar)
initFlight(myRoot)

-- Phase 1: Spin in center for 3 seconds
currentOffset = Vector3.new(0, 0, 5)
setSpin(15, Vector3.new(1, 1, 0.8))

while tick() - moveStartTime < 3 and _G.moveActive do
    updatePosition(mainHead, currentOffset)
    RunService.Heartbeat:Wait()
end

-- Phase 2: Dash forward 300 studs
setSpin(20, Vector3.new(1, 1, 0.8))
local startOffset = currentOffset
local targetOffset = Vector3.new(0, 0, 305)

while tick() - moveStartTime < 4.8 and _G.moveActive do
    local alpha = (tick() - moveStartTime - 3) / 1.8
    alpha = math.min(alpha, 1)
    alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
    currentOffset = startOffset:Lerp(targetOffset, alpha)
    updatePosition(mainHead, currentOffset)
    RunService.Heartbeat:Wait()
end

-- Cleanup
setSpin(0)
cleanup()

if myRoot then
    myRoot.CFrame = CFrame.new(0, 1000, 0)
end

_G.stopAntiFling()
_G.moveActive = false

print("[RED REVERSAL] Complete")
