class App extends Main
	->
		super!
		@loaded = no
		@taskbarHeight = 39
		@desktopWidth = innerWidth
		@desktopHeight = innerHeight - @taskbarHeight
		@desktopX = 0
		@desktopY = 0
		@desktopBgPath = \/C/imgs/bg/0.jpg
		@desktopTid = void
		@apps = []
		@tasks = []

	oncreate: (vnode) !->
		@dom = vnode.dom
		await fs.init bytes: 536870912
		for path in Paths"/C/!(apps)/**/*.*"
			buf = await m.fetch path, \arrayBuffer
			await @writeFile path, buf
		for path in Paths"/C/apps/*"
			await @installApp \local path, path
		addEventListener \message @onmessage
		@loaded = yes
		m.redraw!
		@desktopTid = @runTask \/C/apps/FileManager/app.yml,
			maximized: yes
			noHeader: yes
			skipTaskbar: yes
			args:
				isDesktop: yes
			evts:
				[\setDesktopBgPath [@desktopBgPath]]
		@runTask \/C/apps/Demo/app.yml

	installApp: (kind, srcPath, path) ->
		switch kind
		| \local
			yaml = await m.fetch "#srcPath/app.yml"
			pack = jsyaml.safeLoad yaml
			await @writeFile "#path/app.yml" yaml
			code = await m.fetch "#srcPath/app.ls"
			await @writeFile "#path/app.ls" code
			try
				styl = await m.fetch "#srcPath/app.styl"
				await @writeFile "#path/app.styl" styl
			app =
				name: pack.name
				path: path
				icon: pack.icon ? \fad:window
				type: pack.type or \user
				title: pack.title
				width: pack.width
				height: pack.height
				x: pack.x
				y: pack.y
				maximized: pack.maximized
				minimized: pack.minimized
				noHeader: pack.noHeader
				skipTaskbar: pack.skipTaskbar
			@apps.push app
		m.redraw!

	onclickTaskbarTask: (task, event) !->
		task.minimize!

	onmessage: (event) !->
		if event.data
			{type, tid} = event.data
			if task = @tasks.find (.tid is tid)
				switch type
				| \fmf
					{mid, name, args} = event.data
					result = void
					isErr = no
					if Task.methods.includes name
						try
							result = await task[name] ...args
						catch
							result = e
							isErr = yes
					else
						result = Error "Không có phương thức '#name'"
						isErr = yes
					task.iframe.contentWindow.postMessage do
						type: type
						mid: mid
						result: result
						isErr: isErr
						\*
				| \mfm
					{mid, result, isErr} = event.data
					if resolver = task.resolvers[mid]
						resolver[isErr and 1 or 0]? result
						delete task.resolvers[mid]

	view: ->
		m \.App,
			m \.App__desktop,
				@tasks.map (task) ~>
					m task,
						key: task.pid
			m \.App__taskbar,
				style: m.style do
					height: @taskbarHeight
				m \.App__taskbarTasks,
					@tasks.map (task) ~>
						if task.skipTaskbar
							m.fragment do
								key: task.pid
						else
							m Button,
								key: task.pid
								class: "App__taskbarTask App__taskbarTask--#{task.pid}"
								icon: task.icon
								onclick: @onclickTaskbarTask.bind void task
								task.title

for k, val of App::
	if k.0 in [\$ \_]
		k2 = k.substring 1
		App::[k2] = val

isM = yes
isF = no
os = new App

m.mount document.body, os
