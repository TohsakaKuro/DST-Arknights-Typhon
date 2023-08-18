local i18n = require('i18n')

-- 提丰
local characterName = 'arknights_typhon'
local upperName = string.upper(characterName)
table.insert(PrefabFiles, characterName)

STRINGS.CHARACTER_TITLES[characterName] = i18n('character.typhon.title')
STRINGS.CHARACTER_NAMES[characterName] = i18n('character.typhon.name')
STRINGS.CHARACTER_DESCRIPTIONS[characterName] = i18n('character.typhon.description')
STRINGS.CHARACTER_QUOTES[characterName] = i18n('character.typhon.quote')
