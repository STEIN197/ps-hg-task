class Task {

	static [string[]] $ACTION = @(
		'create',
		'list',
		'delete'
	);
	static [string] $PREFIX = 'kissmedev';

	static [boolean] Exists([int] $ID) {} # TODO
}
