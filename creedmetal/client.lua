local CreedCore = exports['creedlib']:getCoreObject()

local boneoffsets = {
    ["w_am_metaldetector"] = {
        bone = 18905, 
        offset = vector3(0.15, 0.1, 0.0), 
        rotation = vector3(-100.0, 0.0, 0.0), 
    },
}



local CreedCore = exports['creedlib']:getCoreObject()

local function AttachEntity(ped, model)
    if boneoffsets[model] then
        CreedCore.Functions.LoadModel(model) -- This will now work seamlessly
        local pos = GetEntityCoords(ped)
        local ent = CreateObjectNoOffset(GetHashKey(model), pos.x, pos.y, pos.z, true, true, false)

        AttachEntityToEntity(ent, ped, GetPedBoneIndex(ped, boneoffsets[model].bone),
            boneoffsets[model].offset.x, boneoffsets[model].offset.y, boneoffsets[model].offset.z,
            boneoffsets[model].rotation.x, boneoffsets[model].rotation.y, boneoffsets[model].rotation.z,
            true, true, false, true, 2, true)

        return ent
    else
        print("Bone offsets not found for model:", model)
    end
end



local function PlayDetectingEmote(ped)
    RequestAnimDict('mini@golfai') 
    while not HasAnimDictLoaded('mini@golfai') do
        Wait(10)
    end
    TaskPlayAnim(ped, 'mini@golfai', 'wood_idle_a', 8.0, -8.0, -1, 49, 0, false, false, false)
end


local function PlayDiggingEmote(ped)
    RequestAnimDict('amb@world_human_gardener_plant@male@base')
    while not HasAnimDictLoaded('amb@world_human_gardener_plant@male@base') do
        Wait(10)
    end
    TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
end


local function getRewardForZone(currentZone)
    local rand = math.random(100) 
    local cumulativeChance = 0

    for _, reward in ipairs(currentZone.rewards) do
        cumulativeChance = cumulativeChance + reward.chance
        if rand <= cumulativeChance then

            return reward.item 
        end
    end


    print('Debug: No item selected. Random:', rand)
    return nil
end


CreateThread(function()
    local pedModel = `a_m_m_farmer_01` -- NPC model
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    local npc = CreatePed(4, pedModel, Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z - 1.0, Config.NPCLocation.w, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'buy_metal_detector',
            icon = 'fas fa-shopping-cart',
            label = 'Buy Metal Detector',
            onSelect = function()
                TriggerEvent('creed:buyMetalDetector')
            end
        },
        {
            name = 'sell_metal_detector_items',
            icon = 'fas fa-dollar-sign',
            label = 'Sell Metal Detector Items',
            onSelect = function()
                TriggerEvent('creed:sellMetalDetectorItems')
            end
        }
    })
    

    
    local blip = AddBlipForCoord(Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z)
    SetBlipSprite(blip, 605) 
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Metal Detector Shop')
    EndTextCommandSetBlipName(blip)
end)


CreateThread(function()
    for _, zone in ipairs(Config.DetectZones) do
        local zoneBlip = AddBlipForRadius(zone.coords, zone.radius)
        SetBlipColour(zoneBlip, 3) 
        SetBlipAlpha(zoneBlip, 128) 

        local labelBlip = AddBlipForCoord(zone.coords)
        SetBlipSprite(labelBlip, 365) 
        SetBlipDisplay(labelBlip, 4)
        SetBlipScale(labelBlip, 0.8)
        SetBlipColour(labelBlip, 3)
        SetBlipAsShortRange(labelBlip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(zone.name) 
        EndTextCommandSetBlipName(labelBlip)
    end
end)


RegisterNetEvent('creed:buyMetalDetector', function()
    local options = {
        {
            title = 'Buy Metal Detector for $' .. Config.MetalDetectorPrice,
            description = 'Enter the quantity you want to purchase.',
            event = 'creed:confirmMetalDetectorPurchase',
        }
    }

    lib.registerContext({
        id = 'metal_detector_menu',
        title = 'Metal Detector Shop',
        options = options
    })

    lib.showContext('metal_detector_menu')


    TriggerServerEvent('creed:logDiscord', 'Metal Detector Shop Accessed', 'Player accessed the metal detector shop.', 'blue')
end)

RegisterNetEvent('creed:confirmMetalDetectorPurchase', function()
    local input = lib.inputDialog('Purchase Metal Detectors', {
        {type = 'number', label = 'Quantity', default = 1}
    })

    if input and input[1] > 0 then
        local quantity = tonumber(input[1])
        TriggerServerEvent('creed:purchaseMetalDetector', quantity)


        TriggerServerEvent('creed:logDiscord', 'Metal Detector Purchase', 'Player purchased ' .. quantity .. ' metal detector(s) for $' .. (Config.MetalDetectorPrice * quantity) .. '.', 'green')
    else
        lib.notify({type = 'error', description = 'Invalid quantity entered.'})


        TriggerServerEvent('creed:logDiscord', 'Invalid Purchase Attempt', 'Player entered an invalid quantity when trying to purchase a metal detector.', 'red')
    end
end)

RegisterNetEvent('creed:sellMetalDetectorItems', function()
    local sellOptions = {}

    for _, sellItem in ipairs(Config.SellItems) do
        table.insert(sellOptions, {
            title = sellItem.item .. " - $" .. sellItem.price .. " each",
            description = "Sell all of your " .. sellItem.item .. ".",
            event = 'creed:confirmSellItem',
            args = { item = sellItem.item, price = sellItem.price }
        })
    end

    table.insert(sellOptions, {
        title = "Sell All Items",
        description = "Sell all the items you have in one go.",
        event = 'creed:sellAllMetalDetectorItems'
    })

    lib.registerContext({
        id = 'sell_metal_detector_items',
        title = 'Sell Metal Detector Items',
        options = sellOptions
    })

    lib.showContext('sell_metal_detector_items')


    TriggerServerEvent('creed:logDiscord', 'Sell Menu Accessed', 'Player accessed the sell menu for metal detector items.', 'blue')
end)

RegisterNetEvent('creed:confirmSellItem', function(data)

    TriggerServerEvent('creed:sellItem', data.item, data.price)
end)

RegisterNetEvent('creed:sellAllMetalDetectorItems', function()

    TriggerServerEvent('creed:sellAllItems')
end)



local function getCurrentZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(Config.DetectZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            return zone
        end
    end
    return nil
end


RegisterNetEvent('creed:useMetalDetector', function()
    if isMetalDetecting then
        lib.notify({ type = 'error', description = 'You are already using the metal detector!' })
        return
    end

    local currentZone = getCurrentZone()
    if currentZone then
        isMetalDetecting = true 
        lib.notify({ type = 'success', description = 'You start searching the area in ' .. currentZone.name .. '...' })

        local playerPed = PlayerPedId()
        local propModel = "w_am_metaldetector" 
        local metalDetectorProp = AttachEntity(playerPed, propModel)

        PlayDetectingEmote(playerPed)

        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, 'metaldetector', 0.2)

        local searchTime = math.random(5000, 15000)
        Wait(searchTime)

        lib.notify({ type = 'success', description = 'You have found an item!' })
        Wait(1000) 

        local success = lib.skillCheck(
            { 'easy', 'easy' },
            { 'e', 'e', 'e', 'e' }
        )

        if not success then
            lib.notify({ type = 'error', description = 'You failed to uncover the item.' })
            if DoesEntityExist(metalDetectorProp) then
                DeleteObject(metalDetectorProp) 
            end
            ClearPedTasksImmediately(playerPed) 
            isMetalDetecting = false 
            return
        end

        if DoesEntityExist(metalDetectorProp) then
            DeleteObject(metalDetectorProp) 
        end
        ClearPedTasksImmediately(playerPed) 

        PlayDiggingEmote(playerPed)

        lib.progressCircle({
            duration = 5000,
            label = 'Uncovering the item...',
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = { car = true, move = true, combat = true }
        })

        ClearPedTasksImmediately(playerPed)

        local rewardedItem = getRewardForZone(currentZone)
        TriggerServerEvent('creed:giveReward', rewardedItem)


        TriggerServerEvent('creed:logDiscord', "Metal Detecting", "**Player:** " .. GetPlayerName(PlayerId()) .. "\n**Item Found:** " .. (rewardedItem or "None") .. "\n**Zone:** " .. currentZone.name, "blue")

        isMetalDetecting = false
    else
        lib.notify({ type = 'error', description = 'You are not in a metal detecting zone!' })
    end
end)
