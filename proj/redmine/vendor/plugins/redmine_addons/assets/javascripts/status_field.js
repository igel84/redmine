var StatusField = Class.create(
	GenericField,
	{
		
  	initialize: function($super, element, field_name) {
    	$super(element, field_name || 'issue[status_id]');
			this.created = false;
  	},

		inputFactory: function() {
			return '';
		},
		
		attachInputHandlers: function() {
		},
				
		getData: function(data) {
			return data.statuses;
		},
		
		clickHandler: function($super, e) {
			var self = this,
					current_status = this.getStatus();

			if (!self.created) {
				Item.load(
					this.getId(),
					function(data) {
						self.createSelect();
						self.fillSelect(self.getData(data), current_status);
						self.created = true;
						self.show();
					}
				);
			}
			else
				this.show();
			
			e.preventDefault();
			e.stopPropagation();			
		},
		
		createSelect: function() {
			this.element.innerHTML = this.element.innerHTML + '<select class="list__select list__hidden" size="1"></select>';
			this.select = Prototype.Selector.select('select', this.element)[0];
			this.input = this.select;
			
			var self = this;
			Event.observe(this.input, 'keyup',	function(e) {	self.keyupHandler(e);	});
			Event.observe(this.input, 'change',	function(e) {	self.send(self.input.getValue());	});
		},
						
		fillSelect: function(data, current_status) {
			var html = '';
			for(var i = 0, l = data.length; i < l; i++) {
				html += this.optionFactory(data[i], current_status);
			}

			this.select.innerHTML = html;
		},

		optionFactory: function(data, current_status) {
			return '<option value="' + data.id + '"' + (current_status == data.position ? ' selected="selected"' : '') + '>' + data.name + '</option>'
		},
		
		getRegexp: function() {
			return /status-(\d+)/;
		},
		
		getStatus: function() {
			var current_status;
			try {
				var matches = this.element.parentNode.className.match(this.getRegexp());
				if ( matches[1] ) {
					current_status = matches[1];
				}
			}
			catch(e) {
				
			}

			return current_status;
		},
		
		show: function($super) {
			this.container = Prototype.Selector.select('.container', this.element)[0];
			this.input = Prototype.Selector.select('select', this.element)[0];

			$super();
		},
			
		hide: function($super) {
			this.container = Prototype.Selector.select('.container', this.element)[0];
			this.input = Prototype.Selector.select('select', this.element)[0];

			$super();			
		},
		

	}
);
