local assert = require("luassert")
local BattleLogParser = require("core.BattleLogParser")

local function readFile(path)
  local file = io.open(path, "r")
  assert.is_not_nil(file, "Could not open file: " .. path)

  local content = file:read("*a")
  file:close()

  return content
end

local function parseLogFile(parser, path)
  local file = io.open(path, "r")
  assert.is_not_nil(file, "Could not open file: " .. path)

  for line in file:lines() do
    parser:parseLine(line)
  end

  file:close()
end

local function testBattleLog(id, expectedRound)
  it("Testing log" .. id, function()
    local loadout = require("spec.fixtures.Log" .. id .. "Loadout")
    local parser = BattleLogParser:new(loadout)
    parseLogFile(
      parser,
      "spec/fixtures/Log" .. id .. ".txt"
    )

    assert.are.equal(expectedRound, parser.round)

    local expected = readFile(
      "spec/fixtures/Log" .. id .. "Result.txt"
    )

    assert.are.equal(expected, parser:FinishedParsing())
  end)
end

describe("core.BattleLogParser", function()
  testBattleLog("01", "8")
  testBattleLog("02", "6")
  testBattleLog("03", "11")
end)
