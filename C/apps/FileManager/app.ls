await os.import do
	\:filesize@9.0.11

App = m.comp do
	oninit: !->
		@path = \/
		@entries = []
		@bgDataUrl = ""

	oncreate: !->
		os.listen do
			setDesktopBgPath: (path) !~>
				dataUrl = await os.readFile path, \dataUrl
				@bgDataUrl = dataUrl
		await @goPath @path
		m.redraw!

	goPath: (path) !->
		try
			@entries = await os.readDir path
			@path = path
		m.redraw!

	view: ->
		m \.h-100.p-2.column.gap-2,
			style: m.style do
				backgroundImage: "url(#@bgDataUrl)"
			unless os.args.isDesktop
				m \.col-0.row.gap-2,
					m \.col-0,
						m InputGroup,
							m Button,
								icon: \chevron-left
							m Button,
								icon: \chevron-right
							m Button,
								icon: \chevron-up
					m \form.col,
						m InputGroup,
							m TextInput,
								defaultValue: @path
							m Button,
								icon: \rotate-right
							m Button,
								type: \submit
								icon: \arrow-turn-down-left
			m \.col,
				if os.args.isDesktop
					m \.grid.gap-2.h-100.text-center.text-white,
						style: m.style do
							gridTemplateRows: "repeat(auto-fill,84px)"
							gridAutoColumns: 120
							gridAutoFlow: \column
						@entries.map (entry) ~>
							m \.column.center.middle.gap-1.p-2.rounded,
								m Icon,
									size: 32
									entry.icon
								m \.text-truncate.w-100,
									entry.name
				else
					m Table,
						class: "h-100"
						header:
							m \tr,
								m \th "Tên"
								m \th "Kích thước"
								m \th "Ngày sửa đổi"
						@entries.map (entry) ~>
							m \tr,
								m \td,
									entry.name
								m \td,
									filesize entry.size
								m \td,
									dayjs entry.mtime .format "DD/MM/YYYY HH:mm"
