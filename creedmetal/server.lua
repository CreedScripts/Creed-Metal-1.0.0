local CreedCore = exports['creedlib']:getCoreObject()


local function isValidItem(itemName)
    for _, sellItem in ipairs(Config.SellItems) do
        if sellItem.item == itemName then
            return true
        end
    end

    for _, zone in ipairs(Config.DetectZones) do
        for _, reward in ipairs(zone.rewards) do
            if reward.item == itemName then
                return true
            end
        end
    end

    return false
end


local playerRewards = {}

local function trackPlayerRewards(playerId)
    local currentTime = os.time()
    if not playerRewards[playerId] then
        playerRewards[playerId] = {}
    end

    table.insert(playerRewards[playerId], currentTime)


    for i = #playerRewards[playerId], 1, -1 do
        if currentTime - playerRewards[playerId][i] > 10 then
            table.remove(playerRewards[playerId], i)
        end
    end


    if #playerRewards[playerId] > 5 then
        local playerName = GetPlayerName(playerId)
        local playerIdentifiers = GetPlayerIdentifiers(playerId)
        local discordIdentifier = nil


        for _, identifier in ipairs(playerIdentifiers) do
            if string.find(identifier, "discord:") then
                discordIdentifier = string.gsub(identifier, "discord:", "")
                break
            end
        end

        local discordMention = discordIdentifier and "<@" .. discordIdentifier .. ">" or "N/A"


        TriggerEvent('creed:logDiscord', 'Suspicious Activity Detected',
            string.format('Player **%s** (Discord: %s) triggered the reward event **%d times in 10 seconds**. Kicked for suspicious activity.',
            playerName, discordMention, #playerRewards[playerId]),
            'red')


        DropPlayer(playerId, "Kicked for triggering the reward event too many times in a short period. Suspicious activity detected.")
    end
end


RegisterNetEvent('creed:giveReward', function(item)
    local src = source
    local Player = CreedCore.Functions.GetPlayer(src)

    if isValidItem(item) then
        if Player then
            Player.Functions.AddItem(item, 1)
            trackPlayerRewards(src) 

            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'You found an item!',
            })

            TriggerEvent('creed:logDiscord', 'Reward Given',
                string.format('Player received **1 x %s**.', item), 'blue')
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'Error giving reward. Please try again.',
            })
        end
    else
        TriggerEvent('creed:logDiscord', 'Invalid Item Attempt',
            string.format('Player attempted to spawn an invalid item: **%s**.', item), 'red')

        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Pesky little cheater stop trying to spawn shit in!!!!',
        })
    end
end)


RegisterNetEvent('creed:sellAllItems', function()
    local src = source
    local Player = CreedCore.Functions.GetPlayer(src)
    local totalEarnings = 0
    local totalItemsSold = 0

    if Player then
        for _, sellItem in ipairs(Config.SellItems) do
            if isValidItem(sellItem.item) then
                local item = Player.Functions.GetItemByName(sellItem.item)
                if item then
                    local itemCount = item.amount
                    Player.Functions.RemoveItem(sellItem.item, itemCount)
                    totalEarnings = totalEarnings + (itemCount * sellItem.price)
                    totalItemsSold = totalItemsSold + itemCount
                end
            end
        end

        if totalEarnings > 0 then
            Player.Functions.AddMoney('cash', totalEarnings)
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'You sold all items for $' .. totalEarnings .. '.',
            })

            TriggerEvent('creed:logDiscord', 'All Items Sold',
                string.format('Player sold **%d items** for a total of **$%d**.', totalItemsSold, totalEarnings), 'green')
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


RegisterNetEvent('creed:sellItem', function(itemName)
    local src = source
    local Player = CreedCore.Functions.GetPlayer(src)

    if isValidItem(itemName) then
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

                TriggerEvent('creed:logDiscord', 'Item Sold',
                    string.format('Player sold **%d x %s** for **$%d**.', itemCount, itemName, itemCount * sellPrice), 'blue')
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
    else
        TriggerEvent('creed:logDiscord', 'Invalid Item Attempt',
            string.format('Player attempted to sell an invalid item: **%s**.', itemName), 'red')

        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Hahaha Pesky Cheater tried to spawn items in!!!',
        })
    end
end)


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

        TriggerEvent('creed:logDiscord', 'Metal Detector Purchased',
            string.format('Player purchased **%d** metal detector(s) for **$%d**.', quantity, price), 'green')
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'You do not have enough money.',
        })
    end
end)


RegisterNetEvent('creed:logDiscord', function(title, description, color)
    local src = source
    local playerName = GetPlayerName(src)
    local playerIdentifiers = GetPlayerIdentifiers(src)
    local discordIdentifier = nil
    local webhookURL = Config.DiscordWebhook

    if not webhookURL then return end

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



