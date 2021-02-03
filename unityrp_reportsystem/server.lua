ESX = nil
local tickets = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('es:addCommand', 'report', function(source, args, user)
	TriggerClientEvent('unityrp_reportsystem:report', source)
end, {help = 'Report an player, incident or something else.'})

ESX.RegisterServerCallback('ticket:executeAction', function(source, cb, data)
	if data.action == 'create' then

		local issuer = GetPlayerName(source)
		local issuerid = source
		local date = os.date('%Y-%m-%d %H:%M')
		local ticket = {issuer = issuer, issuerid = issuerid, date = date, content = data.content, controlledBy = nil, status = 'pending', playersMentioned = {}}
		local words = {}

		local players = ESX.GetPlayers()
		local notifyMessage = ('<span style="font-weight: bold;">A new report has been filed!</span><br>Created by: %s<br>Player ID: %s'):format(issuer, issuerid)

		for k,playerId in ipairs(players) do
			local xPlayer = ESX.GetPlayerFromId(playerId)

			if xPlayer then
				local group = xPlayer.getGroup()

				if group == 'mod' or group == 'admin' or group == 'superadmin' then
					TriggerClientEvent('unityrp_reportsystem:notifyStaff', playerId, notifyMessage)
				end
			end
		end

		--Getting all the words starting with '@'
		for w in ticket.content:gmatch('%S+') do 
			if string.sub(w, 1, 1) == '@' then
				local playerId = w:gsub('%@', '')
				--Checking if it is a number
				if tonumber(playerId) ~= nil then

					--Getting the player with that id
					if GetPlayerName(playerId) ~= nil then
						local identifier = GetPlayerIdentifiers(playerId)[1]
						local name = GetPlayerName(playerId)

						local string = playerId .. ' - ' .. identifier .. ' - ' .. name

						table.insert(ticket.playersMentioned, string)
					end
				end
			end
		end

		local id = string.random(10)
		if tickets[id] ~= nil then
			while tickets[id] ~= nil do
				id = string.random(10)
				Wait(0)
			end
		end

		ticket.id = id
		tickets[id] = ticket

		cb({success = true})
	elseif data.action == 'modifyTicket' then
		local id = data.ticketid

		if tickets[id] ~= nil then
			if data.status == 'deleted' then
				tickets[id] = nil
			else
				tickets[id].status = data.status
				tickets[id].controlledBy = data.controlledBy
			end
		end

		cb({success = true})
	elseif data.action == 'getTickets' then
		cb({success = true, data = tickets})
	elseif data.action == 'getHomepage' then
		local pending = 0
		local controlled = 0

		for k,v in pairs(tickets) do
			if v.status == 'pending' then
				pending = pending + 1
			else
				controlled = controlled + 1
			end
		end

		cb({success = true, pending = pending, controlled = controlled, total = pending + controlled})
	elseif data.action == 'getTicket' then
		if tickets[data.ticketid] ~= nil then
			cb({success = true, data = tickets[data.ticketid]})
		else
			cb({success = false})
		end
	elseif data.action == 'reportAction' then
		if tickets[data.ticketid] ~= nil then
			tickets[data.ticketid].status = data.status

			--We should somehow get the player name ???

			--Maybe this will do
			tickets[data.ticketid].controlledBy = data.by
			if data.status == 'deleted' then
				tickets[data.ticketid] = nil
			end
			cb({success = true})
		else
			cb({success = false})
		end
	end
end)

--Random String Stuff
local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
	math.randomseed(os.time())

	if length > 0 then
		return string.random(length - 1) .. charset[math.random(1, #charset)]
	else
		return ''
	end
end