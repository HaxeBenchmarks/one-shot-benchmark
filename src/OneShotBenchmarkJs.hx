import haxe.Http;
import js.Browser;
import js.jquery.JQuery;

class OneShotBenchmarkJs {
	public static function main() {
		checkBenchmarkStatus();
	}

	static function checkBenchmarkStatus() {
		var request:Http = new Http("status.txt");

		request.onData = function(data:String) {
			var status:OneShotStatus = cast data;
			switch (status) {
				case null:
					updateStatus("unknown");
				case InQueue:
					updateStatus("waiting in queue");
				case Running:
					updateStatus("benchmark is running ");
				case Finished:
					updateStatus("benchmark finished");
					new BenchmarkJS();
					return;
				case Failed:
					updateStatus("benchmark failed");
					return;
			}
			Browser.window.setTimeout(checkBenchmarkStatus, 60 * 1000);
		}
		request.onError = function(msg:String) {
			updateStatus("unkown");
			Browser.window.setTimeout(checkBenchmarkStatus, 60 * 1000);
		}
		request.request();
	}

	static function updateStatus(text:String) {
		new JQuery("#benchmark-status").text(text);
	}
}
