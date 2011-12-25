var subject, desc, start_date, iduedate, istatus, ipriority, iassigned, idone, ispent, ac, iauditor, iestimated;

var ViewUpdater = Class.create();
ViewUpdater.prototype = {
	
	initialize: function(responseText) {
		this.responseText = responseText;
		this.e = this.createElement();

		this.update();
	},
	
	createElement: function() {
		var e = document.createElement('div');
		e.innerHTML = this.responseText;

		return e;
	},
	
	updateForm: function(data) {
		var regexp = /<input id="issue_lock_version" name="issue\[lock_version\]" type="hidden" value="(\d+)" \/>/i,
				matches = this.responseText.match(regexp);
		if ( matches && matches[1] ) {
			var new_lock_version = matches[1],
					lock_version_node = $('issue_lock_version');

			lock_version_node.value = new_lock_version;
			lock_version_node.setAttribute('value', new_lock_version);
		}
		
		regexp = /<input name="authenticity_token" type="hidden" value="([a-zA-Z0-9=]+)" \/>/i;
		matches = this.responseText.match(regexp);
		if ( matches && matches[1] ) {
			var new_token = matches[1],
					token_node = Prototype.Selector.select('input[name=authenticity_token]')[0];

			token_node.value = new_token;
			token_node.setAttribute('value', new_token);
		}
	},
	
	update: function() {
		this.updateForm();
		this.updateSubject();
		this.updateStatus();
		this.updatePriority();
		this.updateAssignedTo();
		this.updateDoneRatio();
		this.updateSpentTime();
		this.updateAuditor();
		this.updateStartDate();
		try { 
			this.updateAcceptDate();
			this.updateDueDate();
			this.updateDoneDate();
			this.updateDescription();
			this.updateEstimated();
		
			this.updateHistory();
		}
		catch (e) {
			
		}
	},	
	
	updateEstimated: function() {
		iestimated.updateFromNode(this.e);
	},
	
	updateDueDate: function() {
		iduedate.updateFromNode(this.e);
	},
	
	updateAcceptDate: function() {
		var element = Prototype.Selector.select('.issue td.accept-date', this.e)[0];		
		Prototype.Selector.select('.issue td.accept-date')[0].innerHTML = element.innerHTML;				
	},

	updateDoneDate: function() {
		var element = Prototype.Selector.select('.issue td.done-date', this.e)[0];		
		Prototype.Selector.select('.issue td.done-date')[0].innerHTML = element.innerHTML;				
	},
	
	updateAuditor: function() {
		iauditor.updateFromNode(this.e);
	},
	
	updateSpentTime: function() {
		ispent.updateFromNode(this.e);
	},
	
	updateDoneRatio: function() {
		idone.updateFromNode(this.e);
	},
	
	updateAssignedTo: function() {
		iassigned.updateFromNode(this.e);
	},
	
	updatePriority: function() {
		ipriority.updateFromNode(this.e);
	},
	
	updateStatus: function() {
		istatus.updateFromNode(this.e);
	},
	
	updateStartDate: function() {
		start_date.updateFromNode(this.e);
	},
	
	updateDescription: function() {
		desc.updateFromNode(this.e);
	},
	
	updateSubject: function() {
		subject.updateFromNode(this.e);
	},
	
	updateHistory: function() {
		if ( $('history') ) {
			$('history').innerHTML = Prototype.Selector.select('#history', this.e)[0].innerHTML;
		}
	}
	
};

var AddComment = Class.create();
AddComment.prototype = {
	
	initialize: function(selector) {
		this.toggler = Prototype.Selector.select(selector)[0];
		this.container = $('add_comment_container');
		this.form = $('update');
		this.showing = false;
		
		var self = this;
		Event.observe(this.toggler, 'click', function(e) { self.toggle(e); });
		Event.observe(document, 'click',	function(e) {
			if ( e.target && e.target != self.container && e.target != self.toggler ) {
				var displayer_found = false,
						current = e.target;
	
				do
				{
					if ( current == self.container ) {
						displayer_found = true;
						break;
					}
					
					if ( !current.parentElement ) {
						break;
					}
					current = current.parentElement;
				}
				while (true);

				if ( !displayer_found ) {
					self.hide();
				}
			}
		});		
	},
	
	toggle: function(e) {
		(this.showing ? this.hide() : this.show());
		e.preventDefault();
		return false;
	},
	
	show: function() {
		if ( !this.showing ) {
			this.toggler.style.display = 'none';

			this.container.style.display = 'none';
			this.container.innerHTML = this.form.innerHTML;
			var items = Prototype.Selector.select('fieldset.tabular');
			for(var i = 0, l = items.length; i < l; i++) {
				items[i].remove();
			}
			
			Prototype.Selector.select('h3', this.container)[0].innerHTML = 'Добавить комментарий';
			
			Prototype.Selector.select('.jstElements', this.container)[0].remove();
			Prototype.Selector.select('.jstHandle', this.container)[0].remove();
			
			var notes = Prototype.Selector.select('#notes', this.container)[0],
					wikiToolbar = new jsToolBar( notes );
			wikiToolbar.setHelpLink('<a href=\"/help/wiki_syntax.html\" onclick=\"window.open(&quot;/help/wiki_syntax.html&quot;, &quot;&quot;, &quot;resizable=yes, location=no, width=300, height=640, menubar=no, status=no, scrollbars=yes&quot;); return false;\">Форматирование текста<\/a>');
			wikiToolbar.draw();
			
			var self = this;
			Event.observe(notes, 'keydown', function(e) {
				if ( e.keyCode == 27 ) {
					self.hide();
				}
			});
			
			this.container.style.display = 'block';
			notes.focus();

			this.showing = true;
		}
	},
	
	hide: function() {
		if ( this.showing ) {
			this.container.innerHTML = '';
			this.toggler.style.display = 'inline';
			this.showing = false;
		}
	}
	
};

var IssueSubject = Class.create();
IssueSubject.prototype = {
	
	initialize: function(paramName, labelSelector) {
		this.paramName = paramName;
		this.form_input = this.formInputFinder();
		
		var target = this.targetFactory();

		this.field = this.fieldFinder(target);
		this.displayer = this.displayerFinder(target);
		this.showing = false;
			
		if ( labelSelector ) {
			this.label = Prototype.Selector.select(labelSelector)[0];
		}
			
		this.attachHandlers();
	},
	
	attachHandlers: function() {
		var self = this;

		Event.observe(document, 'click',	function(e) {
			if ( e.target && e.target != self.field && (!self.label || (self.label && e.target != self.label)) ) {
				var displayer_found = false,
						current = e.target;
	
				do
				{
					if ( current == self.displayer ) {
						displayer_found = true;
						break;
					}
					
					if ( !current.parentElement ) {
						break;
					}
					current = current.parentElement;
				}
				while (true);

				if ( !displayer_found ) {
					self.hide();
				}
			}
		});
		Event.observe(this.displayer, 'click',	function(e) { self.show(); });
		if ( this.label ) {
			Event.observe(this.label, 'click',	function(e) { self.show(); });
		}
		Event.observe(this.field, 'keydown', function(e) { self.keyupHandler(e); });		
	},
	
	formInputFinder: function() {
		return Prototype.Selector.select('input[name="' + this.paramName + '"]');
	},
	
	targetFactory: function() {
		var target = Prototype.Selector.select('.subject h3')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><input type="text" class="hidden" style="width:100%" value="' + target.innerHTML + '">';
		target.innerHTML = new_html;
		
		return target;
	},
	
	fieldFinder: function(target) {
		return Prototype.Selector.select('input', target)[0];
	},
	
	displayerFinder: function(target) {
		return Prototype.Selector.select('span', target)[0];
	},
	
	keyupHandler: function(e) {
		if ( e.keyCode == 27 ) {
			this.hide();
		}
		if ( e.keyCode == 13 && this.field.value.length > 0 ) {
			if ( this.field.tagName.toLowerCase() == 'textarea' ) {
				if ( e.ctrlKey ) {
					this.submit();

					e.preventDefault();
					e.stop();
					e.stopPropagation();
					e.stopImmediatePropagation();
					
					return false;
				}
			}
			else {
				this.submit();
			}
		}		
	},
		
	completeHandler: function(data) {
		var u = new ViewUpdater(data.responseText);
	},
	
	fieldUpdater: function(value) {
		this.field.value = value;
		this.field.setAttribute('value', value);
	},
	
	displayerUpdater: function(value) {
		this.displayer.innerHTML = value;
	},
	
	submitSetValues: function() {
		for(var i = 0, l = this.form_input.length; i < l; i++) {
			this.form_input[i].value = this.field.value;
			this.form_input[i].setAttribute('value', this.field.value);
			this.form_input[i].removeAttribute('disabled');
		}
	},
	
	updateFromNode: function(node) {
		var input = Prototype.Selector.select('input[name="' + this.paramName + '"]', node)[0],
				value = input.value;		
		this.displayerUpdater(value);
		this.fieldUpdater(value);		
		
		input = this.form_input[0];
		input.value = value;
		input.setAttribute('value', value);
	},
		
	submit: function() {
		this.displayerUpdater(this.field.value);
		this.submitSetValues();

		var self = this;
		$('issue-form').request(
			{
				onComplete: function(data) {
					self.completeHandler(data);
				}
			}
		);

		this.hide();
	},
	
	show: function() {
		if ( !this.showing ) {
			this.displayer.addClassName('hidden');
			this.field.removeClassName('hidden');

			this.field.focus();
			this.field.select();
			
			this.showing = true;
		}
	},
	
	hide: function() {
		if ( this.showing ) {
			this.field.addClassName('hidden');
			this.displayer.removeClassName('hidden');
			this.showing = false;
		}
	}
};

var IssueDesc = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		$super(paramName, labelSelector);
	},

	formInputFinder: function() {
		return Prototype.Selector.select('textarea[name="issue[description]"]');
	},

	fieldFinder: function($super, target) {
		return Prototype.Selector.select('textarea', target)[0];
	},

	targetFactory: function() {
		var target = Prototype.Selector.select('div.issue .wiki')[0];
		target.innerHTML = '<span class="inline-value">' + target.innerHTML + '</span><textarea rows="3" class="hidden" style="width:100%">' + $('issue_description').innerHTML + '</textarea>';		
		
		return target;
	},
	
	completeHandler: function($super, data) {
		new ViewUpdater(data.responseText);
	},
	
	displayerUpdater: function(value) {
		this.displayer.innerHTML = value;
	},
	
	updateFromNode: function(node) {
		var wiki = Prototype.Selector.select('div.issue .wiki', node)[0].innerHTML;
		this.displayerUpdater(wiki);
		
		this.form_input.innerHTML = Prototype.Selector.select('textarea[name="' + this.paramName + '"]', node)[0].innerHTML;
	}	
	
});

var IssueEstimated = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		$super(paramName, labelSelector);
	},

	targetFactory: function() {
		var target = Prototype.Selector.select('.issue td.estimated-hours')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><input type="text" class="hidden" size="10" value="' + (this.form_input[0].getAttribute('value') === null ? '' : this.form_input[0].getAttribute('value')) + '">';
		target.innerHTML = new_html;
		
		return target;
	},

	completeHandler: function(data) {
		new ViewUpdater(data.responseText);
	},

	displayerUpdater: function(value) {
		this.displayer.innerHTML = value;
	},

	updateFromNode: function(node) {
		if ( this.displayer ) {
			this.displayerUpdater(Prototype.Selector.select('.issue td.estimated-hours', node)[0].innerHTML);

			var value = Prototype.Selector.select('input[name=' + this.paramName + ']', node)[0].value,
					target = Prototype.Selector.select('input[name=' + this.paramName + ']')[0];
			target.value = value;
			target.setAttribute('value',value);

			this.field.value = value;
			this.field.setAttribute('value',value);
		}
	}
	
});


var StartDate = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		if ( this.sourceEnabled() ) {
			$super(paramName, labelSelector);
			
			var self = this;
			Calendar.setup(
				{
					inputField: this.input_id,
					ifFormat: '%Y-%m-%d',
					onUpdate: function(c) {
						if ( c.dateClicked ) {
							self.submit();
						}
					}
				}
			);			
		}
	},

	targetFactory: function() {
		this.input_id = 'r' + Math.random();
		var target = Prototype.Selector.select('.issue td.start-date')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><input type="text" class="hidden" id="' + this.input_id + '" size="10" value="' + (this.form_input[0].getAttribute('value') === null ? '' : this.form_input[0].getAttribute('value')) + '">';
		target.innerHTML = new_html;
		
		return target;
	},

	completeHandler: function(data) {
		new ViewUpdater(data.responseText);
	},

	displayerUpdater: function(value) {
		this.displayer.innerHTML = value;
	},

	updateFromNode: function(node) {
		if ( this.displayer ) {
			var from = Prototype.Selector.select('.issue td.start-date', node);
			if ( from.length ) {
				this.displayerUpdater(from[0].innerHTML);
			}

			from = Prototype.Selector.select('input[name=' + this.paramName + ']', node);
			if ( from.length > 0 ) {
				var value = from[0].value,
						target = Prototype.Selector.select('input[name=' + this.paramName + ']')[0];
				target.value = value;
				target.setAttribute('value',value);

				this.field.value = value;
				this.field.setAttribute('value',value);
			}
		}
	},

	sourceEnabled: function() {
		var disabled = $('issue_start_date').getAttribute('disabled');
		return disabled !== 'disabled';
	},
	
	show: function($super) {
		$super();
		if ( this.showing ) {
			this.field.click();
		}
	}
});

var DueDate = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		if ( this.sourceEnabled() ) {
			$super(paramName, labelSelector);
			
			var self = this;
			Calendar.setup(
				{
					inputField: this.input_id,
					ifFormat: '%Y-%m-%d',
					onUpdate: function(c) {
						if ( c.dateClicked ) {
							self.submit();
						}
					}
				}
			);			
		}
	},

	targetFactory: function() {
		this.input_id = 'r' + Math.random();
		var target = Prototype.Selector.select('.issue td.due-date')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><input type="text" class="hidden" id="' + this.input_id + '" size="10" value="' + (this.form_input[0].getAttribute('value') === null ? '' : this.form_input[0].getAttribute('value')) + '">';
		target.innerHTML = new_html;
		
		return target;
	},

	completeHandler: function(data) {
		new ViewUpdater(data.responseText);
	},

	updateFromNode: function(node) {
		if ( this.displayer ) {
			var matches = Prototype.Selector.select('.issue td.due-date', node);
			this.displayer.innerHTML = matches[0].innerHTML;		

			var value = Prototype.Selector.select('input[name=' + this.paramName + ']', node)[0].value,
					target = Prototype.Selector.select('input[name=' + this.paramName + ']')[0];
				
			target.value = value;
			target.setAttribute('value',value);
		}
	},

	sourceEnabled: function() {
		var disabled = $('issue_due_date').getAttribute('disabled');
		return disabled !== 'disabled';
	},
	
	show: function($super) {
		$super();
		if ( this.showing ) {
			this.field.click();
		}
	}
});

var IssueStatus = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		if ( this.sourceEnabled(paramName) ) {
			$super(paramName, labelSelector);
		}
	},

	sourceEnabled: function(paramName) {
		var e = Prototype.Selector.select('select[name="' + paramName + '"]');
		return e.length > 0;
	},

	targetFactory: function() {
		var target = Prototype.Selector.select('.issue td.status')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><select class="hidden">' + this.form_input[0].innerHTML + '</select>';
		target.innerHTML = new_html;
		
		return target;
	},

	formInputFinder: function() {
		return Prototype.Selector.select('select[name="' + this.paramName + '"]');
	},

	fieldFinder: function(target) {
		return Prototype.Selector.select('select', target)[0];
	},

	attachHandlers: function($super) {
		$super()

		var self = this;
		Event.observe(this.field, 'change', function(e) { self.submit(); });		
	},
	
	displayerUpdater: function() {
		var label = Prototype.Selector.select('option[value=' + this.field.value + ']', this.field)[0].innerHTML;
		this.displayer.innerHTML = label;
	},
	
	updateFromNode: function(node) {
		if ( this.displayer ) {		
			var matches = Prototype.Selector.select('#issue_status_id', node);
			this.displayer.innerHTML = Prototype.Selector.select('option[selected]', matches[0])[0].innerHTML;

			var options_html = matches[0].innerHTML;
			for(var i = 0, l = this.form_input.length; i < l; i++) {
				this.form_input[i].innerHTML = options_html;
			}
			this.field.innerHTML = options_html;
		}
	},	
	
	completeHandler: function($super, data) {
		new ViewUpdater(data.responseText);
	},

});

var IssuePriority = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		if ( this.sourceEnabled() ) {
			$super(paramName, labelSelector);
		}
	},

	sourceEnabled: function() {
		var disabled = $('issue_priority_id').getAttribute('disabled');
		return disabled !== 'disabled';
	},

	targetFactory: function() {
		var target = Prototype.Selector.select('.issue td.priority')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><select class="hidden">' + this.form_input[0].innerHTML + '</select>';
		target.innerHTML = new_html;
		
		return target;
	},

	formInputFinder: function() {
		return Prototype.Selector.select('select[name="' + this.paramName + '"]');
	},

	fieldFinder: function(target) {
		return Prototype.Selector.select('select', target)[0];
	},

	attachHandlers: function($super) {
		$super()

		var self = this;
		Event.observe(this.field, 'change', function(e) { self.submit(); });		
	},
	
	displayerUpdater: function() {
		var label = Prototype.Selector.select('option[value=' + this.field.value + ']', this.field)[0].innerHTML;
		this.displayer.innerHTML = label;
	},

	updateFromNode: function(node) {
		if ( this.displayer ) {
			var matches = Prototype.Selector.select('#issue_priority_id', node);
			this.displayer.innerHTML = Prototype.Selector.select('option[selected]', matches[0])[0].innerHTML;

			var options_html = matches[0].innerHTML;
			for(var i = 0, l = this.form_input.length; i < l; i++) {
				this.form_input[i].innerHTML = options_html;
			}
			this.field.innerHTML = options_html;
		}
	},	
	
	completeHandler: function($super, data) {
		new ViewUpdater(data.responseText);
	}
});

var DoneRatio = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		if ( this.enabled() ) {
			$super(paramName, labelSelector);

			this.skip_check = false;
			this.ajax_container_id = 'done_ajax';
		}
	},
	
	enabled: function() {
		var e = Prototype.Selector.select('div.issue')[0],
				parent_index = e.getAttribute('class').indexOf('parent'),
				child_index = e.getAttribute('class').indexOf('child'),
				result = (child_index > -1 && parent_index == -1) || (parent_index == -1 && child_index == -1);

		return result;
	},
	
	getId: function() {
		var f = Prototype.Selector.select('form#issue-form')[0],
				action = f.getAttribute('action'),
				matches = action.match(/\/issues\/(\d+)/i);
		return matches[1];
	},

	extractPercents: function(e) {
		var value = 0;
		
		if ( e ) {
			var p = e.getAttribute('style'),
					matches = p.match(/width: (\d+)%;/i);
			value = matches[1];
		}
		
		return value;
	},

	percentHTMLFactory: function(value) {
		var html = '<table class="progress" style="width:80px"><tbody><tr>' + ( value > 0 ? '<td class="closed" style="width: ' + value + '%;"></td>' : '' ) + ( 100 - value > 0 ? '<td class="todo" style="width: ' + (100 - value) + '%;"></td>' : '') + '</tr></tbody></table><p class="pourcent">' + value + '%</p>';
		return html;
	},

	formInputFinder: function() {
		return Prototype.Selector.select('input[name="' + this.paramName + '"]');
	},

	submitSetValues: function() {
		for(var i = 0, l = this.form_input.length; i < l; i++) {
			this.form_input[i].value = this.field.value;
			this.form_input[i].setAttribute('value', this.field.value);
		}
	},
	
	loadTimelogWindow: function() {
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
					
					// Event.observe($$('#' + self.ajax_container_id + ' form input[type=submit]')[0], 'click', function(e) { form.submit(); });
					self.showing = true;
									 						
					Prototype.Selector.select('#' + self.ajax_container_id + ' #time_entry_hours')[0].focus();
					Calendar.setup({inputField : 'time_entry_spent_on', ifFormat : '%Y-%m-%d', button : 'time_entry_spent_on_trigger' });
					
					Event.observe(
						Prototype.Selector.select('#' + self.ajax_container_id + ' input[type=submit]')[0],
						'click',
						function() {
							self.submit100Percent();
						}
					);
				}
			}
		);
	},
	
	submit100Percent: function() {
		var time_entry_hours = Prototype.Selector.select('input[name="time_entry[hours]"]')[0],
				time_entry_hours_old_val = time_entry_hours.value,
				time_entry_comments = Prototype.Selector.select('input[name="time_entry[comments]"]')[0],
				time_entry_comments_old_val = time_entry_comments.value,
				time_entry_activity_id = Prototype.Selector.select('select[name="time_entry[activity_id]"]')[0],
				time_entry_activity_id_old_html = time_entry_activity_id.innerHTML;
		
		time_entry_hours.value = Prototype.Selector.select('#' + this.ajax_container_id + ' #time_entry_hours')[0].value;
		time_entry_comments.value = Prototype.Selector.select('#' + this.ajax_container_id + ' #time_entry_comments')[0].value;
		
		var from = Prototype.Selector.select('#' + this.ajax_container_id + ' #time_entry_activity_id')[0];
		time_entry_activity_id.innerHTML = from.innerHTML;
		Prototype.Selector.select('option[value=' + from.getValue() + ']')[0].setAttribute('selected', 'selected');

		this.skip_check = true;
		this.submit();
		this.skip_check = false;

		time_entry_hours.value = time_entry_hours_old_val;
		time_entry_comments.value = time_entry_comments_old_val;
		time_entry_activity_id.innerHTML = time_entry_activity_id_old_html;

		this.hide();		
	},
	
	submit: function($super) {
		if ( !this.skip_check ) {
			this.loadTimelogWindow();
		}
		else {
			
			
			var oldHTML = this.form_input[0].innerHTML;
			$super();

			for(var i = 0, l = this.form_input.length; i < l; i++) {
				this.form_input[i].innerHTML = oldHTML;
			}
		}
	},

	hide: function($super) {
		$super();

		var c = $(this.ajax_container_id);
		c.innerHTML = '';
		c.style.left = 0;
		c.style.top = 0;
		
		this.field.value = this.inputValueGetter();
	},

	inputValueGetter: function() {
		var e = Prototype.Selector.select('.issue td.progress table.progress td.closed')[0],
				value = this.extractPercents(e);
		return value;
	},

	targetFactory: function() {
		var value = this.inputValueGetter(),
				html = '';
		
		html = this.percentHTMLFactory(value);

		var target = Prototype.Selector.select('.issue td.progress')[0],
				new_html = '<span class="inline-value">' + html + '</span><input type="text" class="hidden" size="10" value="' + value + '">';
		target.innerHTML = new_html;
		
		return target;
	},

	displayerUpdater: function() {
		var value = this.field.value;
		value = (value < 0 ? 0 : value);
		value = (value > 100 ? 100 : value);

		this.displayer.innerHTML = this.percentHTMLFactory(value);
	},
	
	completeHandler: function(data) {
		new ViewUpdater(data.responseText);
	},
	
	updateFromNode: function(node) {
		if ( this.displayer ) {		
			var element = Prototype.Selector.select('.issue td.progress table.progress td.closed', node)[0],
					value = this.extractPercents(element),
					html = this.percentHTMLFactory(value);
			this.displayer.innerHTML = html;
		
			this.form_input[0].value = value;
			this.form_input[0].setAttribute('value',value);
		}
	}
});

var AssignedTo = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		$super(paramName, labelSelector);
	},

	targetFactory: function() {
		var target = Prototype.Selector.select('.issue td.assigned-to')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><select class="hidden">' + this.form_input[0].innerHTML + '</select>';
		target.innerHTML = new_html;
		
		return target;
	},
	
	formInputFinder: function() {
		return Prototype.Selector.select('select[name="' + this.paramName + '"]');
	},
	
	fieldFinder: function(target) {
		return Prototype.Selector.select('select', target)[0];
	},
	
	attachHandlers: function($super) {
		$super()

		var self = this;
		Event.observe(this.field, 'change', function(e) { self.submit(); });		
	},
	
	displayerUpdater: function() {
		var label = Prototype.Selector.select('option[value=' + this.field.value + ']', this.field)[0].innerHTML;
		this.displayer.innerHTML = label;
	},
	
	updateFromNode: function(node) {
		var matches = Prototype.Selector.select('.issue td.assigned-to', node);
		if ( matches.length > 0 ) {
			this.displayer.innerHTML = matches[0].innerHTML;
		}
		
		var matches = Prototype.Selector.select('#issue_assigned_to_id', node);
		if ( matches.length > 0 ) {
			var options_html = matches[0].innerHTML;
			for(var i = 0, l = this.form_input.length; i < l; i++) {
				this.form_input[i].innerHTML = options_html;
			}
			this.field.innerHTML = options_html;
		}
	},
	
	completeHandler: function(data) {
		new ViewUpdater(data.responseText);
	}
});

var Auditor = Class.create(IssueSubject, {
	initialize: function($super, paramName, labelSelector) {
		$super(paramName, labelSelector);
	},

	targetFactory: function() {
		var target = Prototype.Selector.select('.issue td.auditor')[0],
				new_html = '<span class="inline-value">' + target.innerHTML + '</span><select class="hidden">' + this.form_input[0].innerHTML + '</select>';
		target.innerHTML = new_html;
		
		return target;
	},
	
	formInputFinder: function() {
		return Prototype.Selector.select('select[name="' + this.paramName + '"]');
	},
	
	fieldFinder: function(target) {
		return Prototype.Selector.select('select', target)[0];
	},
	
	attachHandlers: function($super) {
		$super()

		var self = this;
		Event.observe(this.field, 'change', function(e) { self.submit(); });		
	},
	
	displayerUpdater: function() {
		var label = Prototype.Selector.select('option[value=' + this.field.value + ']', this.field)[0].innerHTML;
		this.displayer.innerHTML = label;
	},
	
	updateFromNode: function(node) {
		var matches = Prototype.Selector.select('.issue td.auditor', node);
		if ( matches.length > 0 ) {
			this.displayer.innerHTML = matches[0].innerHTML;		
		}
		
		var from = Prototype.Selector.select('#issue_auditor_id', node);
		if ( from.length > 0 ) {
			var html = from[0].innerHTML;
			this.field.innerHTML = html;
			this.form_input[0].innerHTML = html;
		}
	},
	
	completeHandler: function(data) {
		new ViewUpdater(data.responseText);
	}
});

var SpentTime = Class.create(IssueSubject, {
	initialize: function($super, labelSelector) {
		if ( this.enabled() ) {
			this.showing = false;
			this.skip_check = false;
			
			this.label = Prototype.Selector.select(labelSelector)[0];
			
			this.attachHandlers();
			this.ajax_container_id = 'done_ajax';
		}
	},
	
	enabled: function() {
		var e = Prototype.Selector.select('div.issue')[0],
				parent_index = e.getAttribute('class').indexOf('parent'),
				child_index = e.getAttribute('class').indexOf('child'),
				result = (child_index > -1 && parent_index == -1) || (parent_index == -1 && child_index == -1);

		return result;
	},
	
	attachHandlers: function() {
		var self = this;
		Event.observe(this.label, 'click',	function(e) { self.show(); });
	},	
	
	getId: function() {
		var f = Prototype.Selector.select('form#issue-form')[0],
				action = f.getAttribute('action'),
				matches = action.match(/\/issues\/(\d+)/i);
		return matches[1];
	},
	
	loadTimelogWindow: function() {
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
					
					self.showing = true;
									 						
					Prototype.Selector.select('#' + self.ajax_container_id + ' #time_entry_hours')[0].focus();
					Calendar.setup({inputField : 'time_entry_spent_on', ifFormat : '%Y-%m-%d', button : 'time_entry_spent_on_trigger' });
					
					Event.observe(
						Prototype.Selector.select('#' + self.ajax_container_id + ' input[type=submit]')[0],
						'click',
						function() {
							self.submit100Percent();
						}
					);
				}
			}
		);
	},
	
	submit100Percent: function() {
		var time_entry_hours = Prototype.Selector.select('input[name="time_entry[hours]"]')[0],
				time_entry_hours_old_val = time_entry_hours.value,
				time_entry_comments = Prototype.Selector.select('input[name="time_entry[comments]"]')[0],
				time_entry_comments_old_val = time_entry_comments.value,
				time_entry_activity_id = Prototype.Selector.select('select[name="time_entry[activity_id]"]')[0],
				time_entry_activity_id_old_html = time_entry_activity_id.innerHTML;
		
		time_entry_hours.value = Prototype.Selector.select('#' + this.ajax_container_id + ' #time_entry_hours')[0].value;
		time_entry_comments.value = Prototype.Selector.select('#' + this.ajax_container_id + ' #time_entry_comments')[0].value;
		
		var from = Prototype.Selector.select('#' + this.ajax_container_id + ' #time_entry_activity_id')[0];
		time_entry_activity_id.innerHTML = from.innerHTML;
		Prototype.Selector.select('option[value=' + from.getValue() + ']')[0].setAttribute('selected', 'selected');

		this.skip_check = true;
		this.submit();
		this.skip_check = false;

		time_entry_hours.value = time_entry_hours_old_val;
		time_entry_comments.value = time_entry_comments_old_val;
		time_entry_activity_id.innerHTML = time_entry_activity_id_old_html;

		this.hide();		
	},
	
	submit: function($super) {
		if ( !this.skip_check ) {
			this.loadTimelogWindow();
		}
		else {
			var self = this;
			$('issue-form').request(
				{
					onComplete: function(data) {
						self.completeHandler(data);
					}
				}
			);

			this.hide();
		}
	},

	show: function() {
		if ( !this.showing ) {
			this.showing = true;
			this.submit();
		}
	},
	
	hide: function() {
		if ( this.showing ) {
			var c = $(this.ajax_container_id);
			c.innerHTML = '';
			c.style.left = 0;
			c.style.top = 0;

			this.showing = false;
		}
	},
	
	completeHandler: function(data) {
		new ViewUpdater(data.responseText);
	},
	
	updateFromNode: function(node) {
		var element = Prototype.Selector.select('.issue td.spent-time', node);		
		if ( element.length > 0 ) {
			var target = Prototype.Selector.select('.issue td.spent-time');
			if ( target.length > 0 ) {
				target[0].innerHTML = element[0].innerHTML;
			}
		}
	}
});


function initInlineEdit() {
	subject = new IssueSubject('issue[subject]'),
	desc = new IssueDesc('issue[description]', '.issue #descr_label'),
	start_date = new StartDate('issue[start_date]', '.issue th.start-date'),
	iduedate = new DueDate('issue[due_date]', '.issue th.due-date'),
	istatus = new IssueStatus('issue[status_id]', '.issue th.status'),
	ipriority = new IssuePriority('issue[priority_id]', '.issue th.priority'),
	iassigned = new AssignedTo('issue[assigned_to_id]', '.issue th.assigned-to'),
	idone = new DoneRatio('issue[done_ratio]', '.issue th.progress'),
	ispent = new SpentTime('.issue th.spent-time'),
	ac = new AddComment('#add_comment'),
	iauditor = new Auditor('issue[auditor_id]', '.issue th.auditor'),
	iestimated = new IssueEstimated('issue[estimated_hours]', '.issue th.estimated-hours');
};

Event.observe(window, 'load', initInlineEdit);