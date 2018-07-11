import os
import sys
import shutil
import random
import os.path
from subprocess import call
from itertools import cycle

from xlsxparser import students

# Target folders
BASE_PATH = "../tasks/"
PDF_PATH = BASE_PATH + "pdf/"

# The available seat numbers per room
r201 = ('1-a', '1-b', '1-c', '1-d', '1-e', '1-f',
        '3-a', '3-b', '3-c', '3-d', '3-e', '3-f',
        '5-a', '5-b', '5-c', '5-d', '5-e', '5-f',
        '7-a', '7-b', '7-c', '7-d', '7-e', '7-f',
        '9-a', '9-b', '9-c', '9-d', '9-e', '9-f',
        '11-a', '11-b', '11-c', '11-d', '11-e', '11-f',
        '13-a', '13-b', '13-c', '13-d', '13-e', '13-f',
        '15-a', '15-b', '15-c', '15-d', '15-e', '15-f',
        '17-a', '17-b', '17-c', '17-d', '17-e', '17-f')

r316 = ('1-a', '1-b', '1-c', '1-d', '1-e', '1-f', '1-g', '1-h',
        '3-a', '3-b', '3-c', '3-d', '3-e', '3-f', '3-g', '3-h', '3-i',
        '5-a', '5-b', '5-c', '5-d', '5-e', '5-f', '5-g', '5-h', '5-i', '5-j',
        '7-a', '7-b', '7-c', '7-d', '7-e', '7-f', '7-g', '7-h', '7-i', '7-j', '7-k',
        '9-a', '9-b', '9-c', '9-d', '9-e', '9-f', '9-g', '9-h', '9-i', '9-j', '9-k',
        '11-a', '11-b', '11-c', '11-d', '11-e', '11-f', '11-g', '11-h', '11-i', '11-j')

r305 = ('1-a', '1-b', '1-c', '1-d', '1-e', '1-f',
        '3-a', '3-b', '3-c', '3-d', '3-e', '3-f',
        '5-a', '5-b', '5-c', '5-d', '5-e', '5-f',
        '7-b', '7-c', '7-d', '7-e')

# The available rooms
avail_seats = {'201': r201, '316': r316, '305': r305}

########################################################################################
def genexam(firstname, lastname, studentid, room, seat):
    '''
            Generates an exam for the given student, if not existing.
            Target file is stored in "folder", with the student ID as file name.
    '''
    # safeguard for broken XLSX reading
    if not lastname or not firstname or not studentid or not room or not seat:
        return
    targetfile = PDF_PATH + studentid + '.pdf'
    if os.path.isfile(targetfile):
        print("Skipping generation of %s, because it exists ..." % targetfile)
        return
    else:
        print("Generating " + targetfile)

    call('latexmk -C', shell=True, cwd=BASE_PATH)
    # multiple runs needed by exam class
    cmdline = 'lualatex "\def\studentid{{{0}}}\def\studentname{{{1} {2}}}\def\proom{{{3}}}\def\place{{{4}}}\input{{exam.tex}}"'.format(
        studentid, firstname, lastname, room, seat)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    shutil.move(BASE_PATH + 'exam.pdf', targetfile)


def next_seat_gen(rooms):
    # Generate seat iterators
    seat_it = {room: iter(avail_seats[room]) for room in rooms}

    # Cycle through rooms and fetch new seat per room
    for room in cycle(rooms):
        seat = next(seat_it[room], None)
        if seat is None:   # room is full, remove from list
            rooms = [r for r in rooms if r != room]
            continue
        yield (room, seat)

    raise RuntimeError("Error: Not enough seats available.")


# Parse command-line arguments
if len(sys.argv) < 3:
    print("ERROR: Not enough arguments.")
    print("generate_plans.py <xlsx file> <room1,room2,...>")
    print("Check also the Makefile.")
    exit(-1)
xlsx_file = sys.argv[1]
room_list = sys.argv[2].split(',')

# Check room list
capacity = 0
for room in room_list:
    if room not in avail_seats.keys():
        print("ERROR: Room %s is not supported, please adjust generate_plans.py accordingly." % room)
        exit(-1)
    capacity += len(avail_seats[room])

# Fetch all students from XLSX, so that we can sort them
all_students = []
for first_name, last_name, student_id in students(xlsx_file):
    all_students.append(
        {'student_id': student_id, 'first_name': first_name, 'last_name': last_name})
all_students = sorted(all_students, key=lambda d: d['student_id'])

if len(all_students) > capacity:
    print("ERROR: The rooms only offer {0} seats, but we have {1} students.".format(
        capacity, len(all_students)))
    exit(-1)

# Lists with student names are generated per room
# Used for entry check in the room
withname = {}
for room in room_list:
    withname[room] = open(BASE_PATH + 'table_withname_{0}.tex'.format(room), 'w')
    withname[room].write("% Generated, do not edit.\n\n")

# Assign places to students
seats = next_seat_gen(room_list)
for stud in all_students:
    stud['room'], stud['seat'] = next(seats)
    print(stud)
    genexam(stud['first_name'], stud['last_name'], stud['student_id'], stud['room'], stud['seat'])
    withname[stud['room']].write(
        "{student_id} & {first_name} & {last_name} & {room} & {seat} \\\\\n".format(**stud))

for f in withname.values():
    f.close()

# Generate target folder, in case it does not exist
try:
    os.mkdir(PDF_PATH)
except Exception:
    pass

# Note: shutil.move() does not work when the target exists

for room in room_list:
    # The template TEX file always includes 'table_withname.tex'
    include_file = BASE_PATH + 'table_withname_{0}.tex'.format(room)
    os.rename(include_file, BASE_PATH + 'table_withname.tex')
    cmdline = 'lualatex ../lib/plan_withname.tex'
    call(cmdline, shell=True, cwd=BASE_PATH)
    shutil.copyfile(BASE_PATH + 'plan_withname.pdf',
                    PDF_PATH + 'plan_withname_{0}.pdf'.format(room))
    os.remove(BASE_PATH + 'plan_withname.pdf')

# Also generate a blank one. LaTex needs some content, so we use gibberish white space.
genexam('~', '~', '~', '~', '~')
