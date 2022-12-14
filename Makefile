CC = swiftc

ppidump: main.swift
	$(CC) -o $@ $^
clean:
	rm -rf ./ppidump *.o
