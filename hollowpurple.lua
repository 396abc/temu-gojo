--[[
    Hollow Purple - Original technique
    Executes based on global role detection
]]

if _G.moveActive then return end
_G.moveActive = true
_G.currentMove = "HollowPurple"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local myRole = _G.ACCOUNT_ROLES[localPlayer.Name]

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

-- Animation blocking functions
local animTrack = nil
local blockAnimConn = nil
local animPlaying = false

local function blockOtherAnimations(humanoid)
    if blockAnimConn then
        blockAnimConn:Disconnect()
        blockAnimConn = nil
    end
    
    animPlaying = true
    
    blockAnimConn = humanoid.AnimationPlayed:Connect(function(playedTrack)
        if playedTrack ~= animTrack then
            pcall(function() playedTrack:Stop() end)
        end
    end)
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if track ~= animTrack then
                pcall(function() track:Stop() end)
            end
        end
    end
end

_G.unblockAnimations = function()
    if blockAnimConn then
        blockAnimConn:Disconnect()
        blockAnimConn = nil
    end
    animPlaying = false
end

local function cleanupAnimation()
    _G.unblockAnimations()
    if animTrack then
        pcall(function()
            if animTrack.IsPlaying then
                animTrack:Stop()
            end
            animTrack:Destroy()
        end)
        animTrack = nil
    end
end

-- MAIN ACCOUNT
if myRole == "Main" then
    print("[MAIN] Playing Hollow Purple animation")
    
    local humanoid = myChar:FindFirstChildOfClass("Humanoid")
    if humanoid then
        cleanupAnimation()
        blockOtherAnimations(humanoid)
        
        local anim = Instance.new("Animation")
        anim.AnimationId = _G.ANIMATION_ID
        
        local success, track = pcall(function()
            return humanoid:LoadAnimation(anim)
        end)
        
        if success and track then
            animTrack = track
            animTrack.Looped = false
            animTrack:Play()
            animTrack:AdjustSpeed(_G.HOLLOW_PURPLE_SPEED)
        end
    end
    
    task.wait(8)
    
    _G.unblockAnimations()
    cleanupAnimation()
    _G.moveActive = false
    return
end

-- ALT ACCOUNTS
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

-- Start anti-fling
_G.startAntiFling()

-- Initialize flight
local myRoot = _G.getRoot(myChar)
initFlight(myRoot)

-- SPINNERS
if myRole == "LeftSpinner" or myRole == "RightSpinner" then
    local dir = (myRole == "LeftSpinner") and -1 or 1
    
    currentOffset = Vector3.new(dir * 5, 0, 2)
    setSpin(15, Vector3.new(1, 1, 0.8))
    
    -- Phase 1: Initial spin
    while tick() - moveStartTime < 2 and _G.moveActive do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    -- Phase 2: Converge
    local startOffset = currentOffset
    local targetOffset = Vector3.new(0, 0, 10)
    
    while tick() - moveStartTime < 4.5 and _G.moveActive do
        local alpha = (tick() - moveStartTime - 2) / 2.5
        alpha = math.min(alpha, 1)
        alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
        currentOffset = startOffset:Lerp(targetOffset, alpha)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    setSpin(0)
    cleanup()
    
    -- Teleport away
    if myRoot then
        myRoot.CFrame = CFrame.new(0, 1000, 0)
    end
    
    _G.stopAntiFling()
    _G.moveActive = false

-- FINAL APPEAR
elseif myRole == "FinalAppear" then
    -- Wait for phase 1-2
    while tick() - moveStartTime < 4.5 and _G.moveActive do
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    currentOffset = Vector3.new(0, 0, 10)
    setSpin(18, Vector3.new(0.8, 1, 0.8))
    
    -- Phase 3: Hold
    while tick() - moveStartTime < 5.5 and _G.moveActive do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    -- Phase 4: Dash
    local startOffset = currentOffset
    local targetOffset = Vector3.new(0, 0, 310)
    
    while tick() - moveStartTime < 7.5 and _G.moveActive do
        local alpha = (tick() - moveStartTime - 5.5) / 2
        alpha = math.min(alpha, 1)
        alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
        currentOffset = startOffset:Lerp(targetOffset, alpha)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    setSpin(0)
    cleanup()
    
    -- Teleport away
    if myRoot then
        myRoot.CFrame = CFrame.new(0, 1000, 0)
    end
    
    _G.stopAntiFling()
    _G.moveActive = false
end

print("[HOLLOW PURPLE] " .. myRole .. " complete")
