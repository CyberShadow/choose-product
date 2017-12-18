import std.algorithm.iteration;
import std.algorithm.searching;
import std.array;
import std.conv;
import std.exception;
import std.string;

import ae.net.ietf.url;
import ae.sys.net;
import ae.sys.net.cachedcurl;
import ae.utils.array;
import ae.utils.meta;
import ae.utils.regex;

import arsd.dom;

static this()
{
	auto ccnet = cast(CachedCurlNetwork)net;
	ccnet.http.verbose = true;
}

struct Product
{
	string asin;
}

Product[] getProducts(string query)
{
	for (int page = 1; ; page++)
	{
		auto pageURL =
			// "https://www.amazon.com/gp/search?" ~
			"https://www.amazon.com/s?" ~
			encodeUrlParameters([
				"rh" : "k:" ~ query,
				"page" : text(page),
			]);
		import std.stdio; writeln(pageURL);

		auto asins = pageURL
			.getFile
			.bytes
			.assumeUTF
			.assumeUnique
			.I!(s => new Document(s))
			.querySelectorAll("#atfResults .s-access-detail-page")
			.map!(node => applyRelativeURL(pageURL, node.attributes["href"]).extractASIN())
			.array;

		if (asins.length == 0)
			break;

		import std.stdio; writeln(asins);
	}
	assert(false);
}

string extractASIN(string url)
{
	if (url.canFind("picassoRedirect.html"))
		url = url.findSplit("?")[2].decodeUrlParameters()["url"];
	return url.extractCapture!string(re!`/dp/(.*?)/`).front;
}
