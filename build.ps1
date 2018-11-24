<#
.Description
Builds the cblite tool for Windows only (It will technically work for Mac and Linux if the directory
separator characters are flipped from backslash to slash)

.Parameter Branch
The branch of LiteCore to use when building

.Parameter Config
The configuration to use when building (Debug (default), Release, MinSizeRel, RelWithDebInfo)

.Parameter GitPath
The path to the git executable (default: C:\Program Files\Git\bin\git.exe)

.Parameter CMakePath
The path to the cmake executable (default: C:\Program Files\CMake\bin\cmake.exe
#>
param(
    [string]$Branch = "master",
    [string]$Config = "Debug",
    [string]$GitPath = "C:\Program Files\Git\bin\git.exe",
    [string]$CMakePath = "C:\Program Files\CMake\bin\cmake.exe"
)

if(-Not (Test-Path vendor\couchbase-lite-core)) {
    & "$GitPath" clone https://github.com/couchbase/couchbase-lite-core vendor\couchbase-lite-core
}

& "$GitPath" submodule update --init --recursive
Push-Location vendor\couchbase-lite-core
& "$GitPath" reset --hard
& "$GitPath" checkout $Branch
& "$GitPath" fetch origin
& "$GitPath" pull origin $BRANCH
& "$GitPath" submodule update --init --recursive
Pop-Location

if(-Not (Test-Path build)) {
    New-Item -ItemType Directory -Name build
}

Push-Location build
& "$CMakePath" ..
& "$CMakePath" --build . --target cblite --config $Config
Pop-Location