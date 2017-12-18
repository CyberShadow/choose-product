import core.thread;

import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.conv;
import std.datetime.systime;
import std.exception;
import std.stdio : stderr;
import std.string;

import ae.net.ietf.url;
import ae.sys.net;
import ae.sys.net.cachedcurl;
import ae.utils.array;
import ae.utils.meta;
import ae.utils.regex;

import arsd.dom;

CachedCurlNetwork ccnet;

static this()
{
	ccnet = cast(CachedCurlNetwork)net;
	ccnet.cookieDir = "cookies";
	ccnet.http.verbose = true;
}

struct Product
{
	string asin;
	@property string url() { return "https://www.amazon.com/dp/" ~ asin; }

	string title, description, features;

	@property string text() { return [title, description, features].join(" | "); }
}

Product[] getProducts(string query)
{
	string[] allASINs;
	for (int page = 1; ; page++)
	{
		auto pageURL =
			"https://www.amazon.com/s?" ~
			encodeUrlParameters([
				"rh" : "k:" ~ query,
				"page" : text(page),
			]);

		auto newASINs = pageURL
			.amazonGet
			.I!(s => new Document(s))
			.querySelectorAll(".s-result-item")
			// .map!(node => node.attributes["data-asin"])
			.filter!(node => node.attributes["id"] != "s-result-list-layout-placeholder")
			.map!(node => node.attributes["data-asin"])
			.array;

		if (newASINs.length == 0)
			break;

		allASINs ~= newASINs;
	}

	allASINs = allASINs.sort.uniq.array;
	Product[] products;
	foreach (asin; allASINs)
	{
		Product product;
		product.asin = asin;

		auto productURL = product.url;
		auto doc = new Document(productURL.amazonGet);

		product.title = doc.querySelector("#productTitle").innerText.strip;
		product.description = doc.querySelector("#productDescription").innerText.strip;
		product.features = doc.querySelector("#feature-bullets").innerText.strip;

		products ~= product;
	}
	return products;
}

private string amazonGet(string url)
{
	ccnet.epoch = 0;
	string html;
	for (int tries = 0; ; tries++)
	{
		html = url
			.getFile
			.bytes
			.assumeUTF
			.assumeUnique;

		if (html.canFind("Sorry, we just need to make sure you're not a robot."))
		{
			stderr.writeln("Backing off...");
			Thread.sleep((1 << tries).seconds);
			ccnet.epoch = Clock.currTime.stdTime;
		}
		else
			return html;
	}
}
