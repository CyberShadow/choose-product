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
	int ram_size;
	float price;
	struct ServerDiskData { int[] nvme, sata, hdd, general; }
	ServerDiskData serverDiskData;
	string datacenter;
	// ...
}

Product[] getProducts()
{
	auto url = "https://www.hetzner.com/_resources/app/data/app/live_data_sb_EUR.json";

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
