param(
    [parameter(Mandatory = $true)]   [string] $Name,
    [parameter(Mandatory = $false)]   [string] $Scope,
    [switch] $ChangeLocation,
    [switch] $DestroyBefore,
    [switch] $Force
)

$location = get-location

try {
    . "$PSScriptRoot/New-LernaWorkspace.ps1" -Name:"$Name" `
        -PackagesPath:"packages" `
        -ChangeLocation:$false `
        -DestroyBefore:($DestroyBefore.IsPresent -and $DestroyBefore) `
        -Force:($Force.IsPresent -and $Force) `
        -Scope:"$Scope"

    # we are now in the lerna workspace
    $newLernaWorkspacePath = get-location

    set-location $location

    $projects = Get-Content projects.json | convertfrom-json

    foreach ($project in $projects.projects) {
        . "./bin/New-NpmProject.ps1" -Name:"$Name-${project.name}" `
            -PackagesPath:"$newLernaWorkspacePath/packages" `
            -Scope:"$Scope"
    }

}
catch {
    Write-Error $_
}
finally {
    if (!$ChangeLocation.IsPresent) {
        set-location $location
    }
}
