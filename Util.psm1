class Util {
	
	static [boolean] IsNumeric([string] $String) {
		return $String -match '^\d+$';
	}
}

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

function Hg-Active-Bookmark {
	return hg log -r . --template '{activebookmark}'
}

function Hg-Current-Path {
	$currentItem = Get-Item -Path .;
	while ($currentItem -ne $null -and !(Test-Path "$($currentItem.FullName)\.hg")) {
		$currentItem = $currentItem.Parent
	}
	return $currentItem ?? $currentItem.FullName
}

function Config-Exists {
	return Test-Path -Path "$($PSScriptRoot)\config.json"
}

function Config-Create {
	New-Item -Path $PSScriptRoot -Name 'config.json' -ItemType 'file'
}

function Config-Path {
	return "$($PSScriptRoot)\config.json"
}

function Config-Get {
	return Get-Content -Path Config-Path -Raw | ConvertFrom-Json -AsHashtable ?? @{
		repositories = @{}
	}
}

function Config-Save([hashtable] $data) {
	$data | ConvertTo-Json -Depth 16 | Out-File -FilePath Config-Path;
}

Export-ModuleMember -Function *
