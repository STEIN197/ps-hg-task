using module .\Task.psm1;
using module .\Mercurial.psm1;
using module .\Config.psm1;

class CLI {

	# TODO
	static [void] Jump([string[]] $Params) {
		[string] $Query = $Params[0];
		[Task[]] $Tasks = [Task]::Find($Query);
		switch ($Tasks.Length) {
			0 {
				throw "Can't find task with ID or description `"$($Query)`"";
			}
			1 {
				[Mercurial] $Repo = [Mercurial]::Current();
				# $Repo.Shelve();
				# $Repo.Update("$([Task]::Prefix())-$($Tasks[0].ID)");
				# $Repo.Unshelve("$([Task]::Prefix())-$($Tasks[0].ID)");
			}
			default {
				throw "Task ID or description `"$($Query)`" is ambiguous. There are $($Tasks.Length) tasks that fall into this query";
			}
		}
	}

	static [void] List([string[]] $Params) {
		[Mercurial] $Repo = [Mercurial]::Current();
		[Config] $Config = [Config]::Get();
		foreach ($BookmarkName in $Repo.Bookmarks()) {
			[string] $BookDescription = $Config.Data['repositories'][$Repo.ToString()]['bookmarks'][$BookmarkName];
			[string] $Output = $BookmarkName;
			if ($BookDescription) {
				$Output = "$($Output)`t$($BookDescription)";
			}
			Write-Host $Output;
		}
	}

	static [void] Create([string[]] $Params) {
		[int] $TaskID = $Params[0];
		[string] $TaskDescription = $Params[1];
		if ([Task]::Exists($TaskID)) {
			throw "Task with ID `"$($TaskID)`" already exists";
		} else {
			[Mercurial]::Current().Shelve();
			[Task]::Create($TaskID, $TaskDescription);
		}
	}

	# TODO
	static [void] Delete([string[]] $Params) {}
	# TODO
	static [void] Reset([string[]] $Params) {} # Task::current();

	static [void] Config([string[]] $Params) {
		[string] $Key = $Params[0];
		[string] $Value = $Params[1];
		if ([Config]::PROPERTY_RESERVED.Contains($Key)) {
			throw "Cannot set reserved property `"$($Key)`"";
		}
		[Config] $Config = [Config]::Get();
		[Mercurial] $Repo = [Mercurial]::Current();
		[hashtable] $RepoConfig = $Config.Data['repositories'][$Repo.ToString()];
		if ($Key -and $Value) {
			$RepoConfig[$Key.ToLower()] = $Value;
			$Config.Save();
		} elseif ($Key) {
			Write-Host $RepoConfig[$Key.ToLower()];
		} else {
			$RepoConfig | ConvertTo-Json -Depth 16 | Write-Host;
		}
	}
}
