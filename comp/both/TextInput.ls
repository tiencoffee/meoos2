TextInput = m.comp do
	oncreate: !->
		@input.dom.value? = @attrs.defaultValue

	onchangeInput: (event) !->
		os.safeCall @attrs.onchange,, event

	view: ->
		m \.TextInput,
			if @attrs.icon
				m Icon, @attrs.icon
			@input =
				m \input.TextInput__input,
					type: @attrs.type
					name: @attrs.name
					value: @attrs.value
					oninput: @onchangeInput
			if @attrs.rightIcon
				m Icon, @attrs.rightIcon
