local PBR = PetBattleRecorder

function PBR:GenerateExport()
    local loadout = self:GetLoadout()
    local parser = BattleLogParser:new(loadout)
    for _, line in ipairs(self.battleLog) do
        parser:parseLine(line)
    end
    return parser:FinishedParsing()
end

function PBR:GetLoadout()
    local loadout = {}
    for i = 1, 3 do
        local petGUID, ability1, ability2, ability3 = C_PetJournal.GetPetLoadOutInfo(i)
        if petGUID then
            local speciesID, customName, level, xp, maxXp,
            displayID, isFavorite, name, icon, petType,
            creatureID = C_PetJournal.GetPetInfoByPetID(petGUID)

            local selectedAbilities = { ability1, ability2, ability3 }
            local idTable = C_PetJournal.GetPetAbilityList(speciesID)

            local loadoutSlots = {}
            local abilities = {}

            for a = 1, 3 do
                local abilityID = selectedAbilities[a]
                if abilityID then
                    -- determine slot (1 or 2)
                    local abilityInLoadout = abilityID == idTable[a] and 1 or 2
                    table.insert(loadoutSlots, abilityInLoadout)
                    -- get ability info
                    local id, abilityName = C_PetBattles.GetAbilityInfoByID(abilityID)
                    table.insert(abilities, {
                        name = abilityName,
                        id = id
                    })
                else
                    table.insert(loadoutSlots, 1)
                end
            end

            table.insert(loadout, {
                creatureID = creatureID,
                loadout = loadoutSlots,
                abilities = abilities
            })
        end
    end
    return loadout
end
