local BattleLogParser = {
  rounds = 0
}

function BattleLogParser:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.rounds = 0

  return obj
end

return BattleLogParser