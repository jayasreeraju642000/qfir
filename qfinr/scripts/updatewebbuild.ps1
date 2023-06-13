$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$indexFilePath = Join-Path -Path $scriptDir -ChildPath ../build/web/index.html

$datestring = Get-Date -UFormat "%Y%m%d_%H%M%Z"
# echo $scriptDir
# echo $indexFilePath
$searchString = 'script src="main.dart.js.*"' #using regex
$replaceString = 'script src="main.dart.js?version=' + $datestring + '"'
Write-Output ('Updating the index.html with version string: ' + $replaceString) #echo

# (Get-Content $indexFilePath).replace('script src="main.dart.js.*"', $replaceString) | Set-Content $indexFilePath

(Get-Content $indexFilePath) -replace $searchString, $replaceString ` | Set-Content $indexFilePath