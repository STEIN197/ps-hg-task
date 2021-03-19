function Is-Numeric([string] $string) {
	return $string -match '^\d+$'
}

function Hg-Installed {
	try {
		hg > $null
		return $true
	} catch {
		return $false
	}
}

function Hg-Bookmarks {
	return (hg bookmarks --template '{bookmark}\n') -split '^n'
}

function Hg-Bookmark {
	return hg log -r . --template '{activebookmark}'
}

function Hg-Current {
	$currentItem = Get-Item -Path .;
	while ($currentItem -ne $null -and !(Test-Path "$($currentItem.FullName)\.hg")) {
		$currentItem = $currentItem.Parent
	}
	return $currentItem ? $currentItem.FullName : $null
}

function Hg-Shelve-List {
	return (hg shelve -l) -split '`n' | % {
		$_ -match '^(.+?)\s+' > $null
		return $matches[1]
	}
}

function Config-Exists {
	return Test-Path -Path "$($PSScriptRoot)\config.json"
}

function Config-Create {
	New-Item -Path $PSScriptRoot -Name 'config.json' -ItemType 'file'
	Config-Save @{
		repositories = @{}
	}
}

function Config-Path {
	return "$($PSScriptRoot)\config.json"
}

function Config-Get {
	return (Get-Content -Path (Config-Path) -Raw | ConvertFrom-Json -AsHashtable) ?? @{
		repositories = @{}
	}
}

function Config-Save([hashtable] $data) {
	$data | ConvertTo-Json -Depth 16 | Out-File -FilePath (Config-Path);
}

function Config-Setup {
	$config = Config-Get
	if (!$config.repositories[(Hg-Current)]) {
		$config.repositories[(Hg-Current)] = @{
			branch = ''
			prefix = ''
			bookmark = ''
			bookmarks = @{}
		}
		Config-Save $config
	}
}

function Task-Current {
	if ((Hg-Bookmark) -match "^$(Task-Prefix)-(\d+)$") {
		return $matches[1]
	} else {
		return $null
	}
}

function Task-Description ($ID) {
	return (Config-Get).repositories[(Hg-Current)].bookmarks["$(Task-Prefix)-$($ID)"]
}

function Task-Prefix {
	return (Config-Get).repositories[(Hg-Current)].prefix
}

function Task-Create($id, $description) {
	$bookmark = "$(Task-Prefix)-$($id)"
	if ((Hg-Bookmarks).Contains($bookmark)) {
		throw "Task `"$($id)`" already exists"
	}
	hg bookmark $bookmark
	if ($description) {
		$config = Config-Get
		$config.repositories.(Hg-Current).bookmarks.$bookmark = $description
		Config-Save $config
	}
}
function Task-Exists($id) {
	return (Hg-Bookmarks).Contains("$(Task-Prefix)-$($id)");
}

function Task-Find($query) {
	$result = @()
	$repoBookmarks = (Config-Get).repositories.(Hg-Current).bookmarks
	Hg-Bookmarks | % {
		if ($_ -match "^$(Task-Prefix)-\d*$($query)\d*$" -or $repoBookmarks.$_ -match $query) {
			$parts = $_ -split '-';
			$result += [int] $parts[$parts.Length - 1];
		}
	}
	return $result
}

Export-ModuleMember -Function *
