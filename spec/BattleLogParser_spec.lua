local assert = require("luassert")
local BattleLogParser = require("core.BattleLogParser")

local log01filePath = 'spec/fixtures/log01.txt'

describe("core.BattleLogParser", function()
  it("check log01", function()
    local parser = BattleLogParser:new()
    local file = io.open(log01filePath, "r")
    assert.is_not_nil(file)
    for line in file:lines() do
      parser:parseLine(line)
    end

    assert.are.equal(parser.round, '8')
  end)
end)
