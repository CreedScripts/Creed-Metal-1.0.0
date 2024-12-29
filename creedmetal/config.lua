Config = {}

Config.MetalDetectorPrice = 500 -- Price of Metal Detector at shop


Config.DiscordWebhook = "YOURWEBHOOKHERE" -- Replace with your actual webhook URL


Config.NPCLocation = vector4(-1510.18, -926.95, 10.16, 149.41) -- Location of Metal Detector shop

Config.DetectZones = {
    {
        name = "Metal Detecting Zone 1",
        coords = vector3(-1484.6450, -1315.2947, 2.5423),
        radius = 75.0,
        rewards = {
            { item = "plastic", chance = 20 },
            { item = "steel", chance = 20 },
            { item = "copper", chance = 20 },
            { item = "rustynail", chance = 35 },
            { item = "gun_case", chance = 5 },
            { item = "toycar", chance = 30 },
            { item = "goldtoycar", chance = 10 },
            { item = "goldwatch", chance = 10 },
        }
    },
    {
        name = "Metal Detecting Zone 2",
        coords = vector3(3352.4316, 5504.3857, 19.6174),
        radius = 100.0,
        rewards = {
            { item = "plastic", chance = 20 },
            { item = "steel", chance = 20 },
            { item = "metalscrap", chance = 20 },
            { item = "rustynail", chance = 35 },
            { item = "gun_case", chance = 5 },
            { item = "old_watch", chance = 10 },
            { item = "broken_phone", chance = 20 },
        }
    },
    {
        name = "Metal Detecting Zone 3",
        coords = vector3(1276.5060, 2451.6243, 74.1774),
        radius = 100.0,
        rewards = {
            { item = "plastic", chance = 20 },
            { item = "steel", chance = 20 },
            { item = "iron", chance = 20 },
            { item = "gun_case", chance = 5 },
            { item = "old_coin", chance = 10 },
            { item = "chain", chance = 15 },
            { item = "goldtoycar", chance = 10 },
        }
    }
}

-- Items and their sell prices
Config.SellItems = {
    { item = "plastic", price = 900 },
    { item = "steel", price = 900 },
    { item = "copper", price = 900 },
    { item = "iron", price = 900 },
    { item = "rustynail", price = 100 },
    { item = "old_coin", price = 2000 },
    { item = "old_watch", price = 2000 },
    { item = "chain", price = 1900 },
    { item = "toycar", price = 700 },
    { item = "goldtoycar", price = 2500 },
    { item = "broken_phone", price = 900 },
    { item = "goldwatch", price = 2500 },
    { item = "metalscrap", price = 900 },
}
