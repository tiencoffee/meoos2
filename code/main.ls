class Main extends Both
	->
		super!
		@select = void

	castPath: (entry) ->
		entry.path or entry

	$getEntry: (path) ->
		stat = await fs.stat path
		name: stat.name
		path: stat.fullPath
		isFile: stat.isFile
		isDir: stat.isDirectory
		mtime: stat.modificationTime
		size: stat.size
		children: path.children

	$moveEntry: (oldPath, path, isCreate) ->
		path = await @castPath path
		entry = await fs.rename oldPath, path, create: isCreate
		@getEntry entry

	$copyEntry: (oldPath, path, isCreate) ->
		path = await @castPath path
		entry = await fs.copy oldPath, path, create: isCreate
		@getEntry entry

	$existsEntry: (path) ->
		fs.exists path

	$createDir: (path) ->
		entry = await fs.mkdir path
		@getEntry entry

	$readDir: (path, isDeep) ->
		path = await @castPath path
		entries = await fs.readdir path, deep: isDeep
		fn = (entries) ~>
			Promise.all entries.map (entry) ~>
				entry = await @getEntry entry
				entry.children and= await fn entry.children
				entry
		fn entries

	$removeDir: (path) ->
		path = await @castPath path
		res = await fs.rmdir path
		res is void

	$readFile: (path, type = \text) ->
		path = await @castPath path
		type = _.upperFirst type
		fs.readFile path, type

	$writeFile: (path, data) ->
		path = await @castPath path
		entry = await fs.writeFile path, data
		@getEntry entry

	$appendFile: (path, data) ->
		path = await @castPath path
		entry = await fs.appendFile path, data
		@getEntry entry

	$removeFile: (path) ->
		path = await @castPath path
		res = await fs.unlink path
		res is void

	$runTask: (filePath, env) ->
		filePath = @castPath filePath
		path = @dirPath filePath
		if app = os.apps.find (.path is path)
			resolve = void
			promise = new Promise (resolve2) !~>
				resolve := resolve2
			task = new Task app, promise, resolve, env
			os.tasks.push task
			m.redraw!
			task.tid
		else
			throw Error "Không tìm thấy ứng dụng '#filePath'"

	$waitTask: (tid) ->
		if task = os.tasks.find (.tid is tid)
			await task.promise

	$closeTask: (tid, val) !->
		if task = os.tasks.find (.tid is tid)
			task.close val

	_showSelect: (items, activeValue, rect) ->
		new Promise (resolve) !~>
			if @iframe
				{x, y} = @iframe.getBoundingClientRect!
				rect :=
					width: rect.width
					height: rect.height
					left: rect.left + x
					top: rect.top + y
					right: rect.right + x
					bottom: rect.bottom + y
			el = document.createElement \div
			el.className = "Select__popper"
			el.style.width = rect.width + \px
			document.body.appendChild el
			m.mount el,
				view: ~>
					items.map (item) ~>
						if \header of item
							m \.Select__header,
								item.header
						else if item.divider
							m \.Select__divider
						else
							m \.Select__item,
								class: m.class do
									"active": activeValue is item.value
									"disabled": item.disabled
								onclick: (event) !~>
									@closeSelect item.value
								m Icon, item.icon
								item.text
			dom =
				getBoundingClientRect: ~>
					rect
			popper = @createPopper dom, el,
				placement: \bottom-start
				flips: \top-start
				allowedFlips: [\bottom-start \top-start]
			document.body.addEventListener \mousedown @onmousedownGlobalSelect
			@select =
				resolve: resolve
				el: el
				popper: popper

	onmousedownGlobalSelect: (event) !->
		if event instanceof MouseEvent and event.isTrusted
			unless @select.el.contains event.target
				@closeSelect!

	_closeSelect: (val) !->
		if @select
			m.mount @select.el
			@select.el.remove!
			@select.popper.destroy!
			@select.resolve val
			@select = void
			document.body.removeEventListener \mousedown @onmousedownGlobalSelect
