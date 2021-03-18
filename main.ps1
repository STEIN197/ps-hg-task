using module .\Util.psm1;
# using module .\CLI.psm1;

function Main {
	Check-Setup
	return
	# if (!$args.Length) {
	# 	[Task] $CurrentTask = [Task]::Current();
	# 	if ($CurrentTask) {
	# 		Write-Host "$($CurrentTask)`t$($CurrentTask.Description)";
	# 	}
	# 	return;
	# }
	# [string] $Action = $Args[0];
	# [string] $ActionRegex = $Action -split '' -match '[a-z]' -join '.*';
	# $ActionRegex = "^$($ActionRegex)";
	# [CLI] | Get-Member -Static -MemberType Method | % {
	# 	if ($_.Name -match $ActionRegex) {
	# 		$Action = $_.Name;
	# 		return;
	# 	}
	# }
	# if (!([CLI] | Get-Member -Name $Action -Static)) {
	# 	throw "Unknown operation `"$($Action)`"";
	# }
	# [CLI]::$Action($Args[1..$Args.Length]);
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
	[hashtable] $repoConfig = (Config-Get).repositories[(Hg-Current)]
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

try {
	Main @Args;
} catch {
	Write-Host $_ -ForegroundColor Red;
	exit 1;
}
