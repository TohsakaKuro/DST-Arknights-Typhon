local assets =
{
    Asset("ANIM", "anim/typhon_mechaxbow_arrow.zip"),
    -- Add any additional assets here
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.Transform:SetPosition(0, 0, 0)
    inst.Transform:SetScale(2, 2, 2)
    inst.entity:SetPristine()

    -- Add components and functionality here

    inst:AddTag("typhon_mechaxbow_arrow")

    if not TheWorld.ismastersim then
        return inst
    end
    inst.AnimState:SetBank("typhon_mechaxbow_arrow")
    inst.AnimState:SetBuild("typhon_mechaxbow_arrow")
    inst.AnimState:PlayAnimation("arrow")

    -- Add network components here

    return inst
end

return Prefab("typhon_mechaxbow_arrow", fn, assets)