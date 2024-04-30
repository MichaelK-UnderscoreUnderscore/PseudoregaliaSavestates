-- Namespaces
local PseudoregaliaSavestates = {}
local UEHelpers = require("UEHelpers")
local Utils = require("Utils")

-- Config
local config_Keybinds = require "config_keybinds"
local SaveFile = "Mods/PseudoregaliaSavestates/Saves/SavedPositions.txt"

-- Local variables
local var_SavedPositions = {}
local var_ReloadTeleport_bool = false
local var_ReloadTeleport_ID = 0

-- Local defines for readability
local MapName = "mapName_4_423D13C74469858B6E9893BEB6ABFBBB"


local function Test()
---@diagnostic disable: need-check-nil, undefined-field
    Utils.print("Test")
end

local function Test2()
    Utils.print("Test2")
---@diagnostic enable: need-check-nil, undefined-field
end
function PseudoregaliaSavestates.LoadSavedPositionsFromFile()
    local File = io.open(SaveFile, "r")
    if File == nil then
        Utils.print("No saved positions file found in \"" .. SaveFile .. "\"")
        return
    end
    for line in File:lines() do
        local ID = tonumber(string.match(line, "ID=(%d+)"))
        local Area = string.match(line, "Area=([A-Za-z0-9_]+)")
        local X = tonumber(string.match(line, "X=(-?%d+%.?%d*)"))
        local Y = tonumber(string.match(line, "Y=(-?%d+%.?%d*)"))
        local Z = tonumber(string.match(line, "Z=(-?%d+%.?%d*)"))
        local Pitch = tonumber(string.match(line, "Pitch=(-?%d+%.?%d*)"))
        local Yaw = tonumber(string.match(line, "Yaw=(-?%d+%.?%d*)"))
        local Roll = tonumber(string.match(line, "Roll=(-?%d+%.?%d*)"))
        if ID ~= nil and Area ~= nil and X ~= nil and Y ~= nil and Z ~= nil and Pitch ~= nil and Yaw ~= nil and Roll ~= nil then
            var_SavedPositions[ID] = {
                ["Area"] = Area,
                ["X"] = X,
                ["Y"] = Y,
                ["Z"] = Z,
                ["Pitch"] = Pitch,
                ["Yaw"] = Yaw,
                ["Roll"] = Roll,
            }
        else
            Utils.print("Error parsing line: " .. line)
        end
    end
end

function PseudoregaliaSavestates.SavePositionsToFile()
    local text = ""
    for ID, Position in pairs(var_SavedPositions) do
        text = text .. "ID=" .. tostring(ID) .. " :: Area=" .. Position.Area .. " :: X=" .. tostring(Position.X) .. " :: Y=" .. tostring(Position.Y) .. " :: Z=" .. tostring(Position.Z) .. " :: Pitch=" .. tostring(Position.Pitch) .. " :: Yaw=" .. tostring(Position.Yaw) .. " :: Roll=" .. tostring(Position.Roll) .. "\n"
    end
    local File = io.open(SaveFile, "w")
    if File == nil then
        Utils.print("Error opening file for writing... \"" .. SaveFile .. "\"")
        return
    end
    File:write(text)
    File:close()
end

function PseudoregaliaSavestates.LoadPosition(ID --[[int]])
    do -- Error checking: ---- ID | GameInstance | Console | PlayerController
        if not var_SavedPositions[ID] then
            Utils.print("No saved position for ID " .. ID)
            return
        end
        if Utils.hook_GameInstance == nil or not Utils.hook_GameInstance:IsValid() then
            Utils.print("GameInstance not found")
            return
        end
        if Utils.hook_Console == nil or not Utils.hook_Console:IsValid() then
            Utils.print("Console not found")
            return
        end
        if Utils.hook_PlayerController == nil or not Utils.hook_PlayerController:IsValid() then
            Utils.print("PlayerController not found")
            return
        end
        if Utils.hook_CheatManager == nil or not Utils.hook_CheatManager:IsValid() then
            Utils.print("CheatManager not found")
            return
        end
    end
    Area = Utils.hook_GameInstance.activeZoneStr[MapName]:ToString()
    if Area == nil or type(Area) ~= "string" then
        Utils.print("Area not found")
        return
    end
    if Area ~= var_SavedPositions[ID].Area then
        var_ReloadTeleport_bool = true
        var_ReloadTeleport_ID = ID
        Utils.print("Teleporting to " .. Area .. " to load position " .. ID)
        Utils.hook_Console:ExecuteConsoleCommand(Utils.hook_PlayerController, "open " .. var_SavedPositions[ID].Area, nil)
        return
    end
    local Location = Utils.hook_PlayerController.Pawn:K2_GetActorLocation()
    local Rotation = Utils.hook_PlayerController.Pawn:K2_GetActorRotation()
    Location.X = var_SavedPositions[ID].X
    Location.Y = var_SavedPositions[ID].Y
    Location.Z = var_SavedPositions[ID].Z
    Rotation.Pitch = var_SavedPositions[ID].Pitch
    Rotation.Yaw = var_SavedPositions[ID].Yaw
    Rotation.Roll = var_SavedPositions[ID].Roll

    Utils.print("Teleporting to position " .. ID)

    Utils.hook_PlayerController.Pawn:K2_SetActorLocation(Location, false, {}, true)
    Utils.hook_PlayerController.Pawn:K2_SetActorRotation(Rotation, false)
end
function PseudoregaliaSavestates.SavePosition(ID --[[int]])
    do -- Error checking: ---- ID | GameInstance | PlayerController
        if type(ID) ~= "number" then
            Utils.print("ID not number")
            return
        end
        if Utils.hook_GameInstance == nil or not Utils.hook_GameInstance:IsValid() then
            Utils.print("GameInstance not found")
            return
        end
        if Utils.hook_PlayerController == nil or not Utils.hook_PlayerController:IsValid() then
            Utils.print("PlayerController not found")
            return
        end
    end
    local Area = Utils.hook_GameInstance.activeZoneStr[MapName]:ToString()
    local Position = Utils.hook_PlayerController.Pawn:K2_GetActorLocation()
    local Rotation = Utils.hook_PlayerController.Pawn:K2_GetActorRotation()
    do -- Error checking: ----  Area | Position | Rotation
        if Area == nil or type(Area) ~= "string" then
            Utils.print("Area not found")
            return
        end
        if Position == nil then
            Utils.print("Position not found")
            return
        end
        if Rotation == nil then
            Utils.print("Rotation not found")
            return
        end
    end
    var_SavedPositions[ID] = {
        ["Area"] = Area,
        ["X"] = Position.X,
        ["Y"] = Position.Y,
        ["Z"] = Position.Z,
        ["Pitch"] = Rotation.Pitch,
        ["Yaw"] = Rotation.Yaw,
        ["Roll"] = Rotation.Roll,
    }
    PseudoregaliaSavestates.SavePositionsToFile()
    Utils.print("Saved position " .. ID)
end

-- Init
-- Reload
Utils.ClientRestart = { 
    [1] = function ()
        var_SavedPositions = {}
        PseudoregaliaSavestates.LoadSavedPositionsFromFile()
        if var_ReloadTeleport_bool then
            var_ReloadTeleport_bool = false
            PseudoregaliaSavestates.LoadPosition(var_ReloadTeleport_ID)
        end
    end
}

-- Keybinds
local function RegisterKey(KeyBindName, Callable)
    if (config_Keybinds[KeyBindName] and not IsKeyBindRegistered(config_Keybinds[KeyBindName].Key, config_Keybinds[KeyBindName].ModifierKeys)) then
        RegisterKeyBind(config_Keybinds[KeyBindName].Key, config_Keybinds[KeyBindName].ModifierKeys, Callable)
    end
end

RegisterKey("Test", function() Test() end)
RegisterKey("Test2", function() Test2() end)
for i = 1, config_Keybinds["PositionSaveCount"] do
    if config_Keybinds["LoadPosition " .. i] then
        RegisterKey("LoadPosition " .. i, function() PseudoregaliaSavestates.LoadPosition(i) end)
    else 
        Utils.print("LoadPosition " .. i .. " not found in config_keybinds.lua")
    end
    if config_Keybinds["SavePosition " .. i] then
        RegisterKey("SavePosition " .. i, function() PseudoregaliaSavestates.SavePosition(i) end)
    else
        Utils.print("SavePosition " .. i .. " not found in config_keybinds.lua")
    end
end