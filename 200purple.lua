--[[
    200% PURPLE - for all 6 alt accounts
    execute this on accounts 1-6 when doing 200% Purple
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

-- Get role from global config
local myRole = _G.ACCOUNT_CONFIG and _G.ACCOUNT_CONFIG[localPlayer.Name]
if not myRole then
    print("[ERROR] No role defined for " .. localPlayer.Name)
    return
end

print("=== 200% PURPLE STARTED for " .. myRole.role .. " ===")

-- state
local active = true
local bp, bg = nil, nil
local spinPhase = 0
local spinSpeed = 0
local spinAxis = Vector3.new(0,1,0)
local currentOffset = Vector3.zero
local frozenY = nil
local moveStartTime = tick()

-- animation shi
local animTrack = nil
local blockAnimConn = nil
local animationPlaying = false
local animHeartbeatConn = nil

-- anti-fling
_G.isAlreadyAntiFling = _G.isAlreadyAntiFling or false
local antiFlingConn = nil

-- noclip
local Noclipping = nil
local noclipActive = false

-- ========== ANIMATION FUNCTIONS (Main account only) ==========
local function blockOtherAnimations(humanoid)
    if blockAnimConn then
        blockAnimConn:Disconnect()
        blockAnimConn = nil
    end
    
    animationPlaying = true
    
    blockAnimConn = humanoid.AnimationPlayed:Connect(function(playedTrack)
        if playedTrack ~= animTrack then
            pcall(function()
                playedTrack:Stop()
            end)
        end
    end)
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if track ~= animTrack then
                pcall(function()
                    track:Stop()
                end)
            end
        end
    end
end

local function unblockAnimations(humanoid)
    if blockAnimConn then
        blockAnimConn:Disconnect()
        blockAnimConn = nil
    end
    
    if animHeartbeatConn then
        animHeartbeatConn:Disconnect()
        animHeartbeatConn = nil
    end
    
    animationPlaying = false
end

local function cleanupAnimation()
    if blockAnimConn then
        blockAnimConn:Disconnect()
        blockAnimConn = nil
    end
    
    if animHeartbeatConn then
        animHeartbeatConn:Disconnect()
        animHeartbeatConn = nil
    end
    
    if animTrack then
        pcall(function()
            if animTrack.IsPlaying then
                animTrack:Stop()
            end
            animTrack:Destroy()
        end)
        animTrack = nil
    end
    
    animationPlaying = false
end

local function playPurple200Animation()
    --  play if this is the main account
    if myRole.role ~= "Main" then return false end
    
    print("[MAIN] Playing 200% Purple animation at 0.4x speed")
    
    local char = localPlayer.Character
    if not char then 
        print("[ANIM] No character")
        return false
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        print("[ANIM] No humanoid")
        return false
    end
    
    cleanupAnimation()
    
    blockOtherAnimations(humanoid)
    
    local anim = Instance.new("Animation")
    anim.AnimationId = _G.ANIMATION_ID
    
    local success, track = pcall(function()
        return humanoid:LoadAnimation(anim)
    end)
    
    if not success or not track then
        print("[ANIM] Failed to load animation")
        unblockAnimations(humanoid)
        return false
    end
    
    animTrack = track
    animTrack.Looped = false
    
    -- stop any other tracks
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, otherTrack in pairs(animator:GetPlayingAnimationTracks()) do
            if otherTrack ~= animTrack then
                pcall(function() otherTrack:Stop() end)
            end
        end
    end
    
    -- start playing
    pcall(function()
        animTrack:Play()
        animTrack.TimePosition = 0
        animTrack:AdjustSpeed(_G.PURPLE_200_SPEED)
    end)
    
    print("[MAIN] Animation started at " .. _G.PURPLE_200_SPEED .. "x speed")
    
    -- monitor animation speed
    animHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not animTrack or not animTrack.IsPlaying then return end
        
        pcall(function()
            if math.abs(animTrack.Speed - _G.PURPLE_200_SPEED) > 0.01 then
                animTrack:AdjustSpeed(_G.PURPLE_200_SPEED)
            end
        end)
    end)
    
    -- auto-unblock after animation duration
    task.spawn(function()
        task.wait(15) -- 200% Purple duration
        if animationPlaying and humanoid and humanoid.Parent then
            unblockAnimations(humanoid)
            print("[MAIN] Animation completed, unblocked")
        end
    end)
    
    return true
end

-- ========== UTILITY FUNCTIONS ==========
local function enableNoclip()
    if myRole.role ~= "FinalAppear" and myRole.role ~= "BackFinalAppear" then return end
    
    if noclipActive then return end
    noclipActive = true
    
    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
    end
    
    Noclipping = RunService.Stepped:Connect(function()
        if not noclipActive then return end
        if localPlayer.Character then
            for _, child in pairs(localPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true then
                    child.CanCollide = false
                end
            end
        end
    end)
    print("[" .. myRole.role .. "] Noclip Enabled")
end

local function disableNoclip()
    if myRole.role ~= "FinalAppear" and myRole.role ~= "BackFinalAppear" then return end
    
    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
    end
    noclipActive = false
    print("[" .. myRole.role .. "] Noclip Disabled")
end

local function startAntiFling()
    if _G.isAlreadyAntiFling then return end
    _G.isAlreadyAntiFling = true
    
    if antiFlingConn then
        antiFlingConn:Disconnect()
    end
    
    antiFlingConn = RunService.Stepped:Connect(function()
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

local function stopAntiFling()
    if antiFlingConn then
        antiFlingConn:Disconnect()
        antiFlingConn = nil
    end
    _G.isAlreadyAntiFling = false
end

local function getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function getHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or getRoot(char)
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

local function cleanup()
    if bp then pcall(function() bp:Destroy() end) bp = nil end
    if bg then pcall(function() bg:Destroy() end) bg = nil end
    
    if localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            hum.Sit = false
            hum.WalkSpeed = 16
        end
    end
end

local function setSpin(speed, axis)
    spinSpeed = speed
    spinAxis = axis or Vector3.new(0,1,0)
    spinPhase = 0
end

local function updatePosition(mainHead, offset)
    if not bp or not active then return end
    
    local headPos = mainHead.Position
    local headCF = mainHead.CFrame
    
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
        spinPhase = spinPhase + 0.05
        bg.CFrame = bg.CFrame * CFrame.Angles(
            spinPhase * spinSpeed * 0.05 * spinAxis.X,
            spinPhase * spinSpeed * 0.05 * spinAxis.Y,
            spinPhase * spinSpeed * 0.05 * spinAxis.Z
        )
    end
end

local function getTimeSinceStart()
    return tick() - moveStartTime
end

-- ========== MAIN EXECUTION ==========
local mainPlayer = Players:FindFirstChild(_G.MAIN_USER_NAME)
if not mainPlayer then 
    print("[ERROR] Main not found")
    active = false 
    return 
end

local mainChar = mainPlayer.Character
for _ = 1, 50 do
    if mainChar then break end
    task.wait(0.1)
    mainChar = mainPlayer.Character
end
if not mainChar then 
    print("[ERROR] Main char missing") 
    active = false 
    return 
end

local mainHead = getHead(mainChar)

local myChar = localPlayer.Character
for _ = 1, 50 do
    if myChar then break end
    task.wait(0.1)
    myChar = localPlayer.Character
end
if not myChar then 
    print("[ERROR] Own char missing") 
    active = false 
    return 
end

if myRole.role == "Main" then
    playPurple200Animation()
    active = false
    return
end

print("[WAIT] Waiting 0.7s for animation to load...")
task.wait(0.7)

-- alt movement
initFlight(getRoot(myChar))
startAntiFling()

moveStartTime = tick()

if myRole.role == "LeftSpinner" then
    print("[LEFTSPINNER] Merging to center front")
    currentOffset = Vector3.new(-5, 0, 2)
    setSpin(40, Vector3.new(1, 1, 0.8)) -- Increased from 20 to 40
    
    while getTimeSinceStart() < 3 and active do
        local progress = getTimeSinceStart() / 3
        local currentX = -5 + (5 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, 2)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    print("[LEFTSPINNER] Disappearing")
    cleanup()
    
    local root = getRoot(myChar)
    if root then
        root.CFrame = CFrame.new(0, 1000, 0)
    end
    active = false
    return
end

if myRole.role == "RightSpinner" then
    print("[RIGHTSPINNER] Merging to center front")
    currentOffset = Vector3.new(5, 0, 2)
    setSpin(40, Vector3.new(1, 1, 0.8))
    
    while getTimeSinceStart() < 3 and active do
        local progress = getTimeSinceStart() / 3
        local currentX = 5 - (5 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, 2)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    print("[RIGHTSPINNER] Disappearing")
    cleanup()
    
    local root = getRoot(myChar)
    if root then
        root.CFrame = CFrame.new(0, 1000, 0)
    end
    active = false
    return
end
if myRole.role == "BackLeftSpinner" then
    print("[BACKLEFT] Merging to center back")
    currentOffset = Vector3.new(-4, 0, -8)
    setSpin(40, Vector3.new(1, 1, 0.5)) 
    
    while getTimeSinceStart() < 3 and active do
        local progress = getTimeSinceStart() / 3
        local currentX = -4 + (4 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, -8)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    print("[BACKLEFT] Disappearing")
    cleanup()
    
    local root = getRoot(myChar)
    if root then
        root.CFrame = CFrame.new(0, 1000, 0)
    end
    active = false
    return
end

if myRole.role == "BackRightSpinner" then
    print("[BACKRIGHT] Merging to center back")
    currentOffset = Vector3.new(4, 0, -8)
    setSpin(40, Vector3.new(1, 1, 0.5)) 
    
    while getTimeSinceStart() < 3 and active do
        local progress = getTimeSinceStart() / 3
        local currentX = 4 - (4 * math.min(progress, 1))
        currentOffset = Vector3.new(currentX, 0, -8)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    print("[BACKRIGHT] Disappearing")
    cleanup()
    
    local root = getRoot(myChar)
    if root then
        root.CFrame = CFrame.new(0, 1000, 0)
    end
    active = false
    return
end

if myRole.role == "BackFinalAppear" then
    enableNoclip()
    
    while getTimeSinceStart() < 3.5 and active do
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    
    currentOffset = Vector3.new(0, 0, -8)
    setSpin(40, Vector3.new(0.5, 1, 0.5)) 
    

    local startY = frozenY or mainHead.Position.Y
    
    while getTimeSinceStart() < 5 and active do
        local riseProgress = (getTimeSinceStart() - 3.5) / 1.5
        riseProgress = math.min(riseProgress, 1)
        frozenY = startY + (riseProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    

    local startOffset = currentOffset
    local targetOffset = Vector3.new(3, 0, 2)
    
    while getTimeSinceStart() < 7 and active do
        local tweenProgress = (getTimeSinceStart() - 5) / 2
        tweenProgress = math.min(tweenProgress, 1)
        tweenProgress = tweenProgress < 0.5 and 2 * tweenProgress * tweenProgress or 1 - math.pow(-2 * tweenProgress + 2, 2) / 2
        
        currentOffset = startOffset:Lerp(targetOffset, tweenProgress)
        frozenY = startY + 10 - (tweenProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    

    setSpin(60, Vector3.new(1, 1, 1)) 
    
    while getTimeSinceStart() < 9 and active do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    

    setSpin(70, Vector3.new(1, 1, 1)) 
    local startDashOffset = currentOffset
    local targetDashOffset = Vector3.new(3, 0, 302)
    
    while getTimeSinceStart() < 11 and active do
        local dashProgress = (getTimeSinceStart() - 9) / 2
        dashProgress = math.min(dashProgress, 1)
        dashProgress = dashProgress < 0.5 and 2 * dashProgress * dashProgress or 1 - math.pow(-2 * dashProgress + 2, 2) / 2
        
        currentOffset = startDashOffset:Lerp(targetDashOffset, dashProgress)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    print("[BACKFINAL] Move complete")
    setSpin(0)
    cleanup()
    disableNoclip()
    stopAntiFling()
    active = false
    return
end


if myRole.role == "FinalAppear" then
    enableNoclip()
    

    while getTimeSinceStart() < 3.5 and active do
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    
    currentOffset = Vector3.new(0, 0, 2)
    setSpin(40, Vector3.new(0.5, 1, 0.5)) 
    

    local startY = frozenY or mainHead.Position.Y
    
    while getTimeSinceStart() < 5 and active do
        local riseProgress = (getTimeSinceStart() - 3.5) / 1.5
        riseProgress = math.min(riseProgress, 1)
        frozenY = startY + (riseProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    

    local startOffset = currentOffset
    local targetOffset = Vector3.new(-3, 0, 2)
    
    while getTimeSinceStart() < 7 and active do
        local tweenProgress = (getTimeSinceStart() - 5) / 2
        tweenProgress = math.min(tweenProgress, 1)
        tweenProgress = tweenProgress < 0.5 and 2 * tweenProgress * tweenProgress or 1 - math.pow(-2 * tweenProgress + 2, 2) / 2
        
        currentOffset = startOffset:Lerp(targetOffset, tweenProgress)
        frozenY = startY + 10 - (tweenProgress * 10)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    

    setSpin(60, Vector3.new(1, 1, 1)) 
    
    while getTimeSinceStart() < 9 and active do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end

    setSpin(70, Vector3.new(1, 1, 1)) 
    local startDashOffset = currentOffset
    local targetDashOffset = Vector3.new(-3, 0, 302)
    
    while getTimeSinceStart() < 11 and active do
        local dashProgress = (getTimeSinceStart() - 9) / 2
        dashProgress = math.min(dashProgress, 1)
        dashProgress = dashProgress < 0.5 and 2 * dashProgress * dashProgress or 1 - math.pow(-2 * dashProgress + 2, 2) / 2
        
        currentOffset = startDashOffset:Lerp(targetDashOffset, dashProgress)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    print("[FINAL] Move complete")
    setSpin(0)
    cleanup()
    disableNoclip()
    stopAntiFling()
    active = false
    return
end

print("[WARN] " .. myRole.role .. " not handled in 200% Purple")
active = false
