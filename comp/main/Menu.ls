Menu = m.comp do
	oninit: !->
		@clicks = {}
		@root = @attrs.root or @
		@isTop = @attrs.isTop ? @root is @
		@items = @parseItems @attrs.items
		@item = void
		@timo = void
		@popper = void

	parseItems: (items, parentId = "") ->
		if @isTop
			os.castArr items .map (item, i) ~>
				id = "#parentId.#i"
				item =
					| not item?
						divider: yes
					| typeof item isnt \object
						text: item + ""
					| \header of item
						header: item.header + ""
					| \divider of item
						divider: yes
					else
						item2 = text: item.text + ""
						item2.icon? = item.icon
						item2.disabled? = item.disabled
						item2.color? = item.color
						if item.items
							items2 = @parseItems item.items, id
							if items2.length
								item2.items = items2
						else
							item2.label? = item.label
							if typeof item.onclick is \function
								@clicks[id] = item.onclick
								item2.onclick = yes
						item2
				item.id = id
				item
		else
			items

	showPopper: (item, refEl) !->
		unless @popper
			@item = item
			@timo = void
			el = document.createElement \div
			el.className = "Menu__popper"
			refEl.appendChild el
			m.mount el,
				view: ~>
					m Menu,
						class: "Menu__submenu"
						basic: yes
						root: @root
						items: item.items
			@popper = os.createPopper refEl, el,
				placement: \right-start
				flips: \left-start
				offset: [-8 -4]
				altAxis: no
			if @isTop
				document.body.addEventListener \mousedown @onmousedownGlobal
			m.redraw!

	closePopper: !->
		if @popper
			@item = void
			@popper.state.elements.popper.remove!
			@popper.destroy!
			@popper = void
			if @isTop
				document.body.removeEventListener \mousedown @onmousedownGlobal
			m.redraw!

	onmouseenterItem: (item, event) !->
		unless @item?id is item.id
			@closePopper!
			if item.items
				@timo = setTimeout !~>
					@showPopper item, event.target
				, 250

	onmouseleaveItem: (item, event) !->
		@timo and= clearTimeout @timo

	onclickItem: (item, event) !->
		event.stopPropagation!
		unless item.items
			os.safeCall @root.clicks[item.id]
			os.safeCall @root.attrs.onitemidclick,, item.id
			@root.closePopper!

	onmousedownGlobal: (event) !->
		unless @dom.contains event.target
			@closePopper!
			m.redraw!

	onremove: !->
		clearTimeout @timo
		@closePopper!

	view: ->
		m \.Menu,
			class: m.class do
				"Menu--basic": @attrs.basic
				@attrs.class
			@items.map (item) ~>
				if \header of item
					m \.Menu__header,
						key: item.id
						item.header
				else if item.divider
					m \.Menu__divider,
						key: item.id
				else
					m \.Menu__item,
						key: item.id
						class: m.class do
							"Menu__item--#{item.color}": item.color
							"active": @item is item
							"disabled": item.disabled
						onmouseenter: @onmouseenterItem.bind void item
						onmouseleave: @onmouseleaveItem.bind void item
						onclick: @onclickItem.bind void item
						m \.Menu__itemIcon,
							m Icon, item.icon
						m \.Menu__itemText,
							item.text
						m \.Menu__itemLabel,
							if item.items
								m Icon, \caret-right
							else
								item.label
