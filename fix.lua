--[[
    UNIVERSAL FIX SCRIPT - execute on any account to reset
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

print("[FIX] Resetting " .. localPlayer.Name)

-- stop all movement
_G.active = false

-- destroy body movers
if _G.bp then pcall(function() _G.bp:Destroy() end) _G.bp = nil end
if _G.bg then pcall(function() _G.bg:Destroy() end) _G.bg = nil end

-- stop anti-fling
if _G.antiFlingConn then
    _G.antiFlingConn:Disconnect()
    _G.antiFlingConn = nil
end
_G.isAlreadyAntiFling = false

-- unblock animations
if localPlayer.Character then
    local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if _G.blockAnimConn then
            _G.blockAnimConn:Disconnect()
            _G.blockAnimConn = nil
        end
        if _G.animHeartbeatConn then
            _G.animHeartbeatConn:Disconnect()
            _G.animHeartbeatConn = nil
        end
        _G.animationPlaying = false
    end
end

-- clean up animation
if _G.animTrack then
    pcall(function()
        if _G.animTrack.IsPlaying then
            _G.animTrack:Stop()
        end
        _G.animTrack:Destroy()
    end)
    _G.animTrack = nil
end

-- reset character
local char = localPlayer.Character
if char then
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
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

print("[FIX] " .. localPlayer.Name .. " reset complete")
