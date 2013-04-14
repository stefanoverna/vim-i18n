# vim-i18n
## Automated translation of Ruby/Rails projects

### Introduction

`vim-i18n' helps you translate your Ruby/Rails project. It just exposes a 
single function, `I18nTranslateString`. This function takes the current visual 
selection, converts it into a `I18n.t()` call, and adds the proper key in a 
specified YAML store.

Mandatory example:

```
  # app/controllers/static_controller.rb
  @some_text = "Hello, %{name}!"
               ^^^^^^^^^^^^^^^^
               Visual select this text and hit <leader>z
```

The plugin will first ask you for the I18n key to use (ie. `homepage.greeting`).
Then, if still not specified, the plugin will ask you the location of the YAML
store (ie. `config/locales/en.yml`).

At this point, the plugin will replace the selection, and add the string to the
YAML store:

```
  # app/controllers/static_controller.rb
  @some_text = I18n.t('homepage.greeting', name: '')
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      BOOM!

  # config/locales/en.yml
  ---
  en:
    homepage:
      title: "This is my text"
```

