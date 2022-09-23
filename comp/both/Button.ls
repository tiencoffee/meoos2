Button = m.comp do
	onbeforeupdate: !->
		@attrs.type ?= \button

	view: ->
		m \button.Button,
			class: m.class do
				"Button--basic": @attrs.basic
				"Button--small": @attrs.small
				"Button--fill": @attrs.fill
				"Button--#{@attrs.alignText}": @attrs.alignText
				"Button--#{@attrs.color}": @attrs.color
				"disabled": @attrs.disabled
				@attrs.class
			type: @attrs.type
			disabled: @attrs.disabled
			onclick: @attrs.onclick
			if @attrs.icon
				m Icon, @attrs.icon
			if @children.length
				m \.Button__text,
					@children
			if @attrs.rightIcon
				m Icon, @attrs.rightIcon
