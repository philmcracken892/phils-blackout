Config = {}

Config.JumpTonic = {
    duration = 15000, 
    jumpHeight = 2.5,
    velocityBoost = 15.0,
    minHeightForBoost = 200.0,
    moveSpeedMultiplier = 1.15,
    animation = {
        drinkDuration = 3000,
        scenario = "DRINK_COFFEE_HOLD"
    },
    notifications = {
        alreadyActive = {
            title = "Jump Tonic",
            description = "You already have high jump active!",
            type = "error",
            duration = 3000
        },
        activated = {
            title = "Jump Tonic",
            description = "High jump activated! Effect lasts 15 seconds",
            type = "success",
            duration = 4000
        },
        wornOff = {
            title = "Jump Tonic",
            description = "High jump effect has worn off.",
            type = "inform",
            duration = 3000
        },
        drinking = {
            title = "Jump Tonic",
            description = "You feel the mystical energy coursing through your body!",
            type = "success",
            duration = 4000
        }
    }
}

function Config.MinutesToMs(minutes)
    return minutes * 60000
end

function Config.SecondsToMs(seconds)
    return seconds * 1000
end