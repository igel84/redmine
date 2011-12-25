var Item = {
	
	data: {},
	load: function(id, callback) {
		if ( this.data[id] ) {
			callback(this.data[id]);
		}
		else {
			Element.show('ajax-indicator');
			
			var self = this;
			new Ajax.Request(
				'/issues/bulk_edit',
				{
			  	onComplete: function(response) {
						Element.hide('ajax-indicator');
			    	if (200 == response.status) {
							var id = response.responseJSON[0];
							self.data[id] = {
								statuses: response.responseJSON[1],
								assignables: response.responseJSON[2],
								priorities: response.responseJSON[3]
							}							
							callback(self.data[id]);
						}
			  	},
					method: 'get',
					parameters: {						
						id: id,
						redmine_specific_addons: 1
					}
				}
			);
		}
	}
	
};