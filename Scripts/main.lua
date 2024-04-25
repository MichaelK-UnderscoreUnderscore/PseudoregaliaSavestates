local PseudoregaliaSavestates = {}
local UEHelpers = require("UEHelpers")

local GameInstance = nil
local PlayerController = nil
local CheatManager = nil
local SavedPositions = {}

function PseudoregaliaSavestates.LoadPosition(ID --[[int]])
    if not SavedPositions[ID] then
        print("No saved position for ID " .. ID)
        return
    end
    CheatManager:BugItGo(SavedPositions[ID].X, SavedPositions[ID].Y, SavedPositions[ID].Z, SavedPositions[ID].Pitch, SavedPositions[ID].Yaw, SavedPositions[ID].Roll)
end

function PseudoregaliaSavestates.SavePosition(ID --[[int]])
    local Position = PlayerController:K2_GetPawn():K2_GetActorLocation()
    local Rotation = PlayerController:K2_GetPawn():K2_GetActorRotation()
    SavedPositions[ID] = {
        ["X"] = Position.X,
        ["Y"] = Position.Y,
        ["Z"] = Position.Z,
        ["Pitch"] = Rotation.Pitch,
        ["Yaw"] = Rotation.Yaw,
        ["Roll"] = Rotation.Roll
    }
    print("Saved position " .. ID)
end

-- Init
-- Reload
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function (Context)
    CheatManager = FindFirstOf("CheatManager")
    if CheatManager == nil or not CheatManager:IsValid() then
        print("CheatManager not found")
        return
    end
    -- The GameInstance holds all the current game states in Pseudo
    GameInstance = FindFirstOf("MV_GameInstance_C")
    if GameInstance == nil or not GameInstance:IsValid() then
        print("GameInstance not found")
        return
    end
    -- Pseudo doesn't mark the used PlayerController as PlayerControlled,
    ---- can't use GetPlayerController()
    PlayerController = FindFirstOf("MainPlayerController_C")
    if PlayerController == nil or not PlayerController:IsValid() then
        print("PlayerController not found")
        return
    end
end)


local Keybinds = {
    ["LoadPosition 1"] = {["Key"] = Key.F5, ["ModifierKeys"] = {}},
    ["LoadPosition 2"] = {["Key"] = Key.F6, ["ModifierKeys"] = {}},
    ["LoadPosition 3"] = {["Key"] = Key.F7, ["ModifierKeys"] = {}},
    ["LoadPosition 4"] = {["Key"] = Key.F8, ["ModifierKeys"] = {}},
    ["SavePosition 1"] = {["Key"] = Key.F5, ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SavePosition 2"] = {["Key"] = Key.F6, ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SavePosition 3"] = {["Key"] = Key.F7, ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SavePosition 4"] = {["Key"] = Key.F8, ["ModifierKeys"] = {ModifierKey.CONTROL}}
}
local function RegisterKey(KeyBindName, Callable)
    if (Keybinds[KeyBindName] and not IsKeyBindRegistered(Keybinds[KeyBindName].Key, Keybinds[KeyBindName].ModifierKeys)) then
        RegisterKeyBind(Keybinds[KeyBindName].Key, Keybinds[KeyBindName].ModifierKeys, Callable)
    end
end
RegisterKey("LoadPosition 1", function() PseudoregaliaSavestates.LoadPosition(1) end)
RegisterKey("LoadPosition 2", function() PseudoregaliaSavestates.LoadPosition(2) end)
RegisterKey("LoadPosition 3", function() PseudoregaliaSavestates.LoadPosition(3) end)
RegisterKey("LoadPosition 4", function() PseudoregaliaSavestates.LoadPosition(4) end)
RegisterKey("SavePosition 1", function() PseudoregaliaSavestates.SavePosition(1) end)
RegisterKey("SavePosition 2", function() PseudoregaliaSavestates.SavePosition(2) end)
RegisterKey("SavePosition 3", function() PseudoregaliaSavestates.SavePosition(3) end)
RegisterKey("SavePosition 4", function() PseudoregaliaSavestates.SavePosition(4) end)