module stores.lenovo.print_cpuspeed;

import std.stdio;

import stores.lenovo;

void main(string[] args)
{
	foreach (arg; args[1..$])
		writefln("%s\t%s", arg, getCPUSpeed(arg));
}
