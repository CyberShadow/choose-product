module stores.servermd;

import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.conv;
import std.exception;
import std.range;
import std.regex;
import std.stdio : stderr;
import std.string;

import ae.sys.net;
import ae.sys.net.cachedcurl;
import ae.utils.array;
import ae.utils.json;
import ae.utils.meta;

import arsd.dom;

import lib.net;

struct Product
{
	string source; // "server.md" or "myserver.md"
	string name;
	string url;
	float price; // lei
	string cpu;
	int sockets;
	int cores;
	int ram; // GB
}

Product[] getProducts()
{
	return getServerMd() ~ getMyServerMd();
}

// --- server.md ---

private Product[] getServerMd()
{
	Product[] products;

	foreach (page; 1 .. 5)
	{
		auto pageURL = page == 1
			? "https://server.md/server?limit=100"
			: "https://server.md/server?limit=100&page=" ~ page.to!string;

		scope(failure) stderr.writeln("Error with ", pageURL);

		auto doc = pageURL
			.getFileAsFirefox
			.bytes
			.assumeUTF
			.assumeUnique
			.I!(s => new Document(s));

		auto items = doc.querySelectorAll(".product-layout");
		if (items.length == 0)
			break;

		foreach (item; items)
		{
			Product p;
			p.source = "server.md";

			auto nameLink = item.querySelector(".us-module-title a");
			if (!nameLink)
				continue;
			p.name = nameLink.innerText.strip;
			p.url = nameLink.attributes["href"];

			auto priceEl = item.querySelector(".us-module-price-new");
			if (!priceEl)
				priceEl = item.querySelector(".us-module-price-actual");
			if (!priceEl)
				continue;
			p.price = parsePriceLei(priceEl.innerText);
			if (p.price == 0)
				continue;

			auto attrs = item.querySelectorAll(".us-category-attr-item");
			foreach (attr; attrs)
			{
				auto spans = attr.querySelectorAll("span");
				if (spans.length < 2)
					continue;
				auto label = spans[0].innerText.strip.chomp(":");
				auto value = spans[1].innerText.strip;
				switch (label)
				{
					case "Model procesor":
						p.cpu = value;
						break;
					case "Numărul de socluri":
						p.sockets = value.toInt;
						break;
					case "Numărul nuclee":
						p.cores = value.toInt;
						break;
					case "Memorie RAM instalată":
						p.ram = value.extractRamGB;
						break;
					default:
				}
			}

			if (p.cpu.length == 0)
				continue;
			p.cpu = normalizeCPU(p.cpu);
			if (p.sockets == 0)
				p.sockets = 1;

			products ~= p;
		}
	}

	return products;
}

// --- myserver.md ---

private Product[] getMyServerMd()
{
	Product[] products;

	static immutable categories = [
		"servere-hp-proliant-refurb-moldova",
		"servere-dell-poweredge-refurb-moldova",
	];

	foreach (cat; categories)
	{
		auto pageURL = "https://myserver.md/categorie/" ~ cat;
		scope(failure) stderr.writeln("Error with ", pageURL);

		auto html = pageURL
			.getFileAsFirefox
			.bytes
			.assumeUTF
			.assumeUnique;

		auto jsonStart = html.indexOf("var products = [");
		if (jsonStart < 0)
			continue;
		jsonStart += "var products = ".length;
		auto jsonEnd = html[jsonStart .. $].indexOf("];\n");
		if (jsonEnd < 0)
			jsonEnd = html[jsonStart .. $].indexOf("];");
		if (jsonEnd < 0)
			continue;
		auto jsonStr = html[jsonStart .. jsonStart + jsonEnd + 1];

		@JSONPartial
		struct RawProduct
		{
			string product_name;
			float product_price;
			int product_stock;
			string product_specifications;
			string product_slug;
		}

		RawProduct[] raw;
		try
			raw = jsonStr.jsonParse!(RawProduct[]);
		catch (Exception e)
		{
			stderr.writeln("JSON parse error: ", e.msg);
			continue;
		}

		foreach (ref r; raw)
		{
			Product p;
			p.source = "myserver.md";
			p.name = r.product_name;
			p.url = "https://myserver.md/produs/" ~ r.product_slug;
			p.price = r.product_price;

			auto specs = r.product_specifications;
			auto specRegex = regex(`<th>(.*?)</th>\s*<td>(.*?)</td>`);
			foreach (m; specs.matchAll(specRegex))
			{
				auto label = m[1].decodeHTML.strip;
				auto value = m[2].decodeHTML.strip;
				if (label == "Procesor")
					p.cpu = normalizeCPU(value);
				else if (label == "Procesoare instalate")
				{
					try p.sockets = value.to!int; catch (Exception) {}
				}
				else if (label == "Nuclee per procesor")
				{
					try p.cores = value.to!int; catch (Exception) {}
				}
				else if (label.startsWith("Memorie RAM"))
					p.ram = extractRamGB(value);
			}

			if (p.cpu.length == 0)
				continue;
			if (p.sockets == 0)
				p.sockets = 1;

			products ~= p;
		}
	}

	return products;
}

// --- shared helpers ---

private:

string normalizeCPU(string name)
{
	// Clean up HTML entities and registered marks
	name = name
		.replace("®", "")
		.replace("&reg;", "")
		.replace("Processor ", "")
		.strip;

	while (name.canFind("  "))
		name = name.replace("  ", " ");

	// "Intel Gold 6136" -> "Intel Xeon Gold 6136"
	if (name.startsWith("Intel Gold") || name.startsWith("Intel Silver"))
		name = "Intel Xeon " ~ name["Intel ".length .. $];
	// "Xeon ..." -> "Intel Xeon ..."
	else if (name.startsWith("Xeon"))
		name = "Intel " ~ name;

	// Manual fixups for names that don't match cpubenchmark
	switch (name)
	{
		case "AMD Turion II Neo N40L":
			return "AMD Turion II Neo N40L Dual-Core";
		case "AMD Opteron X3418":
			return "AMD Opteron X3418 APU";
		default:
	}

	// Normalize version suffixes to match sources.cpubenchmark format.
	// sources.cpubenchmark's getCPU does .replace(" V", "V") on the cpubenchmark side,
	// so input must also have no space before V:
	// "E5-2680 v3" -> "E5-2680V3", "E5-2697A v4" -> "E5-2697AV4"
	name = name.replace(" v", "V").replace(" V", "V");

	return name;
}

float parsePriceLei(string text)
{
	// "5 300,00 lei" or "39 200,00 lei"
	string digits;
	foreach (c; text)
	{
		if (c >= '0' && c <= '9')
			digits ~= c;
		else if (c == ',')
			digits ~= '.';
	}
	if (digits.length == 0)
		return 0;
	try
		return digits.to!float;
	catch (Exception)
		return 0;
}

string decodeHTML(string s)
{
	return s
		.replace("&reg;", "")
		.replace("&amp;", "&")
		.replace("&lt;", "<")
		.replace("&gt;", ">")
		.replace("&nbsp;", " ")
		.replace("®", "")
		.strip;
}

int toInt(string s)
{
	try
		return s.to!int;
	catch (Exception)
		return 0;
}

int extractRamGB(string s)
{
	string digits;
	foreach (c; s)
	{
		if (c >= '0' && c <= '9')
			digits ~= c;
		else
			break;
	}
	if (digits.length == 0)
		return 0;
	try
		return digits.to!int;
	catch (Exception)
		return 0;
}
