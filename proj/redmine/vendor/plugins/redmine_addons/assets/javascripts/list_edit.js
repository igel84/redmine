window.IN_PROGRESS_STATUS_ID = 1;

function init() {

	var queue = [], queue_index = 0;
	function continue_queue() {
		queue[queue_index]();
		queue_index++;
		
		if ( queue_index < queue.length - 1 ) {
			setTimeout(continue_queue, 5);
		}
	};
	
	function slice_targets(items) {
		var middle = Math.floor(items.length / 2);
		var d1 = items.slice(0, middle);
		var d2 = items.slice(middle, items.length);
		
		return [d1, d2];
	}

	var d = slice_targets( $$('.done_ratio') );
	queue.push(function() {	d[0].each(function(element) { new DoneField(element, window.IN_PROGRESS_STATUS_ID); });	});

	var e = slice_targets( $$('.estimated_hours') );
	queue.push(function() { e[0].each(function(element) { new EstimatedTimeField(element); }); });

	var start = slice_targets( $$('.start_date') );
	queue.push(function() {	start[0].each(function(element) { new StartDateField(element);	});	});

	var due = slice_targets( $$('.due_date') );
	queue.push(function() { due[0].each(function(element) { new DueDateField(element);	});	});

	var st = slice_targets( $$('.status') );
	queue.push(function() { st[0].each(function(element) { new StatusField(element); }); });

	var p = slice_targets( $$('.priority') );
	queue.push(function() {	p[0].each(function(element) { new PriorityField(element); }); });

	var a = slice_targets( $$('.assigned_to') );
	queue.push(function() {	a[0].each(function(element) { new AssignedField(element); });	});
	
	queue.push(function() {	d[1].each(function(element) { new DoneField(element, window.IN_PROGRESS_STATUS_ID); });	});
	queue.push(function() { e[1].each(function(element) { new EstimatedTimeField(element); }); });
	queue.push(function() {	start[1].each(function(element) { new StartDateField(element);	});	});
	queue.push(function() { due[1].each(function(element) { new DueDateField(element);	});	});
	queue.push(function() { st[1].each(function(element) { new StatusField(element); }); });
	queue.push(function() {	p[1].each(function(element) { new PriorityField(element); }); });
	queue.push(function() {	a[1].each(function(element) { new AssignedField(element); });	});	
	
	continue_queue();
};

function attachListEditInitHandler() {
	Event.observe(window, 'load', init);
};