class Ifrm extends Both
	->
		super!

for k, val of Ifrm::
	if k.0 is \$
		k2 = k.substring 1
		Ifrm::[k2] = val

osx = void

let Promise
	TID = "{{@tid}}"
	resolvers = {}
	randomUUID = crypto.randomUUID.bind crypto

	send = (type, name, args = []) ->
		new Promise (resolve, reject) !~>
			mid = randomUUID!
			top.postMessage do
				type: \fmf
				tid: TID
				mid: mid
				name: name
				args: args
				\*
			resolvers[mid] = [resolve, reject]

	addEventListener \message (event) !->
		if event.data
			switch event.data.type
			| \fmf
				{mid, result, isErr} = event.data
				if resolver = resolvers[mid]
					resolver[isErr and 1 or 0] result
					delete resolvers[mid]

	data = await send \fmf \initTask
	for let name in data.methods
		Ifrm::[name] = (...args) ->
			send \fmf name, args

	os := new Ifrm
	osx := {[k, val] for k, val of os
		when typeof val is \function and data.publMethods.includes k
	}

	document.body.addEventListener \mousedown (event) !->
		if event instanceof MouseEvent and event.isTrusted
			os.mousedownGlobalTask do
				event.x
				event.y
				event.button

((os, osx, Ifrm, Both) !->
	{{code}}

	m.mount document.body, App
) osx
