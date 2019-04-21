import std.algorithm.comparison;
import std.algorithm.iteration;
import std.array;
import std.conv;
import std.stdio;
import std.string;

import common;

void main()
{
	auto urls = getCategory("appliances/home_appliances/freezing_chambers");
	auto products = urls.map!getProduct.array;

	foreach (product; products)
	{
		auto minDim = ["Высота", "Ширина", "Глубина"]
			.map!(dimension => product.props[dimension])
			.map!(dimStr => dimStr.chomp(" см").to!real)
			.reduce!min;
		if (minDim > 53)
			continue;
		writeln(product.url, " - ", product.name);
	}
}
