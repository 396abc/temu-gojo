--[[
    Blue Lapse - RightSpinner exclusive
    Orbiting behind left side
]]

if _G.moveActive then return end
_G.moveActive = true
_G.currentMove = "BlueLapse"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local myRole = _G.ACCOUNT_ROLES[localPlayer.Name]

-- Verify role
if myRole ~= "RightSpinner" then
    print("[BLUE] Not RightSpinner, exiting")
    _G.moveActive = false
    return
end

-- State
local bp = nil
local bg = nil
local spinPhase = 0
local spinSpeed = 0
local spinAxis = Vector3.new(0,1,0)
local frozenY = nil
local moveStartTime = tick()
local orbitAngle = 0

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

local function updateOrbitPosition(head, centerOffset, radius, angle, height)
    if not bp or not _G.moveActive then return end
    
    local headPos = head.Position
    local headCF = head.CFrame
    
    if not frozenY then
        frozenY = headPos.Y
    end
    
    local centerPos = headPos + 
        headCF.LookVector * centerOffset.Z +
        headCF.RightVector * centerOffset.X
    
    local orbitX = math.cos(angle) * radius
    local orbitZ = math.sin(angle) * radius
    
    local targetPos = Vector3.new(
        centerPos.X + orbitX,
        frozenY + height,
        centerPos.Z + orbitZ
    )
    
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

-- Phase 1: Initial position (2 seconds)
local centerOffset = Vector3.new(-4, 0, -5)
setSpin(10, Vector3.new(0, 1, 0))

while tick() - moveStartTime < 2 and _G.moveActive do
    local pos = mainHead.Position + 
        mainHead.CFrame.LookVector * -5 +
        mainHead.CFrame.RightVector * -4
    bp.Position = Vector3.new(pos.X, frozenY or mainHead.Position.Y, pos.Z)
    RunService.Heartbeat:Wait()
end

-- Phase 2: Orbiting (5 seconds)
local angle = 0

while tick() - moveStartTime < 7 and _G.moveActive do
    local elapsed = tick() - moveStartTime - 2
    local progress = elapsed / 5
    
    angle = angle + 0.4
    local radius = 4 + (progress * 20)
    local height = progress * 10
    
    updateOrbitPosition(mainHead, centerOffset, radius, angle, height)
    RunService.Heartbeat:Wait()
end

-- Instant reset
setSpin(0)
cleanup()

if myRoot then
    myRoot.CFrame = CFrame.new(0, 1000, 0)
    myRoot.Anchored = false
    myRoot.Velocity = Vector3.zero
    myRoot.RotVelocity = Vector3.zero
end

_G.stopAntiFling()
_G.moveActive = false

print("[BLUE LAPSE] Complete")
