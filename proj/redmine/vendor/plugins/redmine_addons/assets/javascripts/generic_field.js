var GenericField = Class.create();
GenericField.prototype = {

  initialize: function(element, field_name, size) {
		this.element = element;
		this.field_name = field_name;
		this.size = size;

		this.showing = false;
		this.sending = false;

		this.initElements();
		this.attachHandlers();		
  },

	inputFactory: function() {
		return '<input type="text" class="list__input list__hidden" size="' + this.size + '">';
	},

	initElements: function() {		
		this.element.innerHTML = '<div class="container" style="height:auto;overflow:hidden">' + this.element.innerHTML + '</div>' + this.inputFactory();
		this.element.setAttribute('title', 'чтобы редактировать кликните');

		try {
			this.input = Prototype.Selector.select('input', this.element)[0];
		}
		catch(e) {
			
		}

		this.container = Prototype.Selector.select('.container', this.element)[0];
	},
	
	show: function() {
		this.container.addClassName('list__hidden');
		this.input.removeClassName('list__hidden');
		this.input.focus();
		this.input.select();

		this.showing = true;
	},
	
	hide: function() {
		this.container.removeClassName('list__hidden');
		this.input.addClassName('list__hidden');
		
		this.showing = false;
	},

	attachInputHandlers: function() {
		var self = this;
		Event.observe(this.input, 'keyup',	function(e) {	self.keyupHandler(e);	});
		Event.observe(this.input, 'keypress', function(e) { self.keypressHandler(e); }, true);
	},
	
	keypressHandler: function(event) {
		var key = window.event ? window.event.keyCode : e ? e.which : 0;
		if ( key >= 32 && key < 127 ) {
			var ch = String.fromCharCode(key);
			if ( /[a-zA-Z]/.test(ch) ) {
				Event.stop(event);
			}
		}
	},
	
	attachHandlers: function() {
		var self = this;
		this.attachInputHandlers();
		Event.observe(document, 'click', function(e) { self.documentClickHandler(e); });
		Event.observe(this.element, 'click', function(e) { self.clickHandler(e); } );						
	},
	
	documentClickHandler: function(e) {
		if ( this.showing ) {
			this.hide();
		}
	},
	
	clickHandler: function(e) {
		if ( this.sending )
			return;
		
		this.input.setValue(this.getValue());

		this.show();

		e.preventDefault();
		e.stopPropagation();		
	},
	
	getValue: function() {
		var value = 0, closed = Prototype.Selector.select('.closed', this.element);
		if ( closed.length == 1 && closed[0].style.width ) {
			var temp = closed[0].style.width;
			temp = temp.substr(0, temp.length - 1);
			value = temp;
		}					

		return  value;
	},
	
	keyupHandler: function(e) {
		if ( e.keyCode == 27 ) {
			this.input.addClassName("list__hidden");
			this.container.removeClassName("list__hidden");						
		}
		
		if ( e.keyCode == 13 ) {
			this.enterPressed();
		}		
	},
	
	enterPressed: function() {
		this.send(this.input.getValue());
	},

	prepareValue: function(value) {
		return value.toString().replace(/^\s+|\s+$/g, '');
	},
		
	formBuilder: function(value) {
		var a_token = $$('input[name=authenticity_token]')[0].getValue(),
				s = '<input type="hidden" name="authenticity_token" value="' + a_token + '"/>' +
						'<input type="hidden" name="back_url" value="' + location.href + '">' +
						'<input type="hidden" name="id" value="' + this.getId() + '"/>' +
						'<input type="hidden" name="' + this.field_name + '" value="' + this.prepareValue(value) + '"/>';
		return s;
	},
	
	getId: function() {
		var id = this.element.parentNode.id;
		id = id.substr(6, id.length - 1);
		return id;
	},
	
	send: function(value) {		
		var form = document.createElement('form');
		Element.extend(form);
		
		form.setAttribute('action', '/issues/bulk_edit');
		form.setAttribute('method', 'post');
		
		form.update(this.formBuilder(value));
		
		this.input.setAttribute('readonly', true);

		Element.show('ajax-indicator');
		this.sending = true;
		
		form.submit();		
	}

};