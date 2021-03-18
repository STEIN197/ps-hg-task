using module .\CLI.psm1
Import-Module $PSScriptRoot\Util -DisableNameChecking

function Main {
	Check-Setup
	if (!$args.Length) {
		$currentTaskId = Task-Current
		if ($currentTaskId) {
			Write-Host "$(Task-Prefix)-$($currentTaskId)`t$(Task-Description $currentTaskId)";
		}
		return;
	}
	$action = Action-Get $args[0]
	if (!$action) {
		"Unknown operation `"$($action)`""
	}
	Config-Setup-Hg
	if ($action.ToLower() -ne 'config') {
		Check-Config
	}
	[CLI]::$action($args[1..$args.Length])
}

function Check-Setup {
	if (-not (Hg-Installed)) {
		throw "Mercurial is not installed on this computer"
	}
	if (-not (Hg-Current)) {
		throw "Mercurial repository does not exist here"
	}
	if (-not (Config-Exists)) {
		Config-Create
	}
}

function Check-Config {
	$repoConfig = (Config-Get).repositories[(Hg-Current)]
	if (-not $repoConfig.bookmark) {
		throw "Main bookmark property is unset";
	}
	if (-not (Hg-Bookmarks -match $repoConfig.bookmark)) {
		throw "Main bookmark `"$($RepoConfig.bookmark)`" does not exist here"
	}
	if (-not $repoConfig.branch) {
		throw "Branch property is unset"
	}
	(hg bookmarks -T '{bookmarks},{branch}\n') -split '^n' | % {
		$book, $branch = $_ -split ','
		if ($book -eq $repoConfig.bookmark -and $branch -ne $repoConfig.branch) {
			throw "Bookmark `"$($Book)`" does not belong to branch `"$($RepoConfig.branch)`""
		}
	}
	if (-not $repoConfig.prefix) {
		throw "Prefix property is unset"
	}
}

function Action-Get($action) {
	$actionRegex = '^' + ($action -split '' -match '[a-z]' -join '.*')
	[CLI] | Get-Member -Static -MemberType Method | % {
		if ($_.Name -match $actionRegex) {
			$action = $_.Name
			return
		}
	}
	if (!([CLI] | Get-Member -Name $action -Static)) {
		return $null
	}
	return $action
}

try {
	Main @args
} catch {
	Write-Host $_ -ForegroundColor Red
	exit 1
}
