App = m.comp do
	oninit: !->
		@valTextInput = "Trái đất"
		@checkedCheckbox = yes
		@itemsSelect =
			* header: "Quốc gia"
			* text: "Nhật Bản"
				icon: \fad:quote-left
				value: \japan
			* text: "Trung Quốc"
			"Hàn Quốc"
			,,
			* value: "Việt Nam"
				icon: \fab:tiktok
			,,
			* header: "Khác"
			* text: "Ấn Độ"
				value: \anDo
			123
			no
		@valSelect = \anDo
		@pkms =
			* name: "Mewtwo"
				no: \150
				types: "Psychic"
			* name: "Salamence"
				no: \373
				types: "Dragon / Flying"
			* name: "Weavile"
				no: \461
				types: "Dark / Ice"
			* name: "Liepard"
				no: \510
				types: "Dark"
			* name: "Minccino"
				no: \572
				types: "Normal"
			* name: "Type: Null"
				no: \772
				types: "Normal"
			* name: "Centiskorch"
				no: \851
				types: "Fire / Bug"
			* name: "Hatterene"
				no: \858
				types: "Psychic / Fairy"
			* name: "Stonjourner"
				no: \874
				types: "Rock"
			* name: "Glastrier"
				no: \896
				types: "Ice"
			* name: "Spectrier"
				no: \897
				types: "Ghost"

	view: ->
		m \.p-2,
			m \style,
				"body > div > * {margin: 4px}"
			m Button,
				"Gray"
			for color in <[blue green yellow red orange cyan purple pink]>
				m Button,
					color: color
					color
			m Button,
				basic: yes
				"Gray"
			for color in <[blue green yellow red orange cyan purple pink]>
				m Button,
					basic: yes
					color: color
					color
			m Icon, \usb-drive
			m Button,
				icon: \fad:download
				"Download"
			m Button,
				disabled: yes
				"Disabled"
			m Button,
				disabled: yes
				color: \red
				"Disabled"
			m Button,
				basic: yes
				small: yes
				color: \red
				icon: \close
			m Table,
				bordered: yes
				striped: yes
				interactive: yes
				header:
					m \tr,
						m \th "No."
						m \th "Icon"
						m \th "Name"
						m \th "Types"
				@pkms.map (pkm) ~>
					m \tr,
						class: m.class do
							"active": pkm.name in [\Weavile \Liepard \Glastrier \Minccino]
						m \td,
							"\##{pkm.no}"
						m \td,
							m \img,
								src: "https://www.serebii.net/pokedex-swsh/icon/#{pkm.no}.png"
						m \td,
							pkm.name
						m \td,
							pkm.types
			m TextInput,
				defaultValue: "default"
			m TextInput,
				icon: \far:globe
				value: @valTextInput
				onchange: (event) !~>
					@valTextInput = event.target.value
			m PasswordInput,
				value: @valTextInput
			m \p 'Những bức ảnh về loài dơi có kích thước to bằng con người gần đây đã xuất hiện trên các phương tiện truyền thông xã hội, khiến cư dân mạng dậy sóng. Hình ảnh về loài dơi kỳ lạ từng được lan truyền trên trang Reddit vào năm 2018 và trở thành chủ đề nóng trên mạng. Mới đây, một bài đăng khác tiếp tục làm dấy lên sự quan tâm về loài dơi đặc biệt này. Nhiều người không tin vào mắt mình trước kích cỡ to lớn của con dơi. Một số ý kiến còn cho rằng sinh vật này không phải là dơi mà là "quái vật" vì quá khổng lồ. Tuy nhiên, sự thật là sinh vật này hoàn toàn có thật. Theo đó, chúng là loài dơi có nguồn gốc từ Philippines, được gọi là dơi "cáo bay vương miện vàng khổng lồ". Chúng cũng được gọi là dơi vương miện vàng, là một loài ăn quả thuộc họ dơi megabat lớn nhất thế giới.'
			m \p Date.now!
			m Checkbox
			m Checkbox,
				label: "Checkbox"
				checked: @checkedCheckbox
				onchange: (event) !~>
					@checkedCheckbox = event.target.checked
			m Radio,
				label: "Radio"
				checked: @checkedCheckbox
				onchange: (event) !~>
					@checkedCheckbox = event.target.checked
			m Select,
				items: @itemsSelect
			m Select,
				items: @itemsSelect
				value: @valSelect
				onvalue: (val) !~>
					@valSelect = val
			m Select,
				items: @itemsSelect
				value: @valSelect
				onvalue: (val) !~>
					@valSelect = \smith
