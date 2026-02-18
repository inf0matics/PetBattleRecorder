local BattleLogParser = {
  round = 0,
}

function BattleLogParser:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.round = 0

  return obj
end

function BattleLogParser:parseLine(line)
  if line:find("Round") then
      local tmp, newRound = line:match("(%w+)(.+)")
      newRound = newRound:sub(2)

      if self.round ~= newRound then
          if newRound ~= "1" then
              self:GenerateRound()
          end
          self.round = newRound
      end
  end
  -- Process Line
end

function BattleLogParser:GenerateRound()
end


return BattleLogParser