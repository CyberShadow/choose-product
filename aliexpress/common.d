import core.thread;

import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.conv;
import std.datetime.systime;
import std.exception;
import std.range;
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
	string id;
	@property string url() { return "https://www.aliexpress.com/item//" ~ id ~ ".html"; }

	string title, description, features;

	@property string text() { return [title, description, features].join(" | "); }

	float avgScore;
	int numReviews;
}

Product[] getProducts(string query)
{
	string[] allIDs;
	for (int page = 1; ; page++)
	{
		auto pageURL =
			"https://www.aliexpress.com/wholesale?" ~
			encodeUrlParameters([
				"SearchText" : query,
				"page" : text(page),
			]);

		auto newIDs = pageURL
			.getFile
			.bytes
			.assumeUTF
			.assumeUnique
			.I!(s => new Document(s))
			.querySelectorAll("#hs-list-items a.product")
			.map!(node => node.attributes["href"].extractCapture(re!`/(\d+)\.html\?`).front)
			.array;

		if (newIDs.length == 0)
			break;

		allIDs ~= newIDs;
	}

	allIDs = allIDs.sort.uniq.array;
	Product[] products;
	foreach (id; allIDs)
	{
		Product product;
		product.id = id;

		auto productURL = product.url;
		auto doc = new Document(productURL
			.getFile
			.bytes
			.assumeUTF
			.assumeUnique
		);

		// TODO
		// product.title = doc.querySelector("#productTitle").innerText.strip;
		// product.description = doc.querySelector("#productDescription").innerText.strip;
		// product.features = doc.querySelector("#feature-bullets").innerText.strip;
		// product.avgScore = chain(
		// 	doc.querySelectorAll("#acrPopover").map!(node => node.attributes["title"].split()[0].to!float),
		// 	float.nan.only,
		// ).front;
		// product.numReviews = chain(
		// 	doc.querySelectorAll("#acrCustomerReviewText").map!(node => node.innerText.split()[0].to!int),
		// 	0.only,
		// ).front;

		products ~= product;
	}
	return products;
}
