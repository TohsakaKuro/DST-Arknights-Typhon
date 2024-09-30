local assets =
{
    Asset("ANIM", "anim/typhon_mechaxbow_arrow_shoot.zip"),
    -- Add any additional assets here
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.Transform:SetPosition(0, 0, 0)
    inst.entity:SetPristine()

    -- Add components and functionality here

    inst:AddTag("typhon_mechaxbow_arrow_shoot")

    if not TheWorld.ismastersim then
        return inst
    end
    inst.AnimState:SetBank("typhon_mechaxbow_arrow_shoot")
    inst.AnimState:SetBuild("typhon_mechaxbow_arrow_shoot")
    inst.AnimState:PlayAnimation("arrow")

    -- Add network components here

    return inst
end

return Prefab("typhon_mechaxbow_arrow_shoot", fn, assets)