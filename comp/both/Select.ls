Select = m.comp do
	oninit: !->
		@controled = \value of @attrs
		@item = {}
		@isOpen = no
		@parseItems!

	oncreate: !->
		if @controled
			@setItemDomValue @attrs.value
		else if @attrs.defaultValue?
			@setItemDomValue @attrs.defaultValue
		else
			@item = @valueItems[@input.dom.selectedIndex] or {}
		m.redraw!

	onbeforeupdate: (old) !->
		if @controled and old and @attrs.value isnt old.attrs.value
			@setItemDomValue @attrs.value

	parseItems: !->
		@items = os.castArr @attrs.items .map (item) ~>
			if item?
				unless typeof item is \object
					item = value: item
				if \header of item
					header: item.header + ""
				else
					text: (item.text ? item.value) + ""
					icon: item.icon
					disabled: item.disabled
					value: (item.value ? "") + ""
			else
				divider: yes
		@valueItems = @items.filter (item) ~>
			\value of item

	setItemDomValue: (val) !->
		@input.dom.value = val
		@item = @valueItems[@input.dom.selectedIndex] or {}

	setItemValue: (val) !->
		unless @controled
			@setItemDomValue val
		os.safeCall @attrs.onvalue,, val
		m.redraw!

	onclickButton: (event) !->
		if @isOpen
			@closePopper!
		else
			@showPopper!

	showPopper: !->
		unless @isOpen
			@isOpen = yes
			@parseItems!
			rect = @dom.getBoundingClientRect!
			val = await os.showSelect @items, @item.value, rect
			if val?
				@setItemValue val
			@isOpen = no

	closePopper: !->
		if @isOpen
			@isOpen = no
			os.closeSelect!

	onremove: !->
		@closePopper!

	view: ->
		m \.Select,
			m Button,
				fill: yes
				alignText: \left
				icon: @item.icon or \blank
				rightIcon: \caret-down
				onclick: @onclickButton
				@item.text
			@input =
				m \select.Select__input,
					name: @attrs.name
					required: @attrs.required
					@valueItems.map (item) ~>
						m \option,
							selected: item.value is @attrs.value
							value: item.value
