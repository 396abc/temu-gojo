--[[
    200% Purple - ALL 6 ACCOUNTS COMBINE
    Back spinners merge, final accounts rise and dash
]]

if _G.moveActive then return end
_G.moveActive = true
_G.currentMove = "200PercentPurple"

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
local noclipConn = nil

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

-- Animation blocking for main
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

-- Noclip for final accounts
local function enableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    
    noclipConn = RunService.Stepped:Connect(function()
        if myChar then
            for _, child in pairs(myChar:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
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

-- MAIN ACCOUNT
if myRole == "Main" then
    print("[MAIN] Playing Hollow Purple at 0.4x speed")
    
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
            animTrack:AdjustSpeed(_G.PURPLE_200_SPEED)
        end
    end
    
    task.wait(12)
    
    _G.unblockAnimations()
    cleanupAnimation()
    _G.moveActive = false
    return
end

-- Start anti-fling for alts
_G.startAntiFling()
local myRoot = _G.getRoot(myChar)
initFlight(myRoot)

-- LEFT SPINNER (Front Left)
if myRole == "LeftSpinner" then
    currentOffset = Vector3.new(-5, 0, 2)
    setSpin(20, Vector3.new(1, 1, 0.8))
    
    while tick() - moveStartTime < 3 and _G.moveActive do
        local progress = (tick() - moveStartTime) / 3
        local currentX = -5 + (5 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, 2)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    cleanup()
    if myRoot then myRoot.CFrame = CFrame.new(0, 1000, 0) end
    _G.stopAntiFling()
    _G.moveActive = false
    return
end

-- RIGHT SPINNER (Front Right)
if myRole == "RightSpinner" then
    currentOffset = Vector3.new(5, 0, 2)
    setSpin(20, Vector3.new(1, 1, 0.8))
    
    while tick() - moveStartTime < 3 and _G.moveActive do
        local progress = (tick() - moveStartTime) / 3
        local currentX = 5 - (5 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, 2)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    cleanup()
    if myRoot then myRoot.CFrame = CFrame.new(0, 1000, 0) end
    _G.stopAntiFling()
    _G.moveActive = false
    return
end

-- BACK LEFT SPINNER
if myRole == "BackLeftSpinner" then
    currentOffset = Vector3.new(-4, 0, -8)
    setSpin(20, Vector3.new(1, 1, 0.5))
    
    while tick() - moveStartTime < 3 and _G.moveActive do
        local progress = (tick() - moveStartTime) / 3
        local currentX = -4 + (4 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, -8)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    cleanup()
    if myRoot then myRoot.CFrame = CFrame.new(0, 1000, 0) end
    _G.stopAntiFling()
    _G.moveActive = false
    return
end

-- BACK RIGHT SPINNER
if myRole == "BackRightSpinner" then
    currentOffset = Vector3.new(4, 0, -8)
    setSpin(20, Vector3.new(1, 1, 0.5))
    
    while tick() - moveStartTime < 3 and _G.moveActive do
        local progress = (tick() - moveStartTime) / 3
        local currentX = 4 - (4 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, -8)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    cleanup()
    if myRoot then myRoot.CFrame = CFrame.new(0, 1000, 0) end
    _G.stopAntiFling()
    _G.moveActive = false
    return
end

-- BACK FINAL APPEAR (Becomes RIGHT FRONT)
if myRole == "BackFinalAppear" then
    enableNoclip()
    
    -- Wait for Phase 1
    while tick() - moveStartTime < 3.5 and _G.moveActive do
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    currentOffset = Vector3.new(0, 0, -8)
    setSpin(20, Vector3.new(0.5, 1, 0.5))
    
    -- Phase 3: Rise up
    local startY = frozenY or mainHead.Position.Y
    
    while tick() - moveStartTime < 5 and _G.moveActive do
        local riseProgress = (tick() - moveStartTime - 3.5) / 1.5
        riseProgress = math.min(riseProgress, 1)
        frozenY = startY + (riseProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    -- Phase 4: Tween to RIGHT FRONT
    local startOffset = currentOffset
    local targetOffset = Vector3.new(3, 0, 2)
    
    while tick() - moveStartTime < 7 and _G.moveActive do
        local tweenProgress = (tick() - moveStartTime - 5) / 2
        tweenProgress = math.min(tweenProgress, 1)
        tweenProgress = tweenProgress < 0.5 and 2 * tweenProgress * tweenProgress or 1 - math.pow(-2 * tweenProgress + 2, 2) / 2
        
        currentOffset = startOffset:Lerp(targetOffset, tweenProgress)
        frozenY = startY + 10 - (tweenProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    -- Phase 5: Spin
    setSpin(30, Vector3.new(1, 1, 1))
    
    while tick() - moveStartTime < 9 and _G.moveActive do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    -- Phase 6: Dash
    setSpin(35, Vector3.new(1, 1, 1))
    local startDashOffset = currentOffset
    local targetDashOffset = Vector3.new(3, 0, 302)
    
    while tick() - moveStartTime < 11 and _G.moveActive do
        local dashProgress = (tick() - moveStartTime - 9) / 2
        dashProgress = math.min(dashProgress, 1)
        dashProgress = dashProgress < 0.5 and 2 * dashProgress * dashProgress or 1 - math.pow(-2 * dashProgress + 2, 2) / 2
        
        currentOffset = startDashOffset:Lerp(targetDashOffset, dashProgress)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    setSpin(0)
    cleanup()
    disableNoclip()
    
    if myRoot then
        myRoot.CFrame = CFrame.new(0, 1000, 0)
    end
    
    _G.stopAntiFling()
    _G.moveActive = false
    return
end

-- FINAL APPEAR (Becomes LEFT FRONT)
if myRole == "FinalAppear" then
    enableNoclip()
    
    -- Wait for Phase 1
    while tick() - moveStartTime < 3.5 and _G.moveActive do
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    currentOffset = Vector3.new(0, 0, 2)
    setSpin(20, Vector3.new(0.5, 1, 0.5))
    
    -- Phase 3: Rise up
    local startY = frozenY or mainHead.Position.Y
    
    while tick() - moveStartTime < 5 and _G.moveActive do
        local riseProgress = (tick() - moveStartTime - 3.5) / 1.5
        riseProgress = math.min(riseProgress, 1)
        frozenY = startY + (riseProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    -- Phase 4: Tween to LEFT FRONT
    local startOffset = currentOffset
    local targetOffset = Vector3.new(-3, 0, 2)
    
    while tick() - moveStartTime < 7 and _G.moveActive do
        local tweenProgress = (tick() - moveStartTime - 5) / 2
        tweenProgress = math.min(tweenProgress, 1)
        tweenProgress = tweenProgress < 0.5 and 2 * tweenProgress * tweenProgress or 1 - math.pow(-2 * tweenProgress + 2, 2) / 2
        
        currentOffset = startOffset:Lerp(targetOffset, tweenProgress)
        frozenY = startY + 10 - (tweenProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    -- Phase 5: Spin
    setSpin(30, Vector3.new(1, 1, 1))
    
    while tick() - moveStartTime < 9 and _G.moveActive do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not _G.moveActive then return end
    
    -- Phase 6: Dash
    setSpin(35, Vector3.new(1, 1, 1))
    local startDashOffset = currentOffset
    local targetDashOffset = Vector3.new(-3, 0, 302)
    
    while tick() - moveStartTime < 11 and _G.moveActive do
        local dashProgress = (tick() - moveStartTime - 9) / 2
        dashProgress = math.min(dashProgress, 1)
        dashProgress = dashProgress < 0.5 and 2 * dashProgress * dashProgress or 1 - math.pow(-2 * dashProgress + 2, 2) / 2
        
        currentOffset = startDashOffset:Lerp(targetDashOffset, dashProgress)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    setSpin(0)
    cleanup()
    disableNoclip()
    
    if myRoot then
        myRoot.CFrame = CFrame.new(0, 1000, 0)
    end
    
    _G.stopAntiFling()
    _G.moveActive = false
    return
end

print("[200% PURPLE] " .. myRole .. " complete")
