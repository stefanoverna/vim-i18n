# vim-i18n

Automated translation of Ruby/Rails projects

## Introduction

`vim-i18n` helps you translate your Ruby/Rails project. It just exposes a
single function, `I18nTranslateString`. This function takes the current visual
selection, converts it into a `I18n.t()` call, and adds the proper key in a
specified YAML store.

## Examples

### Extracting translations in `.html.erb` files

```
# app/views/users/show.html.erb
<dt>Name</dt>
    ^^^^
    -> Visual select and `:call I18nTranslateString()`
```

You will be asked for a key. In keeping with Rails translation syntax, if the
key begins with `.` it will be considered a relative key:

```
# app/views/users/show.html.erb
<dt><%= t('.name') %>

# config/locales/en.yml

en:
  users:
    show:
      name: Name
```

### Extracting translations in `.rb` files

Say you have the following line in your codebase:

```
# app/controllers/static_controller.rb
@some_text = "Hello, %{name}!"
             ^^^^^^^^^^^^^^^^^
             -> Visual select this text and `:call I18nTranslateString()`
```

The plugin will first ask you for the I18n key to use (ie. `homepage.greeting`).
Then, if still not specified, the plugin will ask you the location of the YAML
store (ie. `config/locales/en.yml`).

At this point, the plugin will replace the selection, and add the string to the
YAML store:

```
# app/controllers/static_controller.rb
@some_text = I18n.t('homepage.greeting', name: '')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
             -> BOOM!

# config/locales/en.yml
---
en:
  homepage:
    title: "Hello, %{name}!"
```

Note that the extracted translation included the appropriate interpolation.

## Vim mapping

Add this line or a simliar one to your `~.vimrc`:

```vim
vmap <Leader>z :call I18nTranslateString()<CR>
```
