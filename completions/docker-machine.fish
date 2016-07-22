function __fish_docker_machine_no_command
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 1
end

function __fish_docker_machine_using_command
    set -l cmd (commandline -opc)
    set -q cmd[2]; and test "$argv[1]" = $cmd[2]
end

function __fish_docker_machine_help_commands
    for c in (__fish_docker_machine_commands_helps | cut -f 1)
        printf "%s\thelp\n" $c
    end
end

function __fish_docker_machine_machines --description 'Lists all available docker machines with status'
    command docker-machine ls | sed -E '1d;s/[[:space:]]+/;/g;s/;$//'
end

# grab the actual list of commands
function __fish_docker_machine_commands_helps
    docker-machine help | sed -E -e '/^ *$/d;1,/Commands/d;$d;$d;s/^ *//' | tr -s '\t' 
end



# generate completion for docker-machine commands wiht helps
for ch in (__fish_docker_machine_commands_helps)
    set c (echo $ch | cut -f 1)  # command
    set h (echo $ch | cut -f 2)  # help
    complete -f -c docker-machine -n '__fish_docker_machine_no_command' -a $c -d "$h"
end 

# machine completion with status
for ms in (__fish_docker_machine_machines)
    set m (echo $ms | cut -d";" -f 1)  # machine 
    set s (echo $ms | cut -d";" -f 2-)  # machine state
    for c in (__fish_docker_machine_commands_helps | cut -f 1 | sed '/help/d;/env/d')
        complete -f -c docker-machine -n "__fish_docker_machine_using_command $c" -a "'""$m""'" -d "'""$s""'"
        echo complete -f -c docker-machine -n "__fish_docker_machine_using_command $c" "'""$m""'" -d "'""$s""'"
    end
end 

# help
complete -f -c docker-machine -n "__fish_docker_machine_using_command help" -a "(__fish_docker_machine_help_commands)"
