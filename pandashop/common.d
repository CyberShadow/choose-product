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
import std.typecons;

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

string[] getCategory(string path) // e.g. "appliances/home_appliances/freezing_chambers"
{
	auto pageURL = "https://www.pandashop.md/ru/catalog/" ~ path ~ "/default.aspx?sort_=ByView_Descending&all=1";

	auto doc = pageURL
		.getFile
		.bytes
		.assumeUTF
		.assumeUnique
		.I!(s => new Document(s));

	return doc
		.querySelectorAll("div.catalog_item div.details div.catalog_name a")
		.map!(node => node.attributes["href"])
		.map!(url => applyRelativeURL(pageURL, url))
		.array;
}

struct Product
{
	string url;
	string name;
	string[string] props;
}

Product getProduct(string url)
{
	Product product;
	product.url = url;
	auto pageURL = product.url;
	scope(failure) stderr.writeln("Error with ", pageURL);
	auto doc = pageURL
		.getFile
		.bytes
		.assumeUTF
		.assumeUnique
		.I!(s => new Document(s));

	product.name = doc
		.querySelector(".oneProductHead h1")
		.enforce
		.innerText
		.strip;

	product.props = doc
		.querySelectorAll(".addDivCharacteristic tr")
		.map!(n =>
			tuple(
				n.querySelector("span.parametr").enforce.innerText.strip,
				n.querySelector("span.value").enforce.innerText.strip,
			)
		)
		.assocArray;

	return product;
}
