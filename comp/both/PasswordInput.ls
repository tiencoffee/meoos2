PasswordInput = m.comp do
	oninit: !->
		@isHidePassword = yes

	onclickIsHidePassword: (event) !->
		not= @isHidePassword

	view: ->
		m InputGroup,
			class:
				"PasswordInput--isHidePassword": @isHidePassword
				"PasswordInput"
				@attrs.class
			m TextInput,
				icon: @attrs.icon
				rightIcon: @attrs.rightIcon
				defaultValue: @attrs.defaultValue
				value: @attrs.value
				onchange: @attrs.onchange
			m Button,
				icon: @isHidePassword and \eye or \eye-slash
				onclick: @onclickIsHidePassword
