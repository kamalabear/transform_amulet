amulet = {}

-- Sets up the inventory for a newly created amulet.  The inventory
-- keeps track of the animals that have been touched by this amulet.
-- The inventory is stored in the metadata of the itemstack.  The
-- key for the inventory is 'animals' and the value is a stringified
-- JSON object.
-- amulet is an ItemStack
amulet.setup_inventory = function(user)
    local meta = user:get_meta()
    meta.set_string("animals", "{}")
end

-- Adds the animal to the amulet's inventory, if it's not already
-- known.
-- amulet is an ItemStack
-- animal is an Entity
amulet.add_animal = function(user, animal)
    local name = animal:get_luaentity().name
    local meta = user:get_meta()
    local json = amulet.animal_to_json(animal)
    if not meta.get_string(name) then
        meta:set_string(name, json)
    end
end

amulet.animal_to_json = function(animal)
    local name = animal:get_luaentity().name
    local props = animal:get_luaentity():get_properties()
    props["name"] = name
    return minetest.write_json(props)
end

amulet.animal_from_json = function(json_animal)
    local name = json_animal["name"]
    local props = minetest.parse_json(json_animal)
    local animal = LuaEntity()
    animal:set_name(name)
    animal:set_properties(props)
end

-- Returns a table of animals known to an amulet.
-- amulet is an ItemStack
amulet.get_animals_for_amulet = function(amulet)
    local known = {}
    local animals = amulet:get_meta():to_table()
    minetest.log(dump(animals))
    utils.log_attributes(animals, "animals known to amulet")
    for k, v in pairs(animals) do -- loop through the animals known to the amulet
        -- look up the entity by name
        known[k] = minetest.registered_entities[k]
    end

    return known
end

-- Transforms the player into the animal.  This includes visual
-- appearance, capabilities (such as flying, speed, etc.), fears,
-- and durability.  There are two exceptions: the user's infotext
-- is retained as is the user's hitpoints, if the animal's hitpoints
-- are fewer.
-- player is a player Entity
-- animal is the string name of the animal entity, such as 'mobs_animal:cow' 
amulet.transform = function(player, animal)
    local animals = player:get_inventory():get_list("animal_properties")
    for k, v in pairs(animals) do
    -- items in an inventory list are indexed numerically, so we have to loop through looking for the animal we want
        if v:get_name() == animal then
            player.set_properties(v:get_meta():to_table())
            return
        end
        
    end
end

-- Stores the properties of an animal in the player inventory for
-- use in transformations.  The animal properties are stored in a
-- list called 'animal_properties'.
-- player is a player Entity
-- animal is an Entity
amulet.register_animal_properties = function(player, animal)
    -- Lazy setup list
    if player:get_inventory():is_empty("animal_properties") then
        player:get_inventory():set_size("animal_properties", math.max(99, #minetest.registered_entities))
         -- supports a max of 99 animals (max size of a list), but there can never be more than the
         -- number of registered entities, so save space if we can

        -- Add the player's properties to the list
        player:get_inventory():add_item("animal_properties", amulet.create_animal_stack(player))
    end

    local animals = player:get_inventory():get_list("animal_properties")

    -- See if the animal properties are already in the list
    for i, a in pairs(animals) do
        if a:get_name() == animal:get_name() then
            return
        end
    end
    player:get_inventory():add_item("animal_properties", amulet.create_animal_stack(animal))
end

-- Move animals from a user to a node.  For use when an amulet is dropped so that the animal
-- list stays with the amulet.
-- user is a player Entity
-- node_pos is the coordinates of a position
amulet.move_animals_to_node = function(user, node_pos)
    local animals = amulet.get_animals_from_user(user)
    amulet.put_animals_to_node(node_pos, animals)
end

-- Writes a JSON list of animals into the metadata of the node at the passed position.
-- node_pos is the coordinates of a position
-- animals is a JSON object
amulet.put_animals_to_node = function(node_pos, animals)
    local meta = minecraft.get_meta(node_pos)
    amulet.store_animals_in_meta(meta, animals)
end

-- Retrieves the animals known by the currently held amulet from the player metadata and returns them
-- in a JSON object.
-- user is a player Entity
amulet.get_animals_from_user = function(user)
    local animals = {}
    for k, v in pairs(user:get_inventory():get_list("animal_properties")) do
        animals[v:get_name()] = v:get_name()
    end
    return animals
end

-- Stores a list of animals in the passed metadata.
-- meta is a MetaDataRef
-- animals is a JSON object
amulet.store_animals_in_meta = function(meta, animals)
    meta:set_string("animals", animals)
end

-- Create a stack for an animal Entity.  Stores the properties of the animal in the ItemStack metadata.
-- animal is an Entity
amulet.create_animal_stack = function(animal)
    local props = animal:get_properties()
    local stack = ItemStack(animal)
    stack:set_name(animal:get_name())
    stack:get_meta():from_table(props)
    return stack
end
