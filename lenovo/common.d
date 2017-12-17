import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.conv;
import std.exception;
import std.range;
import std.regex;
import std.stdio;
import std.string;

import ae.net.ietf.url;
import ae.utils.regex;

import net;

struct Product
{
	string name, url;
	real price, weight, size;
	int cpuSpeed;
	string[string] specs, meta;
}

Product[] getProducts(string indexURL)
{
	string[] urls;
	for (int page = 0; ; page++)
	{
		auto pageURL = indexURL ~ "?q=%3A&page=" ~ text(page);
		auto newURLs = pageURL
			.cachedGet
			.assumeUTF
			.assumeUnique
			.extractCapture(re!`<a href="(/.*?)" class="facetedResults-cta">`)
			.map!(url => applyRelativeURL(pageURL, url))
			.array;
		if (!newURLs.length)
			break;

		newURLs.each!writeln;
		urls ~= newURLs;
	}

	urls = urls.sort.uniq.array;
	Product[] products;

	foreach (url; urls)
		try
		{
			auto html = url
				.cachedGet()
				.assumeUTF
				.assumeUnique;

			enforce(!html.canFind(`<h2 class="errorHeading">Our Apologies</h2>`), "Error page");

			Product product;
			product.url = url;
			product.name = html.extractCapture(re!`<h1 class="desktopHeader" itemprop="name">(.*?)</h1>`).front;

			product.meta = html.extractCaptures!(string, string)(re!`<meta name="(.*?)" content="(.*?)" />`)
				.assocArray;

			auto specTable = html.extractCapture(re!`<table (?:border="0" )?(?:width=".*?" height=".*?" )?class="techSpecs-table"(?: style=".*?")?><tbody>(.*?)</tbody></table>`).front;
			specTable = specTable
				.replaceAll(re!`( |&nbsp;)?<div class="tstooltip".*?</div>`, ``)
				.replaceAll(re!`<sup(?: style=".*?")?>&reg;</sup>`, ``)
				.replaceAll(re!`&reg;`, ``)
				.replaceAll(re!`\s*<\s*`, `<`) // can't use replace with capture - std.regex bug?
				.replaceAll(re!`\s*>\s*`, `>`)
				.replaceAll(re!`>(Weight \(with battery\))<`, `>Weight<`)
				.replaceAll(re!`>(WLAN|Wi[fF]i)(\s*(/|&amp;)\s*(BT|Bluetooth))?<`, `>WiFi<`)
				.replaceAll(re!`>((I/O( \(Input ?/ ?Output\))? )?Ports( &amp; Slots)?|Connectors)<`, `>Ports<`)
				.replaceAll(re!`>Dimensions( \((H x W x D|W x D x H)\))?<`, `>Dimensions<`)
				;
			product.specs = specTable
				.extractCaptures!(string, string)(re!
					`<tr(?: style=".*?")?><td(?: style=".*?")?>\s*(.*?)\s*</td>\s*<td(?: style=".*?")?>\s*(.*?)\s*</td></tr>`
				)
				.assocArray;

			product.price = chain(
				html.extractCapture(re!`<meta name="productsaleprice" content="(.*?)" />`),
				html.extractCapture(re!`<meta name="productprice" content="(.*?)" />`),
			).front.replace(",", "").to!real;

			if ("Weight" in product.specs)
			{
				scope(failure) writeln(product.specs["Weight"]);
				product.weight = product.specs["Weight"]
					.extractCapture(re!`([0-9.]+)\s*[1l]bs`)
					.front.to!real;
			}
			if ("Dimensions" in product.specs)
			{
				scope(failure) writeln(product.specs["Dimensions"]);
				auto dims = product.specs["Dimensions"]
					.replace(`&rdquo;`, `"`)
					.replaceAll(re!`([0-9.]+)-`, ``)
					.replaceAll(re!`\s*`, ``)
					.extractCapture!(real, real, real)(re!`([0-9.]+)"?x([0-9.]+)"?x([0-9.]+)"`)
					.front;
				product.size = max(dims.expand);
			}

			auto processor = product.meta["processor"];
			// auto processor = product.specs["Processor"].replace("&nbsp;", " ");
			auto cpuName = processor.extractCapture(re!`(\S*)\s+(v.\s+)?[Pp]rocessor`).front;
			// auto suggestions = ("http://cpuboss.com/cacheable/api/product-autosuggest/v2?query=" ~ encodeUrlParameter(cpuName))
			// 	.cachedGet
			// 	.assumeUTF
			// 	.assumeUnique
			// 	.parseJSON
			// 	.object["suggestions"].array;
			// if (suggestions.length > 0)
			// {
			// 	enforce(suggestions.length == 1, "Ambiguous CPU: " ~ cpuName);
			// 	auto label = suggestions[0].object["label"].str;
			// 	auto url = "http://cpuboss.com/cpu/" ~ label.replace(" ", "-");
			// 	url
			// 		.cachedGet
			// 		.assumeUTF
			// 		.assumeUnique
					
			// }
			product.cpuSpeed = getCPUSpeed(cpuName);

			products ~= product;
		}
		catch (Throwable e)
			writefln("Error with %s :\n%s", url, e);

	return products;
}

int getCPUSpeed(string cpuName)
{
	auto passmarkSearchURL = "https://www.passmark.com/search/zoomsearch.php?zoom_query=" ~ encodeUrlParameter(cpuName);

	scope(failure) writeln(passmarkSearchURL);
	auto passmarkSearchHTML = passmarkSearchURL
		.cachedGet.assumeUTF.assumeUnique;
	auto passmarkResults = passmarkSearchHTML
		.extractCapture(re!`<a href="(https://www\.cpubenchmark\.net/cpu\.php\?cpu=.*?)" >`);
	if (!passmarkResults.empty)
	{
		return passmarkResults.front
			.cachedGet.assumeUTF.assumeUnique
			.extractCapture!int(re!`Single Thread Rating: (\d+)`)
			.front;
	}

	return 0;
}
