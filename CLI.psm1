Import-Module $PSScriptRoot\Util -DisableNameChecking

class CLI {

	# # TODO
	# static [void] Jump([string[]] $Params) {
	# 	[string] $Query = $Params[0];
	# 	[Task[]] $Tasks = [Task]::Find($Query);
	# 	switch ($Tasks.Length) {
	# 		0 {
	# 			throw "Can't find task with ID or description `"$($Query)`"";
	# 		}
	# 		1 {
	# 			[Mercurial] $Repo = [Mercurial]::Current();
	# 			# $Repo.Shelve();
	# 			# $Repo.Update("$([Task]::Prefix())-$($Tasks[0].ID)");
	# 			# $Repo.Unshelve("$([Task]::Prefix())-$($Tasks[0].ID)");
	# 		}
	# 		default {
	# 			throw "Task ID or description `"$($Query)`" is ambiguous. There are $($Tasks.Length) tasks that fall into this query";
	# 		}
	# 	}
	# }

	static [void] List([string[]] $params) {
		$bookmarksConfig = (Config-Get).repositories[(Hg-Current)].bookmarks
		Hg-Bookmarks | % {
			$description = $bookmarksConfig[$_]
			$output = $_
			if ($description) {
				$output += "`t$($description)"
			}
			Write-Host $output
		}
	}

	static [void] Create([string[]] $params) {
		if (!$params[0]) {
			throw "No arguments provided"
		}
		if (!(Is-Numeric $params[0])) {
			throw "Task ID `"$($params[0])`" must be a numeric identifier"
		}
		[int] $id = $params[0]
		[string] $description = $params[1]
		if (Task-Exists $id) {
			throw "Task with ID `"$($id)`" already exists"
		} else {
			hg shelve -A
			Task-Create $id $description
		}
	}

	# # TODO
	# static [void] Delete([string[]] $Params) {}

	# static [void] Reset([string[]] $Params) {
	# 	[Mercurial] $Repo = [Mercurial]::Current();
	# 	[Config] $Config = [Config]::Get();
	# 	[hashtable] $RepoConfig = $Config.Data.repositories[$Repo.ToString()];

	# 	if ($Repo.GetActiveBookmark() -eq $RepoConfig.bookmark) {
	# 		return;
	# 	}
	# 	$Repo.Shelve();
	# 	$Repo.Update($RepoConfig.bookmark);
	# }

	static [void] Config([string[]] $params) {
		[string] $key = $params[0]
		[string] $value = $params[1]
		if (@('bookmarks').Contains($key)) {
			throw "Cannot set reserved property `"$($key)`""
		}
		if ($key -and $value) {
			$config = Config-Get
			$config.repositories[(Hg-Current)][$key.ToLower()] = $value
			Config-Save $config
		} elseif ($Key) {
			Write-Host (Config-Get).repositories.(Hg-Current)[$key.ToLower()]
		} else {
			Config-Get | ConvertTo-Json -Depth 16 | Write-Host
		}
	}
}
