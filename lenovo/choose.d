import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.stdio;

import ae.utils.regex;

import common;

version = maria;

void main()
{
	auto allProducts = getProducts("https://www3.lenovo.com/us/en/laptops/c/LAPTOPS");

	int[string] allSpecs;
	foreach (product; allProducts)
		foreach (name, value; product.specs)
			allSpecs[name]++;
	writeln("All specs:");
	foreach (name; allSpecs.keys.sort)
		writefln("\t%-30s: %3d/%3d", name, allSpecs[name], allProducts.length);
	writeln();

	int[string] allCPUs;
	foreach (product; allProducts)
			allCPUs[product.meta["processor"]]++;
	writeln("All CPUs:");
	foreach (name; allCPUs.keys.sort)
		writefln("\t%-10s\t%-30s: %3d/%3d",
			name.extractCapture(re!`(\S*)\s+(v.\s+)?[Pp]rocessor`).front,
			name, allCPUs[name], allProducts.length);
	writeln();

	auto products = allProducts.filter!(
		(Product product)
		{
			scope(failure) writeln(product.url);

			bool nope(string why) { writefln("Filtering out %s because %s", product.name, why); return false; }

			version (maria)
			{
				if (product.price >= 380)
					return nope("it is too expensive");
				if (product.specs.get("Memory", "").canFind("2GB"))
					return nope("it has only 2GB of RAM");
				if (product.size < 13)
					return nope("it is too small");
			}
			else
			{
				if (product.weight > 5)
					return nope("it is too heavy");
				if (product.size < 13)
					return nope("it is too small");
				if (product.size > 16)
					return nope("it is too big"); // technically redundant because they will also be heavy
				if (product.specs.get("Graphics", "").canFind("Quadro"))
					return nope("it has a Quadro GPU");
				// if (!product.meta["processor"].match(re!`-[78]`))
				// 	return nope("its CPU is not last generation");
			}
			return true;
		})
		.array;

	version (maria)
		products.sort!((a, b) => a.price < b.price);
	else
		products.multiSort!(
			(a, b) => a.cpuSpeed > b.cpuSpeed,
			(a, b) => a.price < b.price,
		);

	foreach_reverse (product; products)
	{
		writefln("%s - $%1.2f - %s", product.name, product.price, product.url);
		foreach (name; product.specs.keys.sort)
			writefln("\t%-30s: %s", name, product.specs[name]);
		writefln("\t%-30s: %s (%d points)", "CPU", product.meta["processor"], product.cpuSpeed);
		writeln();
	}

	writefln("Filtered %d out of %d products.", products.length, allProducts.length);
}
