import std.stdio;

import common;

void main(string[] args)
{
	foreach (arg; args[1..$])
		writefln("%s\t%s", arg, getCPUSpeed(arg));
}
