using module .\Config.psm1;
using module .\Mercurial.psm1;

class Task {

	[int] $ID;

	Task([int] $ID) {
		$this.ID = $ID;
	}

	static [boolean] Exists([int] $ID) {
		return [Mercurial]::Current().Bookmarks().Contains("$([Task]::Prefix())-$($ID)");
	}

	static [Task] Create([int] $ID, [string] $Description) {
		[string] $BookmarkName = "$([Task]::Prefix())-$($ID)";
		[Mercurial] $Repo = [Mercurial]::Current();
		if ($Repo.Bookmarks().Contains($BookmarkName)) {
			throw "Task `"$($ID)`" already exists";
		}
		$Repo.CreateBookmark($BookmarkName);
		if ($Description) {
			[Config] $Config = [Config]::Get();
			$Config.Data['repositories'][$Repo.ToString()]['bookmarks'][$BookmarkName] = $Description; # TODO
			$Config.Save();
		}
		return [Task]::New($ID);
	}

	static [Task] Get([int] $TaskID) {
		if ([Task]::Exists($TaskID)) {
			return [Task]::New($TaskID);
		} else {
			return $null;
		}
	}

	static [Task[]] Find([string] $Query) {
		[Mercurial] $Repo = [Mercurial]::Current();
		[Task[]] $Result = @();
		[Config] $Config = [Config]::Get();
		$Repo.Bookmarks() | % {
			if ($_ -match "^$([Task]::Prefix())-\d*$($Query)\d*$" -or $Config.Data['repositories'][$Repo.ToString()]['bookmarks'][$_] -match $Query) {
				$Parts = $_ -split '-';
				$Result += $Parts[$Parts.Length - 1];
			}
		}
		return $Result;
	}

	# TODO
	static [Task] Current() {
		$BookmarkName = Invoke-Expression 'hg log -r . -T {activebookmark}';
		if ($BookmarkName -match "^$([Task]::Prefix())-(\d+)$") {
			return [Task]::New($Matches.0);
		} else {
			return $null;
		}
	}

	static [string] Prefix() {
		return [Config]::Get().Data['repositories'][[Mercurial]::Current().ToString()]['prefix'];
	}
}
