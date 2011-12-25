var EstimatedTimeField = Class.create(
	GenericField,
	{
		
  	initialize: function($super, element) {
    	$super(element, 'issue[estimated_hours]', 12);
  	},

		getValue: function() {
			return this.element.innerText;
		},
		
		prepareValue: function(value) {
			var temp = value.replace(/^\s+|\s+$/g, '');
			temp = temp.replace(/,/g,".")

			return temp;
		}		

	}
);