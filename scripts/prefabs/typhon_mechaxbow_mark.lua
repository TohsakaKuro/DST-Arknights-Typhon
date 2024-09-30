local assets =
{
    Asset("ANIM", "anim/typhon_mechaxbow_mark.zip"),
    -- Add any additional assets here
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:SetPristine()

    -- Add components and functionality here

    inst:AddTag("typhon_mechaxbow_mark")

    if not TheWorld.ismastersim then
        return inst
    end
    -- local yOffset = 0.5;
    -- local parent = inst.entity:GetParent()
    -- if parent then
    --     local size = parent.Physics:GetRadius()
    --     print("typhon_mechaxbow_mark size: ", size)
    --     yOffset = size * yOffset
    -- end
    -- inst.Transform:SetPosition(0, yOffset, 0)
    inst.AnimState:SetBank("typhon_mechaxbow_mark")
    inst.AnimState:SetBuild("typhon_mechaxbow_mark")
    inst.AnimState:PlayAnimation("marked", true)

    -- Add network components here

    return inst
end

return Prefab("typhon_mechaxbow_mark", fn, assets)