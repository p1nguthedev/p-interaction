local interactable = false
local text3D = vector3(1623.0204, 3473.4985, 36.5775) 

local interactions = {}

local keyCodes = {
    ["A"] = 34,   ["B"] = 29,   ["C"] = 26,   ["D"] = 9,    ["E"] = 38,
    ["F"] = 23,   ["G"] = 47,   ["H"] = 74,   ["I"] = 311,  ["J"] = 245,
    ["K"] = 311,  ["L"] = 182,  ["M"] = 244,  ["N"] = 249,  ["O"] = 79,
    ["P"] = 199,  ["Q"] = 44,   ["R"] = 45,   ["S"] = 8,    ["T"] = 245,
    ["U"] = 303,  ["V"] = 0,    ["W"] = 32,   ["X"] = 73,   ["Y"] = 246,
    ["Z"] = 20,   ["NUMPAD_0"] = 92, ["NUMPAD_1"] = 36, ["NUMPAD_2"] = 37, ["NUMPAD_3"] = 38,
    ["NUMPAD_4"] = 39, ["NUMPAD_5"] = 40, ["NUMPAD_6"] = 41, ["NUMPAD_7"] = 42, ["NUMPAD_8"] = 43,
    ["NUMPAD_9"] = 44, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F4"] = 166,
    ["F5"] = 167, ["F6"] = 168, ["F7"] = 169, ["F8"] = 170, ["F9"] = 171,
    ["F10"] = 172, ["F11"] = 173, ["F12"] = 174
}

RegisterCommand('keytest', function()
    print(keyCodes["E"])
end)

CreateThread(function()
    local bounceAmplitude = 0.1 
    local bounceSpeed = 2.0 

    while true do
        local wait = 500  

        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, interaction in ipairs(interactions) do
            local startZ = interaction.coords.z 
            local time = GetGameTimer() / 1000.0
            local offset = math.sin(time * bounceSpeed) * bounceAmplitude
            local currentZ = startZ + offset

            local distance = #(playerCoords - interaction.coords)

            if distance < interaction.distance and distance >= 2.0 then
                Draw3DIcon(interaction.coords.x, interaction.coords.y, currentZ, 'p_interaction', 'circle-preview')
                wait = 0  
            elseif distance < 2.0 then
                Draw3DIconWithText(interaction.coords.x, interaction.coords.y, currentZ, 'p_interaction', 'key-container', interaction.key)
                Draw3DMessage(interaction.coords.x + 0.05, interaction.coords.y, currentZ, interaction.message)
                if IsControlJustReleased(1, keyCodes[interaction.key]) then 
                    if interaction.type == 'client' then
                        TriggerEvent(interaction.event)
                    elseif interaction.type == 'server' then
                        TriggerServerEvent(interaction.event)
                    end
                end
                wait = 0  
            end
        end

        Wait(wait)
    end
end)


function Draw3DIcon(x, y, z, dict, txtName)
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict, true)
        while not HasStreamedTextureDictLoaded(dict) do
            Wait(0)
        end
    end

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    local size = 0.025 
    DrawSprite(dict, txtName, _x, _y, size, size, 0.0, 255, 255, 255, 255)
end

function Draw3DIconWithText(x, y, z, dict, iconName, key)
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict, true)
        while not HasStreamedTextureDictLoaded(dict) do
            Wait(0)
        end
    end

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    local width = 0.02 
    local height = 0.03 

    DrawSprite(dict, iconName, _x, _y, width, height, 0.0, 255, 255, 255, 255)


    SetTextScale(0.55, 0.55)
    SetTextFont(2)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(key)
    DrawText(_x, _y - 0.018) 
end



function Draw3DMessage(x, y, z, message)

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    local textLength = string.len(message)
    local width = 0.08 
    local height = 0.03 
    local baseOffsetX = 0.025

    local offsetX = baseOffsetX + (textLength > 5 and 0.015 * math.pow((textLength - 5), 0.5) or 0)    

    local textSize = 0.45 
    local textOffsetY = 0.017
    local textOffsetX = 0.001 

    local adjustedX = _x + offsetX

    SetTextScale(textSize, textSize)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(2)

    AddTextComponentString(message)
    DrawText(adjustedX - textOffsetX, _y - textOffsetY) 
end

function AddInteraction(id, coords, distance, type, event, key, message)
    for _, interaction in ipairs(interactions) do
        if interaction.id == id then
            return 
        end
    end

    table.insert(interactions, {
        id = id,
        coords = coords,
        distance = distance,
        type = type,
        event = event,
        key = key,
        message = message
    })
end

function RemoveInteraction(id)
    for i, interaction in ipairs(interactions) do
        if interaction.id == id then
            table.remove(interactions, i)
            break
        end
    end
end