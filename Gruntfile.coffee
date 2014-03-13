module.exports = (grunt) ->

	# Project configuration.
	grunt.initConfig
		defaults:
			replacementUrls:
				development: "http://127.0.0.1:1337/"
				git: "https://rawgithub.com/DadaMonad/sevianno-next/master/widgets/"
				ftp: "http://dbis.rwth-aachen.de/~jahns/role-widgets/sevianno-next/"
				
		browserify:
			dist:
				files:
					'widgets/js/upload.js': ['lib_build/upload.js']
				options:
					#transform: ['coffeeify']
					debug: true

		coffee:
			lib:
				options:
					bare: true
					sourceMap: true
					expand: true
					src: ["lib/**/*.coffee", "lib/*.coffee"]
					dest: "build/"
					ext: ".js"
			widgets:
				options:
					bare: true
					sourceMap: true
					expand: true
					src: ["widgets/js/*.coffee"]
					dest: "widgets/js/"
					ext: ".js"

		'ftp-deploy':
			build:
				auth:
					host: 'manet.informatik.rwth-aachen.de'
					port: 21
					#authKey: 'key1'
				src: './widgets'
				dest: '/home/jahns/public_html/role-widgets/sevianno-next'
				exclusions: []
		coffeelint:
			options:
				"indentation":
					"level": "ignore"
				"no_tabs":
					"level": "ignore"
				"max_line_length":
					"level": "ignore"
				"line_endings":
					"level": "ignore"
				"no_trailing_whitespace":
					"level": "ignore"
			
			gruntfile: [
				'Gruntfile.coffee'
				]
			lib: [
				'lib/**/*.coffee'
				]
			widgets: [
				'widgets/**/*.coffee'
				]
		
		githooks:
			all:
				'pre-commit': 'replaceUrlsProduction'
				'post-commit': 'replaceUrlsDevelopment'
				
		watch:
			gruntfile:
				files: ['widgets/*', 'lib/**/*']
				tasks: ['coffeelint', 'coffee', 'browserify']
				
		connect:
			server:
				options:
					hostname: '*'
					port: 1337
					base: 'widgets'
					keepalive: true
		replace:
			mainGit:
				src: ['widgets/*.xml']
				dest: 'widgets/'
				replacements: [{
					from: "<%= defaults.replacementUrls.development %>"
					to: "<%= defaults.replacementUrls.git %>"
				}]
			jsGit:
				src: ['widgets/js/*.+(js|coffee)']
				dest: 'widgets/js/'
				replacements: [{
					to: "<%= defaults.replacementUrls.git %>"
					from: "<%= defaults.replacementUrls.development %>"
				}]     
				
			cssGit:
				src: ['widgets/css/*.css']
				dest: 'widgets/css/'
				replacements: [{
					to: "<%= defaults.replacementUrls.git %>"
					from: "<%= defaults.replacementUrls.development %>"
				}]     
			 
			readmeGit:
				src: ['README.md']
				dest: 'README.md'
				replacements: [{
					from: "<%= defaults.replacementUrls.development %>"
					to: "<%= defaults.replacementUrls.git %>"
				}]     
			 
			mainFtp:
				src: ['widgets/*.xml']
				dest: 'widgets/'
				replacements: [{
					from: "<%= defaults.replacementUrls.development %>"
					to: "<%= defaults.replacementUrls.ftp %>"
				}]     
			 
			jsFtp:
				src: ['widgets/js/*.+(js|coffee)']
				dest: 'widgets/js/'
				replacements: [{
					to: "<%= defaults.replacementUrls.ftp %>"
					from: "<%= defaults.replacementUrls.development %>"
				}]     
			 
			cssFtp:
				src: ['widgets/css/*.css']
				dest: 'widgets/css/'
				replacements: [{
					to: "<%= defaults.replacementUrls.ftp %>"
					from: "<%= defaults.replacementUrls.development %>"
				}]     
			 
			 
			readmeFtp:
				src: ['README.md']
				dest: 'README.md'
				replacements: [{
					from: "<%= defaults.replacementUrls.development %>"
					to: "<%= defaults.replacementUrls.ftp %>"
				}]     
			 
			maindev:
				src: ['widgets/*.+(xml|md)']
				dest: 'widgets/'
				replacements: [{
					from: "<%= defaults.replacementUrls.git %>"
					to: "<%= defaults.replacementUrls.development %>"
				},{
					from: "<%= defaults.replacementUrls.ftp %>"
					to: "<%= defaults.replacementUrls.development %>"
				}]     
			 
			jsdev:
				src: ['widgets/js/*.+(js|coffee))']
				dest: 'widgets/js/'
				replacements: [{
					from: "<%= defaults.replacementUrls.git %>"
					to: "<%= defaults.replacementUrls.development %>"
				},{
					from: "<%= defaults.replacementUrls.ftp %>"
					to: "<%= defaults.replacementUrls.development %>"
				}]     
			 
			cssdev:
				src: ['widgets/css/*.css']
				dest: 'widgets/css/'
				replacements: [{
					from: "<%= defaults.replacementUrls.git %>"
					to: "<%= defaults.replacementUrls.development %>"
				},{
					from: "<%= defaults.replacementUrls.ftp %>"
					to: "<%= defaults.replacementUrls.development %>"
				}]
			
			readmedev:
				src: ['README.md']
				dest: 'README.md'
				replacements: [{
					from: "<%= defaults.replacementUrls.git %>"
					to: "<%= defaults.replacementUrls.development %>"
				},{
					from: "<%= defaults.replacementUrls.ftp %>"
					to: "<%= defaults.replacementUrls.development %>"
				}]

			
	grunt.loadNpmTasks 'grunt-contrib-qunit'
	grunt.loadNpmTasks 'grunt-contrib-jshint'
	grunt.loadNpmTasks 'grunt-coffeelint'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-text-replace'
	grunt.loadNpmTasks 'grunt-githooks'
	grunt.loadNpmTasks 'grunt-ftp-deploy'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-browserify'
	

	
	grunt.registerTask 'replaceUrlsProduction', ['replace:mainGit', 'replace:jsGit', 'replace:cssGit', 'replace:readmeGit']
	grunt.registerTask 'replaceUrlsFtp', ['replace:mainFtp', 'replace:jsFtp', 'replace:cssFtp', 'replace:readmeFtp']
	grunt.registerTask 'replaceUrlsDevelopment', ['replace:maindev', 'replace:jsdev', 'replace:cssdev', 'replace:readmedev']
	grunt.registerTask 'servewidgets', ['connect']
	grunt.registerTask 'save-githooks', ['githooks']
	grunt.registerTask 'deploy', ['replaceUrlsFtp', 'ftp-deploy', 'replaceUrlsDevelopment']
	grunt.registerTask 'default', ['coffeelint', 'coffee', 'browserify', 'watch']


