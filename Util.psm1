class Util {
	
	static [boolean] IsNumeric([string] $String) {
		return $String -match '^\d+$';
	}
}
