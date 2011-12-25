var AssignedField = Class.create(
	StatusField,
	{
  	initialize: function($super, element) {
			var link = Prototype.Selector.select('a', element)[0];
			if ( link ) {
			try {
				var matches = link.getAttribute('href').match(/\/users\/(\d+)/);
				this.current_status = matches[1];
			}
			catch(e) {				
			}
				
				element.innerHTML = link.innerHTML;
			}			
	
    	$super(element, 'issue[assigned_to_id]');
  	},

		optionFactory: function(data, current_status) {
			return '<option value="' + data.id + '"' + (current_status == data.id ? ' selected="selected"' : '') + '>' + data.firstname + ' ' + data.lastname + '</option>'
		},

		getData: function(data) {
			return data.assignables;
		},

		getStatus: function() {
			return this.current_status;
		},
	}
);