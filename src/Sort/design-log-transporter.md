# Design Read 1Mb log files from client machines

In real world, you write log files out locally, and some task or process reads through them line by line, chunking/batching it and send it off as a request. You then catch it in a distributed queue and process into whatever form you want. Imagine "design splunk" or "design datadog". The conceptual idea is logs as event streams.

The log on the client is then rotated or deleted by the service itself. This is a nice pattern because the log is append only and therefore very cheap, and allows you to write huge volumes of logs. The process that reads those logs only needs to understand that, and can run as another container aside your application. Separate resourcing too. If the log processor running locally crashes or has problems, you can just replay it back on the last found timestamp to get your logs back. If the app crashes, any unsent logs can be sent, and then allow the container to terminate. As you send batches of logs, you infuse that batch with metadata. So app name, container, etc etc.

Batch -> Compress -> (maybe) stream

Stream stuff is arguable, it's better to chunk and send in small fragments, overhead of maintaining the stream and stuff is complicated. Then if you're missing a fragment, you can just ask for that chunk.

Imagine running millions of container or something. Keeping all those streams open is expensive. Better to be async.

Batches (configurable) should be big enough to take advantage of compression. Like greater than 2mb for gzip.
