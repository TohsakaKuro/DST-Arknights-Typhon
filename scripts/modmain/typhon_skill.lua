local i18n = require('typhon_i18n')
local utils = require("../typhon_utils")
-- skill ui
local TyphonSkillUI = require('widgets/typhon_skill_ui')
AddClassPostConstruct('widgets/inventorybar', function(self, owner)
  local owner = owner or self.owner
  if (owner and owner:HasTag('typhon')) then
    local typhonSkillUI = self:AddChild(TyphonSkillUI(owner))
    self.typhonSkillUI = typhonSkillUI
    owner.skillUI = typhonSkillUI
    typhonSkillUI:MoveToBack()
    SendModRPCToServer(MOD_RPC['typhon']['syncSkillStatus'])
  end
end)
-- skill hotkey
-- 把config里的hotkey 提取出来, 快捷键与技能名称的映射
for k, v in pairs(TUNING.TYPHON_CONFIG.skills) do
  TheInput:AddKeyDownHandler(v.hotkey, function()
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local IsHUDActive = screen and screen.name == "HUD"
    if not IsHUDActive then
      return
    end
    SendModRPCToServer(MOD_RPC['typhon']['trySkill'], k, TheInput:IsKeyDown(KEY_CTRL))
  end)
end
AddClientModRPCHandler("typhon", "setSkillStatus", function(player, skillName, cdTime, buffTime, ammo, lock)
  if not player.skillUI then
    return
  end
  player.skillUI:SetSkillState({
    skillName = skillName,
    cdTime = cdTime,
    buffTime = buffTime,
    ammo = ammo,
    lock = lock
  })
end)

AddModRPCHandler("typhon", "syncSkillStatus", function(player)
  if not player.SyncSkillStatus then
    return
  end
  player:SyncSkillStatus()
end)

AddModRPCHandler("typhon", "trySkill", function(player, skillName, forceAttack)
  if not player.EmitSkill then
    return
  end
  player:EmitSkill(skillName, forceAttack)
end)

AddModRPCHandler("typhon", 'skill3Shoot', function(player, forceAttack) player:TrySkill3Shoot(forceAttack) end)

AddModRPCHandler("typhon", 'skill3ReadyShoot', function(player) player:TrySkill3ReadyShoot() end)

-- 在 modmain.lua 文件中

local function PostInitPlayerController(self)
  local _DoAttackButton = self.DoAttackButton
  self.DoAttackButton = function(self)
    print("DoAttackButton")
    if not self.inst:HasTag('typhon') then
      print("DoAttackButton, not typhon")
      return _DoAttackButton(self)
    end
    if not self.inst.skill3Trigger:value() then
      print("DoAttackButton, not skill3Trigger")
      return _DoAttackButton(self)
    end
    if not self.inst.skill3ReadyShoot:value() then
      print("DoAttackButton, not skill3ReadyShoot")
      return
    end
    if self.ismastersim then
      self.inst.TrySkill3Shoot()
    else
      SendModRPCToServer(MOD_RPC['typhon']['skill3Shoot'], TheInput:IsKeyDown(KEY_CTRL))
    end
  end
end

-- 使用 AddClassPostConstruct 来劫持 PlayerController 类
AddClassPostConstruct("components/playercontroller", PostInitPlayerController)
