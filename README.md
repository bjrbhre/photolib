ruby-app-skeleton
=================

Skeleton for a simple ruby application.

## Application Configuration

`Application` is configured by `environment.rb`.

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
`Rakefile` also provides a `:environment` task which provides a context
in which application is set up (config, access to models...).
