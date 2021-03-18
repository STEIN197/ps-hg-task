# using module .\Task.psm1;
# using module .\Config.psm1;
# using module .\Mercurial.psm1;
# using module .\Util.psm1;
# using module .\CLI.psm1;

Import-Module .\Util.psm1

function Main {
	Check-Setup
	return
	if (!$Args.Length) {
		[Task] $CurrentTask = [Task]::Current();
		if ($CurrentTask) {
			Write-Host "$($CurrentTask)`t$($CurrentTask.Description)";
		}
		return;
	}
	[string] $Action = $Args[0];
	[string] $ActionRegex = $Action -split '' -match '[a-z]' -join '.*';
	$ActionRegex = "^$($ActionRegex)";
	[CLI] | Get-Member -Static -MemberType Method | % {
		if ($_.Name -match $ActionRegex) {
			$Action = $_.Name;
			return;
		}
	}
	if (!([CLI] | Get-Member -Name $Action -Static)) {
		throw "Unknown operation `"$($Action)`"";
	}
	[CLI]::$Action($Args[1..$Args.Length]);
}

function Check-Setup {
	if (!(Hg-Installed)) {
		throw "Mercurial is not installed on this computer";
	}
	if (!(Hg-Current-Path)) {
		throw "Mercurial repository does not exist here";
	}
	if (!(Config-Exists)) {
		Config-Create
	}
	[hashtable] $repoConfig = (Config-Get).repositories[(Hg-Current-Path)]
	if (!$repoConfig.bookmark) {
		throw "Main bookmark property is unset";
	}
	if (!(Hg-Bookmarks -match $repoConfig.bookmark)) {
		throw "Main bookmark $($RepoConfig.bookmark) does not exist here";
	}
	if (!$repoConfig.branch) {
		throw "Branch property is unset";
	}
	# (hg bookmarks -T '{bookmarks},{branch}\n') -split '^n' | % {
	# 	$Book, $Branch = $_ -split ',';
	# 	if ($Book -eq $RepoConfig.bookmark -and $Branch -ne $RepoConfig.branch) {
	# 		throw "Bookmark `"$($Book)`" does not belong to `"$($RepoConfig.branch)`"";
	# 	}
	# }
	# if (!$RepoConfig.prefix) {
	# 	throw "Prefix property is unset";
	# }
}

try {
	Main @Args;
} catch {
	Write-Host $_ -ForegroundColor Red;
	exit 1;
}
