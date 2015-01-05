Photolib
=================

Application to manage multiple sources of photo libraries.

**Purpose**

+ [x] index original pictures on localhost
+ [x] extract exif infos
+ [x] compute file digest to be able to de-duplicate imports
+ [ ] import original pictures to library (de-duplicated)
+ [ ] organize library directory structure `"/#{year}/#{month}/#{day}"`
+ [ ] clean library filenames "#{timestamp}.#{digest}.#{format}"`
+ [ ] create thumbnails of different sizes
+ [ ] identical image detection
+ [ ] sync library with online storage
+ [ ] distribute library storage (localhost, online, backups)
+ [ ] index and import movies
+ [ ] search library
+ More meta infos
    + [ ] albums / smart albums
    + [ ] geolocation
    + [ ] user input (views, likes, rating)
    + [ ] image content, people
+ [ ] API to interact with library
+ [ ] import from online services (icloud, flickr, picasa, facebook...)


## Application Configuration

`Application` is configured by `application.rb`.

### config.yml

The configuration is described by `config/config.yml`
and accessible through `Application.config`.

`config.yml` can rely on ENV variables using the following syntax:

```
some_var: <%= ENV['SOME_VAR'] %>
```

In development, instead of exporting ENV variables,
they can be declared in `config/application.yml`:

```
SOME_VAR: __some_value__
```

### autoload_path

`app`, `lib` and any (sub)folder of `app/models` are added to `autoload_path`.

### initializers

Scripts in `config/initializers` are executed at the end application setup.


## Rake tasks

`Rakefile` sets up basics for `rake` tasks.
Any `*.rake` file in `lib/**/tasks` is loaded into rake.
`Rakefile` also provides a `setup:application` task which provides a context
in which application is set up (config, access to models...).
