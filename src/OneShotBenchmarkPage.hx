import haxe.Exception;
import haxe.Resource;
import haxe.Template;
import haxe.io.Path;
import php.Global;
import php.SuperGlobal;
import sys.FileSystem;
import sys.io.File;

class OneShotBenchmarkPage {
	static function showSubmitForm() {
		var context = {}
		var template:Template = new Template(Resource.getString("uploadForm.html"));
		Sys.println(template.execute(context));
	}

	static function setupOneShotBenchmark() {
		var repoUrl:String = OneShotBenchmarkMacro.gitRepoFolder();
		if (repoUrl == null) {
			redirect("index.php?error=No%20repo");
			return;
		}
		var code:String = SuperGlobal._POST["code"];
		var dependencies:String = SuperGlobal._POST["dependencies"];
		if (dependencies == null || code == null) {
			redirect("index.php?error=No%20data");
			return;
		}
		code = code.trim();
		dependencies = dependencies.trim();
		if (code.length <= 0) {
			redirect("index.php?error=Code%20empty");
			return;
		}

		var branchName:String = 'benchmark-${DateTools.format(Date.now(), "%Y%m%d-%H%M%S")}';
		var tempFolder:String = Path.join([untyped sys_get_temp_dir(), branchName]);

		// FileSystem.createDirectory(tempFolder);
		command("git", ["clone", "--depth", "1", repoUrl, tempFolder]);
		var cwd:String = Sys.getCwd();
		Sys.setCwd(tempFolder);
		command("git", ["checkout", "-b", branchName]);
		writeRunHxml(branchName, tempFolder);
		writeJenkinsfile(branchName, tempFolder);
		writeCode(branchName, tempFolder, code);
		writeRunner(branchName, tempFolder, dependencies);

		command("git", ["add", "."]);
		command("git", ["commit", "-m", "submitted for benchmark", "--author", "OneShotWebpage"]);
		command("git", ["push"]);
		cleanup(tempFolder);
		setupIndexHtml(branchName, dependencies, code);
	}

	static function writeRunHxml(branchName:String, tempFolder:String) {
		File.saveContent(Path.join([tempFolder, "run.hxml"]), Resource.getString("run_hxml"));
	}

	static function writeJenkinsfile(branchName:String, tempFolder:String) {
		var context = {
			branchName: branchName
		}
		var template:Template = new Template(Resource.getString("Jenkinsfile"));
		File.saveContent(Path.join([tempFolder, "Jenkinsfile"]), template.execute(context));
	}

	static function writeCode(branchName:String, tempFolder:String, code:String) {
		File.saveContent(Path.join([tempFolder, "BenchmarkCode.hx"]), code);
	}

	static function writeRunner(branchName:String, tempFolder:String, dependencies:String) {
		var libLines:Array<String> = dependencies.split("\n").map(l -> l.trim()).filter(l -> l.split(" ").length == 2);
		var libs:Array<{name:String, url:String}> = libLines.map(function(line:String) {
			var parts:Array<String> = line.split(" ");
			return {
				name: parts[0],
				url: parts[1],
			};
		});

		var context = {
			branchName: branchName,
			libs: libs
		}
		var template:Template = new Template(Resource.getString("OneShotBenchmark.hx"));
		File.saveContent(Path.join([tempFolder, "OneShotBenchmark.hx"]), template.execute(context));
	}

	static function cleanup(tempFolder:String) {
		FileSystem.deleteFile(Path.join([tempFolder, "Jenkinsfile"]));
		FileSystem.deleteFile(Path.join([tempFolder, "run.hxml"]));
		FileSystem.deleteFile(Path.join([tempFolder, "OneShotBenchmark.hx"]));
		FileSystem.deleteFile(Path.join([tempFolder, "BenchmarkCode.hx"]));
		FileSystem.deleteDirectory(tempFolder);
	}

	static function setupIndexHtml(branchName:String, libs:String, code:String) {
		var context = {
			branchName: branchName,
			libs: libs,
			code: code
		}
		var template:Template = new Template(Resource.getString("oneShotResults.html"));
		var webrootFolder:String = Sys.getEnv("BENCHMARKS_WEBROOT");
		if (webrootFolder == null) {
			return;
		}
		File.saveContent(Path.join([webrootFolder, "one-shot-benchmarks", branchName, "index.html"]), template.execute(context));
		File.saveContent(Path.join([webrootFolder, "one-shot-benchmarks", branchName, "status.txt"]), cast OneShotStatus.InQueue);
		redirect('/one-shot-benchmarks/$branchName');
	}

	static function command(cmd:String, ?args:Array<String>):Int {
		return Sys.command(cmd, args);
	}

	static function redirect(url:String) {
		Global.header('Location: $url');
		Sys.exit(0);
	}

	static function main() {
		for (key => value in SuperGlobal._SERVER) {
			if (key == "REQUEST_METHOD" && value == "POST") {
				try {
					setupOneShotBenchmark();
				} catch (e:Exception) {
					trace(e);
					// redirect("index.php?error=" + e.message);
				}
				return;
			}
		}
		showSubmitForm();
	}
}
