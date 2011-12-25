var PriorityField = Class.create(
	StatusField,
	{
  	initialize: function($super, element) {
    	$super(element, 'issue[priority_id]');
  	},

		getData: function(data) {
			return data.priorities;
		},

		getRegexp: function() {
			return /priority-(\d+)/;
		}
	}
);