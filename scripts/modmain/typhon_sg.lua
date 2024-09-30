local function eventPostInit(self)
  local oldAttackDestState = self.actionhandlers[ACTIONS.ATTACK].deststate
  self.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
    if inst.skill3Trigger ~= nil and inst.skill3Trigger:value() then
      print("goto sg typhon_skill3_shoot")
      return "typhon_skill3_shoot"
    end
    return oldAttackDestState(inst, action)
  end
end

AddStategraphPostInit("wilson", eventPostInit)
AddStategraphPostInit("wilson_client", eventPostInit)