$ErrorActionPreference = 'Stop';

$unzipLocation   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$PackageParameters = Get-PackageParameters -Parameters "/Channel:'stable'"
# if ($PackageParameters['Channel'] -or [String]::IsNullOrWhiteSpace($PackageParameters['Channel'])) { $PackageParameters['Channel'] = 'stable' }

$channelIds = [PSCustomObject]@{
  stable ="channel-0"
  beta   ="channel-1"
  dev    ="channel-2"
  canary ="channel-3"
}
$channel = $channelIds.($PackageParameters['Channel'])

$googleUrl = 'https://dl.google.com/android/repository'
$buildToolsXmlUrl = "$googleUrl/repository2-1.xml"

Write-Output("Checking google repository for latest build-tools version.")
[xml]$data = (New-Object System.Net.WebClient).DownloadString($buildToolsXmlUrl)
$versions = $data.'sdk-repository'.remotePackage |
  Where-Object { ($_.path -like "build-tools*" -or $_.'display-name' -like "*Build-Tools*") -and $_.channelRef.ref -like $channel -and $_.obsolete -notlike "true" }
if ($versions.Count -eq 0) { Throw "No versions found under $($PackageParameters['Channel']) channel ($channel)." }
$latest = $versions | Sort-Object -Property path -Descending | Select-Object -First 1
$revision = "{0}.{1}.{2}" -f $latest.revision.major, $latest.revision.minor, $latest.revision.micro
$source = ($latest.archives.archive | Where-Object -Property 'host-os' -Like 'windows').complete
Write-Output("Using version $revision")

$existingAapt = Get-Command -Name aapt.exe -ErrorAction SilentlyContinue
if (($null -ne $existingAapt) -and ($existingAapt.Path.StartsWith($env:ChocolateyInstall) -eq $false)) {
  Write-Warning "aapt.exe already exists: $($existingAapt.Path)"
}

$filename     = $source.url
$checksum     = $source.checksum
$url          = "$googleUrl/$filename"
$fileFullPath = "$unzipLocation\$filename"
Write-Output("Downloading from $url`n")

$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  fileFullPath = $fileFullPath
  url          = $url
  checksum     = $checksum
  checksumType = 'sha1'
}
Get-ChocolateyWebFile @packageArgs

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipFile = [System.IO.Compression.ZipFile]::OpenRead($fileFullPath)
$zipFile.Entries |
  Where-Object { $_.Name -in "aapt.exe","libaapt2_jni.dll","libwinpthread-1.dll" } |
  ForEach-Object { [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$unzipLocation\$($_.Name)", $true) }
$zipFile.Dispose()
Remove-Item $fileFullPath