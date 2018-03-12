. "$PSScriptRoot\config.ps1"

$modulePath = ($env:PSModulePath -split ";")[0] + '\wsl-alias\wsl-alias.psm1'
$funcTemplate = @'
function \$wslcommand {
    if($MyInvocation.ExpectingInput){
        $input | & wsl $MyInvocation.InvocationName $args
    }else{
        & wsl $MyInvocation.InvocationName $args
    }
}
function \$wslcolorcommand {
    if($MyInvocation.ExpectingInput){
        $input | & wsl $MyInvocation.InvocationName --color=auto $args
    }else{
        & wsl $MyInvocation.InvocationName --color=auto $args
    }
}
'@
$ToWslPathFunction = @'
function ToWslPath ($path) {
    if (-not (Test-Path $path)) { return $path }
    if (Split-Path $path -IsAbsolute) {
        $path = "/mnt/" + (Split-Path $path -Qualifier).Replace(":", "").ToLower() + (Split-Path $path -NoQualifier)
    }
    return $path.Replace("\", "/")
}
'@

Remove-Module wsl-alias -Force 2>$null
Set-Location $PSScriptRoot
New-Item $modulePath -Force

if ($convertPath) {
    $ToWslPathFunction | Out-File $modulePath -Encoding ascii -Append
    $funcTemplate = $funcTemplate.Replace('$args', '($args | ForEach-Object{ToWslPath $_})')
}
$funcTemplate | Out-File $modulePath -Encoding ascii -Append

$commands = if ($whiteList) {$whiteList} else {& wsl sh get_command.sh}
$commands = $commands | Where-Object { $blackList -notcontains $_ }
if (-not $overrideDefault) { $commands = $commands | Where-Object { -not(Test-Path alias:$_) } }

$setAliasCommands = [System.Collections.Generic.List[string]]::new()
foreach ($name in $commands) {
    if ($autoColorCommands -contains $name) {
        $setAliasCommands.Add('Set-Alias {0} ''\$wslcolorcommand''' -f $name)
    }
    else {
        $setAliasCommands.Add('Set-Alias {0} ''\$wslcommand''' -f $name)
    }

    Write-Host $name
}
$setAliasCommands | Out-File $modulePath -Encoding ascii -Append

New-ModuleManifest $modulePath.Replace('.psm1', '.psd1') -RootModule 'wsl-alias.psm1' -Author 'naminodarie' -ModuleVersion '0.1' -FunctionsToExport 'ToWslPath', '\$wslcommand', '\$wslcolorcommand' -AliasesToExport $commands

Import-Module wsl-alias
