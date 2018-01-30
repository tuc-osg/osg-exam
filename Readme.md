# Exam class for the TUC Operating System Group

This is the template for our exams, which relies on the [LaTex exam class](https://www.ctan.org/pkg/exam). It supports:

  - Automated generation of personalized exams from a list of students.
  - Generation of a seating plan, based on predefined room capacities.
  - Generation of a checklist for students showing up.
  - Generation of grading proposals based on ECTS.

This is still work in progress.

## Installation

- Make sure you have Python 3 installed.
- Clone this repository from GitHub.
- *pip3 install openpyxl*
- Start to modify the content of the tasks/ folder.
- Use the different *make* targets.

## Rules

- You only have to edit the content of the tasks/ folder.
- The file tasks/exam_meta.tex is used by several templates, so please keep it separated.
- In tasks/students.xlsx, the following format must be kept:
  - All data is on the first sheet.
  - There are columns with the name "Matrikelnummer", "Vorname" and "Name" (not case sensitive)
  - There are no empty rows.

## Hints

- For easy editing, you can directly compile exam.tex while being in the tasks/ folder, instead of using the Makefile. 
- For an english exam, comment out the translations in templates/translations.tex (TODO: Add switch instead) 
- For bilingual exams, you can use \dep{} to give german translations for the descriptions (see tasks/ directory for examples).
- After correction you can use bin/ects.py to generate your grade list.
