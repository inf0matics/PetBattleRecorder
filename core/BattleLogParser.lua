local NO_ABILITY = { name = "wait/pass/doesn't matter", id = 0 }

BattleLogParser = {}
BattleLogParser.__index = BattleLogParser

function BattleLogParser:new(loadout)
  local obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.loadout = loadout or {}
  obj.usedAbilities = obj:CreateAbilitiesListFromLoadout(loadout or {})
  obj.round = "-1"
  obj.battleText = ""

  obj:ResetRoundVars()

  return obj
end

function BattleLogParser:CreateAbilitiesListFromLoadout(loadout)
  local abilities = {}
  for _, creature in ipairs(loadout) do
    for _, ability in ipairs(creature.abilities) do
      table.insert(abilities, ability)
    end
  end
  return abilities
end

function BattleLogParser:ResetRoundVars()
  self.activeAbility = NO_ABILITY
  self.enemyDied = nil
  self.myDied = nil
  self.enemySwitch = nil
  self.mySwitch = nil
  self.enemyMechanical = nil
  self.myMechanical = nil    
  self.enemyUndeadRound = nil
  self.myUndeadRound = nil
end

function BattleLogParser:parseLine(line)
  self:CheckForRound(line)
  self:CheckForDied(line)
  self:CheckForPetSwitch(line)
  self:CheckForAbilities(line)
end

function BattleLogParser:FinishedParsing()
  self:GenerateRound()
  local export = self:GetLoadout() .. "\n\n"
  export = export .. '[ol]\n'
  export = export .. self.battleText
  export = export .. '[/ol]\n'
  return export
end

function BattleLogParser:GetLoadout()
  local parts = {}
  for _, pet in ipairs(self.loadout) do
    table.insert(parts,
      "[npc=" .. pet.creatureID .. "] (" .. table.concat(pet.loadout, "/") .. ")"
    )
  end
  return table.concat(parts, ", ")
end

function BattleLogParser:CheckForRound(line)
  if line:find("Round") then
      local tmp, newRound = line:match("(%w+)(.+)")
      newRound = newRound:sub(2)

      if self.round ~= newRound then
          if newRound == "1" then
            self.battleText = ''
            self:ResetRoundVars()
          else
            self:GenerateRound()
          end
          self.round = newRound
      end
  end
end

function BattleLogParser:CheckForDied(line)
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
end

function BattleLogParser:CheckForPetSwitch(line)
    if line:find("active pet") then
        if line:find("enemy active") then self.enemySwitch = line:sub(0, -26) end
        if line:find("your active") then self.mySwitch = line:sub(0, -25) end
    end
end

function BattleLogParser:CheckForAbilities(line)
    for j = 1, #self.usedAbilities do
        local ability = self.usedAbilities[j]
        if self.activeAbility.id == 0 and line:find("%[" .. ability.name:gsub('%-', '%%%-') .. "%]") then
            self.activeAbility = ability
        end
    end
end

function BattleLogParser:GenerateRound()
    if self.activeAbility.id == 0 then
        self.battleText  = self.battleText  .. "[li]" .. self.activeAbility.name
    else
        self.battleText = self.battleText .. "[li][pet-ability=" .. self.activeAbility.id .. "]"
    end
    if self.enemyDied then self.battleText = self.battleText .. " > " .. self.enemyDied .. " dies" end
    if self.enemyMechanical then self.battleText = self.battleText .. " > " .. self.enemyMechanical .. " mechanical applied" end
    if self.enemySwitch then self.battleText = self.battleText .. " > Enemy switches to " .. self.enemySwitch end
    if self.enemyUndeadRound then self.battleText = self.battleText .. " > " .. self.enemyUndeadRound .. " undead round" end

    if self.myDied then self.battleText = self.battleText .. " > " .. self.myDied .. " dies" end
    if self.myMechanical then self.battleText = self.battleText .. " > " .. self.myMechanical .. " mechanical applied" end
    if self.mySwitch then self.battleText = self.battleText .. " > Switch to " .. self.mySwitch end
    if self.myUndeadRound then self.battleText = self.battleText .. " > " .. self.myUndeadRound .. " undead round" end

    self.battleText = self.battleText .. "[/li]\n"
  self:ResetRoundVars()
end

return BattleLogParser
