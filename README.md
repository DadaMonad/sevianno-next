# Sevianno-next
This is the sevianno-nextproject -
a web application for semantic video annotation developed by the ACIS group, chair for information systems and databases, RWTH Aachen.
[Link to role space](http://role-sandbox.eu/spaces/sevianno2)

## Role widgets
This Repository provides the following widgets.
* [Upload widget](http://127.0.0.1:1337/upload.xml)
* [Annotations table](http://127.0.0.1:1337/annotationsTable.xml)

#Developer
In order to work on the widget you need `nodejs` and `npm` installed on your system.

Just for convenience we use `grunt` (a nodejs task manager) to start a http server,
syntax check the code, upload all widgets to ftp, replace urls from `127.0.0.1` to some other url,
register git hooks and generate documentation.  Grunt is incredible helpful, if you want to develop role-widgets.

```
npm install -g grunt-cli
```

Copy/Fork this repository and navigate into the folder and install all the libraries needed by grunt.
```
npm install
```

To customize the grunt build (where to upload, urls, ..) see the section `defaults` in `Gruntfile.coffee`.
The following command will start grunt and an http server on port 1337
```
grunt
```


## Grunt Tasks

If you haven't used Grunt before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide.
You can execute the following Grunt tasks:
* `grunt deploy_all` - upload ./widgets folder to the specified ftp server. The url are replaced automatically.
* `grunt deploy` - upload ./widgets folder (except pictures and libraries) to the specified ftp server. The url are replaced automatically. This is much faster than deploy_all
* `grunt replaceUrlsGit` - replace urls to the git-urls
* `grunt replaceUrlsFtp` - replace urls to the ftp-urls
* `grunt replaceUrlsDevelopment` - replace urls to the localhost -urls
* `grunt servewidegts` - start a fileserver accessible under `127.0.0.1:1337`. Will also set CORS headers. Note that this is accessible from everywhere (not just localhost).
* `grunt save-githooks` - After executing this task, you saved two [githooks](http://git-scm.com/book/en/Customizing-Git-Git-Hooks):
  * `pre-commit` - before you commit, all urls are replaced to git-urls.
  * `post-commit` - after the commit, all urls are replaced back to the localhost-version.
  * This makes it possible to serve widget also via git. Be sure that you use the http://rawgithub... urls (not raw.github...), since they don't overwrite the filetype.
* `grunt codo` - generate the [CODO](https://github.com/coffeedoc/codo) documentation.
* `grunt browserify` - Make sure to inform yourself about [browserify](http://browserify.org/articles.html). This tash transforms all the nodejs-like files in ./lib to js files in ./widgets/js .
* `grunt coffeelint` - check coding style for all coffee files.
* `grunt jslint` - check coding style for all js files.
* `grunt` - The defualt task starts a watch daemon that executes `servewidgets`, `coffeelint`, `jshint`, `browserify`, and `codo` tasks when a file is changed.

## How to add javasript libraries.
You can either write simple js-files under ./widegts/js or you write npm modules located in the ./lib folder. These modules may contain other npm modules (the usual way via e.g. `require('jquery')`). Add your module under the _browserify_ section in _Gruntfile.coffee_. When you execute `grunt` these modules are transformed with [browserify](http://browserify.org/articles.html). At the moment these modules are not minified. Please use a tool like 'closure compiler' from google or 'uglify'.

## Libraries
Copy-paste libraries like jquery is bad style. You should rather use npm modules, [git submodules](http://git-scm.com/book/en/Git-Tools-Submodules) or [bower](http://bower.io/). 
In this project we locate _git submodules_ here ./widgets/external, and bower modules here ./widgets/bower. There is a bower config file that installs
bower modules automatically in the right location. 

### Why you should use version management.
* Easy to upgrade to a newer version of that library
* You always  have a version that is known to work in your project
* You are able to compile modules like jquery or bootstrap yourself. 
* It's much faster to type `bower install jquery` than 
  * visit the library homepage
  * download the library
  * unzip
  * move to the right location



## Documentation
You can find documentation of the Sevianno module here:
[Documentation](https://rawgit.com/DadaMonad/sevianno-next/master/widgets/doc/index.html)

#Demos

## Older demo
[![Sevianno2](http://img.youtube.com/vi/fQuJayMdcp4/0.jpg)](http://www.youtube.com/watch?v=fQuJayMdcp4)

# Related projects
## Sevianno-1
[![Sevianno1](http://img.youtube.com/vi/_VkmcWc82Us/0.jpg)](http://www.youtube.com/watch?v=_VkmcWc82Us)

## AnViAnno
[![AnViAnno](http://img.youtube.com/vi/qK8WzPZw5BQ/0.jpg)](http://www.youtube.com/watch?v=qK8WzPZw5BQ)

