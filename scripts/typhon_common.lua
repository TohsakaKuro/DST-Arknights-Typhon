
local REGISTERED_FIND_ATTACK_TARGET_TAGS = TheSim:RegisterFindTags({"_combat"}, {"INLIMBO"})

local function TargetIsHostile(inst, target)
  if inst.HostileTest ~= nil then
    return inst:HostileTest(target)
  elseif target.HostileToPlayerTest ~= nil then
    return target:HostileToPlayerTest(inst)
  else
    return target:HasTag("hostile")
  end
end

local function ValidateAttackTarget(inst, target, forceAttack)
  local combat = inst.replica.combat
  if not combat:CanTarget(target) then
    return false
  end
  local targetCombat = target.replica.combat
  if targetCombat ~= nil then
    if combat:IsAlly(target) then
      return false
    else
      if not forceAttack then
        if target.HostileToPlayerTest ~= nil and target:HasTag("shadowsubmissive")
          and not target:HostileToPlayerTest(inst) then
          return false
        else
          if targetCombat:GetTarget() ~= inst then
            -- must use force attack non-hostile creatures
            if not TargetIsHostile(inst, target) then
              return false
            end
            -- must use force attack on players' followers
            local follower = target.replica.follower
            if follower ~= nil then
              local leader = follower:GetLeader()
              if leader ~= nil and leader:HasTag("player") and leader.replica.combat:GetTarget() ~= inst then
                return false
              end
            end
          end
        end
      end
    end
  end
  return true
end
local function findTyphonSkillTargetEntities(inst, centerInst, range, forceAttack,  maxNum)
  local combat = inst.replica.combat
  if not combat then
    return {}
  end
  maxNum = maxNum or 10
  local x, y, z = centerInst.Transform:GetWorldPosition()
  print("findTyphonSkillTargetEntities", x, y, z, range)
  local entities = TheSim:FindEntities_Registered(x, y, z, range, REGISTERED_FIND_ATTACK_TARGET_TAGS)
  -- 从entities中过滤出符合条件的实体, 即存在 target.replica.combat:CanBeAttacked(ThePlayer) 为true的实体
  local targetEntities = {}
  for i, v in ipairs(entities) do
    if (ValidateAttackTarget(inst, v, forceAttack)) then
      table.insert(targetEntities, v)
      if #targetEntities >= maxNum then
        break
      end
    end
  end
  return targetEntities
end

return {
  findTyphonSkillTargetEntities = findTyphonSkillTargetEntities,
}