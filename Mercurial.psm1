class Mercurial {

	static [string] $DIR_NAME = '.hg';

	[System.IO.FileSystemInfo] $Path;

	Mercurial([System.IO.FileSystemInfo] $Path) {
		$this.Path = $Path;
	}

	[boolean] BookmarkInstalled([string] $Name) {
		return $this.Bookmarks().Contains($Name);
	}

	[string[]] Bookmarks() {
		$Output = Invoke-Expression 'hg bookmarks --template "{bookmark} "';
		return $Output -split " ";
	}

	[void] CreateBookmark([string] $Name) {
		Invoke-Expression "hg bookmarks $($Name)";
	}

	[void] PushBookmark([string] $Name) {
		Invoke-Expression "hg push -B $($Name)";
	}

	static [boolean] Installed() {
		try {
			Get-Command "hg";
			return $true;
		} catch {
			return $false;
		}
	}
	
	static [Mercurial] Current() {
		if (![Mercurial]::Installed()) {
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
