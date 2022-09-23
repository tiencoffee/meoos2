Checkbox = m.comp do
	oninit: !->
		@controled = \checked of @attrs

	onbeforeupdate: !->
		if @controled
			@checked = @attrs.checked

	onchangeInput: (event) !->
		unless @controled
			@checked = event.target.checked
		os.safeCall @attrs.onchange,, event

	view: ->
		m \label.Checkbox,
			class: m.class do
				"disabled": @attrs.disabled
			m \input.Checkbox__input,
				type: \checkbox
				disabled: @attrs.disabled
				checked: @checked
				onchange: @onchangeInput
			if @attrs.label
				m \.Checkbox__label,
					@attrs.label
