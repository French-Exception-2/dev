param(
    [parameter(Mandatory = $true)]   [string] $Name,
    [parameter(Mandatory = $false)]   [string] $Scope,
    [parameter(Mandatory = $false)]  [string] $PackagesPath = "./packages",
    [switch] $ChangeLocation,
    [switch] $DestroyBefore,
    [switch] $Force,
    [switch] $Independant,
    [switch] $Fixed
)

$location = get-location

try {

    if ([string]::IsNullOrEmpty($Scope)) {
        $Scope = $( $(jq -r '.name' $location/package.json ) -replace "/dev", "")
    }

    . "$PSScriptRoot/New-NpmProject.ps1" -Name "$Name-dev" `
        -Scope:"$Scope" `
        -DestroyBefore:($DestroyBefore.IsPresent -and $DestroyBefore -eq $true) `
        -Force:($Force.IsPresent -and $Force -eq $true) `
        -ChangeLocation:$true `
        -PackagesPath:"$PackagesPath"

    # We are now in the location of the new Lerna workspace 
    get-location

    $lernaJson = @{
        version="0.0.0"
        packages=@('packages/*')
    }

    $lernaJson | out-file lerna.json

    new-item -path packages -ItemType Directory
}
catch {
    Write-Error $_
}
finally {
    if (!$ChangeLocation.IsPresent) {
        set-location $location
    }
}