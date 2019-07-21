return {
	magic = {
		OPEN_SET = '[', -- [abc]
		CLOSE_SET = ']', -- [abc]
		NEGATED_SET = '^', -- [^abc]
		RANGE = '-', -- [0-9]
	},
	class = {
		a = "[a-zA-Z]",
		d = "[0-9]",
		l = "[a-z]",
		u = "[A-Z]",
		w = "[a-zA-Z0-9]", -- maybe '_' ?
		A = "[^a-zA-Z]",
		D = "[^0-9]",
		L = "[^a-z]",
		U = "[^A-Z]",
		W = "[^a-zA-Z0-9]", -- maybe '_' ?
	}
}