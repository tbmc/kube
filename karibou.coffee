# Fonctions
setViewRender = (f) ->
	app.get '/' + f, (req, res) ->
		res.render 'views/' + f

listViews = (folder) ->
	filenames = fs.readdirSync(folder)
	for filename in filenames
		if filename == 'templates'
			continue
		f = filename.substring(0, filename.lastIndexOf('.'))
		#console.log 'View : ' + f
		setViewRender f

listThemes = (folder) ->
	filenames = fs.readdirSync(folder)
	return filenames

# Lecture des paramètres
fs = require('fs')
jade = require('jade')
compression = require('compression')

parameters = JSON.parse fs.readFileSync('./parameters.json', 'utf-8')


connectAssets = require('connect-assets')({
	paths: [
		'assets'
		'assets/js'
		'assets/css'
		'assets/librairies'
	]
	build: true
	#compress: true
	buildDir: 'builtAssets'
	fingerprinting: false
	sourceMaps: false
})

express = require('express')
app = express()
app.use compression({level: 9})
app.use connectAssets

if app.get('env') == 'development'
	app.locals.pretty = true

app.set 'view engine', 'jade'
app.use express.static(__dirname + '/public')

themeList = listThemes 'public/themes'
listViews 'views/views'


app.get '/', (req, res) ->
	res.render 'karibou', {
		themes: themeList
	}

app.use (req, res, next) ->
	#res.render 404
	res.render 'karibou', {
		themes: themeList
	}

if app.get('env') == 'development'
    devPort = 80
    app.listen devPort
    console.log 'Lance sur le port ' + devPort

else
    app.listen parameters.port

    console.log 'Lance sur le port ' + parameters.port



 