class Both
	->
		m.bind @
		@libs = Object.create null

	$castArr: (val) ->
		if Array.isArray val => val
		else if val? => [val]
		else []

	$safeCall: (func, thisArg, ...args) ->
		if typeof func is \function
			try
				func.apply thisArg, args
			catch
				console.error e

	$indent: (text, level = 1) ->
		(text + "")replace /^(?=.)/gm "\t"repeat level

	$createPopper: (refEl, popperEl, opts) ->
		Popper.createPopper refEl, popperEl,
			placement: opts.placement
			modifiers:
				* name: \offset
					options:
						offset: opts.offset
				* name: \preventOverflow
					options:
						padding: opts.padding
						terser: opts.terser or opts.terser is 0
						terserOffset: opts.terser
				* name: \flip
					options:
						fallbackPlacements: opts.flips
						allowedAutoPlacements: opts.allowedFlips

	$splitPath: (path) ->
		if path.0 is \/
			root = \/
			path .= substring 1
		else
			root = ""
		nodes = []
		vals = path.split /\/+/
		for val in vals
			val .= trim!
			switch val
			| \. "" =>
			| \.. => nodes.pop!
			else nodes.push val
		[nodes, root]

	$normPath: (path) ->
		[nodes, root] = @splitPath path
		root + nodes.join \/

	$dirPath: (path) ->
		[nodes, root] = @splitPath path
		root + nodes.slice 0 -1 .join \/

	$filePath: (path) ->
		[nodes] = @splitPath path
		nodes.at -1 or ""

	$basePath: (path) ->
		name = @filePath path
		/^(.*?)(?:\.[^.]*)?$/exec name .1

	$extPath: (path, withDot) ->
		name = @filePath path
		base = @basePath name
		ext = name.replace base, ""
		unless withDot
			ext .= substring 1
		ext

	$import: (...names) ->
		libs = []
		for let name in names
			unless lib = @libs[name]
				[kind, path] = name.split \:
				kind = \npm if kind is ""
				isCss = name.endsWith \.css
				url = switch kind
					| \npm => "https://cdn.jsdelivr.net/npm/#path"
					| \gh => "https://cdn.jsdelivr.net/gh/#path"
				prom = new Promise (resolve) !~>
					text = await m.fetch url
					resolve text
				lib =
					kind: kind
					path: path
					isCss: isCss
					url: url
					prom: prom
				@libs[name] = lib
			if lib.prom
				libs.push lib
		libs.sort (a, b) ~> b.isCss - a.isCss
		texts = await Promise.all libs.map (.prom)
		for text, i in texts
			lib = libs[i]
			if lib.prom
				delete lib.prom
				if lib.isCss
					libsEl.textContent += "#text\n"
				else
					window.eval text

os = void
dayjs.locale \vi
