var currentTicket;
var resourceName = "unityrp_reportsystem";
var homePage;
var ticketsPage;
var viewTicket;
var playerName;


$(function () {
	$('#tickets').hide();

	$('.navigation ul li a').click(function () {
		var page = $(this).data('page');
		if (page != undefined) {
			setPage(page);
		}
	});

	/* Close with ESC */
	$(document).keyup(function (e) {
		if (e.keyCode == 27) {
			$.post('http://' + resourceName + '/closeTickets');
			$('#tickets').fadeOut();
		}
	});

	window.addEventListener('message', function (event) {
		if (event.data.type == "ticket") {
			if (event.data.action == "open") {
				playerName = event.data.name;
				getHomepage();
				$('#tickets').fadeIn();
			} else if (event.data.action == "close") {
				$('#tickets').fadeOut();
			}
		}
	});

	homePage = new Vue({
		el: '#homepage',
		data: {
			pending: 12,
			controlled: 512,
			total: 524,
		}
	});

	ticketsPage = new Vue({
		el: '#ticketspage',
		data: {
			reports: {},
		},
		filters: {
			trim: function (value) {
				return value.substr(0, 20);
			}
		},
		methods: {
			openReport: function (event) {
				var targetid = $(event.target).attr('data-id');
				getTicket(targetid);
			},
			controlledTickets: function (event) {
				getTickets(true);
			}
		}
	});

	viewTicket = new Vue({
		el: '#viewticket',
		data: {
			id: null,
			issuer: null,
			issuerid: null,
			date: null,
			content: null,
			players: {},
			by: null,
			status: null,
		},
		methods: {
			acceptReport: function (event) {
				var targetid = $(event.target).attr('data-id');
				reportAction("accepted", targetid);
			},
			denyReport: function (event) {
				var targetid = $(event.target).attr('data-id');
				reportAction("denied", targetid);
			},
			deleteReport: function (event) {
				var targetid = $(event.target).attr('data-id');
				reportAction("deleted", targetid);
			}

		}
	});

});

function getTickets(controlled) {
	var data = { "action": "getTickets" };

	startLoading();

	$.post('http://' + resourceName + '/ticketAction', JSON.stringify(data)).done(function (resp) {
		var returnTickets = [];
		var tickets = resp.data;
		if (controlled) {
			for (var i = 0; i < Object.keys(tickets).length; i++) {
				var key = Object.keys(tickets)[i];
				if (tickets[key].status != "pending") {
					returnTickets.push(tickets[key]);
				}
			}
		} else {
			for (var i = 0; i < Object.keys(tickets).length; i++) {
				var key = Object.keys(tickets)[i];
				if (tickets[key].status == "pending") {
					returnTickets.push(tickets[key]);
				}
			}
		}

		populateTickets(returnTickets);
		stopLoading();

		$('.page.active').removeClass('active');
		$('#ticketspage').addClass('active');
	});
}

function getHomepage() {
	var data = { "action": "getHomepage" };
	startLoading();

	$.post('http://' + resourceName + '/ticketAction', JSON.stringify(data)).done(function (resp) {
		updateHomepage(resp);
		stopLoading();
		$('.page.active').removeClass('active');
		$('#homepage').addClass('active');
	});
}

function getTicket(id) {
	var data = { "action": "getTicket", "ticketid": id };
	startLoading();

	$.post('http://' + resourceName + '/ticketAction', JSON.stringify(data)).done(function (resp) {
		updateTicketPage(resp.data);
		stopLoading();
		currentTicket = id;
		setPage('viewticket');
	});
}

function reportAction(status, id) {
	var data = { "action": "reportAction", "status": status, "ticketid": id, "by": playerName };
	startLoading();

	$.post('http://' + resourceName + '/ticketAction', JSON.stringify(data)).done(function (resp) {
		stopLoading();
		getTickets(false);
	});
}

function updateTicketPage(data) {
	viewTicket.id = data.id;
	viewTicket.issuer = data.issuer;
	viewTicket.issuerid = data.issuerid;
	viewTicket.date = data.date;
	viewTicket.content = data.content;
	viewTicket.players = data.playersMentioned;
	viewTicket.by = data.controlledBy;
	viewTicket.status = data.status;
}

function populateTickets(data) {
	ticketsPage.reports = data;
}

function updateHomepage(data) {
	homePage.pending = data.pending;
	homePage.controlled = data.controlled;
	homePage.total = data.total;
}

function setPage(page) {
	if (page == "ticketspage") {
		getTickets(false);
	} else if (page == "homepage") {
		getHomepage();
	} else {
		$('.page.active').removeClass('active');
		$('#' + page).addClass('active');
	}
}

function startLoading(text) {
	$('.loading span').html(text);
	$('.loading').fadeIn();
}

function stopLoading() {
	$('.loading').fadeOut();
}