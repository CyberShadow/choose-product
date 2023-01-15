import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.range;
import std.stdio;

import ae.utils.regex;

import hetzner;
import cpuspeed;

version = maria;

void main()
{
	auto servers = getProducts();
	auto cpus = new CPUSpeed();

	auto scores = servers.length
		.iota
		.map!((idx)
			{
				auto server = servers[idx];
				auto cpu = cpus.getCPU(server.cpu);
				auto score = float(cpu.mark) / server.price;
				return score;
			}
		)
		.array;

	auto order = servers.length.iota.array;
	order = order
		.filter!(idx => servers[idx].price <= 40)
		.array
		.sort!((a, b) => scores[a] > scores[b])
		.release;
	writefln("Filtered out %d candidates.", order.length);

	foreach (idx; order[0 .. 10])
		writefln("#%d\t%d\t%s\t%s\t%s", 1 + idx, servers[idx].id, servers[idx].price, cpus.getCPU(servers[idx].cpu).mark, scores[idx]);
}
