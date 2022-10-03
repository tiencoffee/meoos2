class Task extends Main
	(app, promise, resolve, env = {}) ->
		super!
		@pid = +_.uniqueId!
		@tid = crypto.randomUUID!
		@app = app
		@promise = promise
		@resolve = resolve
		@name = app.name
		@icon = app.icon
		@path = app.path
		@type = app.type or env.type
		@title = app.title ? env.title ? @name
		@width = app.width or env.width or 800
		@height = app.height or env.height or 600
		@x = app.x ? env.x ? Math.floor (os.desktopWidth - @width) / 2
		@y = app.y ? env.y ? Math.floor (os.desktopHeight - @height) / 2
		@maximized = Boolean app.maximized ? env.maximized
		@minimized = Boolean app.minimized ? env.minimized
		@noHeader = app.noHeader ? env.noHeader ? no
		@skipTaskbar = app.skipTaskbar ? env.skipTaskbar ? no
		@args = env.args or {}
		@evts = env.evts or []
		if typeof @evts.0 is \string
			@evts = [@evts]
		@resolvers = {}
		@moving = no
		@loaded = no

	oncreate: (vnode) !->
		@dom = vnode.dom
		@iframe = @dom.querySelector \iframe
		@clampXY!
		@updateSizeDom!
		@updateXYDom!
		if @maximized
			@updateMaximizeDom 0
		if @minimized
			@updateMinimizeDom 0
		await @initContent!
		@loaded = yes
		anime do
			targets: @dom
			scale: [0.9 1]
			opacity: [0 1]
			duration: 300
			easing: \easeOutCubic
		m.redraw!

	initContent: !->
		code = await @readFile "#@path/app.ls"
		code = codef.replace /(\t*)\{\{(@?)(\w+)\}\}/g (, tab, thisArg, name) ~>
			val = if thisArg => @[name] else eval name
			@indent val, tab.length
		code = livescript.compile code
		try
			styl = await @readFile "#@path/app.styl"
		catch
			styl = ""
		styl = stylf + \\n + styl
		styl = stylus.render styl, compress: yes
		temp = tempf
			.replace /\{\{(\w+)\}\}/g (, name) ~>
				eval name
			.replace /<!-- Code injected by live-server -->.+?<\/script>/s ""
		@iframe.srcdoc = temp

	$maximize: (val) !->
		val = Boolean val ? not @maximized
		if val isnt @maximized
			@maximized = val
			@updateMaximizeDom!
			m.redraw!

	$minimize: (val) !->
		val = Boolean val ? not @minimized
		if val isnt @minimized
			@minimized = val
			@updateMinimizeDom!
			m.redraw!

	$close: (val) !->
		if @resolve
			_.pull os.tasks, @
			@resolve val
			@resolve = void
			m.redraw!

	clampXY: !->
		@x = _.clamp @x, 0 os.desktopWidth - @width
		@y = _.clamp @y, 0 os.desktopHeight - @height

	updateSizeDom: !->
		anime.set @dom,
			width: @width
			height: @height

	updateXYDom: !->
		anime.set @dom,
			left: @x
			top: @y

	updateMaximizeDom: (duration = 300) !->
		if @dom and not @minimized
			if @maximized
				anime do
					targets: @dom
					left: 0
					top: 0
					width: os.desktopWidth
					height: os.desktopHeight
					duration: duration
					easing: \easeOutCubic
			else
				anime.remove @dom
				anime.set @dom,
					left: @x
					top: @y
					width: @width
					height: @height
				delete @dom.dataset.restored
				@dom.offsetWidth
				@dom.dataset.restored = 1

	updateMinimizeDom: (duration = 300) !->
		if @dom
			if @minimized
				el = document.querySelector ".App__taskbarTask--#@pid"
				rect = el.getBoundingClientRect!
			else
				rect =
					if @maximized
						x: 0
						y: 0
						width: os.desktopWidth
						height: os.desktopHeight
					else
						x: @x
						y: @y
						width: @width
						height: @height
			anime do
				targets: @dom
				left: rect.x
				top: rect.y
				width: rect.width
				height: rect.height
				duration: duration
				easing: \easeOutCubic

	postMessageTask: (name, args, resolve, reject) !->
		mid = crypto.randomUUID!
		@resolvers[mid] = [resolve, reject]
		@iframe.contentWindow.postMessage do
			type: \mfm
			mid: mid
			name: name
			args: args
			\*

	_initTask: ->
		methods: @@methods
		publMethods: @@publMethods
		args: delete @args

	_mousedownGlobalTask: (x, y, button) !->
		rect = @iframe.getBoundingClientRect!
		evt = new MouseEvent \mousedown,
			clientX: x + rect.x
			clientY: y + rect.y
			button: button
		document.body.dispatchEvent evt

	_startListenTask: !->
		if @evts
			for evt in @evts
				@postMessageTask.apply void evt
			delete @evts

	_showSubmenu: (items, rect) ->
		os.showSubmenu items, rect, @

	_closeSubmenu: (itemId) !->
		os.closeSubmenu itemId

	onpointerdownTitle: (event) !->
		event.target.setPointerCapture event.pointerId
		@moving = 0

	onpointermoveTitle: (event) !->
		event.redraw = no
		@moving = yes if @moving is 0
		if @moving
			if @maximized
				@x = event.x - @width / 2
				@y = 0
				@clampXY!
				@maximize no
			@x += event.movementX
			@y += event.movementY
			@updateXYDom!

	onlostpointercaptureTitle: (event) !->
		if @moving
			@clampXY!
			@updateXYDom!
		@moving = no

	onclickMinimize: (event) !->
		@minimize!

	onclickMaximize: (event) !->
		@maximize!

	onclickClose: (event) !->
		@close!

	onbeforeremove: ->
		@closeSelect!
		if os.taskSubmenu is @
			os.closeSubmenu!
		anime do
			targets: @dom
			scale: 0.9
			opacity: 0
			duration: 300
			easing: \easeOutCubic
		.finished

	view: ->
		m \.Task,
			class: m.class do
				"Task--loaded": @loaded
				"Task--maximized": @maximized
				"Task--minimized": @minimized
			unless @noHeader
				m \.Task__header,
					m Button,
						basic: yes
						small: yes
						icon: @icon
					m \.Task__title,
						onpointerdown: @onpointerdownTitle
						onpointermove: @onpointermoveTitle
						onlostpointercapture: @onlostpointercaptureTitle
						@title
					m Button,
						basic: yes
						small: yes
						icon: \minus
						onclick: @onclickMinimize
					m Button,
						basic: yes
						small: yes
						icon: \plus
						onclick: @onclickMaximize
					m Button,
						basic: yes
						small: yes
						color: \red
						icon: \times
						onclick: @onclickClose
			m \.Task__body,
				m \iframe.Task__iframe

	@publMethods = []
	@methods = []

for k, val of Task::
	if k.0 in [\$ \_]
		k2 = k.substring 1
		Task::[k2] = val
		if k.0 is \$
			Task.publMethods.push k2
		unless Both::[k]
			Task.methods.push k2
