using module .\Config.psm1;
using module .\Mercurial.psm1;

class Task {

	[int] $ID;
	[string] $Description;

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

	# TODO
	static [Task[]] Find([string] $Query) {
		[Mercurial] $Repo = [Mercurial]::Current();
		[Task[]] $Result = @();
		$Repo.Bookmarks() | % {
			if ($_ -match "^$([Task]::Prefix())-(\d*$($Query)\d*)$") {
				$Result += [Task]::Get($Matches[0]);
			}
		}
		if (!$Result.Length) {
			[hashtable] $RepoConfig = [Config]::Get().Data.repositories[[Mercurial]::Current().ToString()].bookmarks;
			# TODO regex by name / desc
		}
		return $Result;
	}

	# TODO
	static [Task] Current() {
		# if null else task
	}

	static [string] Prefix() {
		return [Config]::Get().Data['repositories'][[Mercurial]::Current().ToString()]['prefix'];
	}
}
