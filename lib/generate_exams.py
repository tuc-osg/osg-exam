import os
import sys
import shutil
import os.path
from subprocess import call

from xlsxparser import students

# Target folder for exam PDF files.
BASE_PATH = "../tasks/"
PDF_PATH = BASE_PATH + "pdf/"


def genexam(firstname, lastname, studentid):
    '''
            Generates an exam for the given student, if not existing.
            Target file is stored in "folder", with the student ID as file name.
    '''
    # safeguard for broken XLSX reading
    if not lastname or not firstname or not studentid:
        return
    targetfile = PDF_PATH + studentid + '.pdf'
    if os.path.isfile(targetfile):
        print("Skipping generation of %s, because it exists ..." % targetfile)
        return
    else:
        print("Generating " + targetfile)

    call('latexmk -C', shell=True, cwd=BASE_PATH)
    # double run needed by exam class
    cmdline = 'lualatex "\def\studentid{{{0}}}\def\studentname{{{1} {2}}}\input{{exam.tex}}"'.format(
        studentid, firstname, lastname)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    shutil.move(BASE_PATH + 'exam.pdf', targetfile)


# Generate target folder, in case it does not exist
try:
    os.mkdir(PDF_PATH)
except Exception:
    pass

for first_name, last_name, student_id in students(sys.argv[1]):
    genexam(first_name, last_name, student_id)

# Also generate a blank one. LaTex needs some content, so we use gibberish white space.
genexam('~', '~', '~')
