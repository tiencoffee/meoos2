Icon = m.comp do
	onbeforeupdate: !->
		val = (@children.0 or "") + ""
		unless val.includes \:
			val = "fas:#val"
		[@kind, @name, @color] = val.split /[:|]/
		if @color?0 isnt \#
			@color = "##@color"

	view: ->
		match @kind
		| /^fa[srltdb]?$/
			m \i.Icon,
				class: m.class do
					"#@kind fa-#@name"
					@attrs.class
				style: m.style do
					fontSize: @attrs.size
					color: @color
					@attrs.style
