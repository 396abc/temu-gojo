--[[
    MAIN ORCHESTRATOR - Execute this on main account only
    This sets up global role assignments and animation constants for all accounts
]]

local Players = game:GetService("Players")

-- CONFIGURATION - Change these to match your account usernames
_G.MAIN_USER_NAME = "hiUnineo"
_G.REPOSITORY_URL = "https://raw.githubusercontent.com/396abc/temu-gojo/refs/heads/main/"

-- Animation constants (global)
_G.ANIMATION_ID = "rbxassetid://109504559118350"  -- Hollow Purple
_G.RED_REVERSAL_ANIMATION_ID = "rbxassetid://117285946325983"  -- Red Reversal (flips upside down)
_G.BLUE_LAPSE_ANIMATION_ID = "rbxassetid://84375395270649"  -- Blue Lapse

-- Animation speeds
_G.HOLLOW_PURPLE_SPEED = 0.6      -- Hollow Purple at 0.6x speed
_G.RED_REVERSAL_SPEED = 1.2       -- Red Reversal at 1.2x speed
_G.BLUE_LAPSE_SPEED = 0.9          -- Blue Lapse at 0.9x speed
_G.PURPLE_200_SPEED = 0.4          -- 200% Purple at 0.4x speed

-- Account role assignments (global so all scripts can access)
_G.ACCOUNT_CONFIG = {
    ["hiUnineo"] = { role = "Main", order = 0 },
    ["hiUnineo1"] = { role = "LeftSpinner", order = 1 },
    ["hiUnineo2"] = { role = "RightSpinner", order = 2 },
    ["hiUnineo3"] = { role = "FinalAppear", order = 3 },
    ["HiUnineo4"] = { role = "BackLeftSpinner", order = 4 },  -- Note capital H
    ["hiUnineo5"] = { role = "BackRightSpinner", order = 5 },
    ["hiUnineo6"] = { role = "BackFinalAppear", order = 6 }
}

-- Export individual role references for direct checking
for username, config in pairs(_G.ACCOUNT_CONFIG) do
    _G[config.role] = username
end

print("=== MAIN ORCHESTRATOR LOADED ===")
print("Main User: " .. _G.MAIN_USER_NAME)
print("Animation Speeds - Hollow Purple: " .. _G.HOLLOW_PURPLE_SPEED .. "x | Red Reversal: " .. _G.RED_REVERSAL_SPEED .. "x | Blue Lapse: " .. _G.BLUE_LAPSE_SPEED .. "x | 200% Purple: " .. _G.PURPLE_200_SPEED .. "x")
print("Roles configured for all accounts")
print("Execute individual move scripts on alt accounts as needed")
