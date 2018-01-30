import os
import sys
import shutil
from itertools import chain
from subprocess import call

from xlsxparser import students

# Target folders
BASE_PATH = "../tasks/"
PDF_PATH = BASE_PATH + "pdf/"

# The available seat numbers per room
n012 = sorted(chain(range(18, 1, -2), range(58, 39, -2), range(98, 79, -2), range(138, 119, -2),
              range(178, 159, -2), range(218, 199, -2), range(258, 239, -2)))

n111 = sorted(chain(range(16, 1, -2), range(48, 33, -2), range(80, 65, -2), range(112, 97, -2)))

n115 = sorted(chain(range(26, 1, -2), range(94, 61, -2), range(162, 129, -2), range(230, 197, -2),
              range(298, 265, -2), range(366, 333, -2), range(434, 401, -2), range(502, 469, -2),
              range(570, 537, -2), range(638, 605, -2), range(706, 673, -2)))

r305 = sorted(chain(range(16, 1, -2), range(48, 33, -2), range(80, 65, -2), range(112, 97, -2)))

# The available rooms
avail_rooms = {'N012': n012, 'N111': n111, 'N115': n115, '305': r305}

########################################################################################


def next_seat_gen(rooms):
    for room in rooms:
        print("Starting to fill room " + room)
        seats = avail_rooms[room]
        for seat in seats:
            yield (room, seat)
    raise RuntimeError("Error: Not enough seats available.")


# Parse command-line arguments
xlsx_file = sys.argv[1]
room_list = sys.argv[2].split(',')

# Check room list
for room in room_list:
    if room not in avail_rooms.keys():
        print("ERROR: Room %s is not supported, please adjust generate_plans.py accordingly." % room)
        exit(-1)

# Fetch all students from XLSX, so that we can sort them
all_students = []
for first_name, last_name, student_id in students(xlsx_file):
    all_students.append({'student_id': student_id, 'first_name': first_name, 'last_name': last_name})
all_students = sorted(all_students, key=lambda d: d['student_id'])

withname = open(BASE_PATH + 'table_withname.tex', 'w')
withoutname = open(BASE_PATH + 'table_withoutname.tex', 'w')

withname.write("% Generated, do not edit.\n\n")
withoutname.write("% Generated, do not edit.\n\n")

seats = next_seat_gen(room_list)
for stud in all_students:
    stud['room'], stud['seat'] = next(seats)
    print(stud)
    withname.write("{student_id} & {first_name} & {last_name} & {room} & {seat} \\\\\n".format(**stud))
    withoutname.write("{student_id} & {room} & {seat} \\\\\n".format(**stud))

withname.close()
withoutname.close()

# Generate target folder, in case it does not exist
try:
    os.mkdir(PDF_PATH)
except Exception:
    pass

# Note: shutil.move() does not work when the target exists

cmdline = 'lualatex ../lib/plan_withname.tex'
call(cmdline, shell=True, cwd=BASE_PATH)
shutil.copyfile(BASE_PATH + 'plan_withname.pdf', PDF_PATH + 'plan_withname.pdf')
os.remove(BASE_PATH + 'plan_withname.pdf')

cmdline = 'lualatex ../lib/plan_withoutname.tex'
call(cmdline, shell=True, cwd=BASE_PATH)
shutil.copyfile(BASE_PATH + 'plan_withoutname.pdf', PDF_PATH + 'plan_withoutname.pdf')
os.remove(BASE_PATH + 'plan_withoutname.pdf')
