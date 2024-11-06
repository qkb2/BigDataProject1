#!/usr/bin/env python3

import sys


# this program should be used as a mapper
def main(argv):
    for line in sys.stdin:
        directed = 0
        acted = 0

        fields = line.split("\t")  # last field not used - cutting newline unecessary
        person_id = fields[2]
        role = fields[3]

        if role == "director":
            directed = 1
        if role == "actor" or role == "actress" or role == "self":
            acted = 1

        print(
            f"{person_id}\t{acted},{directed}"
        )  # newline is implicitly added by print


if __name__ == "__main__":
    main(sys.argv)
