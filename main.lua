--[[
    MAIN ORCHESTRATOR - Execute this on main account only
    This sets up global role assignments for all accounts
]]

local Players = game:GetService("Players")

-- CONFIGURATION - Change these to match your account usernames
_G.MAIN_USER_NAME = "hiUnineo"
_G.REPOSITORY_URL = "https://raw.githubusercontent.com/396abc/temu-gojo/refs/heads/main/"

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

-- Animation constants (global)
_G.ANIMATION_ID = "rbxassetid://109504559118350"  -- Hollow Purple
_G.RED_REVERSAL_ANIMATION_ID = "rbxassetid://117285946325983"
_G.BLUE_LAPSE_ANIMATION_ID = "rbxassetid://84375395270649"

_G.PLAYBACK_SPEED = 0.6          -- Hollow Purple
_G.RED_REVERSAL_SPEED = 1.2      -- Red Reversal
_G.BLUE_LAPSE_SPEED = 0.9         -- Blue Lapse
_G.PURPLE_200_SPEED = 0.4         -- 200% Purple

print("=== MAIN ORCHESTRATOR LOADED ===")
print("Roles configured for all accounts")
print("Execute individual move scripts on alt accounts as needed")
