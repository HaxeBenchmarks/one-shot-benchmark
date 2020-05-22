enum abstract OneShotStatus(String) {
	var InQueue = "waiting in queue";
	var Running = "running";
	var Finished = "finished";
	var Failed = "failed";
}
