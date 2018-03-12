# if you need only a few alias, you should set the alias to $whiteList
# $whiteList = @('grep')
$whiteList = @()

# if you don't need some alias , you should set the alias to $blackList
$blackList = @('cd', 'bash', 'more')

# $autoColorCommands have "--color=auto" option
$autoColorCommands = @(
    'ls',
    'grep',
    'egrep',
    'fgrep'
)

# convert path string in $args to wsl path string
$convertPath = $true
