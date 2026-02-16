--[[
    200% PURPLE MOVE SCRIPT
    - ALL 6 ACCOUNTS COMBINE
    - Back spinners merge, front spinners merge
    - Final accounts rise, tween to front, then dash
    - Animation at 0.4x speed on main
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local MAIN_USER_NAME = "hiUnineo"

-- Animation constants
local ANIMATION_ID = "rbxassetid://109504559118350"
local PLAYBACK_SPEED = 0.4

-- Determine role from global variables
local myRole = nil
if _G.LeftSpinner == localPlayer then
    myRole = "LeftSpinner"
elseif _G.RightSpinner == localPlayer then
    myRole = "RightSpinner"
elseif _G.FinalAppear == localPlayer then
    myRole = "FinalAppear"
elseif _G.BackLeftSpinner == localPlayer then
    myRole = "BackLeftSpinner"
elseif _G.BackRightSpinner == localPlayer then
    myRole = "BackRightSpinner"
elseif _G.BackFinalAppear == localPlayer then
    myRole = "BackFinalAppear"
elseif localPlayer.Name == MAIN_USER_NAME then
    myRole = "Main"
else
    print("[200%] No role for " .. localPlayer.Name)
    return
end

print("[200%] " .. localPlayer.Name .. " role: " .. myRole)

-- State
local active = true
local bp = nil
local bg = nil
local spinPhase = 0
local spinSpeed = 0
local spinAxis = Vector3.new(0,1,0)
local currentOffset = Vector3.zero
local frozenY = nil
local moveStartTime = tick()

-- Animation state
local animTrack = nil
local blockAnimConn = nil
local animationPlaying = false
local animHeartbeatConn = nil

-- Anti-fling
local antiFlingConn = nil

local function startAntiFling()
    if antiFlingConn then return end
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
end

-- Animation functions
local function blockOtherAnimations(humanoid)
    if blockAnimConn then blockAnimConn:Disconnect() end
    animationPlaying = true
    
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

local function unblockAnimations(humanoid)
    if blockAnimConn then blockAnimConn:Disconnect() blockAnimConn = nil end
    if animHeartbeatConn then animHeartbeatConn:Disconnect() animHeartbeatConn = nil end
    animationPlaying = false
end

local function cleanupAnimation()
    if blockAnimConn then blockAnimConn:Disconnect() end
    if animHeartbeatConn then animHeartbeatConn:Disconnect() end
    if animTrack then
        pcall(function()
            if animTrack.IsPlaying then animTrack:Stop() end
            animTrack:Destroy()
        end)
        animTrack = nil
    end
    animationPlaying = false
end

local function playMainAnimation()
    if myRole ~= "Main" then return false end
    
    local char = localPlayer.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    cleanupAnimation()
    blockOtherAnimations(humanoid)
    
    local anim = Instance.new("Animation")
    anim.AnimationId = ANIMATION_ID
    
    local success, track = pcall(function() return humanoid:LoadAnimation(anim) end)
    if not success or not track then
        unblockAnimations(humanoid)
        return false
    end
    
    animTrack = track
    animTrack.Looped = false
    
    pcall(function()
        animTrack:Play()
        animTrack.TimePosition = 0
        animTrack:AdjustSpeed(PLAYBACK_SPEED)
    end)
    
    animHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not animTrack or not animTrack.IsPlaying then return end
        pcall(function()
            if math.abs(animTrack.Speed - PLAYBACK_SPEED) > 0.01 then
                animTrack:AdjustSpeed(PLAYBACK_SPEED)
            end
        end)
    end)
    
    return true
end

-- Utility functions
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function getHead(char)
    return char and (char:FindFirstChild("Head") or getRoot(char))
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

-- Main execution
local function execute()
    local mainPlayer = Players:FindFirstChild(MAIN_USER_NAME)
    if not mainPlayer then 
        print("[200%] Main not found")
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
        print("[200%] Main char missing") 
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
        print("[200%] Own char missing") 
        active = false 
        return 
    end

    -- MAIN ACCOUNT
    if myRole == "Main" then
        print("[MAIN] Playing Hollow Purple at 0.4x speed")
        playMainAnimation()
        
        task.wait(12)
        
        if localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                unblockAnimations(hum)
            end
        end
        
        active = false
        return
    end

    -- Start anti-fling for alts
    if myRole ~= "Main" then
        startAntiFling()
    end
    
    initFlight(getRoot(myChar))

    -- LEFT SPINNER (Front Left)
    if myRole == "LeftSpinner" then
        print("[LEFTSPINNER] Merging to center front")
        currentOffset = Vector3.new(-5, 0, 2)
        setSpin(20, Vector3.new(1, 1, 0.8))
        
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

    -- RIGHT SPINNER (Front Right)
    if myRole == "RightSpinner" then
        print("[RIGHTSPINNER] Merging to center front")
        currentOffset = Vector3.new(5, 0, 2)
        setSpin(20, Vector3.new(1, 1, 0.8))
        
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

    -- BACK LEFT SPINNER
    if myRole == "BackLeftSpinner" then
        print("[BACKLEFT] Merging to center back")
        currentOffset = Vector3.new(-4, 0, -8)
        setSpin(20, Vector3.new(1, 1, 0.5))
        
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

    -- BACK RIGHT SPINNER
    if myRole == "BackRightSpinner" then
        print("[BACKRIGHT] Merging to center back")
        currentOffset = Vector3.new(4, 0, -8)
        setSpin(20, Vector3.new(1, 1, 0.5))
        
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

    -- BACK FINAL APPEAR (Becomes RIGHT FRONT)
    if myRole == "BackFinalAppear" then
        -- Enable noclip
        local noclipConn = RunService.Stepped:Connect(function()
            if myChar then
                for _, child in pairs(myChar:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = false
                    end
                end
            end
        end)
        
        -- Wait for Phase 1 (spinners merging)
        while getTimeSinceStart() < 3.5 and active do
            RunService.Heartbeat:Wait()
        end
        
        if not active then return end
        
        currentOffset = Vector3.new(0, 0, -8)
        setSpin(20, Vector3.new(0.5, 1, 0.5))
        
        -- Phase 3: Rise up
        local startY = mainHead.Position.Y
        frozenY = startY
        
        while getTimeSinceStart() < 5 and active do
            local riseProgress = (getTimeSinceStart() - 3.5) / 1.5
            riseProgress = math.min(riseProgress, 1)
            frozenY = startY + (riseProgress * 10)
            updatePosition(mainHead, currentOffset)
            RunService.Heartbeat:Wait()
        end
        
        if not active then return end
        
        -- Phase 4: Tween to RIGHT FRONT (X = 3, Z = 2)
        local startOffset = currentOffset
        local targetOffset = Vector3.new(3, 0, 2)
        local startYPos = frozenY
        
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
        
        -- Phase 5: Spin together (increase spin)
        setSpin(30, Vector3.new(1, 1, 1))
        
        while getTimeSinceStart() < 9 and active do
            updatePosition(mainHead, currentOffset)
            RunService.Heartbeat:Wait()
        end
        
        if not active then return end
        
        -- Phase 6: Dash forward 300 studs
        setSpin(35, Vector3.new(1, 1, 1))
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
        
        if noclipConn then noclipConn:Disconnect() end
        
        if mainPlayer and mainPlayer.Character then
            local mainHum = mainPlayer.Character:FindFirstChildOfClass("Humanoid")
            if mainHum then
                unblockAnimations(mainHum)
            end
        end
        
        stopAntiFling()
        active = false
        return
    end

    -- FINAL APPEAR (Becomes LEFT FRONT)
    if myRole == "FinalAppear" then
        -- Enable noclip
        local noclipConn = RunService.Stepped:Connect(function()
            if myChar then
                for _, child in pairs(myChar:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = false
                    end
                end
            end
        end)
        
        -- Wait for Phase 1 (spinners merging)
        while getTimeSinceStart() < 3.5 and active do
            RunService.Heartbeat:Wait()
        end
        
        if not active then return end
        
        currentOffset = Vector3.new(0, 0, 2)
        setSpin(20, Vector3.new(0.5, 1, 0.5))
        
        -- Phase 3: Rise up
        local startY = mainHead.Position.Y
        frozenY = startY
        
        while getTimeSinceStart() < 5 and active do
            local riseProgress = (getTimeSinceStart() - 3.5) / 1.5
            riseProgress = math.min(riseProgress, 1)
            frozenY = startY + (riseProgress * 10)
            updatePosition(mainHead, currentOffset)
            RunService.Heartbeat:Wait()
        end
        
        if not active then return end
        
        -- Phase 4: Tween to LEFT FRONT (X = -3, Z = 2)
        local startOffset = currentOffset
        local targetOffset = Vector3.new(-3, 0, 2)
        local startYPos = frozenY
        
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
        
        -- Phase 5: Spin together (increase spin)
        setSpin(30, Vector3.new(1, 1, 1))
        
        while getTimeSinceStart() < 9 and active do
            updatePosition(mainHead, currentOffset)
            RunService.Heartbeat:Wait()
        end
        
        if not active then return end
        
        -- Phase 6: Dash forward 300 studs
        setSpin(35, Vector3.new(1, 1, 1))
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
        
        if noclipConn then noclipConn:Disconnect() end
        
        if mainPlayer and mainPlayer.Character then
            local mainHum = mainPlayer.Character:FindFirstChildOfClass("Humanoid")
            if mainHum then
                unblockAnimations(mainHum)
            end
        end
        
        stopAntiFling()
        active = false
        return
    end
end

-- Run the move
local success, err = pcall(execute)
if not success then
    print("[200%] Error: " .. tostring(err))
    active = false
    cleanup()
    stopAntiFling()
    cleanupAnimation()
end

while active do
    task.wait(0.1)
end

print("[200%] Move complete for " .. localPlayer.Name)
