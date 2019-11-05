$ErrorActionPreference = 'Stop';
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'aapt2*'
  fileType      = 'EXE'
  silentArgs   = ''
  validExitCodes= @(0)
}
$uninstalled = $false
