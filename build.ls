require! {
	"fs-extra": fs
	\glob-concat
}

paths = {}
globs =
	"comp/both/*"
	"comp/main/*"
	"comp/ifrm/*"
	"C/apps/*"
	"C/!(apps)/**/*.*"
for glob in globs
	if typeof glob is \string
		glob = (glob): [glob]
	for k, val of glob
		paths"/#k" = globConcat.sync val .map (\/ +)
fs.writeJsonSync \paths.json paths, spaces: \\t
