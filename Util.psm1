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

function Config-Setup-Hg {
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
	if (Hg-Bookmark -match "^$(Task-Prefix)-(\d+)$") {
		return $matches.0
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

function Task-Create {}
function Task-Exists {}
function Task-Find {}

Export-ModuleMember -Function *
