await os.import do
	\:filesize@9.0.11

App = m.comp do
	oninit: !->
		@path = \/
		@entries = []

	oncreate: !->
		await @goPath @path

	goPath: (path) !->
		try
			@entries = await os.readDir path
			@path = path
		m.redraw!

	view: ->
		m \.h-100.p-2.column.gap-2,
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
