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
alias art = php artisan

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

use std/util "path add"
path add ($env.HOME | path join "go/bin")
path add ($env.HOME | path join ".local/bin")
path add ($env.HOME | path join ".cargo/bin")
path add ($env.HOME | path join ".config/herd-lite/bin")

let rust_path = ^asdf where rust nightly
let bun_path = ^asdf where bun
path add ($env.HOME | path join $bun_path "bin")
path add ($env.HOME | path join $rust_path "bin")
plugin add ($env.HOME | path join $rust_path "bin/nu_plugin_gstat")

# DOTNET CONFIG
let dotnet_path = ^asdf which dotnet
$env.DOTNET_ROOT = $dotnet_path | path expand  | path dirname
$env.DOTNET_VERSION = ^asdf dotnet --version
$env.MSBuildSDKsPath = $"($env.DOTNET_ROOT)/sdk/($env.DOTNET_VERSION)/Sdks"
$env.DOTNET_CLI_TELEMETRY_OPTOUT = 1
path add $env.DOTNET_ROOT



def home_abbrev [os] {
    let is_home_in_path = ($env.PWD | str starts-with $nu.home-path)
    if ($is_home_in_path == true) {
        if ($os == "windows") {
            let home = ($nu.home-path | str replace -ar '\\' '/')
            let pwd = ($env.PWD | str replace -ar '\\' '/')
            $pwd | str replace $home '~'
        } else {
            $env.PWD | str replace $nu.home-path '~'
        }
    } else {
        $env.PWD | str replace -ar '\\' '/'
    }
}

# Get the current directory with home abbreviated
def current_dir_style [] {
    let current_dir = ($env.PWD)

    let current_dir_abbreviated = if $current_dir == $nu.home-path {
        '~'
    } else {
        let current_dir_relative_to_home = (
            do --ignore-errors { $current_dir | path relative-to $nu.home-path } | str join
        )

        if ($current_dir_relative_to_home | is-empty) == false {
            $'~(char separator)($current_dir_relative_to_home)'
        } else {
            $current_dir
        }
    }

    $current_dir_abbreviated
}

def get_branch_name [gs] {
  let br = ($gs | get branch)
  if $br == "no_branch" {
    ""
  } else {
    $"($br) "
  }
}

$env.PROMPT_COMMAND = { $"(current_dir_style) (gstat | get_branch_name $in)" }
$env.PROMPT_COMMAND_RIGHT = {||}
$env.PROMPT_MULTILINE_INDICATOR = {||}
