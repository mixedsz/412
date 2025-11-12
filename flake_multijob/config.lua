Config = {}

Config.MaxJobs = 3
Config.AllowAutoJobSavining = true
Config.DefaultJobWhenPlayerIsFire = 'unemployed'

Config.OpenJobUIKey = 'F6'
Config.OpenJobUICommand = 'jobs'
Config.NewESX = true

-- Blip settings
Config.BlipSprite = 457
Config.BlipColor = 3
Config.BlipText = 'Job Managment'

Config.BlipCenterSprite = 498
Config.BlipCenterColor = 3
Config.BlipCenterText = 'Job Center'

Config.MarkerSprite = 27
Config.MarkerColor = {66, 135, 245}
Config.MarkerSize = 1.5

-- Job center locations
Config.LocationsJobCenters = {
    {coords = vector3(-264.4684, -965.3973, 31.2238), blip = true}
}

-- Management locations
Config.LocationsToChangeJobs = {
    {coords = vector3(-264.2940, -966.0424, 77.2268), blip = false}
}

-- Off duty settings
Config.OffdutyForEveryone = true
Config.JobsThatCanUseOffduty = {
    'police',
    'ambulance',
    'mechanic'
}

-- Jobs available at job centers
Config.DefaultJobsInJobCenter = {
    {job = 'miner', label = "Miner", icon = "fas fa-gem", description = "You mine stuff and get materials you can sell", color = "#8B4513"},
    {job = 'trucking', label = "Trucker", icon = "fas fa-truck-fast", description = "Deliver Truck Goods/Cargo", color = "#FF8C00"},
    {job = 'garbage', label = "Trash Man", icon = "fas fa-dumpster", description = "Pick up Waste off of the streets", color = "#696969"},
    {job = 'trucker', label = "Towing", icon = "fas fa-truck-fast", description = "Tow Vehicles", color = "#FFD700"}
}

-- Default jobs (always available)
Config.DefaultJobs = {
    {job = 'unemployed', grade = 0}
}

-- Text/Notifications
Config.Text = {
    ['cant_offduty'] = 'You cant go offduty!',
    ['open_ui_hologram'] = '[~b~E~w~] Open Job Managment',
    ['open_jobcenter_ui_hologram'] = '[~b~E~w~] Open Job Center',
    ['wrong_usage'] = 'Wrong command usage',
    ['job_added'] = 'Job added!'
}

-- Notification function
function SendTextMessage(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(0, 1)
end