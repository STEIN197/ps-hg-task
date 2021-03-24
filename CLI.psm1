Import-Module $PSScriptRoot\util -DisableNameChecking

class CLI {

	static [void] Jump([string[]] $params) {
		[string] $query = $params[0]
		[int] $taskId = Task-Find $query
		$bookmark = "$(Task-Prefix)-$taskId"
		if ((Hg-Bookmark) -eq $bookmark) {
			return
		}
		hg shelve -A
		hg update $bookmark
		Hg-Shelve-List | % {
			if ($_ -eq $bookmark) {
				hg unshelve -n $bookmark
				return
			}
		}
	}

	static [void] List([string[]] $params) {
		$bookmarksConfig = (Config-Get).repositories[(Hg-Current)].bookmarks
		$currentBookmark = Hg-Bookmark
		$shelves = Hg-Shelve-List
		Hg-Bookmarks | % {
			if (-not ($_ -match "^$(Task-Prefix)-\d+$")) {
				return
			}
			$description = $bookmarksConfig[$_]
			$output = $_
			if ($_ -in $shelves) {
				$output += " | shelved"
			} else {
				$output += " |        "
			}
			if ($description) {
				$output += " | $($description)"
			}
			Write-Host $output -ForegroundColor $($_ -eq $currentBookmark ? 'Green' : 'White')
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

	# TODO: Delete branch?
	static [void] Delete([string[]] $params) {
		[string] $query = $params[0]
		[int] $taskId = Task-Find $query
		[string] $bookmark = "$(Task-Prefix)-$taskId"
		[hashtable] $config = Config-Get
		if ((Hg-Bookmark) -eq $bookmark) {
			hg shelve -A
			hg update $config.repositories.(Hg-Current).bookmark
		}
		hg bookmark -d $bookmark
		Hg-Shelve-List | % {
			if ($_ -eq $bookmark) {
				hg shelve -d $bookmark
				return
			}
		}
		$config.repositories.(Hg-Current).bookmarks.Remove($bookmark)
		Config-Save $config
	}

	# TODO
	static [void] Apply([string[]] $params) {
		# if ($params[0]) {
		# 	$taskId = Task-Find $params[0]
		# } else {
		# 	$taskId = Task-Current
		# 	if (!$task) {
		# 		throw "No task is active"
		# 	}
		# }
	}

	static [void] Unset([string[]] $params) {
		$mainBookmark = (Config-Get).repositories.(Hg-Current).bookmark
		if ((Hg-Bookmark) -eq $mainBookmark) {
			return
		}
		hg shelve -A
		hg update $mainBookmark
	}

	# TODO
	static [void] Push([string[]] $params) {
		# if ($params[0]) {
		# 	[string] $query = $params[0]
		# 	[int[]] $tasks = Task-Find $query
		# 	switch ($tasks.Length) {
		# 		0 {
		# 			throw "Can't find task with ID or description `"$($query)`"";
		# 		}
		# 		1 {
		# 			break
		# 		}
		# 		default {
		# 			throw "Task ID or description `"$($query)`" is ambiguous. There are $($tasks.Length) tasks that match this query"
		# 		}
		# 	}
		# 	[string] $bookmark = "$(Task-Prefix)-$($tasks[0])"
		# } else {
		# 	[int] $taskId = Task-Current
		# 	if (!$taskId) {
		# 		throw 'Current bookmark is not task'
		# 	}
		# 	[string] $bookmark = "$(Task-Prefix)-$($taskId)"
		# }
		# (hg bookmarks --template '{bookmarks},{phase}') -split '`n' | % {
		# 	$book, $phase = $_ -split ','
		# 	if ($book -eq $bookmark -and $phase -eq 'secret') {
		# 		throw "Bookmark `"$bookmark`" is in secret phase"
		# 	}
		# }
		# hg push -B $bookmark
	}

	# static [void] Apply([string[]] $params) {}
	# static [void] Merge([string[]] $params) {}

	static [void] Config([string[]] $params) {
		[string] $key = $params[0]
		[string] $value = $params[1]
		if (@('bookmarks').Contains($key)) {
			throw "Cannot set reserved property `"$($key)`""
		}
		if ($key -and $value) {
			$config = Config-Get
			$currentValue = $config.repositories[(Hg-Current)][$key.ToLower()]
			if ($currentValue) {
				throw 'Changing value is not allowed'
			}
			$config.repositories[(Hg-Current)][$key.ToLower()] = $value
			Config-Save $config
		} elseif ($Key) {
			Write-Host (Config-Get).repositories.(Hg-Current)[$key.ToLower()]
		} else {
			(Config-Get).repositories.(Hg-Current) | ConvertTo-Json -Depth 16 | Write-Host
		}
	}
}
