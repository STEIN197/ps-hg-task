class Mercurial {

	static [string] $DIR_NAME = '.hg';

	[System.IO.FileSystemInfo] $Path;

	Mercurial([System.IO.FileSystemInfo] $Path) {
		$this.Path = $Path;
	}

	[boolean] BookmarkExists([string] $Name) {
		return $this.Bookmarks().Contains($Name);
	}

	[string[]] Bookmarks() {
		$Output = Invoke-Expression 'hg bookmarks --template "{bookmark} "';
		return $Output -split " ";
	}

	[void] CreateBookmark([string] $Name) {
		Invoke-Expression "hg bookmarks $($Name)";
	}

	static [boolean] Exists() {
		try {
			Get-Command "hg";
			return $true;
		} catch {
			return $false;
		}
	}
	
	static [Mercurial] Current() {
		if (![Mercurial]::Exists()) {
			return $null;
		}
		$CurrentItem = Get-Item -Path ".";
		while ($CurrentItem -ne $null -and !(Test-Path "$($CurrentItem.FullName)\$([Mercurial]::DIR_NAME)")) {
			$CurrentItem = $CurrentItem.Parent;
		}
		if ($CurrentItem -eq $null) {
			return $null;
		} else {
			return [Mercurial]::New($CurrentItem);
		}
	}
}
