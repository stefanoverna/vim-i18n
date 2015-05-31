let s:install_path=expand("<sfile>:p:h")

function! IsSyntaxRuby()
  let syntax = synIDattr(synID(line("'<"),col("'<"),1),"name")
  return match(syntax, "ruby")
endfunction

function! I18nTranslateString()
  " copy last visual selection to x register
  normal gv"xy
  let text = s:removeQuotes(s:strip(@x))
  let variables = s:findInterpolatedVariables(text)
  let key = s:askForI18nKey()
  if &filetype == 'eruby' || &filetype == 'eruby.html' || &filetype == 'slim' || &filetype == 'haml'
    let fullKey = s:determineFullKey(key)

    if IsSyntaxRuby() != -1
      let @x = s:generateI18nCall(key, variables, "t('", "')")
    elseif &filetype == 'eruby' || &filetype == 'eruby.html' || &filetype == 'slim'
      let @x = s:generateI18nCall(key, variables, "<%= t('", "') %>")
    elseif &filetype == 'haml'
      let @x = s:generateI18nCall(key, variables, "= t('", "')")
    endif

    call s:addStringToYamlStore(text, fullKey)
  else
    let @x = s:generateI18nCall(key, variables, "t('", "')")
    call s:addStringToYamlStore(text, key)
  endif
  " replace selection
  normal gv"xp
endfunction

function! I18nDisplayTranslation()
  normal gv"ay
  ruby get_translation(Vim.evaluate('@a'), Vim.evaluate('s:askForYamlPath()'))
endfunction

ruby << EOF
require 'yaml'

def get_translation(translation_key, file_name)
  locale = file_name.match(/(?<locale>\w+[-_]?\w+)\.yml$/)[:locale]
  translations_hash = load_yaml(file_name)
  translation = get_deep_value_for(translations_hash, "#{locale}.#{translation_key}")
  print translation || "Sorry, there's no translation for the key: '#{translation_key}', with locale: '#{locale}'"
end

def load_yaml(file_name)
  begin
    YAML.load(File.open(file_name))
  rescue
    raise "There's a problem with parsing translations from the file: #{file_name}"
  end
end

def get_deep_value_for(hash, key)
  return if hash.nil?
  keys = key.split('.')
  first_segment_of_key = keys.delete_at(0)
  segment_tail_of_key = keys.join('.')
  value = hash[first_segment_of_key]

  return value if segment_tail_of_key.empty?
  get_deep_value_for(value, segment_tail_of_key)
end
EOF

function! s:removeQuotes(text)
  let text = substitute(a:text, "^[\\\"']", "", "")
  let text = substitute(text, "[\\\"']$", "", "")
  return text
endfunction

function! s:strip(text)
  return substitute(a:text, "^\\s*", "", "")
endfunction

function! s:findInterpolatedVariables(text)
  let interpolations = []
  " match multiple occurrences of %{XXX} and fill interpolations with XXX
  call substitute(a:text, "\\v\\%\\{([^\\}]\+)\\}", "\\=add(interpolations, submatch(1))", "g")
  return interpolations
endfunction

function! s:generateI18nCall(key, variables, pre, post)
  if len(a:variables) ># 0
    return a:pre . a:key . "', " . s:generateI18nArguments(a:variables) . a:post
  else
    return a:pre . a:key . a:post
  endif
endfunction

function! s:generateI18nArguments(variables)
  let arguments = []
  for interpolation in a:variables
    call add(arguments, interpolation . ": ''")
  endfor
  return join(arguments, ", ")
endfunction

function! s:askForI18nKey()
  call inputsave()
  let key = ""
  if exists('g:I18nKey')
    let key = g:I18nKey
  endif
  let key = input('I18n key: ', key)
  let g:I18nKey = key
  call inputrestore()
  return key
endfunction

function! s:determineFullKey(key)
  if match(a:key, '\.') == 0
    let controller = expand("%:h:t")
    let view = substitute(expand("%:t:r:r"), '^_', '', '')
    let fullKey = controller . '.' . view . a:key
    return fullKey
  else
    return a:key
  end
endfunction

function! s:addStringToYamlStore(text, key)
  let yaml_path = s:askForYamlPath()
  let escaped_text = shellescape(a:text)
  let cmd = s:install_path . "/add_yaml_key '" . yaml_path . "' '" . a:key . "' " . escaped_text
  call system(cmd)
endfunction

function! s:askForYamlPath()
  call inputsave()
  let path = ""
  if exists('g:I18nYamlPath')
    let path = g:I18nYamlPath
  else
    let path = input('YAML store: ', 'config/locales/en.yml', 'file')
    let g:I18nYamlPath = path
  endif
  call inputrestore()
  return path
endfunction

vnoremap <leader>z :call I18nTranslateString()<CR>
vnoremap <leader>dt :call I18nDisplayTranslation()<CR>
