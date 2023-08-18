GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

Assets = {}
PrefabFiles = {}

import 'modmain.typhon.lua'