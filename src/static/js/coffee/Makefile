SRC=libs.coffee \
	models/entry.coffee \
    models/week.coffee \
	views/search.coffee \
	views/entry.coffee \
	views/entries.coffee \
	views/report.coffee \
	views/history.coffee \
	views/app.coffee

compile:
	coffee -mcj ../main.js $(SRC)

watch:
	coffee --watch -cj ../main.js $(SRC)
