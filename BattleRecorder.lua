local PBR = PetBattleRecorder
local frame = PBR.frame

----------------------------------
-- START RECORDING
----------------------------------

function PBR:StartRecording()
    self.battleLog = {}
    self.currentRound = 0
    self.recording = true
    print("PBR: Recording started")
end

----------------------------------
-- STOP RECORDING
----------------------------------

function PBR:StopRecording()
    self.recording = false
    print("PBR: Recording stopped")
end

----------------------------------
-- ADD LOG ENTRY
----------------------------------

function PBR:AddLogEntry(message)
    if not self.recording then return end
    table.insert(self.battleLog, message)
end

----------------------------------
-- EVENTS
----------------------------------

frame:RegisterEvent("PET_BATTLE_OPENING_START")
frame:RegisterEvent("PET_BATTLE_CLOSE")
frame:RegisterEvent("CHAT_MSG_PET_BATTLE_COMBAT_LOG")

frame:SetScript("OnEvent", function(_, event, msg)
    if event == "PET_BATTLE_OPENING_START" then
        PBR:StartRecording()
    elseif event == "PET_BATTLE_CLOSE" then
        PBR:StopRecording()
    elseif event == "CHAT_MSG_PET_BATTLE_COMBAT_LOG" then
        PBR:AddLogEntry(msg)
    end
end)
