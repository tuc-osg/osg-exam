# Exam class for the TUC Operating System Group

This is the template for our exams, which relies on the [LaTex exam class](https://www.ctan.org/pkg/exam). It supports:

  - Useful defaults for layout and titlepage
  - Automated generation of personalized exams from a list of students.
  - Automated handling of multilangual exams
  - Flexible directory layout for source and output documents
  
  In addition, there are Python scripts for:
  - Generation of a seating plan, based on predefined room capacities.
  - Generation of a checklist for students showing up.
  - Generation of grading proposals based on ECTS.

This is still work in progress.

## Installation

- Make sure you have Python 3 and LuaLaTeX installed.
- *pip3 install openpyxl*
- Copy *osgexam.cls' somewhere in your tex-path (and run *sudo texhash*) or your local directory where you prepare the exam

## Usage

- Create a new latex document with the osgexam class and set the option "development"
- Run *lualatex -shell-escape <source.tex>* 
   - Alternatively: copy *latexmkrc* into your directory and run *latexmkrc <source.tex>*  
- For interactive mode / 

## Rules
- In tasks/students.xlsx, the following format must be kept:
  - All data is on the first sheet.
  - There are columns with the name "Matrikelnummer", "Vorname" and "Name" and possibly "Platz" (not case sensitive)
  - There are no empty rows.
