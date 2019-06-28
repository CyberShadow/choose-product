import ae.utils.aa;

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.array;
import std.stdio;
import std.string;

import sammobile;

void main()
{
	//enum productName = "Galaxy Note 4";
	static immutable string[] modelNames = [
		"SM-N910A",
		"SM-N910F",
		"SM-N910G",
		"SM-N910H",
		"SM-N910P",
		"SM-N910R4",
		"SM-N910V",
		"SM-N910T",
		"SM-N910T3",
		"SM-N910V",
		"SM-N910W8",
		"SM-N915F",
		"SM-N915G",
		"SM-N915P",
		"SM-N915R4",
		"SM-N915T",
		"SM-N915W8",
	];

	auto data = modelNames.map!(modelName => getProduct(/*productName, */modelName)).array;

	alias MSS = OrderedMap!(string, string);
	alias MSMS = OrderedMap!(string, MSS);
	MSMS[] specs;
	specs.length = data.length;
	foreach (i, datum; data)
		foreach (cat; datum.categories)
			foreach (spec; cat.specs)
			{
				if (cat.name !in specs[i])
					specs[i][cat.name] = MSS.init; // TODO
				if ((cat.name ~ " - " ~ spec.name).among(
						"General Information - Color",
						"Audio and Video - Video Playing Format",
						"Network/Bearer - Network",
						"Network/Bearer - 2G GSM",
						"Network/Bearer - 3G UMTS",
						"Network/Bearer - 4G LTE",
					))
				{
					foreach (item; spec.value.split(","))
						specs[i][cat.name][spec.name ~ " - " ~ item.strip] = "Y";
				}
				else
					specs[i][cat.name][spec.name] = spec.value;
			}

	OrderedMap!(string, OrderedSet!string) allProps;
	foreach (spec; specs)
		foreach (catName, catProps; spec)
		{
			if (catName !in allProps)
				allProps[catName] = OrderedSet!string.init; // TODO
			foreach (specName, value; catProps)
				allProps[catName].add(specName);
		}

	bool[string][string] differentProps;
	foreach (catName, catProps; allProps)
		foreach (propName; catProps)
			foreach (spec; specs)
				if (spec    .get(catName, MSS.init).get(propName, null) !=
					specs[0].get(catName, MSS.init).get(propName, null))
					differentProps[catName][propName] = true;

	// foreach (datum; data[1..$])
	// 	foreach (cat; datum.categories)
	// 		foreach (spec; cat.specs)
	// 			allProps[cat.name][spec.name] = true;

	// same values:
	// foreach (catName, catProps; allProps)
	// 	foreach (propName, b; catProps)
	// 		if (!differentProps.get(catName, null).get(propName, false))
	// 			writeln(catName, " - ", propName);

	writefln("| Property | %-(%s | %|%)", modelNames);
	foreach (catName, catProps; allProps)
		foreach (propName; catProps)
			if (differentProps.get(catName, null).get(propName, false))
			{
				writeln("|-");
				write("| ", catName, " - ", propName, " | ");
				foreach (i, spec; specs)
					write(spec.get(catName, MSS.init).get(propName, "-"), " | ");
				writeln;
			}
	
	// writeln(differentProps);
}
