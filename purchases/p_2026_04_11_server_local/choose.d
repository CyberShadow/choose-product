import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.array;
import std.conv : to;
import std.range;
import std.stdio;

import stores.servermd;
import sources.cpubenchmark;

void main()
{
	auto servers = getProducts();
	auto cpus = new CPUSpeed();

	auto scores = servers.length
		.iota
		.map!((idx)
			{
				auto server = servers[idx];
				CPU cpu;
				try
					cpu = cpus.getCPU(server.cpu);
				catch (Exception)
					return -1.0f;
				auto totalMark = float(cpu.mark) * server.sockets;
				return totalMark / server.price;
			}
		)
		.array;

	auto order = servers.length.iota.array;
	order = order
		.filter!(idx => scores[idx] >= 0)
		.array
		.sort!((a, b) => scores[a] > scores[b])
		.release;
	writefln("Found %d servers (%d with known CPUs).", servers.length, order.length);

	writeln("Rank\tSource\t\tPrice\tCPU\t\t\t\tSock\tMark\tTotalMark\tScore\tName");
	foreach (i, idx; order)
	{
		auto server = servers[idx];
		auto cpu = cpus.getCPU(server.cpu);
		auto totalMark = cpu.mark * server.sockets;
		writefln("#%d\t%-11s\t%s\t%-30s\t%d\t%d\t%d\t\t%.2f\t%s",
			i + 1,
			server.source,
			server.price,
			server.cpu,
			server.sockets,
			cpu.mark,
			totalMark,
			scores[idx],
			server.name,
		);
	}
}
