var RejectAcceptButtons = {
	performReject: function() {
		var reason = prompt("Укажите причину, по которой вы отклоняете задачу")
		if ( reason ) {		
			var f = $('issue-form');
			f.innerHTML = f.innerHTML + '<input type="hidden" name="reject_button_pressed" value="1">';

			document.getElementById('notes').value = reason;

			f.submit();
		}
	},

	performAccept: function() {
		var f = $('issue-form');
		f.innerHTML = f.innerHTML + '<input type="hidden" name="accept_button_pressed" value="1">';
		f.submit();	
	},
	
	performKick: function() {
		var message = prompt("Можете указать сообщение для исполнителя")
		if ( message ) {		
			var f = $('issue-form');
			f.innerHTML = f.innerHTML + '<input type="hidden" name="kick_button_pressed" value="1">';
			f.innerHTML = f.innerHTML + '<input type="hidden" name="kick_button_message" value="' + message + '">';

			f.submit();
		}		
	}
};