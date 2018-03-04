. "$PSScriptRoot\config.ps1"

$modulePath = ($env:PSModulePath -split ";")[0] + '\wsl-alias\wsl-alias.psm1'
$funcTemplate = @'
function $name {
    if($MyInvocation.ExpectingInput){
        $input | & wsl $name $color $args
    }else{
        & wsl $name $color $args
    }
}
'@

if($convertPath) {
    $funcTemplate = $funcTemplate.Replace('$args','($args | ForEach-Object{ToWslPath $_})')
}

$ToWslPathFunction = @'
function ToWslPath ($path) {
    if (-not (Test-Path $path)) { return $path }
    if (Split-Path $path -IsAbsolute) {
        $path = "/mnt/" + (Split-Path $path -Qualifier).Replace(":", "").ToLower()        + (Split-Path $path -NoQualifier)
    }
    return $path.Replace("\", "/")
}
'@

Set-Location $PSScriptRoot
New-Item $modulePath -Force

$functions = [System.Collections.Generic.List[string]]::new()
$functions.Add($ToWslPathFunction)

$commands = if ($whiteList) {$whiteList} else {& wsl sh get_command.sh}
$commands = $commands | Where-Object { $blackList -notcontains $_ }
foreach ($name in $commands) {
    if ($autoColorCommands -contains $name) {
        $color = '--color=auto'
    } else {
        $color = ''
    }

    $func = $funcTemplate.Replace('$name', $name).Replace('$color', $color)
    $functions.Add($func)
    Write-Host $name
}
$functions | Out-File $modulePath -Encoding ascii
"Export-ModuleMember -Function $($commands -join ',')" | Out-File $modulePath -Encoding ascii -Append

Import-Module wsl-alias