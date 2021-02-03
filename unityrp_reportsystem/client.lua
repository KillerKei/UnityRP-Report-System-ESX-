ESX = nil
local admin = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('unityrp_reportsystem:report')
AddEventHandler('unityrp_reportsystem:report', function(text)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'report', {
		title = 'Compose your report',
		type = 'big',
		value = text or ''
	}, function(data, menu)
		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'report_confirm', {
			title    = 'Confirm report',
			align    = 'top-left',
			elements = {
				{label = 'No I\'m not done', confirm = 1},
				{label = 'Delete report', confirm = 2},
				{label = 'Send report', confirm = 3}
		}}, function(data2, menu2)
			local action = data2.current.confirm
			menu2.close()

			if action == 1 then
				TriggerEvent('unityrp_reportsystem:report', data.value)

			elseif action == 3 then
				ESX.TriggerServerCallback('ticket:executeAction', function(resp)
					if resp.success then
						TriggerEvent('customNotification', 'Your ticket has been sent to the administration, please be patient as we handle the tickets in an chronological order.')
					end
				end, {action = 'create', content = data.value})
			end
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		menu.close()
	end)
end)

RegisterNUICallback('ticketAction', function(data, cb)
	ESX.TriggerServerCallback('ticket:executeAction', function(response)
		cb(response)
	end, data)
end)

RegisterNUICallback('closeTickets', function()
	closeReports()
end)

RegisterNetEvent('unityrp_reportsystem:openReports')
AddEventHandler('unityrp_reportsystem:openReports', function()
	if not admin then
		openReports2()
	end
end)

function openReports2()
	SendNUIMessage({type = 'ticket', action = 'open', name = GetPlayerName(PlayerId())})
	SetNuiFocus(true, true)
	admin = true
end

function closeReports()
	SendNUIMessage({type='ticket', action='close'})
	SetNuiFocus(false)
	admin = false
end


RegisterNetEvent('unityrp_reportsystem:notifyStaff')
AddEventHandler('unityrp_reportsystem:notifyStaff', function(text)
	TriggerEvent('pNotify:SendNotification', {
		text = text,
		type = 'warning',
		timeout = 10000,
		layout = 'centerRight',
		queue = 'right'
	})
end)
