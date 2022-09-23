Table = m.comp do
	view: ->
		m \.Table,
			class: m.class do
				"Table--hasHeader": @attrs.header
				"Table--bordered": @attrs.bordered
				"Table--striped": @attrs.striped
				"Table--interactive": @attrs.interactive
				@attrs.class
			style: m.style do
				@attrs.style
			m \table,
				m \thead,
					@attrs.header
				m \tbody,
					@children
