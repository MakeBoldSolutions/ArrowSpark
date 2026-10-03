// Spike-only diagnostics for real-device checks. Inert unless the document URL carries ?spike.
// Reports viewport, pixel ratio, orientation, input capabilities and the canvas-to-CSS scale,
// and counts browser-level touch/pointer/mouse events. It changes no game behavior.
(function () {
	if (!/[?&]spike(=|&|$)/.test(window.location.search)) {
		return;
	}
	const panel = document.createElement('pre');
	panel.id = 'spike-probe';
	document.body.appendChild(panel);

	const counts = { touchstart: 0, touchend: 0, pointerdown: 0, mousedown: 0, click: 0 };
	let maxTouches = 0;
	window.addEventListener('touchstart', function (event) {
		maxTouches = Math.max(maxTouches, event.touches.length);
	}, { capture: true, passive: true });
	Object.keys(counts).forEach(function (name) {
		window.addEventListener(name, function () {
			counts[name] += 1;
		}, { capture: true, passive: true });
	});

	function media(query) {
		return window.matchMedia(query).matches ? 'yes' : 'no';
	}

	function render() {
		const canvas = document.getElementById('canvas');
		const scale = canvas && canvas.width ? (canvas.clientWidth / canvas.width) : NaN;
		panel.textContent = [
			'build     ' + window.location.pathname.split('/')[2],
			'viewport  ' + window.innerWidth + ' x ' + window.innerHeight + ' CSS px',
			'dpr       ' + window.devicePixelRatio,
			'orient    ' + (window.innerWidth >= window.innerHeight ? 'landscape' : 'portrait'),
			'canvas    ' + (canvas ? canvas.width + ' x ' + canvas.height + ' px' : 'n/a'),
			'canvas>css ' + (isFinite(scale) ? scale.toFixed(3) : 'n/a'),
			'pointer:fine ' + media('(pointer: fine)') + '  hover ' + media('(hover: hover)'),
			'touch pts ' + (navigator.maxTouchPoints || 0),
			'max fingers down ' + maxTouches,
			'events    ts ' + counts.touchstart + ' te ' + counts.touchend
				+ ' pd ' + counts.pointerdown + ' md ' + counts.mousedown + ' clk ' + counts.click,
		].join('\n');
	}

	window.addEventListener('resize', render);
	window.addEventListener('orientationchange', render);
	window.setInterval(render, 500);
	render();
}());
