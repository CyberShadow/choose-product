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

	string[string][string][] specs;
	specs.length = data.length;
	foreach (i, datum; data)
		foreach (cat; datum.categories)
			foreach (spec; cat.specs)
			{
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

	bool[string][string] allProps;
	foreach (spec; specs)
		foreach (catName, catProps; spec)
			foreach (specName, value; catProps)
				allProps[catName][specName] = true;

	bool[string][string] differentProps;
	foreach (catName, catProps; allProps)
		foreach (propName, b; catProps)
			foreach (spec; specs)
				if (spec    .get(catName, null).get(propName, null) !=
					specs[0].get(catName, null).get(propName, null))
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
		foreach (propName, b; catProps)
			if (differentProps.get(catName, null).get(propName, false))
			{
				writeln("|-");
				write("| ", catName, " - ", propName, " | ");
				foreach (i, spec; specs)
					write(spec.get(catName, null).get(propName, "-"), " | ");
				writeln;
			}
	
	// writeln(differentProps);
}
