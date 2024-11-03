#!/usr/bin/python3

import sys

# this program can be used both as reducer and as a combiner
def main(argv):
    with open("test_map_output") as f:
        line = f.readline()
        current_person_id = None
        directed = 0
        acted = 0

        try:
            while line:
                fields = line.split("\t") # int() skips newline - cutting unnecessary
                person_id = fields[0] # field 0 is person id
                if person_id == current_person_id: # if it's still the same person being processed
                    acted += int(fields[1]) # field 1 is movies starred in count
                    directed += int(fields[2]) # field 2 is movies directed count
                else: # if person changed
                    if current_person_id: # don't print empty person
                        print(f"{current_person_id}\t{acted}\t{directed}") # print prev. person

                    acted = int(fields[1])
                    directed = int(fields[2])
                    current_person_id = person_id
                
                line = f.readline()
        except "end of file":
            if current_person_id: # don't print empty person
                print(f"{current_person_id}\t{acted}\t{directed}") # print prev. person
            return None

if __name__ == "__main__":
     main(sys.argv)