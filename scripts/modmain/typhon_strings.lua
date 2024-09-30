local i18n = require('typhon_i18n')

STRINGS.CHARACTER_TITLES['typhon'] = i18n.get('character.typhon.title')
STRINGS.CHARACTER_NAMES['typhon'] = i18n.get('character.typhon.name')
STRINGS.CHARACTER_DESCRIPTIONS['typhon'] = i18n.get('character.typhon.description')
STRINGS.CHARACTER_QUOTES['typhon'] = i18n.get('character.typhon.quote')

local strings = i18n.get('strings')
-- 递归遍历strings, 与常量表STRINGS合并
local function mergeTable(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == 'table' then
      if not t1[k] then
        t1[k] = {}
      end
      mergeTable(t1[k], v)
    else
      t1[k] = v
    end
  end
end

mergeTable(STRINGS, strings)
