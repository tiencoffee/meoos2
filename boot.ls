Paths = await m.fetch \paths.json \json

[codeb, codem, codet, codea, codef, stylb, stylm, stylf, tempf, compb, compm, compf] = await Promise.all [
	m.fetch \/code/both.ls
	m.fetch \/code/main.ls
	m.fetch \/code/task.ls
	m.fetch \/code/app.ls
	m.fetch \/code/ifrm.ls
	m.fetch \/styl/both.styl
	m.fetch \/styl/main.styl
	m.fetch \/styl/ifrm.styl
	m.fetch \/ifrm.html
	Promise.all Paths"/comp/both/*"map ~> m.fetch it
	Promise.all Paths"/comp/main/*"map ~> m.fetch it
	Promise.all Paths"/comp/ifrm/*"map ~> m.fetch it
]
compb *= \\n
compm *= \\n
compf *= \\n

stylm = stylb + stylm
stylf = stylb + stylf
codem = compb + compm + codeb + codem + codet + codea
codef = compb + compf + codeb + codef

stylm = stylus.render stylm, compress: yes
stylEl.textContent = stylm

codem = livescript.compile codem
eval codem
