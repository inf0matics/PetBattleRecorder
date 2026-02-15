-- GLOBAL ADDON OBJECT
PetBattleRecorder = {}

-- Create main addon table
local PBR = PetBattleRecorder
PBR.battleLog = {}
PBR.currentRound = 0
PBR.recording = false

PBR.frame = CreateFrame("Frame")

-- Print loaded message
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if addonName == "PetBattleRecorder" then
        print("|cff00ff00Pet Battle Recorder loaded. Type /pbr to open.|r")
    end
end)
