--[[
    HOLLOW PURPLE - For LeftSpinner, RightSpinner, FinalAppear
    Execute this on alt accounts when performing Hollow Purple
    Animation only plays on main account
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

-- Only run if this account is part of Hollow Purple
if myRole.role ~= "LeftSpinner" and myRole.role ~= "RightSpinner" and myRole.role ~= "FinalAppear" and myRole.role ~= "Main" then
    print("[SKIP] " .. myRole.role .. " not used in Hollow Purple")
    return
end

print("=== HOLLOW PURPLE STARTED for " .. myRole.role .. " ===")

-- State
local active = true
local bp, bg = nil, nil
local spinPhase = 0
local spinSpeed = 0
local spinAxis = Vector3.new(0,1,0)
local currentOffset = Vector3.zero
local frozenY = nil
local moveStartTime = tick()

-- Animation state (only used for main account)
local animTrack = nil
local blockAnimConn = nil
local animationPlaying = false
local animHeartbeatConn = nil

-- Anti-fling
_G.isAlreadyAntiFling = _G.isAlreadyAntiFling or false
local antiFlingConn = nil

-- Noclip for FinalAppear
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

local function playMainAnimation()
    -- ONLY play if this is the main account
    if myRole.role ~= "Main" then return false end
    
    print("[MAIN] Playing Hollow Purple animation")
    
    -- NO DELAY - Play animation immediately
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
    
    -- Clean up any existing animation
    cleanupAnimation()
    
    -- Block all other animations
    blockOtherAnimations(humanoid)
    
    -- Load animation
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
    
    -- Stop any other tracks
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, otherTrack in pairs(animator:GetPlayingAnimationTracks()) do
            if otherTrack ~= animTrack then
                pcall(function() otherTrack:Stop() end)
            end
        end
    end
    
    -- Start playing
    pcall(function()
        animTrack:Play()
        animTrack.TimePosition = 0
        animTrack:AdjustSpeed(_G.PLAYBACK_SPEED)
    end)
    
    print("[MAIN] Animation started at " .. _G.PLAYBACK_SPEED .. "x speed")
    
    -- Monitor animation speed
    animHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not animTrack or not animTrack.IsPlaying then return end
        
        pcall(function()
            if math.abs(animTrack.Speed - _G.PLAYBACK_SPEED) > 0.01 then
                animTrack:AdjustSpeed(_G.PLAYBACK_SPEED)
            end
        end)
    end)
    
    -- Auto-unblock after animation duration
    task.spawn(function()
        task.wait(8) -- Hollow Purple duration
        if animationPlaying and humanoid and humanoid.Parent then
            unblockAnimations(humanoid)
            print("[MAIN] Animation completed, unblocked")
        end
    end)
    
    return true
end

-- ========== UTILITY FUNCTIONS ==========
local function enableNoclip()
    if myRole.role ~= "FinalAppear" then return end
    
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
    print("[FINALAPPEAR] Noclip Enabled")
end

local function disableNoclip()
    if myRole.role ~= "FinalAppear" then return end
    
    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
    end
    noclipActive = false
    print("[FINALAPPEAR] Noclip Disabled")
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
        spinPhase = spinPhase + (spinSpeed * 0.05)
        bg.CFrame = bg.CFrame * CFrame.Angles(
            math.rad(spinPhase * 30 * spinAxis.X),
            math.rad(spinPhase * 30 * spinAxis.Y),
            math.rad(spinPhase * 30 * spinAxis.Z)
        )
    end
end

local function getTimeSinceStart()
    return tick() - moveStartTime
end

-- ========== MAIN EXECUTION ==========
-- PLAY ANIMATION ON MAIN ACCOUNT ONLY (NO DELAY)
if myRole.role == "Main" then
    playMainAnimation()
    active = false
    return
end

-- ALT ACCOUNTS - ADD 0.7 SECOND DELAY BEFORE MOVEMENT
print("[WAIT] Waiting 0.7s for animation to load...")
task.wait(0.7)

-- ALT ACCOUNTS MOVEMENT LOGIC
local mainPlayer = Players:FindFirstChild(_G.MAIN_USER_NAME)
if not mainPlayer then print("[ERROR] Main not found") return end

local mainChar = mainPlayer.Character
for _ = 1, 50 do
    if mainChar then break end
    task.wait(0.1)
    mainChar = mainPlayer.Character
end
if not mainChar then print("[ERROR] Main char missing") return end

local mainHead = getHead(mainChar)

local myChar = localPlayer.Character
for _ = 1, 50 do
    if myChar then break end
    task.wait(0.1)
    myChar = localPlayer.Character
end
if not myChar then print("[ERROR] Own char missing") return end

startAntiFling()
initFlight(getRoot(myChar))

-- Reset moveStartTime AFTER the 0.7s delay to ensure proper timing
moveStartTime = tick()

-- ROLE-SPECIFIC LOGIC
if myRole.role == "LeftSpinner" or myRole.role == "RightSpinner" then
    local dir = (myRole.role == "LeftSpinner") and -1 or 1
    
    currentOffset = Vector3.new(dir * 5, 0, 2)
    setSpin(15, Vector3.new(1, 1, 0.8))
    
    -- Phase 1: Track head
    while getTimeSinceStart() < 2 and active do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    -- Phase 2: Converge
    local startOffset = currentOffset
    local targetOffset = Vector3.new(0, 0, 10)
    
    while getTimeSinceStart() < 4.5 and active do
        local alpha = (getTimeSinceStart() - 2) / 2.5
        alpha = math.min(alpha, 1)
        alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
        currentOffset = startOffset:Lerp(targetOffset, alpha)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    setSpin(0)
    cleanup()
    
    -- Teleport away
    local root = getRoot(myChar)
    if root then
        root.CFrame = CFrame.new(0, 1000, 0)
    end
    
    stopAntiFling()
    print("[DONE] " .. myRole.role .. " finished")

elseif myRole.role == "FinalAppear" then
    enableNoclip()
    
    -- Wait for Phase 1-2 (accounting for the 0.7s delay)
    while getTimeSinceStart() < 4.5 and active do
        RunService.Heartbeat:Wait()
    end
    
    if not active then return end
    
    currentOffset = Vector3.new(0, 0, 10)
    setSpin(18, Vector3.new(0.8, 1, 0.8))
    
    -- Phase 3: Hold position briefly
    while getTimeSinceStart() < 5.5 and active do
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    -- Phase 4: Dash
    local startOffset = currentOffset
    local targetOffset = Vector3.new(0, 0, 310)
    
    while getTimeSinceStart() < 7.5 and active do
        local alpha = (getTimeSinceStart() - 5.5) / 2
        alpha = math.min(alpha, 1)
        alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
        currentOffset = startOffset:Lerp(targetOffset, alpha)
        updatePosition(mainHead, currentOffset)
        RunService.Heartbeat:Wait()
    end
    
    setSpin(0)
    cleanup()
    disableNoclip()
    stopAntiFling()
    print("[DONE] FinalAppear finished")
end

active = false
