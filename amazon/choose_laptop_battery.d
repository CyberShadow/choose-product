import std.algorithm.iteration;
import std.array;
import std.regex;
import std.stdio;
import std.string;

import ae.utils.regex;

import common;

void main()
{
	auto allProducts = getProducts("vgp-bps24");

	auto products = allProducts.filter!(
		(Product product)
		{
			scope(failure) writeln(product.url);

			string s = product.text;

			bool nope(string why) { writefln("Filtering out %s because %s", product.title, why); return false; }

			if (s.toLower.match(re!`4[24]00\s*mah`))
				return nope("it has too few mAh");

			// if (product.numReviews < 3)
			// 	return nope("it has too few reviews");

			// if (product.avgScore < 4)
			// 	return nope("it has poor reviews");

			if (!s.toLower.match(re!`mah\b`))
				return nope("it doesn't mention how many mAh it has");

			return true;
		})
		.array;
	writeln();

	foreach_reverse (product; products)
	{
		writefln("%s - %3.1f (%d) - %s", product.url, product.avgScore, product.numReviews, product.title);
		writeln();
	}

	writefln("Filtered %d out of %d products.", products.length, allProducts.length);
}
