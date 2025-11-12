ESX = nil
local JobInfo = {}

if not Config.NewESX then
    TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
else
    ESX = exports["es_extended"]:getSharedObject()
end

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM jobs WHERE 1", {}, function(name)
        for _, v in ipairs(name) do
            JobInfo[v.name] = {}
            JobInfo[v.name].job_label = v.label
            JobInfo[v.name].grades = {}

            MySQL.Async.fetchAll("SELECT * FROM job_grades WHERE job_name = @job", {["@job"] = v.name}, function(gradeInfo)
                for __, g in ipairs(gradeInfo) do
                    JobInfo[v.name].grades[g.grade] = g
                end
            end)
        end
    end)
end)

function AddJob(identifier, job, grade, rem)
    MySQL.Sync.execute(
        "REPLACE INTO `user_jobs`(`identifier`, `job`, `grade`, `removeable`) VALUES (@identifier, @job, @grade, @removeable)",
        {["@identifier"] = identifier, ["@job"] = job, ["@grade"] = grade, ["@removeable"] = rem}
    )
end

function UpdateJob(identifier, job, grade)
    MySQL.Sync.execute(
        "UPDATE `user_jobs` SET grade = @grade WHERE identifier = @identifier and job = @job LIMIT 1",
        {["@identifier"] = identifier, ["@job"] = job, ["@grade"] = grade}
    )
end

function RemoveJob(identifier, job, grade)
    MySQL.Sync.execute(
        "DELETE FROM `user_jobs` WHERE identifier = @identifier AND job = @job AND grade = @grade",
        {["@identifier"] = identifier, ["@job"] = job, ["@grade"] = grade}
    )
end

RegisterCommand("removejob", function(source, args, rawCommand)
    if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
        local group = xPlayer.getGroup()
        if group == "admin" or group == "superadmin" or group == "owner" then
            if args[1] ~= nil then
                local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
                if xTarget ~= nil then
                    if args[2] ~= nil and args[3] ~= nil then
                        RemoveJob(xTarget.identifier, args[2], args[3], true)
                    else
                        TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                    end
                else
                    TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                end
            else
                TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
            end
        else
            TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
        end
    end
end, false)

RegisterCommand("addjob", function(source, args, rawCommand)
    if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
        local group = xPlayer.getGroup()
        if group == "admin" or group == "superadmin" or group == "owner" then
            if args[1] ~= nil then
                local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
                if xTarget ~= nil then
                    if args[2] ~= nil and args[3] ~= nil then
                        AddJob(xTarget.identifier, args[2], args[3], true)
                    else
                        TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                    end
                else
                    TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                end
            else
                TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
            end
        else
            TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
        end
    end
end, false)

ESX.RegisterServerCallback("core_multijob:getJobs", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT * FROM user_jobs WHERE identifier = @identifier", {["@identifier"] = xPlayer.identifier}, function(jobs)
        local user_jobs = {}
        local online = {}

        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers, 1 do
            local targetPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if targetPlayer ~= nil then
                local targetJob = targetPlayer.getJob()
                if online[targetJob.name] ~= nil then
                    online[targetJob.name] = online[targetJob.name] + 1
                else
                    online[targetJob.name] = 1
                end
            end
        end

        for _, v in ipairs(jobs) do
            local on = online[v.job]
            if on == nil then on = 0 end

            if JobInfo[v.job] == nil then
                print('[Core Multiple Jobs] Job data not found for ' .. v.job)
            else
                table.insert(user_jobs, {
                    name = v.job,
                    grade = v.grade,
                    label = JobInfo[v.job].job_label,
                    grade_label = JobInfo[v.job].grades[v.grade].label,
                    salary = JobInfo[v.job].grades[v.grade].salary,
                    online = on,
                    removable = v.removeable
                })
            end
        end

        for _, v in ipairs(Config.DefaultJobs) do
            local on = online[v.job]
            if on == nil then on = 0 end

            if JobInfo[v.job] ~= nil then
                table.insert(user_jobs, {
                    name = v.job,
                    grade = v.grade,
                    label = JobInfo[v.job].job_label,
                    grade_label = JobInfo[v.job].grades[v.grade].label,
                    salary = JobInfo[v.job].grades[v.grade].salary,
                    online = on,
                    removable = false
                })
            else
                print("[Core Multiple Jobs] You dont have a job named " .. v.job .. " as stated in the config... Ignoring it")
            end
        end

        cb(user_jobs)
    end)
end)

RegisterServerEvent("core_multijob:addJob")
AddEventHandler("core_multijob:addJob", function(job)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end
    AddJob(xPlayer.identifier, job, 0, true)
    TriggerClientEvent("core_multijob:sendMessage", src, Config.Text["job_added"])
end)

RegisterServerEvent("core_multijob:changeJob")
AddEventHandler("core_multijob:changeJob", function(job, grade)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end

    local canAssignJob = false
    MySQL.Async.fetchAll("SELECT * FROM user_jobs WHERE identifier = @identifier", {["@identifier"] = xPlayer.identifier}, function(jobs)
        for k, v in pairs(Config.DefaultJobs) do
            if v.job == job then
                canAssignJob = true
                break
            end
        end

        if not canAssignJob then
            if job == 'offduty' or job == 'unemployed' or job == Config.DefaultJobWhenPlayerIsFire then
                canAssignJob = true
            elseif jobs and #jobs > 0 then
                for _, v in ipairs(jobs) do
                    if v.job == job then
                        canAssignJob = true
                        break
                    end
                end
            end
        end

        if not canAssignJob then
            xPlayer.kick('[KICKED] Not allowed, sorry.')
            return
        end
        
        xPlayer.setJob(job, grade)
    end)        
end)

RegisterServerEvent("core_multijob:checkForJob")
AddEventHandler("core_multijob:checkForJob", function(oldJob, oldGrade)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll("SELECT * FROM user_jobs WHERE identifier = @identifier", {["@identifier"] = xPlayer.identifier}, function(jobs)
        local playerJob = xPlayer.getJob()
        local jobRemove = false                

        for i, v in ipairs(jobs) do
            if playerJob.name == v.job then
                if tonumber(playerJob.grade) == tonumber(v.grade) then
                    return
                elseif tonumber(playerJob.grade) < tonumber(v.grade) or tonumber(playerJob.grade) > tonumber(v.grade) then
                    UpdateJob(xPlayer.identifier, v.job, playerJob.grade)
                    return                            
                end
            end
        end

        if playerJob.name == Config.DefaultJobWhenPlayerIsFire then
            RemoveJob(xPlayer.identifier, oldJob, oldGrade)
            jobRemove = true
            return
        end

        for _, v in ipairs(Config.DefaultJobs) do
            if playerJob.name == v.job then
                return
            end
        end

        if jobs and (#jobs < Config.MaxJobs or (jobRemove and #jobs <= Config.MaxJobs)) then
            AddJob(xPlayer.identifier, playerJob.name, playerJob.grade, true)
            return
        end
    end)
end)

RegisterServerEvent("core_multijob:removeJob")
AddEventHandler("core_multijob:removeJob", function(job, grade)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end
    RemoveJob(xPlayer.identifier, job, grade)
end)