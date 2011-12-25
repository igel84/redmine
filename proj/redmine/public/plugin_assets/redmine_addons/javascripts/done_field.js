var DoneField = Class.create(
	GenericField,
	{
		
  	initialize: function($super, element, in_progress_status_id) {
    	$super(element, 'issue[done_ratio]', 3);
			this.in_progress_status_id = in_progress_status_id;
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

		initElements: function($super) {
			$super();

			this.ajax_container_id = 'done_ajax';
			if ( this.getValue() < 100 ) {
				this.container.innerHTML = '<table style="border-spacing:0;border-collapse:collapse"><tr><td>' + this.container.innerHTML + '</td><td><img src="/images/toggle_check.png" class="list__done-image" title="100%"></td></tr></table>';
				this.image = Prototype.Selector.select('.list__done-image', this.element)[0];			
			}
			else {
				this.container.innerHTML = '<table style="border-spacing:0;border-collapse:collapse"><tr><td>' + this.container.innerHTML + '</td><td style="width:11px"></td></tr></table>';
			}
		},
		
		showWrongStatusMessage: function() {
			alert("Нельзя проставить 100% выполнения задаче без статуса «В работе»");
		},
		
		attachHandlers: function($super) {
			$super();
			
			if ( this.getValue() < 100 ) {
				var self = this;
				Event.observe(this.image, 'click', function(e) { self.imageClickHandler(e, true); } );
			}
		},
		
		hide: function($super) {
			$super();

			var c = $(this.ajax_container_id);
			if ( c ) {
				$(this.ajax_container_id).innerHTML = '';
			}
		},
		
		documentClickHandler: function(e) {
			var image_clicked = e.srcElement && e.srcElement.id && e.srcElement.id == 'time_entry_spent_on_trigger';
			var select_clicked = e.srcElement && e.srcElement.id && e.srcElement.id == 'time_entry_activity_id';

			if ( this.showing && !image_clicked && !select_clicked ) {
				this.hide();
			}
			
			if ( image_clicked ) {
				$('time_entry_spent_on_trigger').onclick();
			}
		},
		
		enterPressed: function() {
			this.imageClickHandler();
		},
		
		imageClickHandler: function(e, force) {
			var old_value = this.input.getValue();
			if ( force ) {
				this.input.setValue(100);
			}
			
			if ( this.input.getValue() == 100 && this.in_progress_status_id.toString() != this.getStatus().toString() ) {
				this.showWrongStatusMessage();
				this.input.setValue(old_value);
			}
			else {
				var self = this;
				new Ajax.Updater(
					{
						success: this.ajax_container_id
					},
					'/issues/' + this.getId() + '/time_entries/new',
					{
						method: 'get',
						parameters: {
							done_field_time_entry: 1,
							id: this.getId(),
							authenticity_token: $$('input[name=authenticity_token]')[0].getValue()
						},
						onComplete: function(request) {
							dims = $(self.ajax_container_id).getDimensions();
							menu_width = dims.width;
							menu_height = dims.height;

							var ws = window_size();
							window_width = ws.width;
							window_height = ws.height;

							var render_x = (window_width - menu_width) / 2;
							var render_y = (window_height - menu_height) / 2;

							$(self.ajax_container_id).style['left'] = (render_x + 'px');
							$(self.ajax_container_id).style['top'] = (render_y + 'px');
						
							var inputs = $$('#' + self.ajax_container_id + ' input[type=text]');

							for(var i = 0, l = inputs.length; i < l; i++) {
								Event.observe(
									inputs[i],
									'keyup',
									function(e) {
										if ( e.keyCode == 27 ) {
											self.hide();
										}
									}
								)
							};
 							
							var form = $$('#' + self.ajax_container_id + ' form')[0];

							Event.observe(form, 'click', function(e) { e.preventDefault(); e.stopPropagation(); });

							Event.observe($$('#' + self.ajax_container_id + ' form input[type=submit]')[0], 'click', function(e) { form.submit(); });
							self.showing = true;

							var input = Prototype.Selector.select('input[name=done_value]', form)[0];

							input.value = self.input.getValue();
							input.setAttribute('input', self.input.getValue());

							$('time_entry_hours').focus();
							Calendar.setup({inputField : 'time_entry_spent_on', ifFormat : '%Y-%m-%d', button : 'time_entry_spent_on_trigger' });
						}
					}
				);
			}
			
			if ( e ) {
				e.preventDefault();
				e.stopPropagation();
			}
		}

	}
);