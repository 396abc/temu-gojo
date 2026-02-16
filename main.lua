--[[
    Temu-Gojo Main Controller
    Global configuration for all accounts
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer

-- GLOBAL CONFIGURATION - Change these as needed
_G.MAIN_USER_NAME = "hiUnineo"  -- Change this to your main account

_G.ACCOUNT_CONFIG = {
    ["hiUnineo"] = { role = "Main", order = 0 },
    ["hiUnineo1"] = { role = "LeftSpinner", order = 1 },
    ["hiUnineo2"] = { role = "RightSpinner", order = 2 },
    ["hiUnineo3"] = { role = "FinalAppear", order = 3 },
    ["HiUnineo4"] = { role = "BackLeftSpinner", order = 4 },
    ["hiUnineo5"] = { role = "BackRightSpinner", order = 5 },
    ["hiUnineo6"] = { role = "BackFinalAppear", order = 6 }
}

-- Base repository URL
_G.BASE_URL = "https://raw.githubusercontent.com/396abc/temu-gojo/refs/heads/main/"

-- Role global variables for easy access
for accountName, config in pairs(_G.ACCOUNT_CONFIG) do
    _G[config.role] = config.role
end

-- Animation constants
_G.ANIMATION_ID = "rbxassetid://109504559118350"
_G.RED_REVERSAL_ANIMATION_ID = "rbxassetid://117285946325983"
_G.BLUE_LAPSE_ANIMATION_ID = "rbxassetid://84375395270649"

-- Move definitions for GUI
_G.MOVES = {
    ["Hollow Purple"] = {
        name = "Hollow Purple",
        description = "Original technique - 0.6x speed",
        color = Color3.fromRGB(147, 112, 219),
        gradient = {Color3.fromRGB(138, 43, 226), Color3.fromRGB(75, 0, 130)},
        duration = 8,
        filename = "hollow_purple.lua"
    },
    ["Red Reversal"] = {
        name = "Red Reversal",
        description = "LeftSpinner - 3s spin then dash",
        color = Color3.fromRGB(255, 68, 68),
        gradient = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(139, 0, 0)},
        duration = 7,
        filename = "red_reversal.lua"
    },
    ["Blue Lapse"] = {
        name = "Blue Lapse",
        description = "RightSpinner - Orbiting behind",
        color = Color3.fromRGB(68, 68, 255),
        gradient = {Color3.fromRGB(0, 0, 255), Color3.fromRGB(0, 0, 139)},
        duration = 12,
        filename = "blue_lapse.lua"
    },
    ["200% Purple"] = {
        name = "200% Purple",
        description = "ALL 6 ACCOUNTS COMBINE - 0.4x speed",
        color = Color3.fromRGB(255, 128, 255),
        gradient = {Color3.fromRGB(255, 0, 255), Color3.fromRGB(128, 0, 128)},
        duration = 15,
        filename = "200_percent_purple.lua"
    }
}

-- Determine my role
local myRole = _G.ACCOUNT_CONFIG[localPlayer.Name]

if not myRole then
    print("[ERROR] No role defined for account: " .. localPlayer.Name)
    print("Available roles:")
    for name, config in pairs(_G.ACCOUNT_CONFIG) do
        print("  " .. name .. " -> " .. config.role)
    end
    return
end

print("=== TEMU-GOJO MAIN CONTROLLER ===")
print("Account: " .. localPlayer.Name)
print("Role: " .. myRole.role)

-- File system functions
local function setupFileSystem()
    local fileSupport = isfile and isfolder and writefile and readfile
    
    if fileSupport then
        if not isfolder("Temu-Gojo") then
            makefolder("Temu-Gojo")
        end
        
        local filePath = "Temu-Gojo/moves.json"
        if not isfile(filePath) then
            local initialData = {
                moveNumber = 0,
                lastMove = "",
                timestamp = os.time(),
                active = false
            }
            writefile(filePath, HttpService:JSONEncode(initialData))
        end
        return true
    end
    return false
end

-- Create GUI only for main account
if myRole.role == "Main" then
    if not setupFileSystem() then
        warn("[ERROR] File system required for main account")
        return
    end
    
    -- Create GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MoveController"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    gradient.Rotation = 90
    gradient.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 28)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    titleBar.BackgroundTransparency = 0.3
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 140, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "MOVE CTRL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 60, 0, 20)
    statusFrame.Position = UDim2.new(1, -65, 0.5, -10)
    statusFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    statusFrame.BackgroundTransparency = 0.2
    statusFrame.Parent = titleBar
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "READY"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextSize = 10
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = statusFrame
    
    local movesContainer = Instance.new("Frame")
    movesContainer.Size = UDim2.new(1, -20, 1, -38)
    movesContainer.Position = UDim2.new(0, 10, 0, 33)
    movesContainer.BackgroundTransparency = 1
    movesContainer.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = movesContainer
    
    for moveName, moveData in pairs(_G.MOVES) do
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, 0, 0, 70)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        buttonFrame.BackgroundTransparency = 0.2
        buttonFrame.Parent = movesContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = buttonFrame
        
        local buttonGradient = Instance.new("UIGradient")
        buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, moveData.gradient[1]),
            ColorSequenceKeypoint.new(1, moveData.gradient[2])
        })
        buttonGradient.Rotation = 45
        buttonGradient.Parent = buttonFrame
        
        local moveLabel = Instance.new("TextLabel")
        moveLabel.Size = UDim2.new(0, 120, 0, 20)
        moveLabel.Position = UDim2.new(0, 10, 0, 8)
        moveLabel.BackgroundTransparency = 1
        moveLabel.Text = moveName
        moveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        moveLabel.TextSize = 13
        moveLabel.Font = Enum.Font.GothamBold
        moveLabel.TextXAlignment = Enum.TextXAlignment.Left
        moveLabel.Parent = buttonFrame
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(0, 140, 0, 30)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = moveData.description
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        descLabel.TextSize = 9
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextWrapped = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = buttonFrame
        
        local executeButton = Instance.new("TextButton")
        executeButton.Size = UDim2.new(0, 60, 0, 30)
        executeButton.Position = UDim2.new(1, -70, 0.5, -15)
        executeButton.BackgroundColor3 = moveData.color
        executeButton.BackgroundTransparency = 0.3
        executeButton.Text = "CAST"
        executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        executeButton.TextSize = 11
        executeButton.Font = Enum.Font.GothamBold
        executeButton.Parent = buttonFrame
        
        local buttonCorner2 = Instance.new("UICorner")
        buttonCorner2.CornerRadius = UDim.new(0, 6)
        buttonCorner2.Parent = executeButton
        
        executeButton:SetAttribute("MoveName", moveName)
        
        executeButton.MouseButton1Click:Connect(function()
            if _G.moveInProgress then
                statusFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                statusText.Text = "LOCKED"
                task.wait(0.3)
                if _G.moveInProgress then
                    statusFrame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                    statusText.Text = "ACTIVE"
                end
                return
            end
            
            local clickedMoveName = executeButton:GetAttribute("MoveName")
            local moveData = _G.MOVES[clickedMoveName]
            
            _G.moveInProgress = true
            statusFrame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            statusText.Text = "ACTIVE"
            
            for _, child in pairs(movesContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundTransparency = 0.5
                end
            end
            
            -- Increment move number
            local data = readMoveFile() or {moveNumber = 0, lastMove = "", timestamp = os.time(), active = true}
            data.moveNumber = data.moveNumber + 1
            data.lastMove = clickedMoveName
            data.timestamp = os.time()
            data.active = true
            writeMoveFile(data)
            
            print("[MAIN] Executing move #" .. data.moveNumber .. ": " .. clickedMoveName)
            
            -- Load and execute the move script
            local success, result = pcall(function()
                return game:HttpGet(_G.BASE_URL .. moveData.filename)
            end)
            
            if success and result then
                local func = loadstring(result)
                if func then
                    func()
                else
                    warn("[ERROR] Failed to load move script")
                end
            else
                warn("[ERROR] Could not fetch move script")
            end
            
            task.wait(moveData.duration)
            
            _G.moveInProgress = false
            statusFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "READY"
            
            for _, child in pairs(movesContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundTransparency = 0.2
                end
            end
            
            local data = readMoveFile()
            if data then
                data.active = false
                writeMoveFile(data)
            end
        end)
    end
    
    -- Draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    mainFrame.Parent = screenGui
    print("[GUI] Created with " .. table.count(_G.MOVES) .. " moves")
    
    -- File read/write functions
    function readMoveFile()
        local success, data = pcall(function()
            local content = readfile("Temu-Gojo/moves.json")
            return HttpService:JSONDecode(content)
        end)
        return success and data or nil
    end
    
    function writeMoveFile(data)
        local success = pcall(function()
            writefile("Temu-Gojo/moves.json", HttpService:JSONEncode(data))
        end)
        return success
    end
else
    -- Alt accounts: Watch for move commands
    if not setupFileSystem() then
        warn("[ERROR] File system required")
        return
    end
    
    local lastMoveNumber = 0
    local initialData = readMoveFile()
    if initialData then
        lastMoveNumber = initialData.moveNumber
    end
    
    RunService.RenderStepped:Connect(function()
        local data = readMoveFile()
        if data and data.moveNumber > lastMoveNumber and data.active and not _G.active then
            print("[WATCHER] " .. myRole.role .. " executing: " .. data.lastMove)
            
            local moveData = _G.MOVES[data.lastMove]
            if moveData then
                local success, result = pcall(function()
                    return game:HttpGet(_G.BASE_URL .. moveData.filename)
                end)
                
                if success and result then
                    local func = loadstring(result)
                    if func then
                        func()
                    end
                end
            end
            
            lastMoveNumber = data.moveNumber
        end
    end)
    
    function readMoveFile()
        local success, data = pcall(function()
            local content = readfile("Temu-Gojo/moves.json")
            return HttpService:JSONDecode(content)
        end)
        return success and data or nil
    end
end

print("=== READY ===")
