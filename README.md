# My-config

 [arch](https://aur.archlinux.org/), [sway](https://swaywm.org/) waybar and [my neovim config for javascript/typescript fullstack development](https://github.com/yamilt351/neovim)

first run:

    sudo pacman -S sway networkmanager intel-ucode ssdm firefox ranger waybar alacritty grim flatpak nvim npm git cmus neofetch swayimg htop wofi pulseaudio fontawesome nerdfonts

next:

```
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

alias:

`nvim  ~/.bashrc`

```

neofetch
alias update="sudo pacman -Syu && flatpak update"
alias install="sudo pacman -Sy && sudo pacman -S"
alias finstall="flatpak install"
alias fsearch="flatpak search"
alias music="cmus"
alias ali='nvim ~/.bashrc'
alias gch="git checkout -b"
alias gst="git status"
alias save="!git add -A && git commit -m 'SAVEPOINT'"
alias gcm="git commit -am" 
alias wifi="nmcli dev wifi"
alias ext="sudo systemctl start mnt-data.mount"
alias cleansys="sudo pacman -Scc && sudo journalctl --vacuum-size=100M"
alias listdisk="df -h /dev/sdb1 && df -h /dev/sda2 && df -h"
alias externalD="sudo mount /dev/sdb1 /mnt/data"

```

#sway config

```
# Default config for sway
#
# Copy this to ~/.config/sway/config and edit it to your liking.
#
# Read `man 5 sway` for a complete reference.
### Variables
#
# Logo key. Use Mod1 for Alt.
set $mod Mod4
# Home row direction keys, like vim
set $left h
set $down j
set $up k
set $right l
set $print grim ~/Screenshots/$(date +%Y%m%d_%H%M%S).png
# Your preferred terminal emulator
set $term alacritty
# Your preferred application launcher
# Note: pass the final command to swaymsg so that the resulting window can be opened
# on the original workspace that the command was run on.
set $menu wofi --show run

### Output configuration
#
# Default wallpaper (more resolutions are available in /usr/share/backgrounds/sway/)
output * bg ~/Descargas/backgrounds/7731900.jpg fill
#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0
#
# You can get the names of your outputs by running: swaymsg -t get_outputs

### Idle configuration
#
# Example configuration:
#
# exec swayidle -w \
#          timeout 300 'swaylock -f -c 000000' \
#          timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
#          before-sleep 'swaylock -f -c 000000'
#
# This will lock your screen after 300 seconds of inactivity, then turn off
# your displays after another 300 seconds, and turn your screens back on when
# resumed. It will also lock your screen before your computer goes to sleep.

### Input configuration
#
# Example configuration:
#
  input * {
    xkb_layout "es"
   }
#
# You can get the names of your inputs by running: swaymsg -t get_inputs
# Read `man 5 sway-input` for more information about this section.

### Key bindings
#
# Basics:
#
    # Start a terminal
    bindsym $mod+Return exec $term

    # Kill focused window
    bindsym $mod+Shift+q kill

    # Start your launcher
    bindsym $mod+d exec $menu

    # Drag floating windows by holding down $mod and left mouse button.
    # Resize them with right mouse button + $mod.
    # Despite the name, also works for non-floating windows.
    # Change normal to inverse to use left mouse button for resizing and right
    # mouse button for dragging.
    floating_modifier $mod normal

    # Reload the configuration file
    bindsym $mod+Shift+c reload

    # Exit sway (logs you out of your Wayland session)
    bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'
#
# Moving around:
#
    # Move your focus around
    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    # Or use $mod+[up|down|left|right]
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # Move the focused window with the same, but add Shift
    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right
    # Ditto, with arrow keys
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right
    bindsym Print exec $print

#
# Workspaces:
#
    # Switch to workspace
    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9
    bindsym $mod+0 workspace number 10
    # Move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9
    bindsym $mod+Shift+0 move container to workspace number 10
    # Note: workspaces can have any name you want, not just numbers.
    # We just use 1-10 as the default.
#
# Layout stuff:
#
    # You can "split" the current object of your focus with
    # $mod+b or $mod+v, for horizontal and vertical splits
    # respectively.
    bindsym $mod+b splith
    bindsym $mod+v splitv

    # Switch the current container between different layout styles
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    # Make the current focus fullscreen
    bindsym $mod+f fullscreen

    # Toggle the current focus between tiling and floating mode
    bindsym $mod+Shift+space floating toggle

    # Swap focus between the tiling area and the floating area
    bindsym $mod+space focus mode_toggle

    # Move focus to the parent container
    bindsym $mod+a focus parent
#
# Scratchpad:
#
    # Sway has a "scratchpad", which is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    bindsym $mod+Shift+minus move scratchpad

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym $mod+minus scratchpad show
#
# Resizing containers:
#
mode "resize" {
    # left will shrink the containers width
    # right will grow the containers width
    # up will shrink the containers height
    # down will grow the containers height
    bindsym $left resize shrink width 10px
    bindsym $down resize grow height 10px
    bindsym $up resize shrink height 10px
    bindsym $right resize grow width 10px

    # Ditto, with arrow keys
    bindsym Left resize shrink width 10px
    bindsym Down resize grow height 10px
    bindsym Up resize shrink height 10px
    bindsym Right resize grow width 10px

    # Return to default mode
    bindsym Return mode "default"
    bindsym Escape mode "default"
}

bindsym $mod+r mode "resize"

#
# Status Bar:
#
# Read `man 5 sway-bar` for more information about this section.
bar {
      swaybar_command waybar
}

# 
# no title bar
# 
for_window [app_id="^.*$"] hide_titlebar
default_border none

gaps inner 8
gaps outer 4

#tareas on start up
exec firefox
exec discord
exec timedatectl set-timezone America/Argentina/Buenos_Aires
include /etc/sway/config.d/*
```

# wofi config to match the gruvbox color scheme

`
cd .config/wofi/style.css
`

```
window{
  font-size:14px;
  background-color:#1d2021;
  border:1px solid #fe8019;
  color:#fbf1c7;
  font-family: monospace;
}

#entry:selected{
  background-color:#fabd2f;
  }

#text:selected{
    color:#1d2021;
  }

#input{
    background-color:#282828;
    border:1px solid #fe8019;
    color:#b8bb26;
  }
```
# waybar config, to match the gruvbox color scheme

`
cd .config/waybar/style.css
`
```
* {
	font-size: 14px;
	font-family: monospace;
}

window#waybar {
	background: #292b2e;
	color: #fdf6e3;
}

#custom-right-arrow-dark,
#custom-left-arrow-dark {
	color: #1a1a1a;
}
#custom-right-arrow-light,
#custom-left-arrow-light {
	color: #292b2e;
	background: #1a1a1a;
}

#workspaces,
#clock.1,
#clock.2,
#clock.3,
#pulseaudio,
#memory,
#cpu,
#battery,
#disk,
#tray {
	background: #1a1a1a;
}

#workspaces button {
	padding: 0 2px;
	color: #fff;
}
#workspaces button.focused {
	 	color: #b8bb26;
}
#workspaces button:hover {
	box-shadow: inherit;
	text-shadow: inherit;
}
#workspaces button:hover {
	background: #1a1a1a;
	border: #1a1a1a;
	padding: 0 3px;
}

#pulseaudio {
    color:#b8bb26;
}
#memory {
		color: #b8bb26;

}
#cpu {
      	color: #b8bb26;
}
#battery {
		color: #b8bb26;
}
#disk {
		color: #b8bb26;
}

#clock,
#pulseaudio,
#memory,
#cpu,
#disk {
	padding: 0 10px;
}
```
`
cd .config/waybar/config
`

```
{
	"layer": "top",
	"position": "top",

	"modules-left": [
		"sway/workspaces",
		"custom/right-arrow-dark"
	],
	"modules-center": [
		"custom/left-arrow-dark",
		"clock#1",
		"custom/left-arrow-light",
		"custom/left-arrow-dark",
		"clock#2",
		"custom/right-arrow-dark",
		"custom/right-arrow-light",
		"clock#3",
		"custom/right-arrow-dark"
	],
	"modules-right": [
		"custom/left-arrow-dark",
		"pulseaudio",
		"custom/left-arrow-light",
		"custom/left-arrow-dark",
		"memory",
		"custom/left-arrow-light",
		"custom/left-arrow-dark",
		"cpu",
		"custom/left-arrow-light",
		"custom/left-arrow-dark",
		"battery",
		"custom/left-arrow-light",
		"custom/left-arrow-dark",
		"disk",
		"custom/left-arrow-light",
		"custom/left-arrow-dark",
		"tray"
	],

	"custom/left-arrow-dark": {
		"format": "",
		"tooltip": false
	},
	"custom/left-arrow-light": {
		"format": "",
		"tooltip": false
	},
	"custom/right-arrow-dark": {
		"format": "",
		"tooltip": false
	},
	"custom/right-arrow-light": {
		"format": "",
		"tooltip": false
	},

	"sway/workspaces": {
		"disable-scroll": true,
		"format": "{name}"
	},

	"clock#1": {
		"format": "{:%a}",
		"tooltip": false
	},
	"clock#2": {
		"format": "{:%H:%M}",
		"tooltip": false
	},
	"clock#3": {
		"format": "{:%d-%m}",
		"tooltip": false
	},

	"pulseaudio": {
		"format": "{icon} {volume:2}%",
		"format-bluetooth": "{icon}  {volume}%",
		"format-muted": "MUTE",
		"format-icons": {
			"headphones": "",
			"default": [
				"",
				""
			]
		},
		"scroll-step": 5,
		"on-click": "pamixer -t",
		"on-click-right": "pavucontrol"
	},
	"memory": {
		"interval": 5,
		"format": "Mem {}%"
	},
	"cpu": {
		"interval": 5,
		"format": "CPU {usage:2}%"
	},
	"battery": {
		"states": {
			"good": 95,
			"warning": 30,
			"critical": 15
		},
		"format": "{icon} {capacity}%",
		"format-icons": [
			"",
			"",
			"",
			"",
			""
		]
	},
	"disk": {
		"interval": 5,
		"format": "Disk {percentage_used:2}%",
		"path": "/"
	},
	"tray": {
		"icon-size": 20
	}
}
```

# ranger config

`
cd .config/ranger/rc.config
`

```
map DD shell mv %s /home/yamil/.local/share/Trash/files/
set preview_images true
set preview_script ~/.config/ranger/preview_script.sh
set use_preview_script true
set column_ratios 1,2,3
set show_hidden true
set line_numbers 0

default_linemode devicons

```

# Alacritty with gruvbox theme

`
cd .config/alacritty/alacritty.yml
`

```
# Colors (Gruvbox dark)
colors:
  # Default colors
  primary:
    # hard contrast: background = '0x1d2021'
    background: '0x282828'
    # soft contrast: background = '0x32302f'
    foreground: '0xebdbb2'

  # Normal colors
  normal:
    black:   '0x282828'
    red:     '0xcc241d'
    green:   '0x98971a'
    yellow:  '0xd79921'
    blue:    '0x458588'
    magenta: '0xb16286'
    cyan:    '0x689d6a'
    white:   '0xa89984'

  # Bright colors
  bright:
    black:   '0x928374'
    red:     '0xfb4934'
    green:   '0xb8bb26'
    yellow:  '0xfabd2f'
    blue:    '0x83a598'
    magenta: '0xd3869b'
    cyan:    '0x8ec07c'
    white:   '0xebdbb2'

window:
  opacity: 0.9
  x: 1
  y: 1

font:
  normal:
    family: DejaVu Sans Mono
    style: Bold
  size: 10

```
