local containers = require "containers"

containers.params.typhon_mechaxbow = {
    widget = {
        slotpos = {Vector3(0, 32 + 4, 0)},
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 15, 0)
    },
    usespecificslotsforitems = true,
    type = "hand_inv",
    excludefromcrafting = true
}
