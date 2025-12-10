Config = {}

-- Job restrictions (leave empty for no restrictions)
Config.AllowedJobs = {
    'vallaw',
    'blklaw',
    'rholaw',
    -- Add more jobs or leave empty {} for everyone
}

-- Require specific job grade? (0 = any grade)
Config.MinimumJobGrade = 0
Config.EnableScheduledBlackouts = true


Config.ScheduledBlackouts = {
     { zone = "global", startHour = 2, endHour = 5 },  -- Blackout from 2 AM to 5 AM
}
-- Enable sounds
Config.EnableSounds = true

-- Enable animations
Config.EnableAnimations = true

-- Enable progress bar when toggling
Config.EnableProgressBar = true
Config.ProgressBarDuration = 3000  -- 3 seconds

-- Flickering effect before blackout
Config.EnableFlickerEffect = true
Config.FlickerCount = 5

-- Generator models
Config.GeneratorModels = {
    's_dov_lab_panel02x',
}

-- Light pole models
Config.LightPoleModels = {
    'p_streetlightnbx07x',
    'p_lightpolenbx02x',
    'p_canalpolenbx01a',
    'p_streetlampnbx01x',
    'p_streetlightnbx02x',
}

-- Zone definitions
Config.Zones = {
    valentine = { x = -280.0, y = 800.0, z = 119.0, radius = 150.0, label = "Valentine" },
    rhodes = { x = 1230.0, y = -1290.0, z = 76.0, radius = 150.0, label = "Rhodes" },
    strawberry = { x = -1745.0, y = -426.0, z = 155.0, radius = 150.0, label = "Strawberry" },
    saintdenis = { x = 2692.71, y = -1385.96, z = 46.44, radius = 300.0, label = "Saint Denis" },
    blackwater = { x = -875.0, y = -1300.0, z = 45.0, radius = 150.0, label = "Blackwater" },
    tumbleweed = { x = -5510.0, y = -2940.0, z = -2.0, radius = 150.0, label = "Tumbleweed" },
    armadillo = { x = -3620.0, y = -2600.0, z = -13.0, radius = 150.0, label = "Armadillo" },
    annesburg = { x = 2930.0, y = 1330.0, z = 45.0, radius = 150.0, label = "Annesburg" },
    vanhorn = { x = 2980.0, y = -570.0, z = 45.0, radius = 120.0, label = "Van Horn" },
    emeraldranch = { x = 1420.0, y = 365.0, z = 90.0, radius = 100.0, label = "Emerald Ranch" },
    lagras = { x = 1985.0, y = -1855.0, z = 45.0, radius = 100.0, label = "Lagras" },
    bacchusstation = { x = 576.0, y = 1691.0, z = 187.0, radius = 80.0, label = "Bacchus Station" },
    fortwallace = { x = 349.0, y = 1484.0, z = 179.0, radius = 80.0, label = "Fort Wallace" },
    vanhornport = { x = 3335.0, y = -680.0, z = 45.0, radius = 80.0, label = "Van Horn Port" },
    wawilaw = { x = 3600.0, y = 215.0, z = 50.0, radius = 100.0, label = "Wapiti" },
    guarma = { x = 5000.0, y = -3550.0, z = 10.0, radius = 300.0, label = "Guarma" },
}

-- Logging
Config.EnableLogging = true
Config.LogWebhook = "YOUR_DISCORD_WEBHOOK_HERE"
