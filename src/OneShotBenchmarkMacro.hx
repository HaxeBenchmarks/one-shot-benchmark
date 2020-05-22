class OneShotBenchmarkMacro {
	macro public static function gitRepoFolder():ExprOf<String> {
		var repoUrl:String = Sys.getEnv("ONE_SHOT_BENCHMARK_REPO");
		return macro $v{repoUrl};
	}
}
