local CreedCore = exports['creedlib']:getCoreObject()

-- Purchase Metal Detector Event
RegisterNetEvent('creed:purchaseMetalDetector', function(quantity)
    local src = source
    local Player = CreedCore.Functions.GetPlayer(src)
    local price = Config.MetalDetectorPrice * quantity

    if Player and Player.Functions.RemoveMoney('cash', price) then
        Player.Functions.AddItem('metal_detector', quantity)
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = 'You purchased ' .. quantity .. ' metal detector(s) for $' .. price .. '.',
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'You do not have enough money.',
        })
    end
end)

-- Give Reward Event
RegisterNetEvent('creed:giveReward', function(item)
    local src = source
    local Player = CreedCore.Functions.GetPlayer(src)

    if Player then
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = 'You found an item!',
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Error giving reward. Please try again.',
        })
    end
end)

-- Sell All Items Event
RegisterNetEvent('creed:sellAllItems', function()
    local src = source
    local Player = CreedCore.Functions.GetPlayer(src)
    local totalEarnings = 0

    if Player then
        for _, sellItem in ipairs(Config.SellItems) do
            local item = Player.Functions.GetItemByName(sellItem.item)
            if item then
                local itemCount = item.amount
                Player.Functions.RemoveItem(sellItem.item, itemCount)
                totalEarnings = totalEarnings + (itemCount * sellItem.price)
            end
        end

        if totalEarnings > 0 then
            Player.Functions.AddMoney('cash', totalEarnings)
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'You sold all items for $' .. totalEarnings .. '.',
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'You have no items to sell.',
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Error processing your request. Please try again.',
        })
    end
end)

-- Sell Specific Item Event
RegisterNetEvent('creed:sellItem', function(itemName)
    local src = source
    local Player = CreedCore.Functions.GetPlayer(src)

    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        local sellPrice = nil

        for _, sellItem in ipairs(Config.SellItems) do
            if sellItem.item == itemName then
                sellPrice = sellItem.price
                break
            end
        end

        if item and sellPrice then
            local itemCount = item.amount
            Player.Functions.RemoveItem(itemName, itemCount)
            Player.Functions.AddMoney('cash', itemCount * sellPrice)
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'You sold ' .. itemCount .. ' ' .. itemName .. '(s) for $' .. (itemCount * sellPrice) .. '.',
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'You do not have this item to sell.',
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Error processing your request. Please try again.',
        })
    end
end)

-- Log to Discord Event
RegisterNetEvent('creed:logDiscord', function(title, description, color)
    local src = source
    local playerName = GetPlayerName(src)
    local playerIdentifiers = GetPlayerIdentifiers(src)
    local discordIdentifier = nil
    local webhookURL = Config.DiscordWebhook 

    if not webhookURL then return end 

    -- Retrieve the Discord identifier
    for _, identifier in ipairs(playerIdentifiers) do
        if string.find(identifier, "discord:") then
            discordIdentifier = string.gsub(identifier, "discord:", "") 
            break
        end
    end

    local discordMention = discordIdentifier and "<@" .. discordIdentifier .. ">" or "N/A"

    local embed = {{
        ["title"] = title,
        ["description"] = description .. '\n\n**Player:** ' .. playerName .. '\n**Discord:** ' .. discordMention,
        ["color"] = color == 'green' and 3066993 or color == 'red' and 15158332 or color == 'blue' and 3447003 or 0,
        ["footer"] = {
            ["text"] = os.date('%Y-%m-%d %H:%M:%S'),
        }
    }}

    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = 'Creed Metal Detector Logs',
        embeds = embed,
    }), {['Content-Type'] = 'application/json'})
end)
