local assert = require("luassert")
local BattleLogParser = require("core.BattleLogParser")

describe("core.BattleLogParser", function()
  it("check log01", function()
    local loadout = require("spec.fixtures.Log01Loadout")
    local parser = BattleLogParser:new(loadout)

    local file = io.open('spec/fixtures/Log01.txt', "r")
    assert.is_not_nil(file)
    for line in file:lines() do
      parser:parseLine(line)
    end

    assert.are.equal(parser.round, '8')
    local resultFile = io.open('spec/fixtures/Log01Result.txt', "r")
    local result = resultFile:read("*a")
    assert.are.equal(parser:FinishedParsing(), result)
  end)

  it("check log02", function()
    local parser = BattleLogParser:new()
    local log02filePath = 'spec/fixtures/log02.txt'

    local file = io.open(log02filePath, "r")
    assert.is_not_nil(file)
    for line in file:lines() do
      parser:parseLine(line)
    end

    assert.are.equal(parser.round, '6')
  end)

  it("check log03", function()
    local parser = BattleLogParser:new()
    local log02filePath = 'spec/fixtures/log03.txt'

    local file = io.open(log02filePath, "r")
    assert.is_not_nil(file)
    for line in file:lines() do
      parser:parseLine(line)
    end

    assert.are.equal(parser.round, '11')
  end)
end)
