Menu = m.comp do
	oninit: !->
		@menuId = crypto.randomUUID!
		@rootMenuId = @attrs.rootMenuId or @menuId
		@level = @attrs.level ? -1
		@clicks = {}
		@items = @parseItems @attrs.items
		@item = void
		@timo = void

	parseItems: (items, parentId = "") ->
		if @rootMenuId is @menuId
			os.castArr items .map (item, i) ~>
				id = "#parentId.#i"
				item =
					if item?
						unless typeof item is \object
							item = text: item + ""
						if \header of item
							header: item.header + ""
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
					else
						divider: yes
				item.id = id
				item
		else
			items

	onmouseenterItem: (item, event) !->
		unless @item?id is item.id
			if @item
				@item = void
				os.closeSubmenu @menuId
			if item.items
				{target} = event
				@timo = setTimeout !~>
					@item = item
					@timo = void
					rect = isF and target.getBoundingClientRect! or target
					id = await os.showSubmenu @menuId, item.items, rect, @rootMenuId, @level + 1
					if @rootMenuId is @menuId and id
						@clicks[id]!
					@item = void
					m.redraw!
				, 250

	onmouseleaveItem: (item, event) !->
		if @timo
			@timo = clearTimeout @timo

	onclickItem: (item, event) !->
		if not item.items and item.onclick
			os.closeSubmenu @rootMenuId, item.id

	onremove: !->
		@timo = clearTimeout @timo
		os.closeSubmenu @menuId

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
