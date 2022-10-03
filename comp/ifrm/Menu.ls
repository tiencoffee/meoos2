Menu = m.comp do
	oninit: !->
		@clicks = {}
		@items = @parseItems @attrs.items
		@item = void
		@timo = void

	parseItems: (items, parentId = "") ->
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

	showPopper: (item, refEl) !->
		unless @item
			@item = item
			@timo = void
			m.redraw!
			rect = refEl.getBoundingClientRect!
			itemId = await os.showSubmenu item.items, rect
			if itemId
				os.safeCall @clicks[itemId]
				os.safeCall @attrs.onitemidclick,, itemId
			@item = void
			m.redraw!

	closePopper: !->
		if @item
			@item = void
			os.closeSubmenu!
			m.redraw!

	onmouseenterItem: (item, event) !->
		unless @item?id is item.id
			await @closePopper!
			if item.items
				@timo = setTimeout !~>
					@showPopper item, event.target
				, 250

	onmouseleaveItem: (item, event) !->
		@timo and= clearTimeout @timo

	onclickItem: (item) !->
		unless item.items
			os.safeCall @clicks[item.id]
			os.safeCall @attrs.onitemidclick,, item.id
			@closePopper!

	onremove: !->
		clearTimeout @timo
		@closePopper!

	view: ->
		m \.Menu,
			class: m.class do
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
