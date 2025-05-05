class_name JavaScriptHighlighter
extends SyntaxHighlighter

const COLOR_PURPLE    = Color("#9f56d6")
const COLOR_FUNCTION   = Color("#dcdcaa")
const COLOR_COMMENT    = Color("#718565")
const COLOR_CONSTANT   = Color(0.34, 0.61, 0.84)   # #569CD6

var keyword_regex = RegEx.new()
var function_regex = RegEx.new()
var comment_regex = RegEx.new()
var constant_regex = RegEx.new()

func _init():
	keyword_regex.compile(r"\b(break|case|catch|class|const|continue|debugger|default|delete|do|else|export|extends|finally|for|function|if|import|in|instanceof|let|new|return|super|switch|this|throw|try|typeof|var|void|while|with|yield|await)\b")
	function_regex.compile(r"\b\w+(?=\s*\()")  # Matches function names before (
	comment_regex.compile(r"//.*")
	constant_regex.compile(r"\b(true|false|null|undefined|NaN|Infinity|function|const|=>)\b")

func _get_line_syntax_highlighting(line_number: int) -> Dictionary:
	var result: Dictionary = {};
	var line: String = get_text_edit().get_line(line_number);

	var protected_regions: Array = []
	var _add_region = func (start: int, end: int, color: Color):
		# Skip if region overlaps with a protected zone (like string or comment)
		for region in protected_regions:
			if start < region.end and end > region.start:
				return  # Overlaps with protected region, skip
		
		# Only apply if not already defined
		if not result.has(start):
			result[start] = { "color": color }
		if not result.has(end):
			result[end] = { "color": Color("#ffff") }
	
	# Apply in order from lowest-priority to highest
	# That way later entries override earlier ones when they overlap
	
	# Comments
	for match in comment_regex.search_all(line):
		_add_region.call(match.get_start(), match.get_end(), COLOR_COMMENT)
	
	# Keywords
	for match in keyword_regex.search_all(line):
		_add_region.call(match.get_start(), match.get_end(), COLOR_PURPLE)
	
	# Functions
	for match in function_regex.search_all(line):
		print(match.get_string())
		_add_region.call(match.get_start(), match.get_end(), COLOR_FUNCTION)
	
	# Constants
	for match in constant_regex.search_all(line):
		_add_region.call(match.get_start(), match.get_end(), COLOR_CONSTANT)
	
	print("result: ", result)
	return result
