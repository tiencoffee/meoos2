Icon = m.comp do
	onbeforeupdate: !->
		val = (@children.0 or "") + ""
		unless val.includes \:
			val = "fas:#val"
		[@kind, @name] = val.split \:

	view: ->
		match @kind
		| /^fa[srltdb]?$/
			m \i.Icon,
				class: m.class do
					"#@kind fa-#@name"
					@attrs.class
