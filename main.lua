local surface = require('gamesense/surface')
local font = surface.create_font("Verdana", 12, 800, 0x200)

local ev0_esp = {
    toggle = ui.new_checkbox("lua", "a", "[ev0] Enable"),
    boxstyle = ui.new_combobox("lua", "a", "[ev0] Box style", {"None", "Bounding", "Bounding Corner"}),
    healthstyle = ui.new_combobox("lua", "a", "[ev0] Healthstyle", {"None", "Text", "Bar Right", "Bar Left", "Bar Bottom"}),
    filled_box = ui.new_checkbox("lua", "a", "[ev0] Filled box"),
    filled_box_alpha = ui.new_slider("lua", "a", "[ev0] Fill Alpha", 0, 255, 255, true, ""),
    head_dot = ui.new_checkbox("lua", "a", "[ev0] Headdot"),
    name = ui.new_checkbox("lua", "a", "[ev0] Show Name"),
    weapon = ui.new_checkbox("lua", "a", "[ev0] Show Weapon")
}

local weapons = {
    [1] = "Desert Eagle",
    [2] = "Dual Berettas",
    [3] = "Five-SeveN",
    [4] = "Glock-18",
    [7] = "AK-47",
    [8] = "AUG",
    [9] = "AWP",
    [10] = "FAMAS",
    [11] = "G3SG1",
    [13] = "Galil AR",
    [14] = "M249",
    [16] = "M4A4",
    [17] = "MAC-10",
    [19] = "P90",
    [23] = "MP5-SD",
    [24] = "UMP-45",
    [25] = "XM1014",
    [26] = "PP-Bizon",
    [27] = "MAG-7",
    [28] = "Negev",
    [29] = "Sawed-Off",
    [30] = "Tec-9",
    [31] = "Taser",
    [32] = "P2000",
    [33] = "MP7",
    [34] = "MP9",
    [35] = "Nova",
    [36] = "P250",
    [38] = "SCAR-20",
    [39] = "SG 553",
    [40] = "SSG 08",
    [41] = "Knife",
    [42] = "Knife",
    [43] = "Flashbang",
    [44] = "HE Grenade",
    [45] = "Smoke",
    [46] = "Molotov",
    [47] = "Decoy",
    [48] = "Incendiary",
    [49] = "C4",
    [59] = "Knife",
    [60] = "M4A1-S",
    [61] = "USP-S",
    [63] = "CZ75-Auto",
    [64] = "R8 Revolver",
    [500] = "Bayonet",
    [505] = "Flip Knife",
    [506] = "Gut Knife",
    [507] = "Karambit",
    [508] = "M9 Bayonet",
    [509] = "Huntsman Knife",
    [512] = "Falchion Knife",
    [514] = "Bowie Knife",
    [515] = "Butterfly Knife",
    [516] = "Shadow Daggers",
    [519] = "Ursus Knife",
    [520] = "Navaja Knife",
    [522] = "Siletto Knife",
    [523] = "Talon Knife",
}

local function localplayer()
    local real_lp = entity.get_local_player()
    if entity.is_alive(real_lp) then
        return real_lp
    else
        local obvserver = entity.get_prop(real_lp, "m_hObserverTarget")
        return obvserver ~= nil and obvserver <= 64 and obvserver or nil
    end
end

local function collect_players()
    local results = {}
    local lp_origin = {entity.get_origin(localplayer())}

    for i=1, 64 do
        if entity.is_alive(i) then
            local player_origin = {entity.get_origin(i)}
            if player_origin[1] ~= nil and lp_origin[1] ~= nil then
                table.insert(results, {i})
            end
        end
    end
    return results
end

local function HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        elseif i == 5 then r, g, b = v, p, q
    end
  
    return r * 255, g * 255, b * 255
end

local function lerp(h1, s1, v1, h2, s2, v2, t)
    local h = (h2 - h1) * t + h1
    local s = (s2 - s1) * t + s1
    local v = (v2 - v1) * t + v1
    return h, s, v
end

local function draw_main_esp()
    if not ui.get(ev0_esp.toggle) then return end
    local enemies = collect_players()
    for i=1, #enemies do
        local enemy = unpack(enemies[i])
        if entity.is_enemy(enemy) then
            local bbox = {entity.get_bounding_box(enemy)}
            if bbox[1] ~= nil or bbox[2] ~= nil or bbox[3] ~= nil or bbox[4] ~= nil or bbox[5] ~= 0 then
                local height, width = bbox[4]-bbox[2], bbox[3]-bbox[1]
                local name = entity.get_player_name(enemy)
                if name == nil then return end
                if ui.get(ev0_esp.healthstyle) then
                    local health = entity.get_prop(enemy, "m_iHealth")
                    local h, s, v = lerp(0, 1, 1, 120, 1, 1, health*0.01)
                    local hr, hg, hb = HSVToRGB(h/360, s, v)
                    local health_color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {hr, hg, hb, 255}
                    if ui.get(ev0_esp.healthstyle) == "Bar Bottom" then
                        renderer.rectangle(bbox[1]-1, bbox[4]+2, width+2, 4, 17, 17, 17, 255)
                        renderer.rectangle(bbox[1], bbox[4]+3, (width*health/100), 2, health_color[1], health_color[2], health_color[3], 255)
                    elseif ui.get(ev0_esp.healthstyle) == "Bar Left" then
                        renderer.rectangle(bbox[1]-7, bbox[2]-1, 4, height+2, 17, 17, 17, 255)
                        renderer.rectangle(bbox[1]-6, bbox[2]+height, 2, -(height*health/100), health_color[1], health_color[2], health_color[3], 255)
                    elseif ui.get(ev0_esp.healthstyle) == "Bar Right" then
                        renderer.rectangle(bbox[3]+3, bbox[2]-1, 4, height+2, 17, 17, 17, 255)
                        renderer.rectangle(bbox[3]+4, bbox[2]+height, 2, -(height*health/100), health_color[1], health_color[2], health_color[3], 255)
                    elseif ui.get(ev0_esp.healthstyle) == "Text" then
                        local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                        local health = entity.get_prop(enemy, "m_iHealth")
                        surface.draw_text(bbox[3]+3, bbox[2], color[1], color[2], color[3], 255, font, string.format("%s HP", health))
                    end
                end
                if ui.get(ev0_esp.boxstyle) == "Bounding" then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 76, 60, 255}
                    surface.draw_outlined_rect(bbox[1], bbox[2], width, height, color[1], color[2], color[3], 255)
                    surface.draw_outlined_rect(bbox[1]-1, bbox[2]-1, width+2, height+2, 0,0,0,255)
                    surface.draw_outlined_rect(bbox[1]+1, bbox[2]+1, width-2, height-2, 0,0,0,255)
                elseif ui.get(ev0_esp.boxstyle) == "Bounding Corner" then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 76, 60, 255}
                    -- toplo
                    renderer.rectangle(bbox[1]-1, bbox[2], 3, height/6, 0,0,0,255)
                    renderer.rectangle(bbox[1]-1, bbox[2]-1, width/6+3, 3, 0,0,0,255)

                    -- topro
                    
                    renderer.rectangle(bbox[3]-2, bbox[2], 3, height/6, 0,0,0,255)
                    renderer.rectangle(bbox[3]+1, bbox[2]-1, -width/6-3, 3, 0,0,0,255)

                    --bottomro
                    
                    renderer.rectangle(bbox[3]-2, bbox[4]-1, 3, -height/6, 0,0,0,255)
                    renderer.rectangle(bbox[3]+1, bbox[4]-2, -width/6-3, 3, 0,0,0,255)

                    --bottomlo

                    renderer.rectangle(bbox[1]-1, bbox[4]-1, 3, -height/6, 0,0,0,255)
                    renderer.rectangle(bbox[1]-1, bbox[4]-2, width/6+3, 3, 0,0,0,255)
                    
                    -- topl
                    renderer.rectangle(bbox[1], bbox[2], 1, height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[1], bbox[2], width/6+1, 1, color[1], color[2], color[3], 255)

                    -- topr

                    renderer.rectangle(bbox[3]-1, bbox[2], 1, height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[3], bbox[2], -width/6-1, 1, color[1], color[2], color[3], 255)

                    --bottomr
                    renderer.rectangle(bbox[3]-1, bbox[4], 1, -height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[3], bbox[4]-1, -width/6-1, 1, color[1], color[2], color[3], 255)

                    --bottoml
                    renderer.rectangle(bbox[1], bbox[4], 1, -height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[1], bbox[4]-1, width/6, 1, color[1], color[2], color[3], 255)
                end

                if ui.get(ev0_esp.filled_box) then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 76, 60, 255}
                    renderer.rectangle(bbox[1]+1, bbox[2]+1, width-2, height-2, color[1], color[2], color[3], ui.get(ev0_esp.filled_box_alpha))
                end

                if ui.get(ev0_esp.head_dot) then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 76, 60, 255}
                    local hitbox = {entity.hitbox_position(enemy, 0)}
                    local hitbox_position = {renderer.world_to_screen(hitbox[1], hitbox[2], hitbox[3])}
                    renderer.rectangle(hitbox_position[1], hitbox_position[2], 3, 3, color[1], color[2], color[3], 255)
                end

                if ui.get(ev0_esp.name) then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}

                    if name:len() > 15 then 
                        name = name:sub(0, 15)
                    end
        
                    local wide, tall = surface.get_text_size(font, name)
        
                    local middle_x = (bbox[1] - bbox[3]) / 2
        
                    surface.draw_text(bbox[1] - wide / 2 - middle_x, bbox[2]-16, color[1], color[2], color[3], 255, font, name)
                end

                if ui.get(ev0_esp.weapon) then
                    local weapon_id = entity.get_prop(enemy, "m_hActiveWeapon")
                    if entity.get_prop(weapon_id, "m_iItemDefinitionIndex") ~= nil then
                        weapon_item_index = bit.band(entity.get_prop(weapon_id, "m_iItemDefinitionIndex"), 0xFFFF)
                    end
                    local weapon_name = weapons[weapon_item_index]
                    if weapon_name == nil then return end
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                    if weapon_name:len() > 15 then 
                        weapon_name = weapon_name:sub(0, 15)
                    end
        
                    local wide, tall = surface.get_text_size(font, weapon_name)
        
                    local middle_x = (bbox[1] - bbox[3]) / 2
        
                    surface.draw_text(bbox[1] - wide / 2 - middle_x, bbox[4]+(ui.get(ev0_esp.healthstyle) == "Bar Bottom" and 6 or 2), color[1], color[2], color[3], 255, font, weapon_name)
                end
            end
        end
    end
end

client.set_event_callback("paint", function()
    if localplayer() == nil then
        return
    end
    draw_main_esp()
end)
