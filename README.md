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
register git hooks and generate documentation.

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

## Documentation
You can find documentation of
[Documentation](http://127.0.0.1:1337/../doc/index.html)

#Demos

## Older demo
[![Sevianno2](http://img.youtube.com/vi/fQuJayMdcp4/0.jpg)](http://www.youtube.com/watch?v=fQuJayMdcp4)

# Related projects
## Sevianno-1
[![Sevianno1](http://img.youtube.com/vi/_VkmcWc82Us/0.jpg)](http://www.youtube.com/watch?v=_VkmcWc82Us)

## AnViAnno
[![AnViAnno](http://img.youtube.com/vi/qK8WzPZw5BQ/0.jpg)](http://www.youtube.com/watch?v=qK8WzPZw5BQ)

