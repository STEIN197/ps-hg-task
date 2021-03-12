using module .\Mercurial.psm1;

class Task {

	static [string[]] $ACTION = @(
		'create',
		'list',
		'delete'
	);
	static [string] $PREFIX = 'kissmedev';

	[int] $ID;
	[string] $Description;

	Task([int] $ID, [string] $Description) {
		$this.ID = $ID;
		$this.Description = $Description;
	}

	[void] Push() {
		$Repo = [Mercurial]::Current();
		$Repo.PushBookmark("$([Task]::PREFIX)-$($ID)");
	}

	static [boolean] Exists([int] $ID) {
		$Repo = [Mercurial]::Current();
		return $Repo.BookmarkExists("$([Task]::PREFIX)-$($ID)");
	}

	static [Task] Create([int] $ID, [string] $Description) {
		$Repo = [Mercurial]::Current();
		$Repo.CreateBookmark("$([Task]::PREFIX)-$($ID)");
		if ($Description) {
			# TODO
		}
	}

	static [Task] Get([int] $TaskID) {}
}
