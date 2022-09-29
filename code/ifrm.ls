class Ifrm extends Both
	->
		super!
		@listeners = void

	$listen: (listeners = {}) !->
		unless @listeners
			@listeners = listeners
			@startListenTask!

isM = no
isF = yes
osx = void

let
	TID = "{{@tid}}"
	resolvers = {}
	Promise = window.Promise
	postMessage = window.top.postMessage.bind window.top
	randomUUID = crypto.randomUUID.bind crypto
	publMethods = []

	for k, val of Ifrm::
		if k.0 is \$
			k2 = k.substring 1
			Ifrm::[k2] = val
			publMethods.push k2

	send = (type, name, args = []) ->
		new Promise (resolve, reject) !~>
			mid = randomUUID!
			resolvers[mid] = [resolve, reject]
			postMessage do
				type: \fmf
				tid: TID
				mid: mid
				name: name
				args: args
				\*

	addEventListener \message (event) !->
		if event.data
			{type} = event.data
			switch type
			| \fmf
				{mid, result, isErr} = event.data
				if resolver = resolvers[mid]
					resolver[isErr and 1 or 0] result
					delete resolvers[mid]
			| \mfm
				{mid, name, args} = event.data
				result = void
				isErr = no
				if Object.hasOwn os.listeners, name
					try
						result = await os.listeners[name] ...args
					catch
						result = e
						isErr = yes
					m.redraw!
				else
					result = Error "Không có sự kiện '#name'"
					isErr = yes
				postMessage do
					type: type
					tid: TID
					mid: mid
					result: result
					isErr: isErr

	data = await send \fmf \initTask
	data.publMethods.push ...publMethods
	for let name in data.methods
		Ifrm::[name] ?= (...args) ->
			send \fmf name, args

	os := new Ifrm
	osx := {[k, val] for k, val of os
		when typeof val is \function and data.publMethods.includes k
	}
	osx.args = data.args

	document.body.addEventListener \mousedown (event) !->
		if event instanceof MouseEvent and event.isTrusted
			os.mousedownGlobalTask do
				event.x
				event.y
				event.button

((os, isM, isF, osx, Ifrm, Both) !->
	{{code}}

	m.mount document.body, App
) osx
