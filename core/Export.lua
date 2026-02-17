local PBR = PetBattleRecorder

function PBR:InitExport()
    self.usedAbilities = {}
    self.round = "-1"
    self.exportedText = ""
    PBR:ResetRoundVars()
end

function PBR:ResetRoundVars()
    self.emptySpell = { name = "wait/pass/doesn't matter", id = 0 }
    self.spell = self.emptySpell
    self.enemyDied = nil
    self.myDied = nil
    self.enemySwitch = nil
    self.mySwitch = nil
    self.enemyMechanical = nil
    self.myMechanical = nil    
    self.enemyUndeadRound = nil
    self.myUndeadRound = nil
end

----------------------------------
-- GET LOADOUT
----------------------------------

function PBR:GetLoadout()
    for i = 1,3 do
        local petGUID, ability1, ability2, ability3 = C_PetJournal.GetPetLoadOutInfo(i)
        if petGUID then
            local speciesID, customName, level, xp, maxXp,
            displayID, isFavorite, name, icon, petType,
            creatureID, sourceText, description, isWild,
            canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petGUID)

            self.exportedText = self.exportedText .. "[npc=" .. creatureID .. "]"
            
            self.exportedText = self.exportedText .. " ("
            local abilities = {ability1, ability2, ability3}
            local idTable = C_PetJournal.GetPetAbilityList(speciesID)

            for a = 1,3 do
                local abilityID = abilities[a]
                if abilityID then
                    local abilityInLoadout = abilityID == idTable[a] and 1 or 2
                    self.exportedText = self.exportedText .. abilityInLoadout
                end
                if a < 3 then self.exportedText = self.exportedText .. "/" end

                local id, name, icon, maxCooldown, unparsedDescription, 
                numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityID)
                table.insert(self.usedAbilities, {
                    name = name,
                    id = id
                })
            end
            self.exportedText = self.exportedText .. ")"
            if i < 3 then self.exportedText = self.exportedText .. ", " end
        end
    end
    return self.exportedText
end

----------------------------------
-- Convert Combat Line
----------------------------------
---

function PBR:GenerateRound()
    if self.spell.id == 0 then
        self.exportedText  = self.exportedText  .. "[li]" .. self.spell.name
    else
        self.exportedText = self.exportedText .. "[li][pet-ability=" .. self.spell.id .. "]"
    end
    if self.enemyDied then self.exportedText = self.exportedText .. " > " .. self.enemyDied .. " dies" end
    if self.enemyMechanical then self.exportedText = self.exportedText .. " > " .. self.enemyMechanical .. " mechanical applied" end
    if self.enemySwitch then self.exportedText = self.exportedText .. " > Enemy switches to " .. self.enemySwitch end
    if self.enemyUndeadRound then self.exportedText = self.exportedText .. " > " .. self.enemyUndeadRound .. " undead round" end

    if self.myDied then self.exportedText = self.exportedText .. " > " .. self.myDied .. " dies" end
    if self.myMechanical then self.exportedText = self.exportedText .. " > " .. self.myMechanical .. " mechanical applied" end
    if self.mySwitch then self.exportedText = self.exportedText .. " > Switch to " .. self.mySwitch end
    if self.myUndeadRound then self.exportedText = self.exportedText .. " > " .. self.myUndeadRound .. " undead round" end

    self.exportedText = self.exportedText .. "[/li]\n"
    PBR:ResetRoundVars()
end

function PBR:AnalyzeLine(line)
    if line:find("died") then
        if line:find("Your") then self.myDied = line:sub(6, -7) end
        if line:find("Enemy") then self.enemyDied = line:sub(7, -7) end
    end

    if line:find("your") and line:find("%[Mechanical%]") then
        self.myMechanical = self.myDied
        self.myDied = nil
    end

    if line:find("enemy") and line:find("%[Mechanical%]") then
        self.enemyMechanical = self.enemyDied
        self.enemyDied = nil
    end

    if line:find("applied") and line:find("your") and line:find("%[Damned%]") then
        self.myUndeadRound = self.myDied
        self.myDied = nil
    end

    if line:find("applied") and line:find("enemy") and line:find("%[Damned%]") then
        self.enemyUndeadRound = self.enemyDied
        self.enemyDied = nil
    end

    if line:find("active pet") then
        if line:find("enemy active") then self.enemySwitch = line:sub(0, -26) end
        if line:find("your active") then self.mySwitch = line:sub(0, -25) end
    end

    for j = 1, #self.usedAbilities do
        local ability = self.usedAbilities[j]
        if self.spell.id == 0 and line:find("%[" .. ability.name:gsub('%-', '%%%-') .. "%]") then
            self.spell = ability
        end
    end
end

function PBR:ProcessLine(line)
    if line:find("Round") then
        local tmp, newRound = line:match("(%w+)(.+)")
        newRound = newRound:sub(2)

        if self.round ~= newRound then
            if newRound ~= "1" then
                PBR:GenerateRound()
            end
            self.round = newRound
        end
    end
    PBR:AnalyzeLine(line)
end

----------------------------------
-- EXPORT TEXT
----------------------------------

function PBR:PrintDebugLog()
    print("Adding Debug Log")
    self.exportedText  = self.exportedText  .. "\n\n--- DebugLog ---\n"
    self.exportedText  = self.exportedText  .. "\nAbilities:\n"
    for i, a in ipairs(self.usedAbilities) do
        for k, v in pairs(a) do self.exportedText = self.exportedText .. v .. "\n" end
    end
    self.exportedText  = self.exportedText  .. "\nBattle Log:\n"
    self.exportedText  = self.exportedText  .. "\n" .. table.concat(self.battleLog, "\n")
end

function PBR:GenerateExport()
    PBR:InitExport()
    self.exportedText = self:GetLoadout()
    self.exportedText  = self.exportedText .. "\n\n[ol]\n"
    for i, entry in ipairs(self.battleLog) do
        PBR:ProcessLine(entry)
    end
    PBR:GenerateRound()
    self.exportedText = self.exportedText .. "[/ol]"
    if true then
        PBR:PrintDebugLog()
    end
    return self.exportedText
end
