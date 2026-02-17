local assert = require("luassert")
local BattleLogParser = require("core.BattleLogParser")

describe("core.BattleLogParser", function()
  it("check rounds", function()
    local parser = BattleLogParser:new()
    assert.are.equal(parser.rounds, 0)
  end)
end)
