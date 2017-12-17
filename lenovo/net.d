module net;

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.array;
import std.file;
import std.net.curl;
import std.path;
import std.string;
import std.typecons;

import ae.sys.file;
import ae.sys.paths;
import ae.utils.digest;
import ae.utils.json;
import ae.utils.time : StdTime;

alias Headers = string[][string];

HTTP http;
static this() { http = HTTP(); }

/*private*/ void req(string url, HTTP.Method method, const(void)[] data, string target, string headerPath)
{
	http.verbose = true;
	http.method = method;
	if (method == HTTP.Method.head)
		http.maxRedirects = uint.max;
	else
		http.maxRedirects = 10;
	auto host = url.split("/")[2];
	auto cookiePath = buildPath("cookies", host);
	if (cookiePath.exists)
		http.addRequestHeader("Cookie", cookiePath.readText);
	Headers headers;
	http.onReceiveHeader =
		(in char[] key, in char[] value)
		{
			headers[key.idup] ~= value.idup;
		};
	if (data)
		http.onSend = (void[] buf)
			{
				size_t len = min(buf.length, data.length);
				buf[0..len] = data[0..len];
				data = data[len..$];
				return len;
			};
	else
		http.onSend = null;
	download!HTTP(url, target, http);
	write(headerPath, headers.toJson);
}

private Tuple!(ubyte[], Headers) cachedReq(string url, HTTP.Method method, in void[] data, StdTime epoch)
{
	auto hash = getDigestString!MD5(url ~ cast(char)method ~ data);
	auto path = buildPath("web", hash[0..2], hash);
	ensurePathExists(path);
	auto headerPath = path ~ ".headers";
	if (path.exists && path.timeLastModified.stdTime < epoch)
		path.remove();
	cached!req(url, method, data, path, headerPath);
	return tuple(cast(ubyte[])read(path), headerPath.exists ? headerPath.readText.jsonParse!Headers : null);
}

ubyte[] cachedGet(string url, StdTime epoch = 0)
{
	return cachedReq(url, HTTP.Method.get, null, epoch)[0];
}

ubyte[] cachedPost(string url, in void[] data, StdTime epoch = 0)
{
	return cachedReq(url, HTTP.Method.post, data, epoch)[0];
}

string cachedResolveRedirect(string url, StdTime epoch = 0)
{
	return cachedReq(url, HTTP.Method.head, null, epoch)[1]["location"][0];
}
