#!/usr/bin/env python3

import sys


# this program can be used both as reducer and as a combiner
def main(argv):
    current_person_id = None
    directed = 0
    acted = 0

    for line in sys.stdin:
        fields = line.split("\t")  # int() skips newline - cutting unnecessary
        person_id = fields[0]  # field 0 is person id
        value_fields = fields[1].split(",")  # field 1 is values split on comma

        if (
            person_id == current_person_id
        ):  # if it's still the same person being processed
            acted += int(value_fields[0])  # subfield 1 is movies starred in count
            directed += int(value_fields[1])  # subfield 2 is movies directed count

        else:  # if person changed
            if current_person_id:  # don't print empty person
                print(f"{current_person_id}\t{acted},{directed}")  # print prev. person

            acted = int(value_fields[0])
            directed = int(value_fields[1])
            current_person_id = person_id

    if current_person_id:  # don't print empty person
        print(f"{current_person_id}\t{acted},{directed}")  # print prev. person


if __name__ == "__main__":
    main(sys.argv)
