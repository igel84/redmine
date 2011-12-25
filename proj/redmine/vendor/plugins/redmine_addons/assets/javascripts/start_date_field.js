var StartDateField = Class.create(
	GenericField,
	{
		
  	initialize: function($super, element) {
    	$super(element, 'issue[start_date]', 11);

			var self = this;

			Calendar.setup(
				{
					inputField: this.input_id,
					ifFormat: '%d-%m-%Y',
					onUpdate: function(c) {
						if ( c.dateClicked ) {
							self.send(self.input.getValue());
						}
					}
				}
			);
  	},

		clickHandler: function($super, e) {
			$super(e);
		
			if ( this.sending )
				return;

			this.input.onclick();
		},

		inputFactory: function() {
			var id = Math.random().toString();
			id = id.substr(2, id.length - 1);
			this.input_id = "list-input" + id;
			return '<input type="text" class="list__input list__hidden" value="' + this.getValue() + '" id="' + this.input_id + '" size="' + this.size + '">';
		},

		getValue: function() {
			var temp = this.element.innerHTML;
			temp = temp.replace(/^\s+|\s+$/g, '');

			var date_parts = temp.match(/^([0-9]{1,2})[./-]([0-9]{1,2})[./-]([0-9]{4})$/);

			if ( date_parts ) {
				year = date_parts[3] * 1;
				month = date_parts[2] * 1;
				day = date_parts[1] * 1;

				temp = day + '.' + month + '.' + year;
      }
			else {
				var now = new Date();
				temp = now.getDate() + '.' + (now.getMonth() + 1) + '.' + now.getFullYear();
			}
		
			return temp;
		}		

	}
);