local PBR = PetBattleRecorder


function PBR:InitExport()
    self.usedAbilities = {}
end


----------------------------------
-- GET LOADOUT
----------------------------------

function PBR:GetLoadout()
    local text = ""
    for i = 1,3 do
        local petGUID, ability1, ability2, ability3 = C_PetJournal.GetPetLoadOutInfo(i)
        if petGUID then
            local speciesID, customName, level, xp, maxXp,
            displayID, isFavorite, name, icon, petType,
            creatureID, sourceText, description, isWild,
            canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petGUID)

            text = text .. "[npc=" .. creatureID .. "]"
            
            text = " ("
            local abilities = {ability1, ability2, ability3}
            local idTable = C_PetJournal.GetPetAbilityList(speciesID)

            for a = 1,3 do
                local abilityID = abilities[a]
                if abilityID then
                    local abilityInLoadout = abilityID == idTable[a] and 1 or 2
                    text = text .. abilityInLoadout
                end
                if a < 3 then text = text .. "/" end

                local id, name, icon, maxCooldown, unparsedDescription, 
                numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityID)
                table.insert(self.usedAbilities, {
                    name = name,
                    id = id
                })
            end
            text = text .. ")"
            if i < 3 then text = text .. ", " end
        end
    end
    return text
end

----------------------------------
-- Convert Combat Line
----------------------------------

function PBR:ConvertCombatLine(line)
end


----------------------------------
-- EXPORT TEXT
----------------------------------

function PBR:GenerateExport()
    PBR:InitExport()
    local text = self:GetLoadout()
    text = text .. "\n\n[ol]\n"
    for i, entry in ipairs(self.battleLog) do
        text = text .. "[li]" .. entry .. "[/li]\n"
    end
    text = text .. "[/ol]"
    return text
end
