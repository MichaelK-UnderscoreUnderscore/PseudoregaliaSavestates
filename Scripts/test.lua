---@diagnostic disable: undefined-global
local UEHelpers = require("UEHelpers")
local MVState_Save = require("MVState_Save")

-- Start --
function PseudoregaliaSavestates.SaveState(Slot --[[int]])
    local SaveGame = MVState_Save.UMVState_Save_C()
    SaveGame.SavedZoneData = GameInstance.allZoneData
    SaveGame.upgrades = GameInstance.upgradeTracker
    SaveGame.hpPieces = GameInstance.hpPieces
    SaveGame.NumberOfKeys = GameInstance.NumberOfKeys
    SaveGame.lastSavedZoneSpawnIn = GameInstance['Last Saved Zone Spawn In']
    SaveGame.lastSavePointName = GameInstance['Last Save Point Name']
    SaveGame.playtime = GameInstance.playtime
    SaveGame.savedZoneArray = GameInstance.allZoneDataStrs
    SaveGame.spawnPointTag = GameInstance.activeSpawnTag
    SaveGame.key1Save = GameInstance.key1
    SaveGame.key2Save = GameInstance.key2
    SaveGame.key3Save = GameInstance.key3
    SaveGame.key4Save = GameInstance.key4
    SaveGame.key5Save = GameInstance.key5
    SaveGame.currentPower = GameInstance.currentPower
    SaveGame.eventTracker = GameInstance.eventTracker
    SaveGame.lastUpgrade = GameInstance.lastObtainedUpgrade
    SaveGame.unlockedOutfits = GameInstance['Unlocked Outfits']
    SaveGame.currentOutfit = GameInstance['Current Outfit']
    SaveGame.allRoomData = GameInstance['All Room Data']
    SaveGame.PlayerPosition = PlayerController.Pawn:K2_GetActorLocation()
    SaveGame.PlayerVelocity = PlayerController.Pawn:GetVelocity()
    SaveGame.PlayerRotation = PlayerController.Pawn:K2_GetActorRotation()
    SaveGame.PlayerHealth = PlayerController.Pawn.Health
    SaveGame.PlayerMaxHealth = PlayerController.Pawn.MaxHealth
    SaveGame.clearedSave = false
    SaveGame['completedSave?'] = false
    SaveGame.collectablePercent = 0
    SaveGame.ngOutfits = false
    SaveGame.ngUpgrades = false
    MV_GameInstance.UMV_GameInstance_C:createDataSaveSlot(Slot, SaveGame)
end

function PseudoregaliaSavestates.LoadState(Slot --[[int]])
    local SaveGame = MVState_Save.UMVState_Save_C()
    MV_GameInstance.UMV_GameInstance_C:loadSaveToSlot(Slot, SaveGame)
    return SaveGame
end






-- End --
Keybinds = {
    ["SaveState 1"] = {["Key"] = Key.F5,    ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SaveState 2"] = {["Key"] = Key.F6,    ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SaveState 3"] = {["Key"] = Key.F7,    ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SaveState 4"] = {["Key"] = Key.F8,    ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["LoadState 1"] = {["Key"] = Key.F5,    ["ModifierKeys"] = {}},
    ["LoadState 2"] = {["Key"] = Key.F6,    ["ModifierKeys"] = {}},
    ["LoadState 3"] = {["Key"] = Key.F7,    ["ModifierKeys"] = {}},
    ["LoadState 4"] = {["Key"] = Key.F8,    ["ModifierKeys"] = {}},
}

local function RegisterKey(KeyBindName, Callable)
    if (Keybinds[KeyBindName] and not IsKeyBindRegistered(Keybinds[KeyBindName].Key, Keybinds[KeyBindName].ModifierKeys)) then
        RegisterKeyBind(Keybinds[KeyBindName].Key, Keybinds[KeyBindName].ModifierKeys, Callable)
    end
end
  
RegisterKey("SaveState 1", function() PseudoregaliaSavestates.SaveState(1) end)
RegisterKey("SaveState 2", function() PseudoregaliaSavestates.SaveState(2) end)
RegisterKey("SaveState 3", function() PseudoregaliaSavestates.SaveState(3) end)
RegisterKey("SaveState 4", function() PseudoregaliaSavestates.SaveState(4) end)
RegisterKey("LoadState 1", function() PseudoregaliaSavestates.LoadState(1) end)
RegisterKey("LoadState 2", function() PseudoregaliaSavestates.LoadState(2) end)
RegisterKey("LoadState 3", function() PseudoregaliaSavestates.LoadState(3) end)
RegisterKey("LoadState 4", function() PseudoregaliaSavestates.LoadState(4) end)