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
				float score = 0;
				score += cpu.mark * 1.0;
				auto totalNVME = server.serverDiskData.nvme.sum;
				if (totalNVME < 430)
					score -= 100000;
				auto totalStorage = chain(server.serverDiskData.nvme, server.serverDiskData.sata, server.serverDiskData.hdd).sum;
				if (totalStorage < 8000)
					score -= 100000;
				score += totalNVME * 0.2;
				score += totalStorage * 0.1;
				score /= server.price;
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
