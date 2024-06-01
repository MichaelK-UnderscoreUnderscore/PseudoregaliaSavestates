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

function PseudoregaliaSavestates.LoadArea(ID --[[int]])
    local SystemLibrary = Utils.hook_KismetSystemLibrary()
    local PlayerController = Utils.hook_PlayerController()
    
    if not var_SavedPositions[ID] then
        Utils.print("No saved position for ID " .. ID)
        return
    end
    if SystemLibrary == nil or PlayerController == nil then
        Utils.print("SystemLibrary or PlayerController not found")
        return
    end
    local Area = var_SavedPositions[ID].Area

    var_ReloadTeleport_bool = true
    var_ReloadTeleport_ID = ID
    Utils.print("Teleporting to " .. Area .. " to load position " .. ID)
    SystemLibrary:ExecuteConsoleCommand(PlayerController, "open " .. var_SavedPositions[ID].Area, nil)
end

function PseudoregaliaSavestates.LoadPosition(ID --[[int]])
    
    if not var_SavedPositions[ID] then
        Utils.print("No saved position for ID " .. ID)
        return
    end
    local GameInstance = Utils.hook_GameInstance()
    local PlayerController = Utils.hook_PlayerController()
    if GameInstance == nil or PlayerController == nil then
        Utils.print("GameInstance or PlayerController not found")
        return
    end

    local Location = PlayerController.Pawn:K2_GetActorLocation()
    local Rotation = PlayerController.Pawn:K2_GetActorRotation()
    Location.X = var_SavedPositions[ID].X
    Location.Y = var_SavedPositions[ID].Y
    Location.Z = var_SavedPositions[ID].Z
    Rotation.Pitch = var_SavedPositions[ID].Pitch
    Rotation.Yaw = var_SavedPositions[ID].Yaw
    Rotation.Roll = var_SavedPositions[ID].Roll

    Utils.print("Teleporting to position " .. ID)

    PlayerController.Pawn:K2_SetActorLocation(Location, false, {}, true)
    PlayerController.Pawn:K2_SetActorRotation(Rotation, false)
end
function PseudoregaliaSavestates.SavePosition(ID --[[int]])
    local GameInstance = Utils.hook_GameInstance()
    local PlayerController = Utils.hook_PlayerController()

    if GameInstance == nil or PlayerController == nil then
        Utils.print("GameInstance or PlayerController not found")
        return
    end    
    local Area = GameInstance.activeZoneStr[MapName]:ToString()
    local Position = PlayerController.Pawn:K2_GetActorLocation()
    local Rotation = PlayerController.Pawn:K2_GetActorRotation()

    if Area == nil or type(Area) ~= "string" then
        Utils.print("Area not found")
        return
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

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function (Context)
        var_SavedPositions = {}
        PseudoregaliaSavestates.LoadSavedPositionsFromFile()
        if var_ReloadTeleport_bool then
            var_ReloadTeleport_bool = false
            PseudoregaliaSavestates.LoadPosition(var_ReloadTeleport_ID)
        end
    end
)

-- Keybinds
for i = 1, config_Keybinds["PositionSaveCount"] do
    if config_Keybinds["LoadPosition " .. i] then
        Utils.RegisterKey("LoadPosition " .. i, function () PseudoregaliaSavestates.LoadArea(i) end, config_Keybinds["LoadPosition ".. i]["Key"], config_Keybinds["LoadPosition ".. i]["ModifierKeys"], false)
    else
        Utils.print("LoadPosition " .. i .. " not found in config_keybinds.lua")
    end
    if config_Keybinds["SavePosition " .. i] then
        Utils.RegisterKey("SavePosition " .. i, function () PseudoregaliaSavestates.SavePosition(i) end, config_Keybinds["SavePosition ".. i]["Key"], config_Keybinds["SavePosition ".. i]["ModifierKeys"], false)
    else
        Utils.print("SavePosition " .. i .. " not found in config_keybinds.lua")
    end
end