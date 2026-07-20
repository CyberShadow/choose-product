module lib.net;

import ae.sys.net;
import ae.sys.net.cachedcurl;

/// Fetch with a browser User-Agent, for sites which reject D's default one.
auto getFileAsFirefox(string url)
{
	auto ccnet = cast(CachedCurlNetwork)net;
	auto req = CachedCurlNetwork.Request(url);
	req.headers ~= ["User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:134.0) Gecko/20100101 Firefox/134.0"];
	return ccnet.cachedReq(req).responseData;
}
