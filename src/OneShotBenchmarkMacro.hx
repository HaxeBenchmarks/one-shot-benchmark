class OneShotBenchmarkMacro {
	macro public static function gitRepoFolder():ExprOf<String> {
		var repoUrl:String = Sys.getEnv("ONE_SHOT_BENCHMARK_REPO");
		return macro $v{repoUrl};
	}

	macro public static function webRoot():ExprOf<String> {
		var webRoot:String = Sys.getEnv("BENCHMARKS_WEBROOT");
		return macro $v{webRoot};
	}
}
