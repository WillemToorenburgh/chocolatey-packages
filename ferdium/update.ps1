﻿import-module au

$releases = "https://github.com/ferdium/ferdium-app/releases"

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(Url\s*=\s*)('.*')"      = "`$1'$($Latest.URL64)'"
      "(Checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
      "(ChecksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
    }
  }
}

function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing
  $regex   = '\/ferdium\/ferdium-app\/tree\/v\d{1,4}\.\d{1,4}\.\d{1,4}(?:\.\d{1,4})?(?:-beta.*)?$'
  $url64     = $download_page.links | Where-Object href -match $regex | Select-Object -First 1 -expand href
  $version = $url64 -split '\/|v' | Select-Object -Last 1
  $url64 = "https://github.com/ferdium/ferdium-app/releases/download/v$version/Ferdium-win-AutoSetup-$version.exe"
  $releaseNotes = "https://github.com/ferdium/ferdium-app/releases/tag/v$version"
  $versionParts = $version -split '-'
  if ($versionParts.Length -gt 1) {
    $versionParts[1] = $versionParts[1].replace('.', '-')  
    $version = $versionParts -join '-'  
  }

  return @{ Version = $version; URL64 = $url64; ChecksumType64 = 'sha512'; ReleaseNotes = $releaseNotes}
}

Update-Package -ChecksumFor all
