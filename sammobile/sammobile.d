import std.exception;
import std.regex;
import std.string;

import arsd.dom;

import ae.sys.net;
import ae.sys.net.cachedcurl;
import ae.utils.array;
import ae.utils.meta;

CachedCurlNetwork ccnet;

static this()
{
	ccnet = cast(CachedCurlNetwork)net;
	ccnet.cookieDir = "cookies";
	ccnet.http.verbose = true;
}

struct Product
{
	struct SpecCategory
	{
		string name;
		struct Spec
		{
			string name;
			string value;
		}
		Spec[] specs;
	}
	SpecCategory[] categories;
}

Product getProduct(/*string name, */string model)
{
	auto pageURL = "https://www.sammobile.com/samsung/%s/specs/%s/"
		.format(
			"x", //name.toLower.replaceAll(regex(`[^a-z0-9]+`), "-"),
			model
		);

	auto doc = pageURL
		.getFile
		.bytes
		.assumeUTF
		.assumeUnique
		.I!(s => new Document(s));

	Product product;
	foreach (row; doc.querySelectorAll("div.spec-detail-table > div.container > div.row"))
	{
		if (row.attributes["class"].contains("spec-row-header"))
			continue;
		else
		if (row.attributes["class"].contains("spec-row-group-header"))
			product.categories ~= Product.SpecCategory(row.innerText.strip);
		else
		{
			Product.SpecCategory.Spec spec;
			spec.name = row.querySelector("div.spec-col-header").innerText.strip;
			spec.value = row.querySelector("div.spec-col-content").innerText.strip;
			product.categories[$-1].specs ~= spec;
		}
	}

	return product;
}
