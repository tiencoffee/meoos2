Radio = m.comp do
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
		m \label.Radio,
			class: m.class do
				"disabled": @attrs.disabled
			m \input.Radio__input,
				type: \radio
				disabled: @attrs.disabled
				checked: @checked
				onchange: @onchangeInput
			if @attrs.label
				m \.Radio__label,
					@attrs.label
