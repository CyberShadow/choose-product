import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.conv;
import std.datetime.systime;
import std.exception;
import std.range;
import std.regex;
import std.stdio;
import std.string;

import ae.net.ietf.url;
import ae.sys.net;
import ae.sys.net.cachedcurl;
import ae.utils.array;
import ae.utils.json;
import ae.utils.regex;

struct CPU
{
	string name;
	int mark;
	int rank;
	// float value;
	// float price;
}

final class CPUSpeed
{
	CPU[] cpus;

	this()
	{
		"https://www.cpubenchmark.net/cpu_list.php"
			.getFile
			.bytes
			.assumeUTF
			.assumeUnique
			.matchAllCaptures(re!`<tr id="cpu.*"><td><a href="cpu_lookup\.php\?cpu=.*">(.*)</a></td><td>(.*)</td><td>(.*)</td><td class="vLink">.*</td><td class="pLink">.*</td></tr>`,
				(string name, string markStr, string rankStr)
				{
					cpus ~= CPU(
						name,
						markStr.replace(",", "").to!int,
						rankStr.replace(",", "").to!int,
					);
				});
	}

	/*ref*/ CPU getCPU(string name)
	{
		switch (name)
		{
			case "Intel Core i7-3930":
				name = "Intel Core i7-3930K";
				break;
			case "AMD Opteron 6338P":
				return CPU.init; // not in cpubenchmarks.net database
			default:
		}

		auto cname0 = name.toUpper.strip;
		foreach (ref cpu; cpus)
		{
			auto cname1 = cpu.name
				.toUpper
				.findSplit(" @ ")[0]
				.replace(" V", "V");
			if (cname0 == cname1)
				return cpu;
		}
		throw new Exception("Unknown CPU: %(%s%)".format([name]));
	}
}
