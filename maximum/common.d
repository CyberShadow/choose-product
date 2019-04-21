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
	@property string url() { return "https://maximum.md/ro/" ~ id ~ "/"; }

	string name;
	string[string] props;
}

Product getProduct(string id)
{
	Product product;
	product.id = id;
	auto pageURL = product.url;
	scope(failure) stderr.writeln("Error with ", pageURL);
	auto doc = pageURL
		.getFile
		.bytes
		.assumeUTF
		.assumeUnique
		.I!(s => new Document(s));

	product.name = doc.querySelector(".product-view__title").enforce.innerText.strip;

	auto desc = doc.querySelector(".product-view-description");
	if (desc)
	{
		string s;
		foreach (Element b; desc.children)
		{
			if (b.nodeType == NodeType.Text)
				s = b.nodeValue.strip.strip("▪").strip;
			else
			if (b.tagName == "b")
				product.props[s] = b.innerText;
		}
		enforce(product.props.length);
	}

	return product;
}
