local LINE_BREAKS = {
    ["\n"] = true,
    ["\r"] = true,
    [string.byte("\n")] = true,
    [string.byte("\r")] = true,
}

return {
	LINE_BREAKS = LINE_BREAKS
}
