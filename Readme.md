# Exam class for the TUC Operating System Group

This is the template for our exams, which relies on the [LaTex exam class](https://www.ctan.org/pkg/exam). It supports:

  - Automated generation of personalized exams from a list of students.
  - Generation of a seating plan, based on predefined room capacities.
  - Generation of a checklist for students showing up.
  - Generation of grading proposals based on ECTS.

This is still work in progress.

## How to use
- For an english exam comment out the translations in setup.tex. 
- For bilingual exams you can use \dep{} to give german translations for the descriptions (see tasks directory for examples).
- Add course name, abbreviation and term in exam_meta.tex
- generate the CSV file for the student details (last name; first name; student number)
- Change room in the Makefile (See generate_sheets.py for details about which rooms are currently supported)
- Add Tasks for your exam
- During design you can simply call lualatex to generate only example.pdf
- If you are satisfied with your design, call make and be happy :)

- After correction you can use ects.py to generate your grade list.

## More details about the ingredients
- The generate_exams.py script generates one exam for each registered student and a plain one. 
- generate_sheets.py generates the room plans and registrations lists
- ects.py can be used to make a grading for the exams
