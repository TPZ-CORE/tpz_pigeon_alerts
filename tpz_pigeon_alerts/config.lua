Config = {}	

Config.DevMode                             = false

Config.SaveInDatabase                      = false -- If set to true, all the alerts will be saved in the tp_alerts database table.

Config.DiscordWebhooking = {
    Label = "Daisy Valley",
    ImageUrl = "https://i.imgur.com/YUTYbMp.png",
    Footer = "© Daisy Town Support Team",
}

Config.RenderNPCDistance                   = 30

Config.CalledPigeonCooldown                = 300 -- The time the pigeon will stay and wait for the player to perform an action in seconds. If the player will not do in those seconds, the pigeon will leave. 
Config.CallPigeonCooldownAfterLeaving      = 60
Config.CallPigeonCooldownAfterSendingAlert = 150
Config.CallPigeonCooldownAfterSendingAlertOnUnconciousPlayer = 100000

Config.OpenStorePromptKey                  = 0x760A9C6F

Config.PigeonFleePromptKey                 = 0xB2F377E8
Config.CallPigeonCommand                   = "callpigeon"

Config.CancelRouteCommand                  = "cancelroute" -- The command to cancel the route, this command is also functional with other scripts to remove the route if bugged.
Config.RouteBlipCooldown                   = 120 -- The time the route blip (not route marker) will be removed in seconds.

-- If this is enabled and a medic accepts a route on a player who is unconscious, the player time is expanding by x2. 
Config.ExpandTimeRespawnOnMedicRoute       = true
Config.MedicJob                            = "medic" -- This is for avoiding looping through all the alert jobs to find the medic job.

Config.AlertsReviewBookItem                = "alert_book_archives" -- This book will be able to be opened only by the jobs that are allowed in Config.Alerts

Config.TrainedPigeonCost                   = 5 -- The cost when purchasing a Trained Pigeon. A Trained Pigeon can be purchased only once.
Config.TrainedPigeonCostMethodType         = 0 -- The cost payment method from 0 - 3 (0 == cash)

Config.AlertRequirements                   = {
    Enabled = true,

    RequiredPaperItem = { item = "paper", removeItem = true },
    RequiredPenItem   = { item = "pen",   removeItem = false, removeDurability = 5 } -- removeDurability for non stackable items only.
}

Config.MedicNPCData = {
    Model         = "CS_DrMalcolmMacIntosh",
    AnimationDict = "mech_revive@unapproved",
    AnimationBody = "revive",
    ReviveCost    = 5,
    ReviveCostMethodType = 0,
}

Config.Stores = {

    ['Guarma'] = {
        Title = "Guarma - Trained Pigeons",

        Coords = {x = 1374.555, y = -7012.58, z = 56.632, h = 99.767318725586},

        BlipData = {
            Enabled = true,
            Sprite = -924533810,
            Scale = 0.2,

            Name = "Trained Pigeons Store",
        },

        NPCData = {
            Enabled = true,
            Model = "cs_exconfedsleader_01",
            Coords = {x = 1374.555, y = -7012.58, z = 55.632, h = 99.767318725586},
        },

        DistanceOpenStore = 1.5,
    },

    ['Valentine'] = {
        Title = "Valentine - Trained Pigeons",

        Coords = {x = -372.943, y = 724.7463, z = 116.37},

        BlipData = {
            Enabled = true,
            Sprite = -924533810,
            Scale = 0.2,

            Name = "Trained Pigeons Store",
        },

        NPCData = {
            Enabled = true,
            Model = "cs_exconfedsleader_01",
            Coords = {x = -372.966, y = 722.7261, z = 115.38, h = 3.09},
        },

        DistanceOpenStore = 1.5,

    },

    
    ['Rhodes'] = {
        Title = "Rhodes - Trained Pigeons",

        Coords = {x = 1302.081, y = -1133.58, z = 80.296 },

        BlipData = {
            Enabled = true,
            Sprite = -924533810,
            Scale = 0.2,

            Name = "Trained Pigeons Store",
        },

        NPCData = {
            Enabled = true,
            Model = "cs_exconfedsleader_01",
            Coords = {x = 1302.081, y = -1133.58, z = 80.296, h = 244.12},
        },

        DistanceOpenStore = 1.5,

    },
    
}

Config.Alerts = {
     {
        Label = "Alert Police",

        name = 'police', --The name of the alert

        message = "A New Police Alert Reported", -- Message to show to theh police
        messageTime = 30000, -- Time the message will stay on screen (miliseconds)
        job = "police", -- Job the alert is for

        icon = "star", -- The icon the alert will use

        originText = "~t6~Hang tight, Police has been successfully notified.", -- Text displayed to the user who enacted the command
        originTime = 10000, --The time the origintext displays (miliseconds)
        notifyCooldown = 60,
        originAlreadyNotified = "~e~Police have been already notified, you have to wait: ",

        PromptKey = 0x6319DB71,

        WebhookManagement = {
            Enabled = true,
            Webhook = "https://discord.com/api/webhooks/1089933178921304085/OnT1dr7f38CJ_dE8p6Y7Ovg5-MQc43DRxpI2giPnfA5d8WoBNruBIfFoQsww-5DO0kgp",
        },

    },

    {
        Label = "Alert Doctors",

        name = 'medic',

        message = "A New Doctors Alert Reported",
        messageTime = 30000,
        job = "medic",
        icon = "shield",

        originText = "~t6~Hang tight, Doctors have been successfully notified.",
        originTime = 10000,
        notifyCooldown = 60,
        originAlreadyNotified = "~e~Doctors have been already notified, you have to wait: ",

        PromptKey = 0x05CA7C52,

        WebhookManagement = {
            Enabled = true,
            Webhook = "https://discord.com/api/webhooks/1089932807448563745/h_T4TzsS3rMr8q-3Oy4xPBeKdIKWCj8KN0MBHIjFn3ACzYt9NWE5LDfpM7TcIQFTcKvQ",
        },
    },

    {
        Label = "Alert Vets",

        name = 'vet',

        message = "A New Vets Alert Reported",
        messageTime = 30000,
        job = "vet",
        icon = "shield",

        originText = "~t6~Hang tight, Vets have been successfully notified",
        originTime = 10000,
        checkPlayerDeath = false,
        checkCallingStations = true,
        notifyCooldown = 60,
        originAlreadyNotified = "~e~Vets have been already notified, you have to wait: ",

        PromptKey = 0xA65EBAB4,

        WebhookManagement = {
            Enabled = false,
            Webhook = "https://discord.com/api/webhooks/1046714370618556416/n5JB6dchQCOMr88xQlL4mvKw_qnSMxLP5CNF0hJCyDwkQZYDqpHSAIcLlQDuU3ngYyoi",
        },

    },

}
