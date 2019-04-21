import std.algorithm.iteration;
import std.algorithm.sorting;
import std.array;
import std.file;
import std.stdio;
import std.string;

import common;

void main()
{
	Product[] products = readText("urls.txt")
		.splitLines
		.map!(line => line.split("/")[$-1])
		.map!getProduct
		.array;

	bool[string] allProps;
	foreach (ref p; products)
		foreach (k, v; p.props)
			allProps[k] = true;

	auto f = File("results.org", "wb");

	f.write("| Name | URL");
	foreach (k; allProps.keys.sort)
		f.write(" | ", k);
	f.writeln;
	f.writeln("|----------------------------");

	foreach (ref p; products.sort!((a, b) => a.id < b.id))
	{
		f.write("| ", p.name, " | ", p.url);
		foreach (k; allProps.keys.sort)
			f.write(" | ", k in p.props ? p.props[k] : "-");
		f.writeln;
	}
}
