using module .\Mercurial.psm1;

class Task {

	static [string[]] $ACTION = @(
		'create',
		'list',
		'delete'
	);
	static [string] $PREFIX = 'kissmedev';

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
}
