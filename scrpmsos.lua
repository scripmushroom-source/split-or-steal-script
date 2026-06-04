--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: SplitOrSteal
    Author: ScripMushroom
    YouTube: https://www.youtube.com/channel/@Scripmushroom
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "Antidisestablishmentarianism",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "Split Or Steal Script"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")

-- Load the Zinzo UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Zinzo"))()

-- Create the Window and Folder
local window = library:window("Auto Farm UI")
local folder = window:folder("Main Toggles")

-- Define the remote events directly based on your Cobalt paths
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Player.CollectAll
local UpgradeEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Player.PurchaseLuckUpgrade

-- Auto Play Remotes
local QuickJoinEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Player.QuickJoin
local TableEnterEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Tables.EnterRequest
local EquipEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Player.EquipBrainrot

-- Game Decision Remote (For Split/Steal)
local DecisionEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Tables.DecisionRequest

-- Game State Signals
local CountdownTickEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Tables.CountdownTick
local TableResetEvent = ReplicatedStorage.BrainrotsThings.Misc.Events.Tables.TableReset

-- State tracking variables
local isCountingDown = false
local tableReady = true -- Starts true so it can join the very first game
local lastTickTime = 0

-- Track when the game fires a countdown tick
CountdownTickEvent.OnClientEvent:Connect(function()
    isCountingDown = true
    tableReady = false -- Round is starting/active, so table is no longer "reset"
    lastTickTime = os.time()
end)

-- Track when Table1 resets
TableResetEvent.OnClientEvent:Connect(function(tableName)
    if tableName == "Table1" then
        tableReady = true
        isCountingDown = false -- Ensure countdown state resets when table clears
    end
end)

-- Separate thread for Auto Collect loop
task.spawn(function()
    while true do
        if library.flags["auto_collect"] then
            pcall(function()
                CollectEvent:FireServer()
            end)
        end
        task.wait(0.1)
    end
end)

-- Separate thread for Auto Upgrade loop
task.spawn(function()
    while true do
        if library.flags["auto_upgrade"] then
            pcall(function()
                UpgradeEvent:FireServer("10")
            end)
        end
        task.wait(0.5)
    end
end)

-- Network-Optimized Auto Play Loop with Table Reset Logic
task.spawn(function()
    while true do
        if library.flags["auto_play"] then
            -- Safety check: If more than 5 seconds passed since the last tick and table isn't ready, reset states
            if isCountingDown and (os.time() - lastTickTime) > 5 then
                isCountingDown = false
            end

            -- ONLY attempt to join if the countdown is NOT active AND the table has successfully reset
            if not isCountingDown and tableReady then
                pcall(function()
                    -- 1. Request to join the game queue
                    QuickJoinEvent:FireServer()
                    task.wait(0.3)
                    
                    -- 2. Take a seat at Table1
                    TableEnterEvent:FireServer("Table1", "Chair1", false)
                    task.wait(0.3)
                    
                    -- 3. Equip your item
                    EquipEvent:FireServer(nil)
                end)
            end
        end
        task.wait(1.5) -- Regular interval check
    end
end)

-- Separate thread for Auto Split / Auto Steal loop
task.spawn(function()
    while true do
        if library.flags["auto_split"] then
            pcall(function()
                DecisionEvent:FireServer("Split")
            end)
        end
        
        if library.flags["auto_steal"] then
            pcall(function()
                DecisionEvent:FireServer("Steal")
            end)
        end
        
        task.wait(0.2)
    end
end)

-- Create Toggles inside the UI folder
folder:toggle({
    name = "Auto Collect", 
    flag = "auto_collect", 
    callback = function() end
})

folder:toggle({
    name = "Auto Upgrade", 
    flag = "auto_upgrade", 
    callback = function() end
})

folder:toggle({
    name = "Auto Play", 
    flag = "auto_play", 
    callback = function() end
})

folder:toggle({
    name = "Auto Split", 
    flag = "auto_split", 
    callback = function() end
})

folder:toggle({
    name = "Auto Steal", 
    flag = "auto_steal", 
    callback = function() end
})
