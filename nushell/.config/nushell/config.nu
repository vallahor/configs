# config.nu
#
# Installed by:
# version = "0.107.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R


alias stow = stow -t ~
alias cdvi = cd ~/.config/nvim/
alias cdproj = cd ~/projects/
alias cdconf = cd ~/projects/configs
alias vi = nvim
alias vim = nvim
alias python3 = python

$env.config.show_banner = false

$env.config.keybindings ++= [{
    name: delete_one_word_backward
    modifier: control
    keycode: backspace
    mode: [emacs vi_insert]
    event: {edit: backspaceword}
}]

$env.config.keybindings ++= [{
    name: complete
    modifier: none
    keycode: tab
    mode: [emacs vi_normal vi_insert]
    event: {
        until: [
            { send: menu name: completion_menu }
            { send: enter }
        ]
    }
}]

$env.config.keybindings ++= [{
    name: delete_one_word
    modifier: control
    keycode: delete
    mode: [emacs vi_insert]
    event: { edit: deleteword }
}]

use std/util "path add"
path add "~/.local/bin"

path add ($env.HOME | path join "go" "bin")
path add ($env.HOME | path join ".cargo" "bin")
path add ($env.HOME | path join ".bun" "bin")
path add ($env.HOME | path join ".config" "herd-lite" "bin")

let shims_dir = (
  if ( $env | get -o ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  } | path join 'shims'
)
$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )

let asdf_data_dir = (
  if ( $env | get -o ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  }
)
