Import-Module $PSScriptRoot\Util -DisableNameChecking

class CLI {

	static [void] Jump([string[]] $params) {
		[string] $query = $params[0]
		[int[]] $tasks = Task-Find $query
		switch ($tasks.Length) {
			0 {
				throw "Can't find task with ID or description `"$($query)`"";
			}
			1 {
				$taskId = $tasks[0]
				hg shelve -A
				hg update "$(Task-Prefix)-$($taskId)"
				Hg-Shelve-List | % {
					if ($_ -eq "$(Task-Prefix)-$($taskId)") {
						hg unshelve -n "$(Task-Prefix)-$($taskId)"
						return
					}
				}
			}
			default {
				throw "Task ID or description `"$($query)`" is ambiguous. There are $($tasks.Length) tasks that match this query"
			}
		}
	}

	static [void] List([string[]] $params) {
		$bookmarksConfig = (Config-Get).repositories[(Hg-Current)].bookmarks
		Hg-Bookmarks | % {
			if (-not ($_ -match "^$(Task-Prefix)-\d+$")) {
				return
			}
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

	static [void] Reset([string[]] $Params) {
		$mainBookmark = (Config-Get).repositories.(Hg-Current).bookmark
		if ((Hg-Bookmark) -eq $mainBookmark) {
			return
		}
		hg shelve -A
		hg update $mainBookmark
	}

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
