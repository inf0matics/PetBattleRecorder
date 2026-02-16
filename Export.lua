local PBR = PetBattleRecorder

----------------------------------
-- GET LOADOUT
----------------------------------

function PBR:GetLoadout()
    local text = ""
    for i = 1,3 do
        local petGUID, ability1, ability2, ability3 =
            C_PetJournal.GetPetLoadOutInfo(i)
        if petGUID then
            local speciesID, customName, level, xp, maxXp,
            displayID, isFavorite, name, icon, petType,
            creatureID =
            C_PetJournal.GetPetInfoByPetID(petGUID)
            text = text .. "[npc=" .. creatureID .. "] ("
            local abilities = {ability1, ability2, ability3}
            local idTable = C_PetJournal.GetPetAbilityList(speciesID)

            for a=1,3 do
                local abilityID = abilities[a]
                if abilityID then
                    local abilityIndex =
                        abilityID == idTable[a] and 1 or 2
                    text = text .. abilityIndex
                end
                if a < 3 then text = text .. "/" end
            end
            text = text .. ")"
            if i < 3 then text = text .. ", " end
        end
    end
    return text
end

----------------------------------
-- EXPORT TEXT
----------------------------------

function PBR:GenerateExport()
    local text = self:GetLoadout()
    text = text .. "\n\n[ol]\n"
    for i, entry in ipairs(self.battleLog) do
        text = text .. "[li]" .. entry .. "[/li]\n"
    end
    text = text .. "[/ol]"
    return text
end
