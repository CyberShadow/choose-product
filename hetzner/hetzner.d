import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.conv;
import std.datetime.systime;
import std.exception;
import std.range;
import std.regex;
import std.stdio;
import std.string;

import ae.net.ietf.url;
import ae.sys.net;
import ae.sys.net.cachedcurl;
import ae.utils.array;
import ae.utils.json;
import ae.utils.regex;

@JSONPartial
struct Product
{
	int id;
	string cpu;
	float price;
	struct ServerDiskData { int[] nvme, sata, hdd, general; }
	ServerDiskData serverDiskData;
	// ...
}

Product[] getProducts()
{
	auto url = "https://www.hetzner.com/_resources/app/jsondata/live_data_sb.json?m=%d".format(
	//	(Clock.currTime() - SysTime.fromUnixTime(0)).total!"msecs"
		0
	);

	@JSONPartial
	struct Response
	{
		Product[] server;
	}
	auto response = url.getFile
		.bytes
		.fromBytes!(char[])
		.jsonParse!Response;
	return response.server;
}
