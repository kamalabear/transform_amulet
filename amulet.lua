-- Transforming Amulet definitions

local modpath = minetest.get_modpath("transform")
dofile(modpath .. "/amulet_actions.lua")

minetest.register_craftitem(
    "transform:amulet",
    {
        description = "Transformation Amulet",
        inventory_image = "amulet_front.png",
        light_source = minetest.LIGHT_MAX,
        on_use = function(itemstack, user, pointed_thing)

            -- See if the pointed_thing is an animal / entity
            if pointed_thing and pointed_thing.ref then
                -- Put the clicked animal in the inventory
                local animal = pointed_thing.ref:get_luaentity().name
                minetest.log("Putting " .. animal .. " into inventory of " .. itemstack:get_name())
                amulet.add_animal(user:get_wielded_item(), pointed_thing.ref)
            end
        end,
        on_secondary_use = function(itemstack, user, pointed_thing)
            minetest.log("Opening amulet inventory for " .. itemstack:get_name())

            local animals = amulet.get_animals_for_amulet(user:get_wielded_item())
            local x = 0
            local y = 0
            local formspec_items = ""

            for i, v in pairs(animals) do
                if v then
                    local name = i
                    minetest.log("Creating a button for " .. name)
                    local button = "item_image_button[" .. x .. "," .. y .. ";1.0,1.0;" .. name .. ";animal;]"
                    minetest.log(button)
                    formspec_items = formspec_items .. button
                    x = x + 1
                    if x == 8 then
                        x = 0
                        y = y + 1
                    end
                end
            end

            local formspec =
                    "formspec_version[4]" ..
                    "size[8,3]" ..
                    "label[0.5,0.5;Animals]" ..
                    "scrollbaroptions[min=0;max=" .. y .. ";smallstep=1;largestep=2;thumbsize=105;arrows=default]" ..
                    "scrollbar[7.8,0.8;0.2,2.5;vertical;program_scroll;0-" .. y .. "]" ..
                    "scroll_container[0,1.0;9.5,3.0;program_scroll;vertical;0.1]" ..
                    formspec_items ..
                    "scroll_container_end[]"

            minetest.show_formspec(
                user:get_player_name(),
                "transform:amulet_inventory",
                formspec
            )

            minetest.register_on_player_receive_fields(
                function(player, formname, fields)
                    minetest.log("Processing fields received")

                    -- Get user selection
                    if formname ~= "transform:amulet_inventory" or not fields.animal then
                        -- If it's not input from our inventory, do nothing
                        return
                    end

                    if fields.quit then
                        -- closed the inventory
                        return
                    end

                    amulet.transform(player, fields.animal)
            end
            )
        end,

    }
)
minetest.register_craft(
    {
        output = "transform:amulet",
        recipe = {
            {"", "default:gold_ingot", ""},
            {"default:mese_crystal", "default:diamond", "default:mese_crystal"},
            {"", "transform:animal_gem", ""}
        }
    }
)
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    amulet.setup_inventory(player)
end)