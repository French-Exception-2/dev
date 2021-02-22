param(
    [parameter(Mandatory = $true)] [string] $Name,
    [parameter(Mandatory = $true)] [string] $Scope,
    [parameter(Mandatory = $false)]  [string] $PackagesPath = "./packages",
    [switch] $ChangeLocation,
    [switch] $DestroyBefore,
    [switch] $Force
)

$location = Get-Location

try {
    $newLocation = "$PackagesPath/$Name"

    if (test-path $newLocation) {
        if ($DestroyBefore.IsPresent) {
            Remove-Item -path $newLocation -force -recurse
        }
        elseif (!$Force.IsPresent) {
            throw "Directory exist"
        }
    }
    
    new-item "$PackagesPath/$Name" -itemtype Directory

    set-location "$PackagesPath/$Name"
        
    "node_modules" | out-file .gitignore -Encoding ascii
    "build" | out-file .gitignore -Encoding ascii -Append

    npm init --force
    json -I -f package.json -e "this.name='$Scope/$Name'"
}
catch {
    Write-Error $_
}
finally {
    if (!$ChangeLocation.IsPresent) {
        set-location $location
    }
}

