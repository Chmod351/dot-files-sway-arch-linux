   #!/bin/bash
   tmux new-session -d -s 󰣇 'cmus'
   tmux new-window -t 󰣇:1 'bash'
   # tmux split-window -h -t 󰣇:1
   tmux split-window -v -t 󰣇:1
   tmux new-window -t 󰣇:2 'bash'
	 tmux split-window -v -t 󰣇:2
   tmux new-window -t 󰣇:3 'lazydocker'
   tmux new-window -t 󰣇:4 'calcurse'
   tmux attach-session -t 󰣇


