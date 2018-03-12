# powershell-wsl-alias
wsl command alias for PowerShell

## Install
```powershell
PS C:\powershell-wsl-alias> .\install.ps1
```

## Usage
```powershell
PS C:\> touch foo.txt
PS C:\> vi foo.txt
```

## Notice

The module is *alias*, not *bash*.
Pipeline work in powershell.


Expected
```bash
naminodarie@PC:~$ yes | head
y
y
y
y
y
y
y
y
y
y
naminodarie@PC:~$
```

Actual
```powershell
PS C:\> yes | head
^C
PS C:\>
```
