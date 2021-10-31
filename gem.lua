-- Animal Gem definitions
minetest.register_craftitem(
    "transform:animal_gem",
    {
        description = "Animal Gem",
        inventory_image = "gem_front.png",
        light_source = minetest.LIGHT_MAX / 2
    }
)
minetest.register_craft(
    {
        type = "shapeless",
        output = "transform:animal_gem",
        recipe = {"mobs:egg", "default:diamond"}
    }
)
